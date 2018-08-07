function multitif_RFmapping_neuroligin
% This function presents movies with different spatial frequencie. 8 filter
% movies and 1 nonfiltered movie (original).
% modified on 14/3/2011


try
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    clear all;
    AssertOpenGL;
    t1=tic;

    %%photodiode settings
    use_pd=0;                        % 0 disables photodiode square
    diodesz=100;                    %size of photodiode detection square in pixels
    %%Parameters
    %     file=5;
    %     Hartley=1;
    Gap=1; % set to oneif want a gray gap
    repetitions=1;  %number of repetitions of the  stimuli
    set_trigger=1 ;      % 0 disables external trigger, 1 activates external trigger
    test =  0    ;         % set to 1 if you want to test without external triggering
    patch_time=.4;
gray_patch_time=1.4;

    %     sequence=[4 8 9 3 1 7 0 2 5 6];

    stimulus=['NIFliInvStack0'];


    stim_filename= ['C:\Documents and Settings\visstim\My Documents\MATLAB\stimBruno\current_stimuli\Flor\Neuroligin\RFmappingStim\' stimulus '.tif'];
    imgstack=ldmultitif1(stim_filename);
    stimFrames=1:180;



    sz=size(imgstack);
    numberofframes=sz(4);


    %%window configuration
    clear mex;
    [window,screenRect,ifi,whichScreen]=initScreen;

    HideCursor;
    Screen('Preference', 'VBLTimestampingMode', -1);


    priorityLevel=MaxPriority(window);
    Priority(priorityLevel);
    frame_dur=round(patch_time/ifi);
    gray_dur=round(gray_patch_time/ifi);
    counter=1;
    for i=stimFrames;
        imgtex(counter)=Screen('MakeTexture', window, imgstack(:,:,:,i));
        counter=counter+1;
    end

    %initialize trigger input line and eze shutter output line

    if test == 0
        dio = digitalio('nidaq','Dev1');
        addline(dio,0,'in');
        mkdir(['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd')]);
        starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
    end

    Screen('FillRect', window,127);
    if use_pd
        Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
    end
    Screen('Flip',window);
    tic

    % Put a gray scren at the beggining
    if set_trigger
        if getvalue(dio.Line(1)), % might be unnecessary?
            while getvalue(dio.Line(1))
            end
        end
        while ~getvalue(dio.Line(1)),
            if KbCheck
                Screen('Close');
                clear mex; clear imgstack; clear imgtex;
                    save([starttimestr stimulus]);
                return
            end;
        end
    else
        while ~KbCheck
        end
        pause(0.1);
    end


    tic

    for rep=1:repetitions; %% Loop for the repetitions of the sequence
        for i=1:numberofframes;
            if set_trigger
                while ~getvalue(dio.Line(1))
                    if KbCheck, clear mex,
                        clear   ans    ...
                            masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                            srcRect stim_ids window x xx y yy;
                            clear mex; clear imgstack; clear imgtex;

                            save([starttimestr stimulus]);
                        ShowCursor;
                        return
                    end

                end
            end


            toclist(i,1)=toc;

            for delay=1:frame_dur;
                Screen('DrawTexture', window, imgtex(i),[],screenRect);
                if use_pd
                    Screen('FillRect', window,255,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
                end
                Screen('Flip',window);
                if KbCheck Screen('Close');clear mex,clear imgstack,clear imgtex,clear a, clear movies
                    save([starttimestr stimulus]),return,end;
            end
                        toclist(i,2)=toc;

            if Gap==1
                for gray_delay=1:gray_dur;
                Screen('FillRect', window,127);
                if use_pd
                    Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
                end
                end
            else if Gap==0
                    Screen('DrawTexture', window, imgtex(i),[],screenRect);
                    if use_pd
                        Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
                    end
                end
            end
            Screen('Flip',window);

        end
    end   %%  end of loop for the repetitions of the images

    Screen('FillRect', window,0);
    if use_pd
        Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
    end
    Screen('Flip',window);
    KbWait;
    Screen('CloseAll')
    clear mex,clear imgstack,clear imgtex, clear a, clear movies
    save([starttimestr stimulus])
    ShowCursor;
catch 
    rethrow(lasterror)  
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);

    %psychrethrow(psychlasterror);
    %     save([starttimestr stimulus])
    clear mex,clear imgstack,clear imgtex, clear a, clear movies
    save([starttimestr stimulus])



end %try..catch..