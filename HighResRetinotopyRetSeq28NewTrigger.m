function HighResRetinotopy
clear mex;
clear all;

%% On each trigger it displays 4 patches black and white each path lasts
%% patch time, next trigger moves to the next position. In scanimage: 28
%% pathces, 5 repetitions is 140 pathces, each trigger every 0.8 seconds.


[window,screenRect,ifi]=initScreen;
HideCursor;
Screen('Preference', 'VBLTimestampingMode', -1);

patch_time=0.2;
n_start_trigger=2; % number of gray/black screens before the stimulus

% isi=0;
frame_dur=round(patch_time/ifi);
set_trigger=1;
n_patches = [7,4];             % number of patches in x and y
field_of_view = [115,90];        % size of the field of view in degree
view_offset =[0,0];        % offset of the field of view
rel_patch_size = 1.2;           % patch size: 1: touching  - 0.5: size an distance is equal
n_reps=5;
% Screen parameters:00
screenSize = 58;              % x screen size in centimeters
mouseDistancecm = 20;           % mouse distance from the screen im cm
mouseCenter = [(screenRect(3)-screenRect(1)) (screenRect(4)-screenRect(2))]/2; % in pixel coordinates (position the mouse pointer on the screen an use GetMouse in MatLab)

mouseDistance = fix((screenRect(3) / screenSize) * mouseDistancecm);           % in pixel
%space_freq = 1 / ( 2 * mouseDistancecm * tan( ( ( 1 / space_freq_deg ) * pi / 180 ) / 2 ) * 1024 / screenSize );   % edit jleong 050718

% calculate the patch shapes
[lo,la]=patches_deg(n_patches, field_of_view, view_offset - field_of_view/2 , rel_patch_size);
[x,y]=pr_gnomonic(reshape(lo, [],1),reshape(la, [],1));
xx=reshape(x,[],4);
yy=reshape(y,[],4);


masktex=zeros(1,prod(n_patches));

for p = 1:prod(n_patches)
    BW=zeros(screenRect(4),screenRect(3)-screenRect(1),2);
    BW(:,:,2) = 255-255*(poly2mask(xx(p,:).* mouseDistance + mouseCenter(1),yy(p,:).* mouseDistance + mouseCenter(2),screenRect(4),screenRect(3)-screenRect(1)));
    BW(:,:,1)=BW(:,:,1)+127;
    masktex(p)=Screen('MakeTexture', window,BW);
    
    if KbCheck %clear all,
        return, end % quit if keyboard was touched
end




load RetSeq28x8.mat; % loads random sequence of numbers between 1 and 144, dont change as Brainware uses this sequence
%randomseq=1:1:28;
% randomseq=randperm(prod(n_patches));

%photodiode settings
use_pd=0;                        % 0 disables photodiode square
diodesz=100;                    %size of photodiode detection square in pixels


priorityLevel=MaxPriority(window);
Priority(priorityLevel);

dio = digitalio('nidaq','Dev1');
addline(dio,0,'in');
addline(dio,0,1,'out');

mkdir(['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd')]);

Screen('FillRect', window,127);
Screen('Flip',window);
tic

if set_trigger
    trigger_counter=0;
    while trigger_counter<n_start_trigger
        statusdiode=0;
        present=getvalue(dio.Line(1));
        while ~statusdiode
            if KbCheck
                starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
                
                clear mex,
                clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                    masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                    srcRect stim_ids window x xx y yy dio*;
                save([starttimestr 'HRret7x4NewTrigCancelled']);
                return
            end
            previous=present;
            present=getvalue(dio.Line(1));
            statusdiode=max([present-previous, 0]);
        end
        if trigger_counter==1
            starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
            t1=tic;
            init_delay=toc;

        end
        trigger_counter=trigger_counter+1;
    end
    
    
else
    tic
    t1=tic;
    starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
    %while ~KbCheck;end
    pause(0.5);
end


for j=1:n_reps
    
    
    for s=1:prod(n_patches);
        %         while ~getvalue(dio.Line(1))
        %             if KbCheck, clear mex,
        %                 clear   ans    ...
        %                     masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
        %                     srcRect stim_ids window x xx y yy;
        %                 save([starttimestr 'HRret']);
        %                 ShowCursor;
        %                 return
        %             end
        %
        %         end
        Screen('FillRect', window,127);
        Screen('Flip',window);
        toclist(j,s,1)=toc;
        toclist2(j,s,1)=toc(t1);
        
        if set_trigger
            statusdiode=0;
            present=getvalue(dio.Line(1));
            while ~statusdiode
                if KbCheck
                    clear mex,
                    clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                        masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                        srcRect stim_ids window x xx y yy dio*;
                    save([starttimestr 'HRret7x4NewTrigCancelled']);
                    return
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
        toclist(j,s,2)=toc;
        toclist2(j,s,2)=toc(t1);
        
        
        for i=1:2*frame_dur
            if KbCheck
                clear mex,
                clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                    masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                    srcRect stim_ids window x xx y yy dio*;
                save([starttimestr 'HRret7x4NewTrigCancelled']);
                return
            end
            if i<max(frame_dur)+1
                Screen('FillRect',window,255);
                Screen('DrawTexture',window,masktex(randomseq(j,s)),[],screenRect);
                if use_pd
                    Screen('FillRect', window,255,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
                end
                Screen('Flip',window);
            else
                Screen('FillRect',window,0);
                Screen('DrawTexture',window,masktex(randomseq(j,s)),[],screenRect);
                if use_pd
                    Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
                end
                Screen('Flip',window);
            end
            
        end
        for ii=1:2*frame_dur
            if KbCheck
                clear mex,
                clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                    masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                    srcRect stim_ids window x xx y yy dio*;
                save([starttimestr 'HRret7x4NewTrigCancelled']);
                return
            end
            if ii<max(frame_dur)+1
                Screen('FillRect',window,255);
                Screen('DrawTexture',window,masktex(randomseq(j,s)),[],screenRect);
                if use_pd
                    Screen('FillRect', window,255,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
                end
                Screen('Flip',window);
            else
                Screen('FillRect',window,0);
                Screen('DrawTexture',window,masktex(randomseq(j,s)),[],screenRect);
                if use_pd
                    Screen('FillRect', window,0,[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
                end
                Screen('Flip',window);
            end
            
        end
        toclist(j,s,3)=toc;
        toclist2(j,s,3)=toc(t1);
        
        Screen('FillRect',window,127);
        Screen('Flip',window);
        %         pause(isi);
        
    end
end
for i=1:4*frame_dur
    Screen('FillRect',window,127);
    Screen('Flip',window);
end

Screen('FillRect', window,0);
Screen('Flip',window);
KbWait;
clear mex,
clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
    masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
    srcRect stim_ids window x xx y yy dio*;
save([starttimestr 'HRret7x4NewTrig']);
ShowCursor;

Screen('Flip',window);
KbWait;
Screen('Close')
clear mex,
% save([starttimestr 'HighResRet'])
ShowCursor;
