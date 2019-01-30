classdef soundTask_v1 < handle
    
    properties
        
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
        
        % list of games
        game
        
        % data
        data
        currentData
        count
        
        % demographics stuff
        ans
        
    end
    
    events
        
        forcedOn
        banditsOn
        choiceMade
        rewardOn
        fixOn
        
        startExperiment
        startBlock
        startGame
        
        endGame
        endBlock
        endExperiment
        
    end
    
    methods
        
        function obj = soundTask_v1(stimdir, sounddir, datadir, savename)
            
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
                obj.data(i).gameNum          = [];
                obj.data(i).trialNum        = [];
                obj.data(i).type            = [];
                obj.data(i).choice          = [];
                obj.data(i).banditOnTime    = [];
                obj.data(i).responseTime    = [];
                obj.data(i).rewardOnTime    = [];
                obj.data(i).forcedOnTime    = [];
                obj.data(i).reward          = [];
                obj.data(i).totalRew        = [];
            end
            
        end
        
        function storeData(obj)
            
            obj.data(obj.count) = obj.currentData;
            obj.count = obj.count + 1;
            
        end
        
        function saveData(obj)
            
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
        
        
        % task functions ==================================================
        function setup(obj, bgColour)
            
            obj.setupPsychSound;
            obj.setRewards;
            obj.loadHorizonSounds;

            obj.setWindow(bgColour);
            obj.setTextParameters(45, 50, [1 1 1]*256);
            obj.setKeys({'1!' '2@' 'space' 'delete' 'p' 'q' '7&'});
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
            sca
            sampleRate = obj.sampleRate;
            
            for i = 1:100
                snd = wavread([obj.sounddir num2str(i) '.wav']);
                
                rewLeft(i)  = soundObject(obj.pahandle, obj.sampleRate);
                rewLeft(i).setSound([snd; snd*0]);
                
                rewRight(i) = soundObject(obj.pahandle, obj.sampleRate);
                rewRight(i).setSound([snd*0; snd]);
            end
            
            obj.rewLeft  = rewLeft;
            obj.rewRight = rewRight;
            
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
            var(i).type = 2;
            i=i+1;
            
            % \delta \mu
            var(i).x = [-10 -5 0 5 10];
            var(i).type = 1;
            i=i+1;
            
            % game length
            var(i).x = [5 10];
            var(i).type = 1;
            i=i+1;
            
            % ambiguity condition
            var(i).x = [1:3];
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
                        switch r
                            case 1
                                nForced = [1 1 1 2];
                            case 2
                                nForced = [1 1 2 1];
                            case 3
                                nForced = [1 2 1 1];
                            case 4
                                nForced = [2 1 1 1];
                        end
                        
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
                        switch r
                            case 1
                                nForced = [2 2 2 1];
                            case 2
                                nForced = [2 2 1 2];
                            case 3
                                nForced = [2 1 2 2];
                            case 4
                                nForced = [1 2 2 2];
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
            [soundOn, soundOff] = rewSound.playSound(GetSecs);
            notify(obj, 'forcedOn');
            
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
            
            notify(obj, 'startGame');
            
            forcedChoices   = game.forcedChoices;
            nFree           = game.nfree;
            Lrew            = game.rewards(1, :);
            Rrew            = game.rewards(2, :);
            
            nForced         = length(forcedChoices);
            
            obj.fix.draw;
            Screen(obj.window, 'Flip');
            notify(obj, 'fixOn');
            
            
            for i = 1:length(forcedChoices)
                
                obj.currentData.trialNum = i;
                obj.forcedTrial(forcedChoices(i), Lrew(i), Rrew(i));
                
                obj.storeData;
                
            end
            
            WaitSecs(1);
            
            for i = 1:nFree
                
                trialNum = i + nForced;
                
                obj.currentData.trialNum = i + nForced;
                obj.freeTrial(Lrew(trialNum), Rrew(trialNum));
                obj.storeData;
            
            end
            WaitSecs(1);
           
            notify(obj, 'endGame');
            
        end
        
        function run(obj, numBlocks, numGames)
            
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
                
                notify(obj, 'startBlock');
                    
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
            
            
        end
        
    end
    
end





