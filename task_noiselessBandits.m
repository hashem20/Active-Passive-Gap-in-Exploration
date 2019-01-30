classdef task_noiselessBandits < handle
    
    properties
        
        % subject number
        subNum
        
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
        rewQQ
        
        points
        totalPoints
        blockPoints
        totalMoney
        blockMoney
        totalMax
        money
        
        % feedback
        partialFeedback
        noFeedback
        
        % reward histories
        rewHistL
        rewHistR
        
        % bandits
        ban
        
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
    
    methods
        
        function obj = task_noiselessBandits(stimdir, sounddir, datadir, savename)
            
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
        
        function [mu, cp] = makeChangePointRewards(obj, h, T, mu_min, mu_max)
            
            % generate a Gaussian change-point test set (known mean,
            % unknown variance)
            
            % test parameter values
            % h = 0.1;
            % T = 500;
            % alpha = 1;
            % beta = 1;
            % mu = 0;
            
            % generate change-points
            cp = rand(T,1) < h;
            
            % compute segment number
            seg = cumsum(cp);
            
            % sample bernoulli rate from Beta distribution
            for s = unique(seg)'
                ind = seg == s;
                mn(s+1) = round(rand(1)*(mu_max-mu_min) + mu_min);
                if s > 0
                    while mn(s+1) == mn(s)
                        mn(s+1) = round(rand(1)*(mu_max-mu_min) + mu_min);
                    end
                end
                mu(ind) = mn(s+1);
            end
            
            
            cp = cp'; % bit of a hack!
            % sample data
            %d = randn(size(mu)).*sig + mu;
            
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
            i=i+1; ev{i} = 'bandits_ex';    iStr{i} = 'Your goal is to maximize the number of points you earn';
            i=i+1; ev{i} = 'bandits_ex';    iStr{i} = 'Use the b and n keys to choose a slot machine. To choose the left slot machine press b.  To choose the right slot machine press n.';
            i=i+1; ev{i} = 'bandits_ex';    iStr{i} = 'In each game the payout from each slot machine is fixed and is the same every time it is played.';
            i=i+1; ev{i} = 'forcedTrials_1';iStr{i} = 'At the start of a game only one option is available to be played.  This is indicated like this ...';
            i=i+1; ev{i} = 'freeTrials';    iStr{i} = 'After the first trial you are then free to choose between the two options for the remainder of the game.';
            i=i+1; ev{i} = 'rewHist';       iStr{i} = 'We will show the outcomes of your previous choices in these history bars. In addition to telling you the previous outcomes, these history bars tell you how many choices you have left in the game.';
            i=i+1; ev{i} = 'hor2';          iStr{i} = 'Games can last either 2 trials, ...';
            i=i+1; ev{i} = 'hor5';          iStr{i} = '... 5 trials, ...';
            i=i+1; ev{i} = 'hor10';         iStr{i} = '... or 10 trials.';
            
            i=i+1; ev{i} = 'default';       iStr{i} = 'Press space when you''re ready to start!  Good luck!';
            %i=i+1; ev{i} = 'default';       iStr{i} = 'Press space when you''re ready to start!  Good luck!  Remember the more points your earn the more money you get!';
            
            obj.iStr = iStr;
            obj.iEv = ev;
            
        end
        
        function instructions(obj)
            
            rew = obj.rew;
            rewXX = obj.rewXX;
            
            % move everything down by dy
            dy = 200;
            for i = 1:length(obj.ban)
                obj.ban(i).setPosition( obj.ban(i).centerPosition + [0 dy]);
            end
            for i = 1:length(obj.rewHistL)
                obj.rewHistL(i).setPositionByTop(obj.rewHistL(i).topPosition + [0 dy]);
                obj.rewHistR(i).setPositionByTop(obj.rewHistR(i).topPosition + [0 dy]);
            end
            %obj.noFeedback.centrePosition = obj.noFeedback.centrePosition + [0 dy];
            %obj.partialFeedback.centrePosition = obj.partialFeedback.centrePosition + [0 dy];
            
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
                        % obj.fix.draw;
                        obj.talkAndFlip(iStr{count});
                        
                    case 'bandits_ex' % bandits example
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        obj.talkAndFlip(iStr{count});
                        
                    case 'bandits_ex_75R' % bandits with 75 in right
                        
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        obj.ban(2).showRewardPlayed([rew(75)]);
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case '52' % 52 left
                        
                        
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        obj.ban(1).showRewardPlayed([rew(52)]);
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case '56' % 56 left
                        
                        
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        obj.ban(1).showRewardPlayed([rew(56)]);
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case '45' % 45 left
                        
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        obj.ban(1).showRewardPlayed([rew(45)]);
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case '90' % 45 left
                        
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        obj.ban(1).showRewardPlayed([rew(90)]);
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case 'rewHist'
                        
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        
                        obj.rewHistL(2).flush;
                        obj.rewHistR(2).flush;
                        
                        obj.rewHistL(2).draw;
                        obj.rewHistR(2).draw;
                        
                        
                        obj.rewHistL(2).addReward(rewXX)
                        obj.rewHistL(2).addReward(rew(52))
                        
                        obj.rewHistR(2).addReward(rewXX)
                        obj.rewHistR(2).addReward(rewXX)
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case 'hor2'
                        
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        
                        i = 2;
                        obj.rewHistL(i).flush;
                        obj.rewHistR(i).flush;
                        
                        obj.rewHistL(i).draw;
                        obj.rewHistR(i).draw;
                        
                        
                        obj.rewHistL(i).addReward(rewXX)
                        obj.rewHistL(i).addReward(rew(52))
                        
                        obj.rewHistR(i).addReward(rewXX)
                        obj.rewHistR(i).addReward(rewXX)
                        
                        obj.talkAndFlip(iStr{count});
                        
                        
                    case 'hor5'
                        
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        
                        i = 5;
                        obj.rewHistL(i).flush;
                        obj.rewHistR(i).flush;
                        
                        obj.rewHistL(i).draw;
                        obj.rewHistR(i).draw;
                        
                        
                        obj.rewHistL(i).addReward(rewXX)
                        obj.rewHistL(i).addReward(rew(52))
                        
                        obj.rewHistR(i).addReward(rewXX)
                        obj.rewHistR(i).addReward(rewXX)
                        
                        obj.talkAndFlip(iStr{count});
                        
                     case 'hor10'
                        
                        for i = 1:length(obj.ban)
                            obj.ban(i).draw;
                        end
                        
                        i = 10;
                        obj.rewHistL(i).flush;
                        obj.rewHistR(i).flush;
                        
                        obj.rewHistL(i).draw;
                        obj.rewHistR(i).draw;
                        
                        
                        obj.rewHistL(i).addReward(rewXX)
                        obj.rewHistL(i).addReward(rew(52))
                        
                        obj.rewHistR(i).addReward(rewXX)
                        obj.rewHistR(i).addReward(rewXX)
                        
                        obj.talkAndFlip(iStr{count});
                        
                       
                       
                        
                    case 'forcedTrials_1'
                        obj.ban(1).drawChange;
                        obj.ban(2).draw;
                        
                        %obj.rewHistL.flush;
                        %obj.rewHistR.flush;
                        %
                        %obj.rewHistL.addReward(rewXX)
                        %obj.rewHistL.addReward(rew(52))
                        %obj.rewHistL.addReward(rew(56))
                        %obj.rewHistL.addReward(rew(45))
                        %
                        %obj.rewHistR.addReward(rew(75))
                        %obj.rewHistR.addReward(rewXX)
                        %obj.rewHistR.addReward(rewXX)
                        %obj.rewHistR.addReward(rewXX)
                        
                        %obj.rewHistL.draw;
                        %obj.rewHistR.draw;
                        
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case 'forcedTrials_2'
                        obj.banR.draw;
                        obj.banL.draw;
                        
                        obj.rewHistL.flush;
                        obj.rewHistR.flush;
                        
                        obj.rewHistL.addReward(rew(56))
                        obj.rewHistL.addReward(rewXX)
                        obj.rewHistL.addReward(rewXX)
                        obj.rewHistL.addReward(rew(45))
                        
                        obj.rewHistR.addReward(rewXX)
                        obj.rewHistR.addReward(rew(65))
                        obj.rewHistR.addReward(rew(75))
                        obj.rewHistR.addReward(rewXX)
                        
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
                       
                    case 'freeTrials'
                        obj.ban(1).draw;
                        obj.ban(2).draw;
                        
                        %obj.rewHistL.flush;
                        %obj.rewHistR.flush;
                        %
                        %obj.rewHistL.addReward(rewXX)
                        %obj.rewHistL.addReward(rew(52))
                        %obj.rewHistL.addReward(rew(56))
                        %obj.rewHistL.addReward(rew(45))
                        %
                        %obj.rewHistR.addReward(rew(75))
                        %obj.rewHistR.addReward(rewXX)
                        %obj.rewHistR.addReward(rewXX)
                        %obj.rewHistR.addReward(rewXX)
                        
                        %obj.rewHistL.draw;
                        %obj.rewHistR.draw;
                        
                        
                        obj.talkAndFlip(iStr{count});
                        
                    
                        
                    case 'infoCond_0'
                        obj.banR.draw;
                        obj.banL.draw;
                        
                        obj.rewHistL.flush;
                        obj.rewHistR.flush;
                        
                        obj.rewHistL.draw;
                        obj.rewHistR.draw;
                        
                        obj.noFeedback.draw;
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case 'infoCond_1'
                        obj.banR.draw;
                        obj.banL.draw;
                        
                        obj.rewHistL.flush;
                        obj.rewHistR.flush;
                        
                        obj.rewHistL.draw;
                        obj.rewHistR.draw;
                        
                        obj.partialFeedback.draw;
                        
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
            for i = 1:length(obj.ban)
                obj.ban(i).setPosition( obj.ban(i).centerPosition - [0 dy]);
            end
            for i = 1:length(obj.rewHistL)
                obj.rewHistL(i).setPositionByTop(obj.rewHistL(i).topPosition - [0 dy]);
                obj.rewHistR(i).setPositionByTop(obj.rewHistR(i).topPosition - [0 dy]);
            end

            
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
            obj.makeFeedback;
            obj.makeBandits(2);
            %obj.makeMoneyBar;
            obj.makeRewardHistory([1 4]);
            
            obj.makeData;
            
            obj.makeGameParameters
            obj.count = 1;
            obj.totalMoney = 0;
        end
        
        function makeMoneyBar(obj)
            obj.mb = moneyBar(obj.window, obj.stimDir, 'dollarBill.png', [0 0 0]);
            obj.mb.setToRightEdge;
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
            obj.rewQQ = picture(obj.window, obj.stimdir, 'QQ.png');
            obj.rewQQ.setup(sfXX, [sw/2 sh/2]);
            
        end
        
        function makeBandits(obj, nBandits)
            
            % banditNum = vector of numbers for the names of the bandit
            % files
            
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            
            
            %num1 = banditNum(1);
            %num2 = banditNum(2);
            
            
            dx = [nBandits:-1:1]*1000;
            dx = dx - mean(dx);
            dx = dx * obj.scaleFactor;
            
            dy = 200;
            
            % Make left and right bandits
            for i = 1:nBandits
                ban(i) = bandit_playable_changePoint(obj.window, obj.stimdir, ['bandit' num2str(i) '.png'], i, 'changed.png');
                ban(i).setup(obj.scaleFactor, obj.bgColour);
                ban(i).setPosition([sw/2-dx(i) sh/2-dy]);
                ban(i).playedBandit;
                ban(i).setupChange;
                ban(i).visible = true;
            end
            
            obj.ban = ban;
            
            
        end
        
        function makeRewardHistory(obj, rewHistNum)
            
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            
            numL = rewHistNum(1);
            numR = rewHistNum(2);
            
            dx = 200*obj.scaleFactor;
            
            for i = 1:10
                
                if i == 1
                    obj.rewHistL = rewardHistory_allie(obj.window, obj.stimdir, i, obj.scaleFactor);
                    obj.rewHistL.setup(['rewHistBackground' num2str(numL) '.png'], 'blankNumber.png', obj.scaleFactor);
                    obj.rewHistL.setPositionByTop([sw/2-dx sh/30]);
                    obj.rewHistR = rewardHistory_allie(obj.window, obj.stimdir, i, obj.scaleFactor);
                    obj.rewHistR.setup(['rewHistBackground' num2str(numR) '.png'], 'blankNumber.png', obj.scaleFactor);
                    obj.rewHistR.setPositionByTop([sw/2+dx sh/30]);
                    
                else
                    obj.rewHistL(i) = rewardHistory_allie(obj.window, obj.stimdir, i, obj.scaleFactor);
                    obj.rewHistL(i).setup(['rewHistBackground' num2str(numL) '.png'], 'blankNumber.png', obj.scaleFactor);
                    obj.rewHistL(i).setPositionByTop([sw/2-dx sh/30]);
                    obj.rewHistR(i) = rewardHistory_allie(obj.window, obj.stimdir, i, obj.scaleFactor);
                    obj.rewHistR(i).setup(['rewHistBackground' num2str(numR) '.png'], 'blankNumber.png', obj.scaleFactor);
                    obj.rewHistR(i).setPositionByTop([sw/2+dx sh/30]);
                end
            end
            
            
        end
        
        function makeFeedback(obj)
            
            sw      = obj.screenWidth;
            sh      = obj.screenHeight;
            win     = obj.window;
            stimdir = obj.stimdir;
            
            obj.noFeedback = picture(win, stimdir, 'value.png');
            obj.noFeedback.setup(obj.scaleFactor, [sw/2 sh/3.5]);
            obj.partialFeedback = picture(win, stimdir, 'infoAndValue.png');
            obj.partialFeedback.setup(obj.scaleFactor, [sw/2 sh/3.5]);
            
        end
        
        function makeGameParameters(obj)
            
            nBandits        = 2;
            
            mu_min          = 1;
            mu_max          = 99;
            sigma_noise     = 0;
            forcedFraction  = 0;
            
            % beta parameter priors for known mean
            AA = 3;
            BB = 2;
            
            i = 1;
            % game length
            var(i).x = [2 5 10];
            var(i).type = 1;
            i=i+1;
            
            % forced side
            var(i).x = [1 2];
            var(i).type = 1;
            i=i+1;
            
            [var, T, N] = counterBalancer(var, 59);
            test_counterBalancing(var);
            
            gameLength_vals = var(1).x_cb;
            forcedSide_vals = var(2).x_cb;
            
            
            for i = 1:length(gameLength_vals)
                
                gameLength  = gameLength_vals(i);
                forcedSide  = forcedSide_vals(i);
                freeSide    = find([1 2]~=forcedSide);
                
                mu1 = round(98*betarnd(AA, BB))+1;
                mu2 = round(rand(1)*98)+1;
                
                clear mu
                mu(1:gameLength,forcedSide) = mu1;
                mu(1:gameLength,freeSide)   = mu2;
                
                forced      = false(gameLength,1);
                forced(1)   = true;
                
                game(i).mean        = mu;
                game(i).forced      = forced;
                game(i).forcedWhere = forcedSide;
                game(i).rewards     = mu;
                game(i).gameLength  = gameLength;
                
            end
            
            obj.game = game;
            
        end
        
        function makeGameParameters_OLD(obj)
            
            nBandits        = 2;
            gameLength      = 1500;
            Tburn           = 1000;
            sigma_drift     = 5;
            sigma_noise     = 2;
            alpha           = 0.02;
            beta = 0.5;
            forcedFraction  = 0.4;
            
            i = 1;
            
            % drift condition
            var(i).x = [3];
            var(i).type = 1;
            i=i+1;
            
            [var, T, N] = counterBalancer(var, 1);
            test_counterBalancing(var);
            
            drift = var(1).x_cb;
            
            for j = 1:T
                
                sigma_drift = drift(j);
                
                % burn in
                mu(1,1:nBandits) = 50;
                for t = 1:Tburn
                    mu(t+1,:) = (1-alpha)*mu(t,:) + alpha*50 + randn(1,nBandits)*sigma_drift;
                    %mu(t+1,:) = (1-beta) * ((1-alpha)*mu(t,:) + alpha*50 + randn(1,nBandits)*sigma_drift) + beta * mu(t,:);
                    ind0 = mu(t+1,:)<1;
                    mu(t+1,ind0) = 2-mu(t+1,ind0);
                    
                    ind100 = mu(t+1,:)>99;
                    mu(t+1,ind100) = 99-(mu(t+1,ind100)-99);
                end
                
                % make means
                mu = mu(end,:);
                for t = 1:gameLength-1
                    mu(t+1,:) = (1-alpha)*mu(t,:) + alpha*50 + randn(1,nBandits)*sigma_drift;
                    ind0 = mu(t+1,:)<1;
                    mu(t+1,ind0) = 2-mu(t+1,ind0);
                    
                    ind100 = mu(t+1,:)>99;
                    mu(t+1,ind100) = 99-(mu(t+1,ind100)-99);
                end
                
                % forced trials
                forced = rand(gameLength,1)<forcedFraction;
                forcedWhere = ceil(rand(gameLength,1)*nBandits) .* forced;
                
                game(j).mean        = mu;
                game(j).forced      = forced;
                game(j).forcedWhere = forcedWhere;
                game(j).rewards = round(mu + randn(size(mu))*sigma_noise);
                
                % ensure rewards are in [1 100]
                ind100 = game(j).rewards>100;
                ind1 = game(j).rewards<1;
                game(j).rewards(ind100) = 100;
                game(j).rewards(ind1) = 1;
                game(j).gameLength = gameLength;
                
            end
            
            %plot(game(1).mean)
            %ylim([0 100])
            obj.game = game;
            
            
        end
        
        function game = makePracticeGameParameters(obj)
            
            
            nBandits        = 2;
            gameLength      = 15;
            Tburn           = 1000;
            sigma_drift     = 5;
            sigma_noise     = 2;
            alpha           = 0.02;
            beta = 0.5;
            forcedFraction  = 0.2;
            
            i = 1;
            
            % drift condition
            var(i).x = [3];
            var(i).type = 1;
            i=i+1;
            
            [var, T, N] = counterBalancer(var, 1);
            test_counterBalancing(var);
            
            drift = var(1).x_cb;
            
            for j = 1:T
                
                sigma_drift = drift(j);
                
                % burn in
                mu(1,1:nBandits) = 50;
                for t = 1:Tburn
                    mu(t+1,:) = (1-alpha)*mu(t,:) + alpha*50 + randn(1,nBandits)*sigma_drift;
                    %mu(t+1,:) = (1-beta) * ((1-alpha)*mu(t,:) + alpha*50 + randn(1,nBandits)*sigma_drift) + beta * mu(t,:);
                    ind0 = mu(t+1,:)<1;
                    mu(t+1,ind0) = 2-mu(t+1,ind0);
                    
                    ind100 = mu(t+1,:)>99;
                    mu(t+1,ind100) = 99-(mu(t+1,ind100)-99);
                end
                
                % make means
                mu = mu(end,:);
                for t = 1:gameLength-1
                    mu(t+1,:) = (1-alpha)*mu(t,:) + alpha*50 + randn(1,nBandits)*sigma_drift;
                    ind0 = mu(t+1,:)<1;
                    mu(t+1,ind0) = 2-mu(t+1,ind0);
                    
                    ind100 = mu(t+1,:)>99;
                    mu(t+1,ind100) = 99-(mu(t+1,ind100)-99);
                end
                
                % forced trials
                forced = rand(gameLength,1)<forcedFraction;
                forcedWhere = ceil(rand(gameLength,1)*nBandits) .* forced;
                
                game(j).mean        = mu;
                game(j).forced      = forced;
                game(j).forcedWhere = forcedWhere;
                game(j).rewards = round(mu + randn(size(mu))*sigma_noise);
                
                % ensure rewards are in [1 100]
                ind100 = game(j).rewards>100;
                ind1 = game(j).rewards<1;
                game(j).rewards(ind100) = 100;
                game(j).rewards(ind1) = 1;
                
            end
            
        end
        
        function forcedTrial(obj, RR, forcedWhere, rewHistL, rewHistR)
            
            ban     = obj.ban;
            rew     = obj.rew;
            rewXX   = obj.rewXX;
            
            rewHistL.draw;
            rewHistR.draw;
            for i = 1:length(ban)
                ban(i).draw;
            end
            ban(forcedWhere).drawChange;
            banditOnTime = Screen(obj.window, 'Flip');
            
            [KeyNum, when] = obj.waitForInput(forcedWhere, GetSecs +Inf);
            reward = RR(KeyNum);
            
            for i = 1:length(ban)
                ban(i).draw;
            end
            ban(KeyNum).drawChange;
            ban(KeyNum).showRewardPlayed(rew(reward));
            
            switch KeyNum
                case 1
                    rewHistL.addReward(rew(reward));
                    rewHistR.addReward(rewXX);
                case 2
                    rewHistR.addReward(rew(reward));
                    rewHistL.addReward(rewXX);
            end
            rewHistL.draw;
            rewHistR.draw;
            rewardOnTime = Screen(obj.window, 'Flip');
            
            % update total points
            obj.blockPoints = obj.blockPoints + reward;
            
            % store in current data
            obj.currentData.type            = 'forced';
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
        
        function freeTrial(obj, RR, rewHistL, rewHistR)
            
            ban     = obj.ban;
            rew     = obj.rew;
            rewXX   = obj.rewXX;
            
            for i = 1:length(ban)
                ban(i).draw;
                
            end
            rewHistL.draw;
            rewHistR.draw;
            
            banditOnTime = Screen(obj.window, 'Flip');
            
            [KeyNum, when] = obj.waitForInput([1:length(ban)], GetSecs +Inf);
            reward = RR(KeyNum);
            
            for i = 1:length(ban)
                ban(i).draw;
            end
            ban(KeyNum).showRewardPlayed(rew(reward));
            switch KeyNum
                case 1
                    rewHistL.addReward(rew(reward));
                    rewHistR.addReward(rewXX);
                case 2
                    rewHistR.addReward(rew(reward));
                    rewHistL.addReward(rewXX);
            end
            rewHistL.draw;
            rewHistR.draw;
            
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
            
            %game            = obj.game;
            
            forced          = game.forced;
            forcedWhere     = game.forcedWhere;
            rew             = game.rewards;
            gameLength      = game.gameLength;
            
            
            obj.rewHistL(gameLength).flush;
            obj.rewHistR(gameLength).flush;
            
            for t = 1:game.gameLength
                %obj.clearCurrentData;
                
                obj.currentData.trialNum = t;
                if forced(t)
                    % forced trial
                    obj.forcedTrial(rew(t,:), forcedWhere(t), obj.rewHistL(gameLength), obj.rewHistR(gameLength));
                    
                else
                    % free trial
                    obj.freeTrial(rew(t,:), obj.rewHistL(gameLength), obj.rewHistR(gameLength));
                end
                obj.storeData;
            end
            obj.saveData;
            
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
                
                obj.talk(['Block ' num2str(blockNum) ...
                    ' of ' num2str(numBlocks)...
                    '\nPress space to begin!']);
                Screen(obj.window, 'Flip');
                
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(0.5);
                
                %notify(obj, 'startBlock');
                % obj.fix.draw;
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
                
                gc = obj.currentData.gameNum;
                
                
                X = vertcat(obj.game(gc-1:gc).rewards);
                MAX_R = sum(max(X'));
                
                
                obj.blockMoney = obj.blockPoints/MAX_R * 3 / length(obj.game);
                obj.totalMoney = obj.totalMoney + obj.blockMoney;
                obj.totalPoints = (obj.totalPoints + obj.blockPoints);
                
                obj.talk(['End of block ' num2str(blockNum) ' of ' ...
                    num2str(numBlocks) '. \n\n You won ' ...
                    num2str(round(obj.blockMoney*100)/100) ...
                    ' dollars out of a possible ' num2str(round(3/length(obj.game)*100)/100) ...
                    ' dollars. \n ' ...
                    'You''re total earnings are ' num2str(round(obj.totalMoney*100)/100) ...
                    ' dollars.' ...
                    ' \n Press space to continue.']);
                
                
                
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
            disp(['Money Earned = ' num2str(obj.totalMoney)]);
            
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
                % obj.fix.draw;
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





