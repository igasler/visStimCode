clear all 
clear MEX
[window,screenRect,ifi,whichScreen]=initScreen;
% clear gammaTable
HideCursor;
Screen('Preference', 'VBLTimestampingMode', -1);

Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);

white=Whiteindex(window);
black=blackindex(window);
gray=(white+black)/2;

Screen('FillRect', window,gray);
Screen('Flip',window);

kbwait;
screen('CloseAll');
