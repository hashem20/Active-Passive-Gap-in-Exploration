function out = getDemographics_v1(window)

% out = getDemographics_v1(window)

% clear
% 
% input(' ');
% Screen('Preference', 'SkipSyncTests', 1);
% whichScreen     = 0;
% [window, rect]  = Screen('OpenWindow', whichScreen, [0 0 0]);
% [A,B]           = Screen('WindowSize', window);
% 

qString{1} = 'Gender';
aString{1} = {
    'Female' 
    'Male' 
    'Decline to answer'};

qString{2} = 'Race';
aString{2} = {
    'American Indian or Alaska Native' 
    'Asian' 
    'Black or African-American' 
    'Native Hawaiian or Other Pacific Islander' 
    'White' 
    'More than one race'
    'Unknown'
    'Decline to answer'};
                
qString{3} = 'Ethnicity';
aString{3} = {
    'Hispanic or Latino'
    'Not Hispanic or Latino'
    'Unknown'
    'Decline to answer'};

qString{4} = 'Are you a native English speaker?';
aString{4} = {
    'Yes'
    'No'
    'Decline to answer'};

% Age
nx = 3;
ny = 1;

bxq = boxQuestion;
bxq.setup(window, 'Age', nx, ny)



for i = 1:length(qString)
    if i == 1
        bq = buttonQuestion;
    else
        bq(i) = buttonQuestion;
    end
    bq(i).setup( window, qString{i}, aString{i});
end
bq(1).setCornerPosition([50 100]);
bq(2).setCornerPosition([400 100]);
bq(3).setCornerPosition([1050 100]);
bq(4).setCornerPosition([400 500]);
bxq.setCornerPosition([50 500]);

string = 'Submit';
textColor = [0 0 0];
edgeColor = [1 1 1]*255;
fillColor_on = [1 0 0]*255;
fillColor_off = [0 1 0]*256;
textSize = 30;
rect = [0 0 300 100];

cb = clickBox;
cb.setup(window, string, textColor, edgeColor, fillColor_on, fillColor_off, textSize, rect);
cb.setCornerPosition([900 800]);

while true
    for i = 1:length(bq)
        bq(i).draw;
    end
    bxq.draw;
    cb.draw;
    
    [x,y,buttons] = GetMouse(window);
    Screen('Flip', window, [], 1);
    if any(buttons)
        for i = 1:length(bq)
            bq(i).check(x,y);
        end
        bxq.check(x,y);
        cb.check(x,y);
    end
    if cb.isOn
        break;
    end
    Screen('FillRect', window, [0 0 0])
end
for i = 1:length(bq)
    bt{i} = [bq(i).bt.but];
end

out.age = bxq.bx.string;

out.gender.string = {bq(1).bt.string}
out.gender.selected = [bt{1}.isOn];
out.gender.answer = {out.gender.string{out.gender.selected}};

out.race.string = {bq(2).bt.string}
out.race.selected = [bt{2}.isOn];
out.race.answer = {out.race.string{out.race.selected}};

out.ethnicity.string = {bq(3).bt.string}
out.ethnicity.selected = [bt{3}.isOn];
out.ethnicity.answer = {out.ethnicity.string{out.ethnicity.selected}};

% clear the screen at the end
Screen('FillRect', window, [0 0 0])


