function HighResRetinotopy3BNN
%% this function shows black and white patches in random order.
%% The order of the patches is saved in the variable randomseq,
%% The order of presentation of squares will be selected from
%% patchseq(randomseq) and the color from colorseq(randomsep)

clear mex;
clear all;
%try
[window,screenRect,ifi]=initScreen;
HideCursor;
Screen('Preference', 'VBLTimestampingMode', -1);

% load gammaTable_05_09_2012.mat
% gammaTable=gammaTable;
% Screen('LoadNormalizedGammaTable', window, gammaTable*[1 1 1]);
load('C:\Documents and Settings\visstim\My Documents\MATLAB\Morgane\Stim_Functions\stimBruno\Flor\Monitor_Calibration\GammaTable_r604u2713_141119.mat')
Screen('LoadNormalizedGammaTable', window, GammaTable_r604u2713_141119'*[1 1 1]);

n_start_trigger=8; % number of gray/black screens before the stimulus

patch_time=0.3;

% isi=0;
frame_dur=round(patch_time/ifi);

set_trigger=1;      % 0 disables external trigger, 1 activates external trigger
test = 0 ;         % set to 1 if you want to test without external triggering


n_patches = [12,10];   %[12,10];[14,12]          % number of patches in x and y
field_of_view = [96,80];   %[96,80]; [84,72] [48,40]     % size of the field of view in degree
view_offset =[0,0];        % offset of the field of view
rel_patch_size = 1.2;           % patch size: 1: touching  - 0.5: size an distance is equal
n_reps=2;
% Screen parameters:00
screenSize = 58;              % x screen size in centimeters
mouseDistancecm = 21;           % mouse distance from the screen im cm
mouseCenter = [(screenRect(3)-screenRect(1)) (screenRect(4)-screenRect(2))]/2; % in pixel coordinates (position the mouse pointer on the screen an use GetMouse in MatLab)

mouseDistance = fix((screenRect(3) / screenSize) * mouseDistancecm);           % in pixel
%space_freq = 1 / ( 2 * mouseDistancecm * tan( ( ( 1 / space_freq_deg ) * pi / 180 ) / 2 ) * 1024 / screenSize );   % edit jleong 050718

% calculate the patch shapes
[lo,la]=patches_deg(n_patches, field_of_view, view_offset - field_of_view/2 , rel_patch_size);
[x,y]=pr_gnomonic(reshape(lo, [],1),reshape(la, [],1));
xx=reshape(x,[],4);
yy=reshape(y,[],4);


masktex=zeros(1,prod(n_patches));
% BW is a matrix that contains the white and black patches (BW(:,:,1)==white, BW(:,:,2) == black)
% save BW and load every time will speed up
%     BW1=zeros(screenRect(4),screenRect(3)-screenRect(1),2,prod(n_patches));

for p = 1:prod(n_patches)
    BW=zeros(screenRect(4),screenRect(3)-screenRect(1),2);
    BW(:,:,2) = 255-255*(poly2mask(xx(p,:).* mouseDistance + mouseCenter(1),yy(p,:).* mouseDistance + mouseCenter(2),screenRect(4),screenRect(3)-screenRect(1)));
    BW(:,:,1)=BW(:,:,1)+127;
    masktex(p)=Screen('MakeTexture', window,BW);
    if KbCheck %clear all,
        return, end % quit if keyboard was touched
end



j=1;
while j<=n_reps
    randomseq(j,:)=[randperm(prod(n_patches)*2)];
    % check if consecutive frames are
    check_aux=randomseq(j,:);
    aux=(randomseq(j,:)<=prod(n_patches));
    check_aux(aux)=randomseq(j,aux)+prod(n_patches);
    if (sum(check_aux(1:2:end)==check_aux(2:2:end))>0)|( sum(check_aux(2:2:end-1)==check_aux(3:2:end-1))>0);
        randomseq(j,:)=zeros(1,(prod(n_patches)*2));
        j
    else j=j+1;
    end
end

patchseq=[1:(prod(n_patches)),1:(prod(n_patches))];
colorseq(1:prod(n_patches))=0;
colorseq(prod(n_patches)+1:prod(n_patches)*2)=255;

%photodiode settings
use_pd=0;                        % 0 disables photodiode square
diodesz=100;                    %size of photodiode detection square in pixels


priorityLevel=MaxPriority(window);
Priority(priorityLevel);

mkdir(['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd')]);
starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];

