 function RetinotAlternateBW_NN_neuroligin
%% this function shows black and white patches in random order.
%% The order of the patches is saved in the variable randomseq,
%% The order of presentation of squares will be selected from
%% patchseq(randomseq) and the color from colorseq(randomsep)

clear mex;
clear all;

[window,screenRect,ifi]=initScreen;
HideCursor;
Screen('Preference', 'VBLTimestampingMode', -1);
    
% load gammatablesetup302.mat
% gammaTable=gammaTable1;
% Screen('LoadNormalizedGammaTable', window, gammaTable*[1 1 1]);
% 
% load gammaTable_05_09_2012.mat
% gammaTable=gammaTable;
% Screen('LoadNormalizedGammaTable', window, gammaTable*[1 1 1]);

patch_time=.3;
% isi=0;
frame_dur=round(patch_time/ifi);
set_trigger=1;      % 0 disables external trigger, 1 activates external trigger
test = 0  ;         % set to 1 if you want to test without external triggering


n_patches = [12,10];   %[12,10];[14,12]          % number of patches in x and y
field_of_view = [96,80];   %[96,80]; [84,72]      % size of the field of view in degree
view_offset =[0,0];        % offset of the field of view
rel_patch_size = 1.2;           % patch size: 1: touching  - 0.5: size an distance is equal
n_reps=2;
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
% BW is a matrix that contains the white and black patches (BW(:,:,1)==white, BW(:,:,2) == black)
% save BW and load every time will speed up
%     BW1=zeros(screenRect(4),screenRect(3)-screenRect(1),2,prod(n_patches));

for p = 1:prod(n_patches)
    BW=zeros(screenRect(4),screenRect(3)-screenRect(1),2);
    BW(:,:,2) = 255-255*(poly2mask(xx(p,:).* mouseDistance + mouseCenter(1),yy(p,:).* mouseDistance + mouseCenter(2),screenRect(4),screenRect(3)-screenRect(1)));
    BW(:,:,1)=BW(:,:,1)+127;
% %         BW2(:,:,p)=BW(:,:,2);
%         BW1(:,:,p)=BW(:,:,1);
    
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

if test == 0
    dio = digitalio('nidaq','Dev1');
    addline(dio,0,'in');
    mkdir(['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd')]);
    starttimestr=['C:\MAT_DATA' '\' datestr(now, 'yyyy_mm_dd') '\' datestr(now, 'yyyy_mm_dd_HH_MM_SS')];
end


Screen('FillRect', window,127);
Screen('Flip',window);
tic
for j=1:n_reps
    if set_trigger
        if getvalue(dio.Line(1)), % might be unnecessary?
            while getvalue(dio.Line(1))
            end
        end
        while ~getvalue(dio.Line(1)),
            if KbCheck
                Screen('Close');
                clear mex; clear imgstack; clear imgtex;
                save([starttimestr 'HRret']);
                return
            end;
        end
    else
        while ~KbCheck
        end
        pause(0.1);
    end
    for s=1:prod(n_patches)*2;
        toclist(j,s)=toc;
        if set_trigger
            
            
            while ~getvalue(dio.Line(1))
                if KbCheck, clear mex,
                    clear   ans    ...
                        masktex n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
                        srcRect stim_ids window x xx y yy;
                    save([starttimestr 'HRret']);
                    ShowCursor;
                    return
                end
                
            end
        end
        Screen('FillRect', window,127);
        Screen('Flip',window);
        for i=1:frame_dur
            
            Screen('FillRect',window,colorseq(randomseq(j,s)));
            Screen('DrawTexture',window,masktex(patchseq(randomseq(j,s))),[],screenRect);
            if use_pd
                Screen('FillRect', window,colorseq(randomseq(j,s)),[screenRect(1) screenRect(4)-diodesz diodesz screenRect(4)] );
            end
            Screen('Flip',window);
            
        end
        
    end
end

for i=1:frame_dur
    Screen('FillRect', window,127);
    Screen('Flip',window);
end

Screen('FillRect', window,0);
Screen('Flip',window);

KbWait;
clear mex,
clear Warte angle ans clutCounter clut_cycles ext_patch_nr eye i i2 j la lo ...
     n o p p1 priorityLevel rand_ori rand_oriidx rand_patches s s1 ...
    srcRect stim_ids window x xx y yy BW
save([starttimestr 'HRret']);
ShowCursor;

% KbWait;
% Screen('Close')
% clear mex,
% save([starttimestr 'HighResRet'])
% clear all;
% ShowCursor;

