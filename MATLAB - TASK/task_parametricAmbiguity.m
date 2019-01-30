classdef task_parametricAmbiguity < handle
    
    properties
        
        % instructions
        iStr
        iEv
        
        % scale factor
        scaleFactor
        
        % directories
        stimdir
        datadir
        sounddir
        
        % savename stuff
        dateAndTime
        computerName
        saveName
        
        % sound stuff
        pahandle
        nrchannels
        sampleRate
        reqlatencyclass
        
        % window stuff
        window
        bgColour
        screenCenter
        screenWidth
        screenHeight
        
        % text stuff
        textSize
        textWidth
        textColour
        
        % key stuff
        keys
        keyName
        
        % fixation cross
        fix
        
        % rewards
        rew
        rewXX
        
        points
        totalPoints
        blockPoints
        totalMax
        money
        
        % reward histories
        rewHistL
        rewHistR
        
        % bandits
        banL
        banR
        
        % game start / end cues
        gameStartCue
        gameEndCue
        pressSpaceCue
        goCue
        
        % list of games
        game
        
        % data
        data
        currentData
        count
        saveFlag
        
        % demographics stuff
        ans
        
    end
    
%     events
%         
%         pressSpaceStartGame
%         pressSpaceStartForced
%         horizonOn
%         forcedOn
%         banditsOn
%         choiceMade
%         rewardOn
%         fixOn
%         
%         startExperiment
%         startBlock
%         startGame
%         startFree
%         
%         endGame
%         endBlock
%         endExperiment
%         
%     end
%     
    methods
        
        function obj = task_parametricAmbiguity(stimdir, sounddir, datadir, savename)
            
            obj.stimdir = stimdir;
            obj.datadir = datadir;
            obj.sounddir = sounddir;
            obj.makeSaveName(savename);
            
        end
        
        % auxilliary functions ============================================
        function talk(obj, str, tp)
            
            if exist('tp') == 0
                DrawFormattedText(obj.window, str, ...
                    'center','center', obj.textColour, 70);
            else
                DrawFormattedText(obj.window, str, ...
                    tp{1},tp{2}, obj.textColour, 70);
                
            end
            
        end
        
        function talkAndFlip(obj, str, pTime)
            
            [A, B] = Screen('WindowSize', obj.window);
            
            if exist('pTime') ~= 1
                pTime = 0.3;
            end
            [nx, ny] = DrawFormattedText(obj.window, ...
                ['\n\n' str], ...
                0.05*A,[B*0.02], obj.textColour, obj.textWidth);
            Screen('TextSize', obj.window,round(obj.textSize));
            DrawFormattedText(obj.window, ...
                ['' ...
                'Press space to continue or delete to go back'], ...
                'center', [B*0.93], [150 150 150], obj.textWidth);
            Screen('TextSize', obj.window,obj.textSize);
            Screen(obj.window, 'Flip');
            WaitSecs(pTime);
            
        end
        
        function setWindow(obj, bgColour, screenCenter, sw, sh);
            
            whichScreen = 0;
            
            [window, rect] = Screen('OpenWindow', whichScreen, bgColour);
            [A,B] = Screen('WindowSize', window);
            
            obj.window = window;
            obj.bgColour = bgColour;
            
            if exist('screenCenter') ~= 1
                
                screenCenter = [A B]/2;
                sw = A;
                sh = B;
                
            end
            
            %obj.scaleFactor = min([sw/A2 sh/B2]);
            
            obj.screenCenter = screenCenter;
            obj.screenWidth = sw;
            obj.screenHeight = sh;
            
        end
        
        function setTextParameters(obj, textSize, textWidth, textColour)
            
            Screen('TextSize', obj.window, textSize);
            obj.textSize = textSize;
            obj.textWidth = textWidth;
            obj.textColour = textColour;
            
        end
        
        function makeFixationCross(obj)
            
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            win = obj.window;
            stimdir = obj.stimdir;
            
            obj.fix = picture(win, stimdir, 'Fix.png');
            obj.fix.setup(1, [sw/2 sh/3.5]);
            
        end
        
        function setKeys(obj, keyName)
            
            for i = 1:length(keyName)
                obj.keys(i) = KbName(keyName{i});
            end
            obj.keyName = keyName;
            
        end
        
        function setupPsychSound(obj)
            
            InitializePsychSound(1);
            
            % Request latency mode 2, which used to be the best one in
            % our measurement: classes 3 and 4 didn't yield any
            % improvements, sometimes they even caused problems.
            % class 2 empirically the best, 3 & 4 == 2
            obj.reqlatencyclass = 2;
            
            % Sampling rate. Must set this. 96khz, 48khz, 44.1khz.
            obj.sampleRate = 44100;
            
            % Open the default audio device [], with default mode []
            % (==Only playback), and a required latencyclass of zero
            % 0 == no
            % low-latency mode, as well as a frequency of freq and
            % nrchannels sound channels.  This returns a handle to the
            % audio device:
            obj.nrchannels = 2;
            
            obj.pahandle = PsychPortAudio('Open', ...
                [], [], obj.reqlatencyclass, ...
                obj.sampleRate, obj.nrchannels);
            
        end
        
        function makeSaveName(obj, saveName)
            
            ds = datestr(now);
            ds(ds==':') = ['_'];
            ds(ds==' ') = '_';
            
            obj.dateAndTime = ds;
            computerName = evalc('!hostname')
            obj.computerName = computerName(1:end-1);
            
            if exist('saveName') == 1
                
                cn = obj.computerName;
                cn(cn=='.') = [];
                cn(cn=='@') = [];
                cn(cn==' ') = [];
                
                obj.saveName = [saveName '_' cn obj.dateAndTime];
            end
            
            if (exist([obj.datadir obj.saveName '.mat']) == 2)
                error(['Data for subject ' saveName ' already exists!']);
            end
            
            
            
        end
        
        function [KeyNum, when] = waitForInput(obj, validKeys, timeOut)
            
            % wait for a keypress for TimeOut seconds
            Pressed = 0;
            
            keys = obj.keys;
            
            while ~Pressed && (GetSecs < timeOut)
                [key, when, keycode] = KbCheck(-1);
                % a valid key was pressed (we ignore invalid keys presses)
                if (key && sum(keycode(keys)))
                    
                    KeyNum = find(keycode(keys),1);
                    if ~isempty(intersect(KeyNum, validKeys))
                        Pressed = 1;
                    end
                end
            end
            
            if Pressed == 0
                
                KeyNum = [];
                when = [];
                
            end
            
        end
        
        % data storage functions ==========================================
        function makeData(obj)
            
            obj.data.block                  = [];
            obj.data.gameNum                = [];
            obj.data.trialNum               = [];
            obj.data.type                   = [];
            obj.data.choice                 = [];
            obj.data.spaceOnTime            = [];
            obj.data.horOnTime              = [];
            obj.data.banditOnTime           = [];
            obj.data.responseTime           = [];
            obj.data.rewardOnTime           = [];
            obj.data.forcedOnTime           = [];
            obj.data.reward                 = [];
            obj.data.totalRew               = [];
            
            obj.currentData.block           = [];
            obj.currentData.gameNum         = [];
            obj.currentData.trialNum        = [];
            obj.currentData.type            = [];
            obj.currentData.choice          = [];
            obj.currentData.spaceOnTime     = [];
            obj.currentData.horOnTime       = [];
            obj.currentData.banditOnTime    = [];
            obj.currentData.responseTime    = [];
            obj.currentData.rewardOnTime    = [];
            obj.currentData.forcedOnTime    = [];
            obj.currentData.reward          = [];
            obj.currentData.totalRew        = [];
            
        end
        
        function clearCurrentData(obj)
            
            obj.currentData.block           = [];
            obj.currentData.gameNum         = [];
            obj.currentData.trialNum        = [];
            obj.currentData.type            = [];
            obj.currentData.choice          = [];
            obj.currentData.spaceOnTime     = [];
            obj.currentData.horOnTime       = [];
            obj.currentData.banditOnTime    = [];
            obj.currentData.responseTime    = [];
            obj.currentData.rewardOnTime    = [];
            obj.currentData.forcedOnTime    = [];
            obj.currentData.reward          = [];
            obj.currentData.totalRew        = [];
            
        end
        
        function clearData(obj)
            
            for i = 1:length(obj.data)
                obj.data(i).block           = [];
                obj.data(i).gameNum         = [];
                obj.data(i).trialNum        = [];
                obj.data(i).type            = [];
                obj.data(i).choice          = [];
                obj.data(i).spaceOnTime     = [];
                obj.data(i).horOnTime       = [];
                obj.data(i).banditOnTime    = [];
                obj.data(i).responseTime    = [];
                obj.data(i).rewardOnTime    = [];
                obj.data(i).forcedOnTime    = [];
                obj.data(i).reward          = [];
                obj.data(i).totalRew        = [];
            end
            
        end
        
        function storeData(obj)
            
            if obj.saveFlag
                obj.data(obj.count) = obj.currentData;
                obj.count = obj.count + 1;
            end
        end
        
        function saveData(obj)
            
            if obj.saveFlag
                
                data        = obj.data;
                totalPoints = obj.totalPoints;
                totalMax    = obj.totalMax;
                answers     = obj.ans;
                game        = obj.game;
                money       = round(obj.money);
                
                save([obj.datadir obj.saveName], ...
                    'data', 'totalPoints', 'answers',...
                    'game', 'totalMax', 'money');
            end
        end
        
        % instructions ====================================================
        function instructionList(obj)
            
            i = 0;
            
            i=i+1; ev{i} = 'default';       iStr{i} = 'Welcome! Thank you for volunteering for this experiment';
            i=i+1; ev{i} = 'bandits_ex';    iStr{i} = 'The task you will perform involves playing a series of games in which you have to make decisions between two different slot machines like this.';
            i=i+1; ev{i} = 'bandits_ex_75R';iStr{i} = 'Every time a slot machine is played it pays out a reward between 1 and 100 points. For example, here the right slot machine has been chosen and is paying out 75 points. ';
            i=i+1; ev{i} = 'bandits_ex';    iStr{i} = 'Use the b and n keys to choose a slot machine. To choose the left slot machine press b.  To choose the right slot machine press n.';
            i=i+1; ev{i} = 'default';       iStr{i} = 'In each game, the average payoff from each slot machine is fixed, but on any given play there is variability in the exact amount.';
            i=i+1; ev{i} = '52';            iStr{i} = 'For example, the average payoff from the left slot machine might be 50 points but on any trial you might receive more or less than 50 points randomly - say 52 points on the first play ... ';
            i=i+1; ev{i} = '56';            iStr{i} = '... 56 on the second ... ';
            i=i+1; ev{i} = '45';            iStr{i} = '...and 45 on the third. ';
            i=i+1; ev{i} = '45';            iStr{i} = 'This variability makes it difficult to figure out which is the best slot machine, but that is exactly what you need to do to maximize your payoff from the game.';
            i=i+1; ev{i} = 'rewHist';       iStr{i} = 'We will show the outcomes of your previous choices in these history bars. In addition to telling you the previous outcomes, these history bars tell you how many choices you have left in the game.';
            i=i+1; ev{i} = 'forcedTrials_1';iStr{i} = 'To help you make your decision, at the beginning of each game the computer will play the two options randomly.  For example it might play the left option three times and the right option once like this ...';
            i=i+1; ev{i} = 'forcedTrials_2';iStr{i} = '... or it might play the left option twice and the right option twice also ...';
            i=i+1; ev{i} = 'forcedTrials_3';iStr{i} = 'In general the total number of these `computer plays'' will be between one and four plays per option';
            i=i+1; ev{i} = 'default';       iStr{i} = 'We will begin with a short practice game to make sure you understand the rules.';
            i=i+1; ev{i} = 'default';       iStr{i} = 'Press space when you''re ready to start!  Good luck!';
            
            obj.iStr = iStr;
            obj.iEv = ev;
            
        end
        
        function instructions(obj)
            
            rew = obj.rew;
            rewXX = obj.rewXX;
            
            % move everything down by dy
            dy = 200;
            obj.banL.setPosition( obj.banL.centerPosition + [0 dy]);
            obj.banR.setPosition( obj.banR.centerPosition + [0 dy]);
            obj.rewHistL.setPositionByTop(obj.rewHistL.topPosition + [0 dy]);
            obj.rewHistR.setPositionByTop(obj.rewHistR.topPosition + [0 dy]);
            obj.fix.centrePosition = obj.fix.centrePosition + [0 dy];
            
            obj.instructionList;
            
            iStr = obj.iStr;
            ev = obj.iEv;
            
            endFlag = false;
            count = 1;
            
            while ~endFlag
                [A, B] = Screen('WindowSize', obj.window);
                
                DrawFormattedText(obj.window, ...
                    ['Page ' num2str(count) ' of ' num2str(length(iStr))], ...
                    [],[B*0.93], obj.textColour, obj.textWidth);
                
                
                ef = false;
                switch ev{count}
                    
                    case 'fix' % draw the fixation cross
                        obj.fix.draw;
                        obj.talkAndFlip(iStr{count});
                        
                    case 'bandits_ex' % bandits example
                        
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.talkAndFlip(iStr{count});
                        
                    case 'bandits_ex_75R' % bandits with 75 in right
                        
                        %obj.banL.draw;
                        obj.banL.draw;
                        obj.banR.showRewardPlayed([rew(75)]);
                    
                        obj.talkAndFlip(iStr{count});
                        
                    case '52' % 52 left
                        
                        
                        obj.banR.draw;
                        obj.banL.showRewardPlayed([rew(52)]);
                    
                        obj.talkAndFlip(iStr{count});
                        
                    case '56' % 56 left
                        
                        
                        obj.banR.draw;
                        obj.banL.showRewardPlayed([rew(56)]);
                    
                        obj.talkAndFlip(iStr{count});
                        
                    case '45' % 45 left
                        
                        obj.banR.draw;
                        obj.banL.showRewardPlayed([rew(45)]);
                    
                        obj.talkAndFlip(iStr{count});
                        
                    case 'rewHist'
                        
                        obj.banR.draw;
                        obj.banL.draw;
                        
                        obj.rewHistL.flush;
                        obj.rewHistR.flush;
                                                
                        obj.rewHistL.draw;
                        obj.rewHistR.draw;
                        
                        
                        obj.rewHistL.addReward(rewXX)
                        obj.rewHistL.addReward(rew(52))
                        obj.rewHistL.addReward(rew(56))
                        obj.rewHistL.addReward(rew(45))
                        
                        obj.rewHistR.addReward(rewXX)
                        obj.rewHistR.addReward(rewXX)
                        obj.rewHistR.addReward(rewXX)
                        obj.rewHistR.addReward(rew(75))
                        
                        obj.talkAndFlip(iStr{count});
                        
                        
                        
                    case 'forcedTrials_1'
                        obj.banR.draw;
                        obj.banL.draw;
                        
                        obj.rewHistL.flush;
                        obj.rewHistR.flush;
                        
                        obj.rewHistL.addReward(rewXX)
                        obj.rewHistL.addReward(rew(52))
                        obj.rewHistL.addReward(rew(56))
                        obj.rewHistL.addReward(rew(45))
                        
                        obj.rewHistR.addReward(rewXX)
                        obj.rewHistR.addReward(rewXX)
                        obj.rewHistR.addReward(rewXX)
                        obj.rewHistR.addReward(rew(75))
                        
                        obj.rewHistL.draw;
                        obj.rewHistR.draw;
                        
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case 'forcedTrials_2'
                        obj.banR.draw;
                        obj.banL.draw;
                        
                        obj.rewHistL.flush;
                        obj.rewHistR.flush;
                        
                        obj.rewHistL.addReward(rewXX)
                        obj.rewHistL.addReward(rewXX)
                        obj.rewHistL.addReward(rew(56))
                        obj.rewHistL.addReward(rew(45))
                        
                        obj.rewHistR.addReward(rewXX)
                        obj.rewHistR.addReward(rewXX)
                        obj.rewHistR.addReward(rew(65))
                        obj.rewHistR.addReward(rew(75))
                        
                        obj.rewHistL.draw;
                        obj.rewHistR.draw;
                        
                        
                        obj.talkAndFlip(iStr{count});
                        
                    
                     case 'forcedTrials_3'
                        obj.banR.draw;
                        obj.banL.draw;
                        
                        obj.rewHistL.flush;
                        obj.rewHistR.flush;
                        
                        obj.rewHistL.addReward(rew(54))
                        obj.rewHistL.addReward(rew(48))
                        obj.rewHistL.addReward(rew(56))
                        obj.rewHistL.addReward(rew(45))
                        
                        obj.rewHistR.addReward(rew(69))
                        obj.rewHistR.addReward(rew(70))
                        obj.rewHistR.addReward(rew(65))
                        obj.rewHistR.addReward(rew(75))
                        
                        obj.rewHistL.draw;
                        obj.rewHistR.draw;
                        
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case 'default' % just draw the text
                        obj.talkAndFlip(iStr{count});
                        
                end
                
                % press button to move on or not
                if ~ef
                    [KeyNum, when] = obj.waitForInput([3:6], Inf);
                    switch KeyNum
                        
                        case 3 % go forwards
                            count = count + 1;
                            if count > length(iStr)
                                endFlag = true;
                            end
                            
                        case 4 % go backwards
                            ef = true;
                            count = count - 1;
                            if count < 1
                                count = 1;
                            end
                            endFlag = false;
                            
                        case 5 % skip through
                            endFlag = true;
                            
                        case 6 % quit
                            sca
                            error('User requested escape!  Bye-bye!');
                            
                    end
                    
                end
            end
            
            % move everything back up by dy
            obj.banL.setPosition( obj.banL.centerPosition - [0 dy]);
            obj.banR.setPosition( obj.banR.centerPosition - [0 dy]);
            obj.rewHistL.setPositionByTop(obj.rewHistL.topPosition - [0 dy]);
            obj.rewHistR.setPositionByTop(obj.rewHistR.topPosition - [0 dy]);
            obj.fix.centrePosition = obj.fix.centrePosition - [0 dy];
            
            WaitSecs(0.1);
        end
        
        % demographics ====================================================
        function demographicQuestionCommand(obj)
            
            x = 0;
            
            while x ~= 1
                obj.ans.age = input('What is your age? ');
                obj.ans.gender = input('What is your gender? ', 's');
                obj.ans.math = input('How many college level math classes have you taken? ');
                
                x = input('Is this information correct? Type 0 for no and 1 for yes ');
            end
            
        end
            
        % task functions ==================================================
        function setup(obj, bgColour)
            
            obj.scaleFactor = 0.75;
            obj.setWindow(bgColour);
            obj.setTextParameters(40, 70, [1 1 1]*256);
            obj.setKeys({'b' 'n' 'space' 'delete' 'p' 'q' '7&'});
            obj.setRewards(obj.scaleFactor, obj.scaleFactor);  %%%
            obj.makeFixationCross;
            obj.makeBandits([1 4]);
            obj.makeRewardHistory([1 4]);
            
            obj.makeData;
            
            obj.makeGameParameters
            obj.count = 1;
        end
        
        function setRewards(obj, scalefactorNum, scalefactorXX)
            
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            
            if exist('scalefactorNum') == 1
                sfN = scalefactorNum;
            else
                sfN = 1;
            end
            
            if exist('scalefactorXX') == 1
                sfXX = scalefactorXX;
            else 
                sfXX = 1;
            end
            
            for i = 1:100;
                rew(i) = picture(obj.window, obj.stimdir, [num2str(i) '.png']);
                rew(i).setup(sfN, [sw/2 sh/2]);
            end
            
            obj.rew = rew;
            obj.rewXX = picture(obj.window, obj.stimdir, 'XX.png');
            obj.rewXX.setup(sfXX, [sw/2 sh/2]);
            
        end
        
        function makeBandits(obj, banditNum)
                        
            % banditNum = vector of numbers for the names of the bandit
            % files
            
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            
            num1 = banditNum(1);
            num2 = banditNum(2);
            
            dx = 500*obj.scaleFactor;
            dy = 200;
            
            % Make left and right bandits
            obj.banL = bandit_playable(obj.window, obj.stimdir, ['bandit' num2str(num1) '.png'], num1);
            obj.banL.setup(obj.scaleFactor, obj.bgColour);
            obj.banL.setPosition([sw/2-dx sh/2-dy]);
            obj.banL.playedBandit;
            
            obj.banR = bandit_playable(obj.window, obj.stimdir, ['bandit' num2str(num2) '.png'], num2);
            obj.banR.setup(obj.scaleFactor, obj.bgColour);
            obj.banR.setPosition([sw/2+dx sh/2-dy]);
            obj.banR.playedBandit;
            
            obj.banL.visible = true;
            obj.banR.visible = true;
            
            
        end
        
        function makeRewardHistory(obj, rewHistNum)
                        
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            
            numL = rewHistNum(1);
            numR = rewHistNum(2);
            
            dx = 100*obj.scaleFactor;
            
            obj.rewHistL = rewardHistory_allie(obj.window, obj.stimdir, 9, obj.scaleFactor);
            obj.rewHistL.setup(['rewHistBackground' num2str(numL) '.png'], 'blankNumber.png', obj.scaleFactor);
            obj.rewHistL.setPositionByTop([sw/2-dx sh/30]);
            
            obj.rewHistR = rewardHistory_allie(obj.window, obj.stimdir, 9, obj.scaleFactor);
            obj.rewHistR.setup(['rewHistBackground' num2str(numR) '.png'], 'blankNumber.png', obj.scaleFactor);
            obj.rewHistR.setPositionByTop([sw/2+dx sh/30]);
            
        end
        
        function makeGameParameters(obj)
            
            i = 1;
            
            % \mu
            var(i).x = [40 60];
            var(i).type = 2;
            i=i+1;
            
            % main bandit number
            var(i).x = [1 2];
            var(i).type = 2;
            i=i+1;
            
            % \delta \mu
            var(i).x = [-10 -5 0 5 10];
            var(i).type = 1;
            i=i+1;
            
            % game length
            var(i).x = [9];
            var(i).type = 1;
            i=i+1;
            
            % ambiguity condition
            var(i).x = [1:10];
            var(i).type = 1;
            i=i+1;
            
            % ambiguity side
            var(i).x = [1 2];
            var(i).type = 2;
            i=i+1;
            
            [var, T, N] = counterBalancer(var, 3);
            test_counterBalancing(var);
            
            mainMean    = var(1).x_cb;
            mainBan     = var(2).x_cb;
            deltaMu     = var(3).x_cb;
            gameLength  = var(4).x_cb;
            ambCond     = var(5).x_cb;
            ambSide     = var(6).x_cb;
            
            for j = 1:T
                
                obj.game(j).gameLength = gameLength(j);
                
                forced = ambCond(j);
                
                switch forced
                    
                    % 1 means forced left
                    % 2 means forced right
                    % -1 means XX on left
                    % -2 means XX on right
                    
                    case 1 % 1 1
                        if ambSide(j) == 1
                            nForced = [-1 -1 -1 1 -2 -2 -2 2];
                        else
                            nForced = [-2 -2 -2 2 -1 -1 -1 1];
                        end
                        
                    case 2 % 1 2
                        if ambSide(j) == 1
                            nForced = [-1 -1 -1 1 -2 -2 2 2];
                        else
                            nForced = [-2 -2 -2 2 -1 -1 1 1];
                        end
                        
                    case 3 % 1 3
                        if ambSide(j) == 1
                            nForced = [-1 -1 -1 1 -2 2 2 2];
                        else
                            nForced = [-2 -2 -2 2 -1 1 1 1];
                        end
                        
                    case 4 % 1 4
                        if ambSide(j) == 1
                            nForced = [-1 -1 -1 1 2 2 2 2];
                        else
                            nForced = [-2 -2 -2 2 1 1 1 1];
                        end
                        
                    case 5 % 2 2
                        if ambSide(j) == 1
                            nForced = [-1 -1 1 1 -2 -2 2 2];
                        else
                            nForced = [-2 -2 2 2 -1 -1 1 1];
                        end
                        
                        
                    case 6 % 2 3
                        if ambSide(j) == 1
                            nForced = [-1 -1 1 1 -2 2 2 2];
                        else
                            nForced = [-2 -2 2 2 -1 1 1 1];
                        end
                        
                    case 7 % 2 4
                        if ambSide(j) == 1
                            nForced = [-1 -1 1 1 2 2 2 2];
                        else
                            nForced = [-2 -2 2 2 1 1 1 1];
                        end
                        
                        
                    case 8 % 3 3
                        if ambSide(j) == 1
                            nForced = [-1 1 1 1 -2 2 2 2];
                        else
                            nForced = [-2 2 2 2 -1 1 1 1];
                        end
                        
                        
                    case 9 % 3 4
                        if ambSide(j) == 1
                            nForced = [-1 1 1 1 2 2 2 2];
                        else
                            nForced = [-2 2 2 2 1 1 1 1];
                        end
                        
                        
                    case 10 % 4 4
                        if ambSide(j) == 1
                            nForced = [1 1 1 1 2 2 2 2];
                        else
                            nForced = [2 2 2 2 1 1 1 1];
                        end
                        
                        
                        
                end
                obj.game(j).forcedChoices = nForced;
                obj.game(j).nfree = [gameLength(j) - 4];
                
                sig_risk = 8;
                
                if mainBan(j) == 1
                    mu(1) = mainMean(j);
                    mu(2) = [mainMean(j) + deltaMu(j)];
                elseif mainBan(j) == 2
                    mu(2) = mainMean(j);
                    mu(1) = [mainMean(j) + deltaMu(j)];
                end
                
                obj.game(j).mean = [mu(1); mu(2)];
                obj.game(j).rewards = ...
                    [(round(randn(gameLength(j),1)*sig_risk + mu(1)))'; ...
                    (round(randn(gameLength(j),1)*sig_risk + mu(2)))'];
                
                ind100 = obj.game(j).rewards>100;
                ind1 = obj.game(j).rewards<1;
                obj.game(j).rewards(ind100) = 100;
                obj.game(j).rewards(ind1) = 1;
                
                
            end
            
        end
        
        function game = makePracticeGameParameters(obj)
            
            i = 1;
            
            % \mu
            var(i).x = [60];
            var(i).type = 1;
            i=i+1;
            
            % main bandit number
            var(i).x = [1];
            var(i).type = 2;
            i=i+1;
            
            % \delta \mu
            var(i).x = [-10 10];
            var(i).type = 1;
            i=i+1;
            
            % game length
            var(i).x = [5 10];
            var(i).type = 1;
            i=i+1;
            
            % ambiguity condition
            var(i).x = [1 3];
            var(i).type = 1;
            i=i+1;
            
            [var, T, N] = counterBalancer(var, 1);
            test_counterBalancing(var);
            
            mainMean = var(1).x_cb;
            mainBan = var(2).x_cb;
            deltaMu = var(3).x_cb;
            gameLength = var(4).x_cb;
            ambCond = var(5).x_cb;
            
            for j = 1:T
                
                game(j).gameLength = gameLength(j);
                
                forced = ambCond(j);
                
                switch forced
                    case 1
                        
                        r = randi(4);
                        nForced = [1 1 1 2];
                        
                        %switch r
                        %    case 1
                        %        nForced = [1 1 1 2];
                        %    case 2
                        %        nForced = [1 1 2 1];
                        %    case 3
                        %        nForced = [1 2 1 1];
                        %    case 4
                        %        nForced = [2 1 1 1];
                        %end
                        
                    case 2
                        
                        r = randi(6);
                        switch r
                            case 1
                                nForced = [1 1 2 2];
                            case 2
                                nForced = [1 2 1 2];
                            case 3
                                nForced = [2 1 1 2];
                            case 4
                                nForced = [2 1 2 1];
                            case 5
                                nForced = [2 2 1 1];
                            case 6
                                nForced = [1 2 2 1];
                        end
                        
                    case 3
                        
                        r = randi(4);
                        nForced = [2 2 2 1];
                        %switch r
                        %    case 1
                        %        nForced = [2 2 2 1];
                        %    case 2
                        %        nForced = [2 2 1 2];
                        %    case 3
                        %        nForced = [2 1 2 2];
                        %    case 4
                        %        nForced = [1 2 2 2];
                        %end
                end
                game(j).forcedChoices = nForced;
                game(j).nfree = [gameLength(j) - 4];
                
                sig_risk = 8;
                
                if mainBan(j) == 1
                    mu(1) = mainMean(j);
                    mu(2) = [mainMean(j) + deltaMu(j)];
                elseif mainBan(j) == 2
                    mu(2) = mainMean(j);
                    mu(1) = [mainMean(j) + deltaMu(j)];
                end
                
                game(j).mean = [mu(1); mu(2)];
                
                game(j).rewards = ...
                    [(round(randn(gameLength(j),1)*sig_risk + mu(1)))'; ...
                    (round(randn(gameLength(j),1)*sig_risk + mu(2)))'];
                
                
            end
            
        end
        
        function forcedTrial(obj, forcedChoice, Lrew, Rrew, rewHistL, rewHistR)
            
            rew = obj.rew;
            rewXX = obj.rewXX;
            rewHistL.draw;
            rewHistR.draw;
            
            switch forcedChoice
                
                case -1 % XX left
                    
                    rew = nan;
                    reward   = nan;
                    choice   = nan;
                    rewHistL.addReward(rewXX);
                    
                case 1 % forced left
                    
                    rew = obj.rew(Lrew);
                    reward   = Lrew;
                    choice   = 1;
                    rewHistL.addReward(rew);
                    
                case 2 % forced right
                    
                    rew = obj.rew(Rrew);
                    reward   = Rrew;
                    choice   = 2;
                    rewHistR.addReward(rew);
                
                case -2 % XX right
                    
                    rew = nan;
                    reward   = nan;
                    choice   = nan;
                    rewHistR.addReward(rewXX);
                
            end
            
            % store in current data
            obj.currentData.type            = 'forced';
            obj.currentData.choice          = choice;
            obj.currentData.banditOnTime    = nan;
            obj.currentData.responseTime    = nan;
            obj.currentData.rewardOnTime    = nan;
            obj.currentData.forcedOnTime    = nan;
            obj.currentData.reward          = reward;
            obj.currentData.totalRew        = nan;
            
        end
        
        function freeTrial(obj, Lrew, Rrew, rewHistL, rewHistR)
            
            rew     = obj.rew;
            rewXX   = obj.rewXX;
            
            obj.banL.draw;
            obj.banR.draw;
            obj.fix.draw;
            rewHistL.draw;
            rewHistR.draw;
            %obj.mb.draw;
            banditOnTime = Screen(obj.window, 'Flip');
            
            [KeyNum, when] = obj.waitForInput([1:2], GetSecs +Inf);
            
            switch KeyNum
                
                case 1 % chose left
                    
                    obj.banR.draw;
                    obj.banL.showRewardPlayed([rew(Lrew)]);
                    reward = Lrew;
                    rewHistL.addReward(rew(reward));
                    rewHistR.addReward(rewXX);
                    
                case 2 % chose right
                    
                    obj.banL.draw;
                    obj.banR.showRewardPlayed([rew(Rrew)]);
                    reward = Rrew;
                    rewHistR.addReward(rew(reward));
                    rewHistL.addReward(rewXX);
                    
            end
            
            rewHistR.draw;
            rewHistL.draw;
            obj.fix.draw;
            
            rewardOnTime = Screen(obj.window, 'Flip');
            
            % update total points
            obj.blockPoints = obj.blockPoints + reward;
            
            % store in current data
            obj.currentData.type            = 'free';
            obj.currentData.choice          = KeyNum;
            obj.currentData.banditOnTime    = banditOnTime;
            obj.currentData.responseTime    = when;
            obj.currentData.rewardOnTime    = rewardOnTime;
            obj.currentData.forcedOnTime    = nan;
            obj.currentData.reward          = reward;
            obj.currentData.totalRew        = obj.totalPoints;
            
            %obj.points = obj.points + reward;
            
            WaitSecs(0.2);
            
            
        end
        
        function playGame(obj, game)
            
            obj.rewHistL.flush;
            obj.rewHistR.flush;
            
            
            forcedChoices   = game.forcedChoices;
            nFree           = game.nfree;
            Lrew            = game.rewards(1, :);
            Rrew            = game.rewards(2, :);
            rewHistL        = obj.rewHistL;
            rewHistR        = obj.rewHistR;
            
            % hard coded for now
            nForced         = 4;%length(forcedChoices);
            
            
            % Forced choice trials ----------------------------------------
            
            % counts for forced choice 1 and forced choice 2
            c1 = 1;
            c2 = 1;
            for i = 1:length(forcedChoices)
                
                %WaitSecs(0.2)
                obj.currentData.trialNum = i;
                
                
                obj.forcedTrial(forcedChoices(i), Lrew(c1), Rrew(c2), rewHistL, rewHistR);
                c1 = c1 + (forcedChoices(i) == 1);
                c2 = c2 + (forcedChoices(i) == 2);

                
                    
                if i == length(forcedChoices)
                    
                    obj.rewHistL.draw;
                    obj.rewHistR.draw;
                    obj.fix.draw;
                
                    obj.currentData.forcedOnTime = Screen(obj.window, 'Flip');
                    %notify(obj, 'forcedOn');
                else
                    %obj.currentData.forcedOnTime = Screen(obj.window, 'Flip');
                    
                end
                
                obj.storeData;
                
            end
            
            % Free choice trials ------------------------------------------
            for i = 1:nFree
                
                trialNum = i + nForced;
                
                obj.currentData.trialNum = i + nForced;
                obj.freeTrial(Lrew(trialNum), Rrew(trialNum), rewHistL, rewHistR);
                obj.storeData;
                
                WaitSecs(0.2)
            end
            
            % Clean up ----------------------------------------------------
            obj.rewHistL.flush;
            obj.rewHistR.flush;
            
        end
        
        function run(obj, numBlocks, numGames)
            obj.saveFlag = true;
            obj.clearCurrentData;
            obj.clearData;
            ng = numBlocks * numGames;
            if ng < length(obj.game)
                beep;
                disp('You''re asking for fewer games than you have!')
            elseif ng > length(obj.game)
                error('You''re asking for more games than you have!')
            end
            
            gameCount = 1;
            obj.totalPoints = 0;
            
            %notify(obj, 'startExperiment');
            obj.makeGameParameters;
            
            for blockNum = 1:numBlocks
                
                obj.blockPoints = 0;
                
                obj.talk(['Press space to begin block ' num2str(blockNum) '.']);
                Screen(obj.window, 'Flip');
                
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(0.5);
                
                %notify(obj, 'startBlock');
                obj.fix.draw;
                Screen(obj.window, 'Flip');
                %notify(obj, 'fixOn');
                
                for gameNum = 1:numGames
                    
                    game = obj.game(gameCount);
                    
                    obj.currentData.block   = blockNum;
                    
                    % game number within block
                    obj.currentData.gameNum = gameCount;
                    
                    obj.playGame(game);
                    gameCount = gameCount + 1;
                end
                
                obj.talk(['End of block ' num2str(blockNum) ' of ' ...
                    num2str(numBlocks) '. \n\n You won ' num2str(obj.blockPoints) ...
                    ' points! \n Press space to continue.']);
                
                obj.totalPoints = (obj.totalPoints + obj.blockPoints);
                Screen(obj.window, 'Flip');
                
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(1);
                
                %notify(obj, 'endBlock');
                obj.saveData;
            end
            
            
            
            %notify(obj, 'endExperiment');
            %obj.moneyWon;
            obj.saveData;
            obj.talk(['This is the end of the experiment. Thank you '...
                'for participating!']);
            
            Screen(obj.window, 'Flip');
            obj.waitForInput([7], GetSecs + Inf);
            disp(['Money Earned = ' num2str(obj.totalPoints / ((1+6)/2*ng*100*3))]);
            obj.money = [obj.totalPoints / ((1+6)/2*ng*100*3)];
%             
        end
        
        function runPractice(obj, numBlocks, numGames)
            
            obj.saveFlag = false;
            game = obj.makePracticeGameParameters;
            ng = numBlocks * numGames;
            if ng < length(game)
                beep;
                disp('You''re asking for fewer games than you have!')
            elseif ng > length(game)
                error('You''re asking for more games than you have!')
            end
            
            gameCount = 1;
            obj.totalPoints = 0;
            
            %notify(obj, 'startExperiment');
            obj.makeGameParameters;
            
            for blockNum = 1:numBlocks
                
                obj.blockPoints = 0;
                
                obj.talk(['Press space to begin practice block ' num2str(blockNum) '.']);
                Screen(obj.window, 'Flip');
                
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(0.5);
                
                %notify(obj, 'startBlock');
                obj.fix.draw;
                Screen(obj.window, 'Flip');
                %notify(obj, 'fixOn');
                
                for gameNum = 1:numGames
                    
                    game = obj.game(gameCount);
                    
                    obj.currentData.block   = blockNum;
                    
                    % game number within block
                    obj.currentData.gameNum = gameCount;
                    
                    obj.playGame(game);
                    gameCount = gameCount + 1;
                end
                
                obj.talk(['End of block ' num2str(blockNum) ' of ' ...
                    num2str(numBlocks) '. \n\n You won ' num2str(obj.blockPoints) ...
                    ' points! \n Press space to continue.']);
                
                obj.totalPoints = (obj.totalPoints + obj.blockPoints);
                Screen(obj.window, 'Flip');
                
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(1);
                
                %notify(obj, 'endBlock');
                obj.saveData;
            end
            
            
            %notify(obj, 'endExperiment');
            %obj.moneyWon;
            obj.saveData;
            obj.talk(['This is the end of the practice.  ' ...
                'Press space to begin the game!']);
            
            Screen(obj.window, 'Flip');
            obj.waitForInput([3], GetSecs + Inf);
            
            
        end
        
        
        
    end
    
end





