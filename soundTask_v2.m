classdef soundTask_v2 < handle
    
    properties
        
        % instructions
        iStr
        iEv
        
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
        rewLeft
        rewRight
        
        points
        totalPoints
        blockPoints
        totalMax
        money
        
        % horizon cues
        hor1
        hor6
        
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
    
    events
        
        pressSpaceStartGame
        pressSpaceStartForced
        horizonOn
        forcedOn
        banditsOn
        choiceMade
        rewardOn
        fixOn
        
        startExperiment
        startBlock
        startGame
        startFree
        
        endGame
        endBlock
        endExperiment
        
    end
    
    methods
        
        function obj = soundTask_v2(stimdir, sounddir, datadir, savename)
            
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
                0.1*A,[B*0.3], obj.textColour, obj.textWidth);
            Screen('TextSize', obj.window,round(obj.textSize));
            DrawFormattedText(obj.window, ...
                ['' ...
                'Press space to continue or delete to go back'], ...
                'center', [B/1.1], [150 150 150], obj.textWidth);
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
            i=i+1; ev{i} = 'fix';           iStr{i} = 'In this task we will measure the diameter of your pupils while you are performing a simple gambling task.  In order for us to measure you pupil diameter accurately we ask that you try to fixate on the small fixation cross above throughout the experiment.';
            i=i+1; ev{i} = 'default';       iStr{i} = 'The task you will perform involves playing a series of games in which you have to make decisions between two different slot machines.  Every time a slot machine is payed it pays out a reward between 1 and 100 points. ';
            i=i+1; ev{i} = 'default';       iStr{i} = 'Because we are measuring the diameter of your pupils the computer will not show you the outcome of your choice as this might change your pupil diameter by changing the brightness of the screen.  Instead we will have the computer tell you the reward value that you earned.';
            i=i+1; ev{i} = 'default';       iStr{i} = 'Furthermore, you will only hear this sound in the ear corresponding to the choice that you made.  To choose the left slot machine press b.  To choose the right slot machine press n.';
            i=i+1; ev{i} = 'p1 45 p2 62';   iStr{i} = 'Press b now to hear an example outcome in the left ear.  Press n to hear an example outcome in the right ear.';
            i=i+1; ev{i} = 'default';       iStr{i} = 'In each game, the average payoff from each slot machine is fixed, but on any given play there is variability in the exact amount.';
            i=i+1; ev{i} = '52';            iStr{i} = 'For example, the mean payoff from the left slot machine might be 50 points but on any trial you might receive more or less than 50 points randomly - say 52 points on the first play ... (press b to hear sound)';
            i=i+1; ev{i} = '56';            iStr{i} = '... 56 on the second ... (press b to hear sound)';
            i=i+1; ev{i} = '45';            iStr{i} = '...and 45 on the third. (press b to hear sound)';
            i=i+1; ev{i} = 'default';       iStr{i} = 'This variability makes it difficult to figure out which is the best slot machine, but that is exactly what you need to do to maximize your payoff from the game.';
            i=i+1; ev{i} = '1 choice';      iStr{i} = 'At the beginning of each game the computer will first tell you how many choices you have in this game.  There will either be just 1 choice (press b to hear sound) ...';
            i=i+1; ev{i} = '6 choices';     iStr{i} =  '... or 6 choices (press b to hear sound)';
            i=i+1; ev{i} = 'p1 4 sounds';   iStr{i} = 'After you have heard the number of choices you should then press space again to have the computer play the slot machines randomly four times.  This is done to give you some information about both options before you start making decisions.  Press b now to hear an example of four computer generated plays.';
            i=i+1; ev{i} = 'default';       iStr{i} = 'At the end of a game the mean payoff of both slot machines changes. When this happens the cross will dissappear.  When the cross returns, a new game begins.  This will also be announced.';
            i=i+1; ev{i} = 'default';       iStr{i} = 'Press space when you''re ready to start the game!  Good luck!';
            
            obj.iStr = iStr;
            obj.iEv = ev;
            
        end
        
        function instructions(obj)
            
            obj.instructionList;
            
            iStr = obj.iStr;
            ev = obj.iEv;
            
            endFlag = false;
            count = 1;
            
            while ~endFlag
                [A, B] = Screen('WindowSize', obj.window);
                
                DrawFormattedText(obj.window, ...
                    ['Page ' num2str(count) ' of ' num2str(length(iStr))], ...
                    [],[B/1.07], obj.textColour, obj.textWidth);
                
                
                ef = false;
                switch ev{count}
                    
                    case 'fix' % draw the fixation cross
                        obj.fix.draw;
                        obj.talkAndFlip(iStr{count});
                        
                    case 'p1 45 p2 62' % example sounds when they press 1 and 2
                        
                        obj.talkAndFlip(iStr{count});
                        ef = false;
                        while ~ef
                            [KeyNum, when] = obj.waitForInput([1:4], Inf);
                            switch KeyNum
                                
                                case 1 % play 45 in left ear
                                    
                                    obj.rewLeft(45).playSound(GetSecs+0.1);
                                    
                                case 2 % play 62 in right ear
                                    obj.rewRight(62).playSound(GetSecs+0.1);
                                    
                                case 3 % go forwards
                                    ef = true;
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
                                    
                                    
                            end
                        end
                        
                    case '52' % example sounds when they press 1 and 2
                        
                        obj.talkAndFlip(iStr{count});
                        ef = false;
                        while ~ef
                            [KeyNum, when] = obj.waitForInput([1:4], Inf);
                            switch KeyNum
                                
                                case 1 % play 45 in left ear
                                    
                                    obj.rewLeft(52).playSound(GetSecs+0.1);
                                    
                                case 2 % play 62 in right ear
                                    obj.rewRight(52).playSound(GetSecs+0.1);
                                    
                                case 3 % go forwards
                                    ef = true;
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
                                    
                                    
                            end
                        end
                        
                    case '56' % example sounds when they press 1 and 2
                        
                        obj.talkAndFlip(iStr{count});
                        ef = false;
                        while ~ef
                            [KeyNum, when] = obj.waitForInput([1:4], Inf);
                            switch KeyNum
                                
                                case 1 % play 45 in left ear
                                    
                                    obj.rewLeft(56).playSound(GetSecs+0.1);
                                    
                                case 2 % play 62 in right ear
                                    obj.rewRight(56).playSound(GetSecs+0.1);
                                    
                                case 3 % go forwards
                                    ef = true;
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
                                    
                                    
                            end
                        end
                        
                    case '45' % example sounds when they press 1 and 2
                        
                        obj.talkAndFlip(iStr{count});
                        ef = false;
                        while ~ef
                            [KeyNum, when] = obj.waitForInput([1:4], Inf);
                            switch KeyNum
                                
                                case 1 % play 45 in left ear
                                    
                                    obj.rewLeft(45).playSound(GetSecs+0.1);
                                    
                                case 2 % play 62 in right ear
                                    obj.rewRight(45).playSound(GetSecs+0.1);
                                    
                                case 3 % go forwards
                                    ef = true;
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
                                    
                                    
                            end
                        end
                        
                        
                    case '1 choice'
                        obj.talkAndFlip(iStr{count});
                        ef = false;
                        while ~ef
                            [KeyNum, when] = obj.waitForInput([1:4], Inf);
                            switch KeyNum
                                
                                case 1 % play 45 in left ear
                                    
                                    obj.hor1.playSound(GetSecs+0.1);
                                    
                                    
                                case 3 % go forwards
                                    ef = true;
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
                                    
                                    
                            end
                        end
                        
                        
                    case '6 choices'
                        obj.talkAndFlip(iStr{count});
                        ef = false;
                        while ~ef
                            [KeyNum, when] = obj.waitForInput([1:4], Inf);
                            switch KeyNum
                                
                                case 1 % play 45 in left ear
                                    
                                    obj.hor6.playSound(GetSecs+0.1);
                                    
                                    
                                case 3 % go forwards
                                    ef = true;
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
                                    
                                    
                            end
                        end
                        
                        
                    case 'p1 4 sounds'
                        
                        obj.talkAndFlip(iStr{count});
                        ef = false;
                        while ~ef
                            [KeyNum, when] = obj.waitForInput([1:4], Inf);
                            switch KeyNum
                                
                                case 1 % play 45 in left ear
                                    
                                    obj.rewLeft(45).playSound(GetSecs+0.5);
                                    obj.rewLeft(52).playSound(GetSecs+0.5);
                                    obj.rewLeft(49).playSound(GetSecs+0.5);
                                    obj.rewRight(65).playSound(GetSecs+0.5);
                                    
                                case 3 % go forwards
                                    ef = true;
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
                                    
                                    
                            end
                        end
                        
                        
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
            
            WaitSecs(0.1);
        end
        
        
        % task functions ==================================================
        function setup(obj, bgColour)
            
            obj.setupPsychSound;
            obj.setRewards;
            obj.setStartAndEndCues;
            obj.loadHorizonSounds;
            
            obj.setWindow(bgColour);
            obj.setTextParameters(32, 50, [1 1 1]*256);
            obj.setKeys({'b' 'n' 'space' 'delete' 'p' 'q' '7&'});
            obj.makeFixationCross;
            
            obj.makeData;
            
            obj.makeGameParameters
            %obj.totalMax = 0;
            obj.count = 1;
        end
        
        function setRewardsBeeps(obj)
            
            freq = logspace(log10(500), log10(4000), 100);
            
            amplit = 1;
            duration = 0.15;
            sampleRate = obj.sampleRate;
            
            for i = 1:100;
                snd = amplit * MakeBeep(freq(i), duration, sampleRate);
                
                rewLeft(i)  = soundObject(obj.pahandle, obj.sampleRate);
                rewLeft(i).setSound([snd; snd*0]);
                
                rewRight(i) = soundObject(obj.pahandle, obj.sampleRate);
                rewRight(i).setSound([snd*0; snd]);
                
            end
            
            obj.rewLeft  = rewLeft;
            obj.rewRight = rewRight;
            
        end
        
        function setRewardsNumbers(obj)
            
            for i = 1:100
                snd = wavread([obj.sounddir num2str(i) '.wav']);
                
                rewLeft(i)  = soundObject(obj.pahandle, obj.sampleRate);
                rewLeft(i).setSound([snd snd*0]');
                
                rewRight(i) = soundObject(obj.pahandle, obj.sampleRate);
                rewRight(i).setSound([snd*0 snd]');
            end
            
            obj.rewLeft  = rewLeft;
            obj.rewRight = rewRight;
            
        end
        
        function setStartAndEndCues(obj)
            
            snd = wavread([obj.sounddir 'NewGame.wav']);
            obj.gameStartCue  = soundObject(obj.pahandle, obj.sampleRate);
            obj.gameStartCue.setSound([snd snd]');
            
            snd = wavread([obj.sounddir 'EndOfGame.wav']);
            obj.gameEndCue  = soundObject(obj.pahandle, obj.sampleRate);
            obj.gameEndCue.setSound([snd snd]');
            
            snd = wavread([obj.sounddir 'PressSpace.wav']);
            obj.pressSpaceCue  = soundObject(obj.pahandle, obj.sampleRate);
            obj.pressSpaceCue.setSound([snd snd]');
            
            snd = wavread([obj.sounddir 'Go.wav']);
            obj.goCue  = soundObject(obj.pahandle, obj.sampleRate);
            obj.goCue.setSound([snd snd]');
            
        end
        
        function setRewards(obj)
            obj.setRewardsNumbers;
        end
        
        function loadHorizonSounds(obj)
            
            s1 = wavread([obj.sounddir '1 choice.wav']);
            obj.hor1 = soundObject(obj.pahandle, obj.sampleRate);
            obj.hor1.setSound([s1 s1]');
            
            s6 = wavread([obj.sounddir '6 choices.wav']);
            obj.hor6 = soundObject(obj.pahandle, obj.sampleRate);
            obj.hor6.setSound([s6 s6]');
            
        end
        
        function makeGameParameters(obj)
            
            i = 1;
            
            % \mu
            var(i).x = [40 60];
            var(i).type = 1;
            i=i+1;
            
            % main bandit number
            var(i).x = [1 2];
            var(i).type = 1;
            i=i+1;
            
            % \delta \mu
            %var(i).x = [-10 -5 0 5 10];
            var(i).x = [-10 -6 -2 2 6 10];
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
                
                obj.game(j).gameLength = gameLength(j);
                
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
                ind1 = obj.game(j).rewards<1
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
        
        function forcedTrial(obj, forcedChoice, Lrew, Rrew)
            
            
            switch forcedChoice
                
                case 1 % forced left
                    
                    rewSound = obj.rewLeft(Lrew);
                    reward   = Lrew;
                    choice   = 1;
                    
                case 2 % forced right
                    
                    rewSound = obj.rewRight(Rrew);
                    reward   = Rrew;
                    choice   = 2;
                    
            end
            
            % play the sound
            notify(obj, 'forcedOn');
            [soundOn, soundOff] = rewSound.playSound(GetSecs);
            
            
            % store in current data
            obj.currentData.type            = 'forced';
            obj.currentData.choice          = choice;
            obj.currentData.banditOnTime    = nan;
            obj.currentData.responseTime    = nan;
            obj.currentData.rewardOnTime    = nan;
            obj.currentData.forcedOnTime    = soundOn;
            obj.currentData.reward          = reward;
            obj.currentData.totalRew        = nan;
            
        end
        
        function freeTrial(obj, Lrew, Rrew)
            
            notify(obj, 'banditsOn');
            
            % wait for choice
            [KeyNum, when] = obj.waitForInput([1:2], GetSecs +Inf);
            notify(obj, 'choiceMade');
            
            switch KeyNum
                
                case 1 % chose left
                    
                    rewSound = obj.rewLeft(Lrew);
                    reward   = Lrew;
                    choice   = 1;
                    
                case 2 % chose right
                    
                    rewSound = obj.rewRight(Rrew);
                    reward   = Rrew;
                    choice   = 2;
                    
            end
            
            % play the sound
            [rewardOnTime, soundOff] = rewSound.playSound(GetSecs);
            notify(obj, 'rewardOn');
            
            % update total points
            obj.blockPoints = obj.blockPoints + reward;
            
            % store in current data
            obj.currentData.type            = 'free';
            obj.currentData.choice          = KeyNum;
            obj.currentData.banditOnTime    = nan;
            obj.currentData.responseTime    = when;
            obj.currentData.rewardOnTime    = rewardOnTime;
            obj.currentData.forcedOnTime    = nan;
            obj.currentData.reward          = reward;
            obj.currentData.totalRew        = obj.totalPoints;
            
        end
        
        function playGame(obj, game)
            
            forcedChoices   = game.forcedChoices;
            nFree           = game.nfree;
            Lrew            = game.rewards(1, :);
            Rrew            = game.rewards(2, :);
            
            nForced         = length(forcedChoices);
            
            
            % New game cue ------------------------------------------------
            obj.gameStartCue.playSound(GetSecs);
            WaitSecs(4);
            
            % Press space to start game -----------------------------------
            notify(obj, 'pressSpaceStartGame');
            %spaceOnTime = obj.pressSpaceCue.playSound(GetSecs);
            spaceOnTime = obj.goCue.playSound(GetSecs);
            
            obj.waitForInput([3], GetSecs + Inf);
            notify(obj, 'startGame');
            obj.currentData.spaceOnTime = spaceOnTime;
            WaitSecs(0.5);
            
            % Horizon cue on ----------------------------------------------
            notify(obj, 'horizonOn');
            switch nFree
                case 1
                    [horOnTime] = obj.hor1.playSound(GetSecs);
                case 6
                    [horOnTime] = obj.hor6.playSound(GetSecs);
            end
            obj.currentData.horOnTime = horOnTime;
            WaitSecs(4);
            
            % Press space to start forced trials --------------------------
            obj.goCue.playSound(GetSecs);
            obj.waitForInput([3], GetSecs + Inf);
            notify(obj, 'pressSpaceStartForced');
            
            
            % Forced choice trials ----------------------------------------
            for i = 1:length(forcedChoices)
                
                WaitSecs(0.5);
                
                obj.currentData.trialNum = i;
                obj.forcedTrial(forcedChoices(i), Lrew(i), Rrew(i));
                
                obj.storeData;
                
            end
            
            % Free choice trials ------------------------------------------
            WaitSecs(4);
            obj.goCue.playSound(GetSecs);
            notify(obj, 'startFree');
            
            for i = 1:nFree
                
                trialNum = i + nForced;
                
                obj.currentData.trialNum = i + nForced;
                obj.freeTrial(Lrew(trialNum), Rrew(trialNum));
                obj.storeData;
                
            end
            %WaitSecs(1);
            
            notify(obj, 'endGame');
            %obj.gameEndCue.playSound(GetSecs);
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
            
            notify(obj, 'startExperiment');
            obj.makeGameParameters;
            
            for blockNum = 1:numBlocks
                
                obj.blockPoints = 0;
                
                obj.talk(['Press space to begin block ' num2str(blockNum) '.']);
                Screen(obj.window, 'Flip');
                
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(0.5);
                
                notify(obj, 'startBlock');
                obj.fix.draw;
                Screen(obj.window, 'Flip');
                notify(obj, 'fixOn');
                
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
                
                notify(obj, 'endBlock');
                obj.saveData;
            end
            
            
            
            notify(obj, 'endExperiment');
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
            
            notify(obj, 'startExperiment');
            obj.makeGameParameters;
            
            for blockNum = 1:numBlocks
                
                obj.blockPoints = 0;
                
                obj.talk(['Press space to begin practice block ' num2str(blockNum) '.']);
                Screen(obj.window, 'Flip');
                
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(0.5);
                
                notify(obj, 'startBlock');
                obj.fix.draw;
                Screen(obj.window, 'Flip');
                notify(obj, 'fixOn');
                
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
                
                notify(obj, 'endBlock');
                obj.saveData;
            end
            
            
            notify(obj, 'endExperiment');
            %obj.moneyWon;
            obj.saveData;
            obj.talk(['This is the end of the practice.  ' ...
                'Press space to begin the game!']);
            
            Screen(obj.window, 'Flip');
            obj.waitForInput([3], GetSecs + Inf);
            
            
        end
        
        
        
    end
    
end





