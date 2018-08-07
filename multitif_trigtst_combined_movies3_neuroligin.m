              function multitif_trigtst_combined_movies3_neuroligin

%try
    %photodiode settings
    use_pd=0;                        % 0 disables photodiode square
    t1=tic;
    % Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
    load('C:\Documents and Settings\visstim\My Documents\MATLAB\Morgane\Stim_Functions\stimBruno\Flornew\New_starttriggerfilename\Neuroligin\Newattcatmouse900fr.mat')
    
    allframes=1; % 1 plays entire movie sequence, 0 plays number specified in howmanyframes
    numberofframes=900;
    n_start_trigger=1; % number of gray/black screens before the stimulus
    
    repetitions=8;
    moviefr=30;     
    
    set_trigger=1    ;
    test = 0   ;                      % set to 1 if you want to test without external triggering
    
    clear mex;
    [window,screenRect,ifi,whichScreen]=initScreen;
    % Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
    load('C:\Documents and Settings\visstim\My Documents\MATLAB\Morgane\Stim_Functions\stimBruno\Flor\Monitor_Calibration\GammaTable_r604u2713_141119.mat')
    Screen('LoadNormalizedGammaTable', window, GammaTable_r604u2713_141119'*[1 1 1]);
    
    HideCursor;
    priorityLevel=MaxPriority(window);
    Priority(priorityLevel);
    refreshdelay=round((1/ifi)/moviefr);
    actualmoviefr=(1/ifi)/refreshdelay;
    % imgstack=ldmultitif(filename);
    % sz=size(imgstack);
    if allframes
        sz=size(imgstack);
        numberofframes=sz(4);
    else
        imgstack=imgstack(:,:,:,[1:numberofframes]);
    end
    
    %initialize trigger input line and eze shutter output line
    mkdir(['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd')]);
    starttimestr=['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
    
    %initialize trigger input line and eze shutter output line
    if test == 0
        dio = digitalio('nidaq','Dev2');
        addline(dio,0,'in');
        addline(dio,0,1,'out');
    end
    for i=1:numberofframes;
        
        imgtex(i)=Screen('MakeTexture', window, imgstack(:,:,:,i));
    end
    Screen('FillRect', window,127);
    if use_pd
        Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
    end
    Screen('Flip',window);
    
    Screen('FillRect', window,127);
    if use_pd
        Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
    end
    Screen('Flip',window);
    tic
    
    %%%%%%%%%%%%first movie
    if set_trigger
        trigger_counter=0
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
                    save([starttimestr '_natural_cancelled']);
                    starttimestr=['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
                    return
                end
                previous=present;
                present=getvalue(dio.Line(1));
                statusdiode=max([abs(present-previous), 0]);
            end
            trigger_counter=trigger_counter+1
            if test == 0 && trigger_counter==1
                starttimestr=['C:\Documents and Settings\visstim\My Documents\MATLAB\Ioana' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
                t1=tic;
                init_delay=toc;
            end
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
   ii=1; 
tt=tic;
    for rep=1:repetitions;
        
        %% trigger for the natural movie
        
        if set_trigger
            statusdiode=0;
            present=getvalue(dio.Line(1));
            while ~statusdiode
                
                if KbCheck
                    [window,screenRect,ifi,whichScreen]=initScreen;
                    Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
                    Screen('Close');clear mex,clear imgstack,clear imgtex,clear movies
                    save([starttimestr '_natural_cancelled'])
                    return
                end
                previous=present;
                present=getvalue(dio.Line(1));
                presentList(ii)=present;
                statusdiode=max([abs(present-previous), 0]);
                statusdiodeList(ii)=statusdiode;
                ii=ii+1;
            end
            trigger_counter=trigger_counter+1
            tic
        else
            tic
            %while ~KbCheck;end
            pause(0.5);
        end
        presentList2(rep)=present;
        statusdiodeList2(rep)=statusdiode;
        toclistMov(rep)=toc(tt);
        tt=tic;
        for i=1:numberofframes;
            toclist(i,rep)=toc;
            for delay=1:refreshdelay;
                
                Screen('DrawTexture', window, imgtex(i),[],screenRect);
                if use_pd
                    Screen('FillRect', window,255,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
                end
                Screen('Flip',window);
                if KbCheck
                    [window,screenRect,ifi,whichScreen]=initScreen;
                    Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
                    Screen('Close');clear mex,clear imgstack,clear imgtex,
                    save([starttimestr '_natural_cancelled']),return,end;
            end
        end
        Screen('DrawTexture', window, imgtex(i),[],screenRect);
        if use_pd
            Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
        end
        Screen('Flip',window);
    rep
    toclistMov(rep)
    end
    
    Screen('FillRect', window,127);
    if use_pd
        Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
    end
    Screen('Flip',window);
    KbWait;
    [window,screenRect,ifi,whichScreen]=initScreen;
    Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
    Screen('CloseAll')
    clear mex,clear imgstack,clear imgtex, clear Pnoisetex, clear Wnoisetex, clear Wnoisestack, clear Pnoisestack, clear a, clear movies
    save([starttimestr 'natural_mov'])
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
%     %   save([starttimestr 'natural'])
%     clear mex,clear imgstack,clear imgtex, clear Pnoisetex, clear Wnoisetex, clear Wnoisestack, clear Pnoisestack, clear a, clear movies
%     save([starttimestr '_natural_cancelled'])
    
end %try..catch..