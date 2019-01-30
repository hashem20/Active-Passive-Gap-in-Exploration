function out = getSubjectID(window)

nx = 5;
ny = 1;

bxq = boxQuestion;
bxq.setup(window, 'Subject ID', nx, ny)
bxq.setCornerPosition([50 100]);


string = 'Submit';
textColor = [0 0 0]+255;
edgeColor = [1 1 1]*255;
fillColor_on = [1 0 0]*255;
fillColor_off = [0 1 0]*256;
textSize = 30;
rect = [0 0 300 100];

cb = clickBox;
cb.setup(window, string, textColor, edgeColor, fillColor_on, fillColor_off, textSize, rect);
cb.setCornerPosition([600 700]);

while true
    bxq.draw;
    cb.draw;
    
    [x,y,buttons] = GetMouse(window);
    Screen('Flip', window, [], 1);
    if any(buttons)
        bxq.check(x,y);
        cb.check(x,y);
    end
    if cb.isOn
        break;
    end
    Screen('FillRect', window, [0 0 0])
end

out.subjectID = bxq.bx.string;
% clear the screen at the end
Screen('FillRect', window, [0 0 0])

