function NEW_retinotopy_trig_New_startrigger
%% Filename inmediately after first trigger
% Stimulus inmediately after trigger
clear mex;
clear all;
% try
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    clear all;
    AssertOpenGL;
    
    t1=tic;
    
    % Screen('Preference', 'SkipSyncTests', 1)```
    [window,screenRect,ifi,whichScreen]=initScreen;
    
    %clear mex;
    HideCursor;
    % ---------------:configuration variables:----------------
    
    % Screen parameters:
    screenSize = 60;              % x screen size in centimeters
    mouseDistancecm = 30;           % mouse distance from the screen im cm
    mouseCenter = [(screenRect(3)-screenRect(1)) (screenRect(4)-screenRect(2))]/2; % in pixel coordinates (position the mouse pointer on the screen an use GetMouse in MatLab)
    % [(screenRect(3)-screenRect(1)) (screenRect(4)-screenRect(2))]/2 is screen center
    
    
    % Grating parameters:
    grating_type = 1;               % 0 creates sine grating, 1 creates square wave grating
    temp_freq = 2;                % temporal frequency in 1/seconds
    space_freq_deg = 0.03 ;       % spatial frequency in 1/pixels
    background_color = [0 0 0];   % background color in R G B
    grating_high_color = [200 200 200]; % grating color in R G B
    grating_low_color = [0 0 0];  % grating color in R G B
    
    
    % Parameters of patches and orientations:
    n_patches = [4,3];             % number of patches in x and y
    field_of_view = [120,90];        % size of the field of view in degree
    view_offset =[0,0];        % offset of the field of view
    rel_patch_size = 1;           % patch size: 1: touching  - 0.5: size an distance is equal
    patch_time = 2;               % time in seconds one patch is shown
    patch_delay = 2;                % time in seconds after trigger before a patch is shown
    orientation_time = 0.25;           % time in seconds after the orientation changes
    orientations = 8;               % number of orientations for randomisation
    angle_increment=225;
    
    n_start_trigger=1; % number of gray/black screens before the stimulus
    
    % randomization settings (0 creates sequential order, 1 creates random order:
    randset_eye=0;
    randset_patch=0;
    randset_ori=1;
    
    mouseDistance = fix((screenRect(3) / screenSize) * mouseDistancecm);           % in pixel
    space_freq = 1 / ( 2 * mouseDistancecm * tan( ( ( 1 / space_freq_deg ) * pi / 180 ) / 2 ) * 1024 / screenSize )   % edit jleong 050718
    
    
    set_trigger=1;                      % 0 disables external trigger, 1 activates external trigger
    test =0  ;                       % set to 1 if you want to test without external triggering
    showPatches = test;
    ext_patch_nr = 0;                   % 1 means external generated pach number (OI)
    n_repetitions = 2 ;              % number of stim cycles
    binoc_stim = 0;                    % 1 means use binocular stimulation with shutters
    
    
    %photodiode settings
    use_pd=0;                        % 0 disables photodiode square
    diodesz=100;                    %size of photodiode detection square in pixels
    %---------------------------------------------------------
    
    mkdir(['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd')]);
    starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
    
    %initialize trigger input line and eze shutter output line
    if test == 0
        dio = digitalio('nidaq','Dev2');
        addline(dio,0,'in');
        addline(dio,0,1,'out');
    end
    
    hz=1/ifi;
    
    clut_cycles = round(hz / temp_freq);
    
    [lo,la]=patches_deg(n_patches, field_of_view, view_offset - field_of_view/2 , rel_patch_size);
    [x,y]=pr_gnomonic(reshape(lo, [],1),reshape(la, [],1));
    xx=reshape(x,[],4);
    yy=reshape(y,[],4);
    
    
    tic
    if showPatches==1 % show all the patches as one test image
        image=uint8(zeros(screenRect(4), screenRect(3)-screenRect(1)));
        rand_p=randperm(prod(n_patches));
        for p=1:prod(n_patches)
            g=127/2+(127/2)*gratingBruno(grating_type,(screenRect(1)+1:screenRect(3)), (screenRect(2)+1:screenRect(4)), rand_p(p) * 360/orientations, space_freq);
            BW = (poly2mask(xx(p,:).* mouseDistance + mouseCenter(1),yy(p,:).* mouseDistance + mouseCenter(2),screenRect(4),screenRect(3)-screenRect(1)));
            img=uint8(g.* BW);
            image = image + img;
            
            if KbCheck %clear all,
                return,
            end
            
        end
        % [window,screenRect] = Screen(whichScreen,'OpenWindow',128,[],8);
        %toc
        %[window screenRect]=Screen('OpenWindow',whichScreen, 0);
        %  [err]=LoadClut(window,squeeze(theCluts(:,:,1)));
        % size(theCluts)
        %toc
        clutCounter = 1;
        % Store grating in texture:
        gratingtex=Screen('MakeTexture', window, image);
        Screen('DrawTexture', window, gratingtex);
        Screen('Flip',window);
        
        
        %Screen(window,'PutImage', uint8(image));
        while KbCheck==0
        end
        
        clear mex
        return
        
        
    else % do the experiment run
        
        mkdir(['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd')]);
        HideCursor;
        waitframes = 1;
        waitduration = waitframes * ifi;
        p1=ceil(1/(space_freq/2));
        shiftperframe= p1 * waitduration * temp_freq;
        
        % calculte all patches with all the orientations
        % (numPatches*Orientations) images
        %for o = 1:orientations
        o=1;
        screenRect
        g=127+127*gratingBruno(grating_type,(screenRect(1)+1:screenRect(3)*2), (screenRect(2)+1:screenRect(4)*2), (o-1) * 360/orientations, space_freq/2);
        gratingtex=Screen('MakeTexture', window, g);
        BW=zeros(1,screenRect(4),screenRect(3)-screenRect(1),2);
        
        
        for p = 1:prod(n_patches)
            
            BW(1,:,:,2) = 255*double(~poly2mask(xx(p,:).* mouseDistance + mouseCenter(1),yy(p,:).* mouseDistance + mouseCenter(2),screenRect(4),screenRect(3)-screenRect(1)));
            masktex(p)=Screen('MakeTexture', window, squeeze(BW(1,:,:,:)));
            if KbCheck %clear all,
                return, end % quit if keyboard was touched
        end
        
        clutCounter = 1;
        rand_oriidx = 0;
        orientationFrames = round(orientation_time * hz);
        % precompile rem command for speed
        rem(1,1);
        Warte = 1;
        priorityLevel=MaxPriority(window);
        % We don't use Priority() in order to not accidentally overload older
        % machines that can't handle a redraw every 40 ms. If your machine is
        % fast enough, uncomment this to get more accurate timing.
        Priority(priorityLevel);
        Screen('FillRect', window,0);
        Screen('Flip',window);
        
        if set_trigger
            trigger_counter=0;
            
            
            t1=tic;
            while trigger_counter<n_start_trigger
                statusdiode=0;
                present=getvalue(dio.Line(1));
                while ~statusdiode
                    if KbCheck
                        clear mex,
                        clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                            n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                            srcRect stim_ids window x xx y yy BW dio*
                        save([starttimestr 'New_retinotopy_cancelled'])
                        starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
                        return
                    end
                    previous=present;
                    present=getvalue(dio.Line(1));
                    statusdiode=max([present-previous, 0]);
                end
                trigger_counter=trigger_counter+1;
                if test == 0 && trigger_counter==1
                    starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
                    t1=tic;
                    init_delay=toc;
                end
            end
            if n_start_trigger==0
                starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
                t1=tic;
                init_delay=toc;
            end
            tic
            first_toc=toc(t1);
        else
            starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
            tic
            t1=tic;
            pause(0.5);
        end
        
        
        
        for j=1:n_repetitions
            
            n = 1 + binoc_stim;
            if randset_eye
                rand_eye=randperm(n)
            else
                rand_eye=1:n
            end
            for eye=1:n
                eye1=rand_eye(eye);
                rand_log.repetition(j).eye(eye).eyedentity=eye1;
                diovalue=logical(eye1-1);
                %             putvalue(dio.Line(2),~diovalue);
                % %             putvalue(dio.Line(3),diovalue);
                stim_ids = 1:prod(n_patches);
                stim_ids = 1:prod(n_patches);
                if randset_patch
                    rand_patches=randperm(prod(n_patches));
                else
                    rand_patches=1:prod(n_patches);
                end
                for s=1: prod(n_patches);
                    if set_trigger
                        statusdiode=0;
                        present=getvalue(dio.Line(1));
                        while ~statusdiode
                            if KbCheck
                                clear mex,
                                clear dio Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                                    masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                                    srcRect stim_ids window x xx y yy;
                                save([starttimestr 'New_retinotopy_cancelled'])
                                return
                            end
                            previous=present;
                            present=getvalue(dio.Line(1));
                            statusdiode=max([present-previous, 0]);
                        end
                    else
                        %while ~KbCheck;end
                        pause(0.5);
                    end
                    s1=rand_patches(s);
                    
                    s;
                    s1;
                    rand_oriidx = 0;
                    Warte = 1;
                    
                    
                    
                    i2=0;
                    if randset_ori
                        rand_ori=randperm(orientations);
                    else
                        rand_ori=0:(orientations-1);
                    end
                    rand_log.repetition(j).eye(eye).patches(s).patchxy(1)=floor((s1-1)/n_patches(2))+1;
                    rand_log.repetition(j).eye(eye).patches(s).patchxy(2)=mod(s1-1,n_patches(2))+1;
                    rand_log.repetition(j).eye(eye).patches(s).patchidx=s1;
                    kjh=0;
                    toclist(s,j,1)=toc;
                    for i=1:patch_time * hz
                        % swap orientation
                        if i==1 | (mod(i,orientationFrames)==0 && rand_oriidx < orientations)
                            rand_oriidx = rand_oriidx + 1;
                            rand_log.repetition(j).eye(eye).patches(s).ori_order(rand_oriidx)=mod(rand_ori(rand_oriidx)*angle_increment,360);
                            %angle=rand_ori(rand_oriidx)*angle_increment;
                            
                            %Screen('CopyWindow',images(p,fix(rand*orientations)+1),window);
                        end
                        angle=90+rand_ori(rand_oriidx)*angle_increment;
                        % check if user wants to quit
                        if KbCheck clear mex,
                            clear dio Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                                masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                                srcRect stim_ids window x xx y yy;
                            %uisave;
                            save([starttimestr 'New_retinotopy_cancelled'])
                            ShowCursor;
                            return
                        end
                        %     [err]=LoadClut(window,squeeze(theCluts(:,:,clutCounter)));
                        clutCounter=rem(clutCounter,clut_cycles)+1;
                        %Screen(window,'WaitBlanking');
                        % Shift the grating by "shiftperframe" pixels per frame:
                        xoffset = mod(i2*shiftperframe,p1);
                        i2=i2+1;
                        
                        % Define shifted srcRect that cuts out the properly shifted rectangular
                        % area from the texture:
                        srcRect=[xoffset 0 (xoffset + screenRect(3)*2) screenRect(4)*2];
                        
                        % Draw grating texture, rotated by "angle":
                        Screen('DrawTexture', window, gratingtex, srcRect, [], angle);
                        Screen('DrawTexture', window, masktex(s1),[],screenRect);
                        if use_pd
                            Screen('FillRect', window,255,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
                        end
                        
                        Screen('Flip',window);
                        rand_log.repetition(j).eye(eye).patches(s).timing(i)=toc;
                    end
                    toclist(s,j,2)=toc;
                    
                    Screen('FillRect', window,0);
                    Screen('Flip',window);
                    WaitSecs(patch_delay); % MFI stimulus shown inmediately after trigger
                    toclist(s,j,3)=toc;
                    %toc
                    %[err]=LoadClut(window,offClut);
                end
            end
            
        end
        
        Screen('FillRect', window,0);
        Screen('Flip',window);
        KbWait;
        clear mex,
        clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
            masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
            srcRect stim_ids window x xx y yy dio;
        %uisave;
        save([starttimestr 'New_retinotopy'])
        ShowCursor;
    end
% catch ME
%     display(ME.message)
%     %this "catch" section executes in case of an error in the "try" section
%     %above.  Importantly, it closes the onscreen window if its open.
%     Screen('CloseAll');
%     Priority(0);
%     %psychrethrow(psychlasterror);
end %try..catch..
