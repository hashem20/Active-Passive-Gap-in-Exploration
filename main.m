function main(option)
clc
% cd ('Users/hashem/Documents/University_Stuffs/Projects/1_Active_Passive_Exploration/019_Fall_2016_Explore_Exploit_Decision_Making/019_Explore_Exploit');
startclock = clock;
subjectID = [];
while isempty(subjectID)
    subjectID = input('Please input the subjectID : ');
end

rand('seed',subjectID);

% directories
mainpath = [pwd '/'];
addpath('./functions');
savepath = ['/Users/hashem/Documents/University_Stuffs/Projects/1_Active_Passive_Exploration/019_Fall_2016_Explore_Exploit_Decision_Making/019_Explore_Exploit/data/'];
time = datestr(now,30);

projectname = 'P019_';                  
% paramet  ers
%  originaltext.textSize = 40;
text.textSize = 30;

text.textColor = [1 1 1]*1;
text.textWrapat = 70;
text.textFont = 'Arial';
colour{1} = [ 97    67    67 ]/255;
colour{2} = [ 55    85    55 ]/255;
colour{3} = [ 71    71   101 ]/255;
colour{4} = [91    71    41]/255;
% textColour = [50    80   100]/255;
textColour = [255 255 255]/255;    
% bgColour = [75 75 75]/255;
bgColour = [1 1 1]/255;

% eyetracker setup
eyetribedir  = ['/Users/wilsonlab/Desktop/python_source'];
eyetribeSourcedir = ['/Users/wilsonlab/Desktop/EyeTribe_for_Matlab/'];
eye = eyetracker(eyetribedir,eyetribeSourcedir);
filename = [projectname, 'eye_raw_sub', num2str(subjectID), '_',time];
eye.setup(savepath,filename);
eye.open;
eye.calibrate;
eye.startmatlabserver;
eye.connect;

cd(mainpath);

% start screen
Screen('Preference', 'SkipSyncTests', 1); 
% execute the AssertOpenGL command
% execute KbName('UnifyKeyNames')
% execute Screen('ColorRange', window, 1, [], 1)
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);
eye.startaquiring;

% % subjectID & demographic information
% eye.marker('getsubjectID');
% sub = getsubjectID(window,subjectID);
% finisheyecaliclock = clock;
% save([savepath projectname 'subjectinfo_sub' num2str(sub.subjectID),'_',time],'sub','startclock','finisheyecaliclock');
% % subjectinfo = importdata([savepath 'subjectinfo.mat']);
% % subjectinfo.ID = [subjectinfo.ID; sub.subjectID]; 
% % subjectinfo.session = [subjectinfo.session; sub.session]; 
% % subjectinfo.calibrationquality = [subjectinfo.calibrationquality; sub.calibrationquality]; 
% % save([savepath 'subjectinfo'],'subjectinfo');
% eye.marker('getdemographic');
% subdemo = demographic(window);
  starttaskclock = clock;
% save([savepath  projectname 'demographicinfo_sub' num2str(sub.subjectID),'_',time],'subdemo','sub','starttaskclock');
sub.subjectID = subjectID;
% % sub.session = 1;

HideCursor;

% introduction
i = 0;
i=i+1; iStr{i} = '\nWelcome! Thank you for volunteering for this experiment.';
i=i+1; iStr{i} = '\nIn this experiment you will do four things.  \n\n\n1. Baseline eye measurement. This will take about 5 minutes. \n\n\n2. Play a gambling task in which you will make choices between two options. This will take about 20 minutes.\n\n\n3. Play another gambling task which also takes about 20 minutes.\n\n\n4. When you''re done with the tasks, there will be a short post_experiment survey.';
ins = instructions(window);
ins.setup(text);
ins.update(iStr);
eye.marker('instructions');
ins.run(0);

% baseline eye measurement
i = 0; iStr = '';
i=i+1; iStr{i} = 'Now we are going to get a baseline measurement of your eyes using the eye tracker. \n\nPress space to continue';
i=i+1; iStr{i} = 'To do this we need you to stare at the screen for 5 minutes.  Feel free to relax and daydream, but please stay in the chin rest.\n\nPress space to continue';
i=i+1; iStr{i} = 'Press space to start the eye-measurement.';
insbase = instructions(window);
insbase.setup(text);
insbase.update(iStr);
eye.marker('instructionsbaseline');
insbase.run(1);
Screen('FillRect',window,[0 0 0]);
Screen('Flip',window);
eye.marker('startbaseline');

WaitSecs(.1);

eye.marker('endbaseline');

% survey
% sur = surveys(window,sub.subjectID);
% i = 0; iStr = '';
% i=i+1; iStr{i} = 'Now we would like you to complete the following survey with a total of 10 questions. \n\nPress space to continue';
% switch sub.session
%     case 1
%         sur.legalkey = [KbName('1'):KbName('4'),KbName('1!'):KbName('4$')];
%         sur.setupsurvey('./survey/','./survey/','ID_Scale','ID_Scale_ans');
%         num = 4;
%         savename = [savepath, projectname,'survey_ID_Scale_sub' num2str(sub.subjectID),'_',time]; 
%     case 2
%         sur.legalkey = [KbName('1'):KbName('5'),KbName('1!'):KbName('5%')];
%         sur.setupsurvey('./survey/','./survey/','CEIII','CEIII_ans');
%         num = 5;        
%         savename = [savepath, projectname,'survey_CEIII_sub' num2str(sub.subjectID),'_',time]; 
% end        
% i=i+1; iStr{i} = ['Please answer the questions by pressing number keys 1 to ' ,num2str(num), '.\n\nPress space to continue'];
% inssur = instructions(window);
% inssur.setup(text);
% inssur.update(iStr);
% inssur.run(1);
% sur.setup(savename,text);
% eye.marker('surveystart');
% sur.run;
% eye.marker('surveyend');

savename0 = [savepath, projectname,'horizontask1_sub' num2str(sub.subjectID),'_',time];

if mod(subjectID,2) == 1
savename = savename0;
main1
main2
else
main2
savename = savename0;
main1
end

eye.endaquiring;
eye.disconnect;
eye.close;

cd(mainpath);


% exit screen
Screen('FillRect',window,[0 0 0]);
tstring= 'Thank you for participating in these tasks! \n\n Now we have a few post-experiment questions for you.\n\nPress anything to exit and continue';
%  original Screen('TextSize',window,40);
Screen('TextSize',window,30);
DrawFormattedText(window,tstring,'center','center',[1 1 1]);
Screen('Flip',window);
KbStrokeWait;
sca;

% copyfile('/Users/wilsonlab/Desktop/data_019', '/Users/wilsonlab/Box Sync/2016_Fall/experiments/019-Explore-Exploit/data');
% Post Experiment Questions
web ('https://uarizona.co1.qualtrics.com/SE/?SID=SV_3yfGM4yVGUlLMwt');

% cd('./IntrospectionQues');
% savename = [savepath  projectname 'PostQues_sub' num2str(sub.subjectID),'_',time];
% eval(['!cp PostExperimentQs.txt ' savename '.txt']);
% cd(savepath);
% eval(['!open -a TextEdit ' savename '.tsxaxt']);

end


