function classic_ori_trig_gray_gaps_neuroligin
clear mex;
clear all;

    t1=tic;
    
    %Screen('Preference','SkipSyncTests', 1);
    %Screen('Preference','VisualDebugLevel', 0);
    %Screen('Preference', 'SuppressAllWarnings', 1);
    %{
The behaviour of PTB can be controlled by the command:
  Screen('Preference', 'VBLTimestampingMode', mode); where mode can be one of the
  following:

  -1 = Disable all cleverness, take noisy timestamps. This is the behaviour
       you'd get from any other psychophysics toolkit, as far as we know.
   0 = Disable kernel-level fallback method (on OS-X), use either beamposition
       or noisy stamps if beamposition is unavailable.
   1 = Use beamposition. Should it fail, switch to use of kernel-level interrupt
       timestamps. If that fails as well or is unavailable, use noisy stamps.
   2 = Use beamposition, but cross-check with kernel-level timestamps.
       Use noisy stamps if beamposition mode fails. This is for the paranoid
       to check proper functioning.
   3 = Always use kernel-level timestamping, fall back to noisy stamps if it fails.
    %}
    timestampmode=1;
    Screen('Preference', 'VBLTimestampingMode', timestampmode);
    tic
    [window,screenRect,ifi,whichScreen]=initScreen;
    init_delay=toc
    load('C:\Documents and Settings\visstim\My Documents\MATLAB\Morgane\Stim_Functions\stimBruno\Flor\Monitor_Calibration\GammaTable_r604u2713_141119.mat')
    Screen('LoadNormalizedGammaTable', window, GammaTable_r604u2713_141119'*[1 1 1]);
    
    
    
    HideCursor;
    % ---------------:configuration variables:----------------
    
    % Screen parameters:
    screenSize = 58;              % x screen size in centimeters
    mouseDistancecm = 20;           % mouse distance from the screen im cm
    mouseCenter = [(screenRect(3)-screenRect(1)) (screenRect(4)-screenRect(2))]/2; % in pixel coordinates (position the mouse pointer on the screen an use GetMouse in MatLab)
    % [(screenRect(3)-screenRect(1)) (screenRect(4)-screenRect(2))]/2 is screen center
    
    
    % Grating parameters:
    grating_type = 1;               % 0 creates sine grating, 1 creates square wave grating
    temp_freq = 2;                % temporal frequency in 1/seconds
    space_freq_deg = 0.035 ;              % spatial frequency in 1/pixels
    background_color = [0 0 0];   % background color in R G B
    grating_high_color = [255 255 255]; % grating color in R G B
    grating_low_color = [0 0 0];  % grating color in R G B
    contrast = 100; %%centage difference between grating high and low bars
    
    
    % Parameters of patches and orientations:
    n_patches = [1, 1];             % number of patches in x and y
    field_of_view = [100,70];        % size of the field of view in degree
    view_offset =[0,0];        % offset of the field of view
    rel_patch_size = 1;            % patch size: 1: touching  - 0.5: size an distance is equal
    %patch_time = 2;               % time in seconds one patch is shown
    ori_delay = 2; %3.5               % time in seconds after trigger grating starts drifting
    orientation_time = 3;           % time in seconds after the orientation changes
    orientations = 8;  % 8 16               % number of orientations for randomisation
    angle_increment=45; %45 22.5;
    n_start_trigger=2; % number of gray/black screens before the stimulus
    
    % randomization settings (0 creates sequential order, 1 creates random order:
    randset_eye=0;
    randset_patch=0;
    randset_ori=1   ;
    
    mouseDistance = fix((screenRect(3) / screenSize) * mouseDistancecm);           % in pixel
    space_freq = 1 / ( 2 * mouseDistancecm * tan( ( ( 1 / space_freq_deg ) * pi / 180 ) / 2 ) * 1024 / screenSize );   % edit jleong 050718
    
    
    set_trigger=0 ;                          % 0 disables external trigger, 1 activates external trigger
    test = 1;                       % set to 1 if you want to test without external triggering
    showPatches = test;
    ext_patch_nr = 0;                    % 1 means external generated pach number (OI)
    n_repetitions = 1; %6             % number of stim cycles
    binoc_stim = 0;                    % 1 means use binocular stimulation with shutters
    
    
    %---------------------------------------------------------
    patch_time=orientation_time;
    patch_delay=ori_delay;
    xoffset=0;
    
    mkdir(['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd')]);
    starttimestr=['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
    
    %initialize trigger input line and eze shutter output line
    if test == 0
        dio = digitalio('nidaq','Dev2');
        addline(dio,0,'in');
        addline(dio,0,1,'out');
    end
    
           AO = analogoutput('nidaq','Dev2');
           addchannel(AO,0); %shutter
           addchannel(AO,1); %laser
    
      

    hz=1/ifi;
    
    HideCursor;
    
    
    p1=ceil(1/(space_freq/2));
    shiftperframe= p1 * ifi * temp_freq;
    
    
    o=1;
    transparency=127.5+(contrast*(127.5/100));
    o=1;
    
    g=transparency*gratingBrunoF(grating_type,(screenRect(1)+1:screenRect(3)*2), (screenRect(2)+1:screenRect(4)*2), (o-1) * 360/orientations, space_freq/2)/1;
    
    % g=127+127 *gratingBrunoF(grating_type,(screenRect(1)+1:screenRect(3)*2), (screenRect(2)+1:screenRect(4)*2), (o-1) * 360/orientations, space_freq/2)/1;
    gratingtex=Screen('MakeTexture', window, g);
    
    % g=127+127*gratingBruno(grating_type,(screenRect(1)+1:screenRect(3)*2), (screenRect(2)+1:screenRect(4)*2), (o-1) * 360/orientations, space_freq/2)/1;
    % gratingtex=Screen('MakeTexture', window, g);
    BW=zeros(prod(n_patches),screenRect(4),screenRect(3)-screenRect(1),2);
    
    
    orientationFrames = round(orientation_time * hz);
    
    priorityLevel=MaxPriority(window);
    
    
    Priority(priorityLevel);
    
    Screen('FillRect', window,127);
    Screen('Flip',window);
    %{
    if set_trigger
                 while ~getvalue(dio), if KbCheck clear mex,return,end,end
    end
    %}
    if set_trigger
        trigger_counter=0;
        t1=tic;
        while trigger_counter<=n_start_trigger
            statusdiode=0;
            present=getvalue(dio.Line(1));
            while ~statusdiode
                if KbCheck
                    clear mex,
                    clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                        n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                        srcRect stim_ids window x xx y yy BW dio*
                    save([starttimestr '_classic_ori_gray_gaps_cancelled']);
                    starttimestr=['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
                    return
                end
                previous=present;
                present=getvalue(dio.Line(1));
                statusdiode=max([present-previous, 0]);
            end
            trigger_counter=trigger_counter+1;
            if test == 0 && trigger_counter==1
                starttimestr=['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
                t1=tic;
                init_delay=toc;
            end
%             putsample(AO,[5 0])
        end
        if n_start_trigger==0
            starttimestr=['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
            t1=tic;
            init_delay=toc;
        end
        tic
        first_toc=toc(t1);
    else
        starttimestr=['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
        tic
        t1=tic;
        pause(0.5);
    end
    for j=1:n_repetitions
           
        n = 1 + binoc_stim;
        if randset_eye
            rand_eye=randperm(n);
        else
            rand_eye=1:n;
        end
        for eye=1:n
            eye1=rand_eye(eye);
            rand_log.repetition(j).eye(eye).eyedentity=eye1;
            %             putvalue(dio2.Line(6),eye - 1) ;
            %             putvalue(dio2.Line(7),eye - 1) ;
            stim_ids = 1:prod(n_patches);
            
            rand_oriidx = 0;
            if randset_ori
                rand_ori=randperm(orientations);
            else
                rand_ori=0:(orientations-1);
            end
            
            
            
            for s=1: orientations;
                
                
                i2=0;
                
                % rand_log.repetition(j).eye(eye).patches(s).patchxy(1)=floor((s1-1)/n_patches(2))+1;
                %rand_log.repetition(j).eye(eye).patches(s).patchxy(2)=mod(s1-1,n_patches(2))+1;
                %rand_log.repetition(j).eye(eye).patches(s).patchidx=s1;
                rand_oriidx = rand_oriidx + 1;
                rand_log.repetition(j).eye(eye).ori(s)=rand_ori(rand_oriidx)*angle_increment;
                angle=90+rand_ori(rand_oriidx)*angle_increment;
                srcRect=[xoffset 0 (xoffset + screenRect(3)*2) screenRect(4)*2];
                
                % Screen('DrawTexture', window, gratingtex, srcRect, [], angle);
                Screen('FillRect', window,127);
                Screen('Flip',window);
                
                
                
                
                
                if j*eye*s>1;
                    
                    
                    if set_trigger
                        statusdiode=0;
                        present=getvalue(dio.Line(1));
                        
                        while ~statusdiode
                            
                            if KbCheck
                                    [window,screenRect,ifi,whichScreen]=initScreen;
                                    Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
                                    Screen('CloseAll');
                                    clear mex,
                                    clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                                        masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                                        srcRect stim_ids window x xx y yy;
                                    
                                    save([starttimestr '_classic_ori_gray_gaps_cancelled']);
                                    ShowCursor;

                            end
                            previous=present;
                            present=getvalue(dio.Line(1));
                            statusdiode=max([present-previous, 0]);
                        end
                        tic
                    else
                        tic
                        %while ~KbCheck;end
                        pause(0.5);
                    end
                end
                %
                
                for i=1:patch_time * hz
                    tic
                    
                    if KbCheck clear mex,
                        [window,screenRect,ifi,whichScreen]=initScreen;
                        Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
                        Screen('CloseAll');
                        clear mex,
                        clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                            masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                            srcRect stim_ids window x xx y yy;
                        
                        save([starttimestr '_classic_ori_gray_gaps_cancelled']);
                        ShowCursor;
                        return
                    end
%                      if i==ceil((patch_time-1.45)*hz)
%                         trial=randsample([0 5]);
%                         putsample(AO,[0 0]);
%                         pause(0.07)
%                         putsample(AO,[0 trial]);
% 
%                         rand_log.repetition(j).eye(eye).patches(s).trigger=trial;                        
%                         rand_log.repetition(j).eye(eye).patches(s).time1=toc;
%                     end
%                     if i==ceil((patch_time-0.95)*hz)%
%                         putsample(AO,[5 0]);
%                         rand_log.repetition(j).eye(eye).patches(s).time2=toc;
%                     end
                    xoffset = mod(i2*shiftperframe,p1);
                    i2=i2+1;
                    
                    % Define shifted srcRect that cuts out the properly shifted rectangular
                    % area from the texture:
                    srcRect=[xoffset 0 (xoffset + screenRect(3)*2) screenRect(4)*2];
                    
                    % Draw grating texture, rotated by "angle":
                    Screen('DrawTexture', window, gratingtex, srcRect, [], angle);
                    %Screen('DrawTexture', window, masktex(1),[],screenRect);
                    
                    Screen('Flip',window);
                    rand_log.repetition(j).eye(eye).patches(s).timing(i)=toc;
               
                
                end
                
                tic
                %for w=1:patch_delay*hz;
                w=toc;
                 while toc<patch_delay*hz
                     
                    % Screen('DrawTexture', window, gratingtex, srcRect, [], angle);
                     if w==ceil((patch_delay-0.3)*hz)%-1
                        trial=randsample([0 5]);
                        putsample(AO,[0 0]);
                        pause(0.1)
                        putsample(AO,[0 trial]);

                        rand_log.repetition(j).eye(eye).patches(s).trigger=trial;                        
                        rand_log.repetition(j).eye(eye).patches(s).time1=toc;
                    end
                    if w==ceil((patch_delay-0.1)*hz)%-0.5
                        putsample(AO,[0 0]);
                        pause(0.1)
                        putsample(AO,[5 0]);
                        rand_log.repetition(j).eye(eye).patches(s).time2=toc;
                    end
                    Screen('FillRect', window,127);
                    Screen('Flip',window);
                    if KbCheck, clear mex,
                        [window,screenRect,ifi,whichScreen]=initScreen;
                        Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
                        Screen('CloseAll');
                        clear mex,
                        clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                            masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                            srcRect stim_ids window x xx y yy;
                        
                        save([starttimestr '_classic_ori_gray_gaps_cancelled']);
                        ShowCursor;
                        
                        return
                    end
                   
                   
                end
            end
        end
        
    end
    Screen('FillRect', window,127);
    Screen('Flip',window);
    KbWait
    [window,screenRect,ifi,whichScreen]=initScreen;
    Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
    Screen('CloseAll');
    clear mex,
    clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
        masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
        srcRect stim_ids window x xx y yy;
    
    save([starttimestr '_classic_ori_gray_gaps']);
    ShowCursor;
% catch ME
%     display(ME.message)
%     %this "catch" section executes in case of an error in the "try" section
%     %above.  Importantly, it closes the onscreen window if its open.
%     [window,screenRect,ifi,whichScreen]=initScreen;
%     Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
%     Screen('CloseAll');
%     Priority(0);
%     %psychrethrow(psychlasterror);
%     %     save([starttimestr 'natural'])
%     clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
%         masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
%         srcRect stim_ids window x xx y yy;
%     
%     save([starttimestr '_classic_ori_gray_gaps_cancelled']);
    
end %try..catch..