%initialize trigger input line and eze shutter output line
if test == 0
    dio = digitalio('nidaq','Dev2');
    addline(dio,0,'in');
    addline(dio,0,1,'out');
end



Screen('FillRect', window,127);
Screen('Flip',window);
tic

% Put a gray scren at the beggining
if set_trigger
    trigger_counter=0;
    t1=tic;
    while trigger_counter<n_start_trigger
        statusdiode=0;
        present=getvalue(dio.Line(1));
        while ~statusdiode
            if KbCheck
                cif KbCheck
                [window,screenRect,ifi,whichScreen]=initScreen;
                Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
                clear mex,
                clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                    masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                    srcRect stim_ids window x xx y yy;
                starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
                save([starttimestr 'HighResRetinotopy3BNN_Newtrig_cancelled'])
                ShowCursor;
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

tic1=tic;

for j=1:n_reps
  
    for s=1:prod(n_patches)*2;
        toclist2(j,s,1)=toc(t1);
        
        if set_trigger
            statusdiode=0;
            present=getvalue(dio.Line(1));
            while ~statusdiode
                if KbCheck
                    [window,screenRect,ifi,whichScreen]=initScreen;
                    Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
                    clear mex,
                    clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                        masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                        srcRect stim_ids window x xx y yy;
                    save([starttimestr 'HighResRetinotopy3BNN_Newtrig_cancelled'])
                    ShowCursor;
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
        
        toclist(s,j,1)=toc; % from last trigger
        toclist(s,j,2)=toc(tic1); % from first trigger to start of patch
        toclist2(j,s,2)=toc(t1);
        
        while toc-toclist(s,j,1)<(patch_time)
            if KbCheck
                [window,screenRect,ifi,whichScreen]=initScreen;
                Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
                clear mex,
                clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
                    masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                    srcRect stim_ids window x xx y yy;
                save([starttimestr 'HighResRetinotopy3BNN_Newtrig_cancelled'])
                ShowCursor;
                return
            end
            %         for i=1:frame_dur
            
            Screen('FillRect',window,colorseq(randomseq(j,s)));
            Screen('DrawTexture',window,masktex(patchseq(randomseq(j,s))),[],screenRect);
            if use_pd
                Screen('FillRect', window,colorseq(randomseq(j,s)),[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
            end
            Screen('Flip',window);
            
        end
        Screen('FillRect', window,127);
        Screen('Flip',window);
        
        toclist(s,j,3)=toc(tic1); % from first trigger to end of patch
        toclist2(j,s,3)=toc(t1);
        
    end
end

for i=1:frame_dur
    Screen('FillRect', window,127);
    Screen('Flip',window);
end

Screen('FillRect', window,0);
Screen('Flip',window);

KbWait;

    save([starttimestr 'HighResRetinotopy3BNN_Newtrig']);
    [window,screenRect,ifi,whichScreen]=initScreen;
    Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
    Screen('CloseAll');
    Priority(0);
    clear mex,
    clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
    n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
    srcRect stim_ids window x xx y yy BW dio*
ShowCursor;

%catch ME
    %display(ME.message)
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
%     [window,screenRect,ifi,whichScreen]=initScreen;
%     Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
%     Screen('CloseAll');
%     Priority(0);
%     %psychrethrow(psychlasterror);
%     %     save([starttimestr 'natural'])
%     clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
%     n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
%     srcRect stim_ids window x xx y yy BW dio*
%     save([starttimestr 'HighResRetinotopy3BNN_Newtrig_cancelled'])
%     
%end %try..catch..% KbWait;
% Screen('Close')
% clear mex,
% save([starttimestr 'HighResRet'])
% clear all;
% ShowCursor;

