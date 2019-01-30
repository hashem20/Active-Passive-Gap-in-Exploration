classdef task_iso_v3 < task_basic_horizonInfo_v1
    
    properties
        
        stimDir
        datadir
        
        gameCount
        points
        TotalPoints
        valueCue
        infoAndValueCue
        language
            
    end
    
    events
        
        startExperiment
        endExperiment
        
        startBlock
        endBlock
        
        forcedOn
        
        startGame
        endGame
        
        startTrial
        endTrial
        
        banditsOn
        rewardOn
        
        %preFixationCrossOn
        %fixationCrossOn
        choiceMade
        %displayReward
        %tooSlowOn
        %
        %
        %signalledChange
        %inst_signalledChange
        
    end
    
    methods
        
        function obj = task_iso_v3(stimDir, datadir, language)
            
            obj.stimDir = stimDir;
            %obj.etStimDir = etStimDir; % stimDir for the calibration
            obj.datadir = datadir;
            obj.language = language;
            
        end

        function setup(obj, bgColour)
            
            obj.scaleFactor = 0.2;
            
            obj.setWindow(bgColour);
            obj.setTextParameters(45, 50, [1 1 1]*256);
            obj.setKeys({'1!' '2@' 'space' 'delete' 'p' 'q' '7&'});
            obj.setRewards;
            obj.makeFixationCross;
            obj.makeBandits([4 4]);
            obj.makeMoneyBar('dollarBill.png', 3);
            obj.makeRewardHistory([4 4]);
            obj.makeData;
            
            %obj.etSetWindow([0 0 0]*254);
            %obj.etMakeNumbers;
            %obj.etMakeFixationCross;
            obj.makeValueInfoSigns;
            obj.totalMax = 0;
            
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
            %var(i).x = [-10 -5 0 5 10];
            var(i).x = [-10 -6 -3 0 3 6 10];
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
            
            % info condition
            var(i).x = [1 2];
            var(i).type = 1;
            i=i+1;
            
            [var, T, N] = counterBalancer(var, 1);
            test_counterBalancing(var);
            
            mainMean = var(1).x_cb;
            mainBan = var(2).x_cb;
            deltaMu = var(3).x_cb;
            gameLength = var(4).x_cb;
            ambCond = var(5).x_cb;
            infoCond = var(6).x_cb;
            
            for j = 1:T
                
                obj.game(j).gameLength = gameLength(j);
                obj.game(j).infoCond = infoCond(j);
                %.............................
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
                
                
                obj.game(j).nforced = nForced;
                
                %.....................................
                obj.game(j).nfree = [gameLength(j) - 4];
                
                %.....................................
                sig_risk = 8;
%                 randn(hor,1)*sig_risk + mu;
                
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
        
        function makePracticeGameParameters(obj)
            
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
            %var(i).x = [-10 -5 0 5 10];
            var(i).x = [-10 -6 -3 0 3 6 10];
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
            
            % info condition
            var(i).x = [1 2];
            var(i).type = 1;
            i=i+1;
            
            [var, T, N] = counterBalancer(var, 1);
            test_counterBalancing(var);
            
            mainMean = var(1).x_cb;
            mainBan = var(2).x_cb;
            deltaMu = var(3).x_cb;
            gameLength = var(4).x_cb;
            ambCond = var(5).x_cb;
            infoCond = var(6).x_cb;
            
            for j = 1:T
                
                obj.practiceGame(j).gameLength = gameLength(j);
                obj.practiceGame(j).infoCond = infoCond(j);
                %.............................
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
                
                
                obj.practiceGame(j).nforced = nForced;
                
                %.....................................
                obj.practiceGame(j).nfree = [gameLength(j) - 4];
                
                %.....................................
                sig_risk = 8;
%                 randn(hor,1)*sig_risk + mu;
                
                if mainBan(j) == 1
                    mu(1) = mainMean(j);
                    mu(2) = [mainMean(j) + deltaMu(j)];
                elseif mainBan(j) == 2
                    mu(2) = mainMean(j);
                    mu(1) = [mainMean(j) + deltaMu(j)];
                end
                
                obj.practiceGame(j).mean = [mu(1); mu(2)];
                
                obj.practiceGame(j).rewards = ...
                    [(round(randn(gameLength(j),1)*sig_risk + mu(1)))'; ...
                    (round(randn(gameLength(j),1)*sig_risk + mu(2)))'];
                    
                
            end
            
        end
        
        
        function makeValueInfoSigns(obj)
            
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            win = obj.window;
            stimDir = obj.stimDir;
            
            switch obj.language
                case 'English'
                    obj.valueCue = picture(win, stimDir, 'valueOnly.png');
                    obj.infoAndValueCue = picture(win, stimDir, 'infoAndValue.png');
                case 'German'
                    obj.valueCue = picture(win, stimDir, 'valueOnly_german.png');
                    obj.infoAndValueCue = picture(win, stimDir, 'infoAndValue_german.png');
            end
            
            obj.valueCue.setup(1, [sw/2 sh/3.5]);
            obj.infoAndValueCue.setup(1, [sw/2 sh/3.5]);
            
            %obj.valueOnlyFix = picture(win, stimDir, 'valueOnlyWithFix.png');
            %obj.valueOnlyFix.setup(1, [sw/2 sh/3.5]);
            %obj.infoValueFix = picture(win, stimDir, 'infoAndValueWithFix.png');
            %obj.infoValueFix.setup(1, [sw/2 sh/3.5]);
            
        end
        
        
        function forcedTrial(obj, forcedTrials, Lrew, Rrew, rewHistL, rewHistR)
            
            rew = obj.rew;
            rewXX = obj.rewXX;
            % obj.mb.draw;
            rewHistL.draw;
            rewHistR.draw;
            
            if forcedTrials == 1
                
                rewHistL.addReward(rew(Lrew));
                rewHistR.addReward(rewXX);
                reward = Lrew;
                choice = 1;
                
            elseif forcedTrials == 2
                
                rewHistR.addReward(rew(Rrew));
                rewHistL.addReward(rewXX);
                reward = Rrew;
                choice = 2;
                
            end
            
            obj.currentData.type = 'forced';
            obj.currentData.choice = choice;
            obj.currentData.banditOnTime = nan;
            obj.currentData.responseTime = nan;
            obj.currentData.rewardOnTime = nan;
            obj.currentData.forcedOnTime = nan;
            obj.currentData.reward = reward;
            obj.currentData.totalRew = nan;
            
        end
        
        function freeTrial(obj, Lrew, Rrew, rewHistL, rewHistR, ...
                infoFlag, infoCond)
            
            rew = obj.rew;
            rewXX = obj.rewXX;
            if infoFlag
                switch infoCond
                    case 1
                        obj.valueCue.draw;
                    case 2
                        obj.infoAndValueCue.draw;
                end
                
            end
            
            obj.banL.draw;
            obj.banR.draw;
            obj.fix.draw;
            rewHistL.draw;
            rewHistR.draw;
            % obj.mb.draw;
            
                
            
            banditOnTime = Screen(obj.window, 'Flip');
            notify(obj, 'banditsOn');
            
            [KeyNum, when] = obj.waitForInput([1:2], GetSecs +Inf);
            notify(obj, 'choiceMade');
            
            
            if KeyNum == 1
                
                if infoFlag & (infoCond==1)
                    rrr = obj.rewQQ;
                else
                    rrr = rew(Lrew);
                end
                
                obj.banL.showRewardPlayed(rrr);
                reward = Lrew;
                rewHistL.addReward(rrr);
                rewHistR.addReward(rewXX);
                
            elseif KeyNum == 2
                
                if infoFlag & (infoCond==1)
                    rrr = obj.rewQQ;
                else
                    rrr = rew(Rrew);
                end
                
                obj.banR.showRewardPlayed(rrr);
                reward = Rrew;
                rewHistR.addReward(rrr);
                rewHistL.addReward(rewXX);
                
            end
            
            
            rewHistR.draw;
            rewHistL.draw;
            obj.fix.draw;
            %obj.mb.addReward(reward);
            % obj.mb.draw;
            
            rewardOnTime = Screen(obj.window, 'Flip');
            notify(obj, 'rewardOn');
            
            obj.currentData.type = 'free';
            obj.currentData.choice = KeyNum;
            obj.currentData.banditOnTime = banditOnTime;
            %obj.currentData.infoOnTime   = infoOnTime;
            obj.currentData.responseTime = when;
            obj.currentData.rewardOnTime = rewardOnTime;
            obj.currentData.forcedOnTime = nan;
            obj.currentData.reward = reward;
            obj.currentData.totalRew = obj.mb.R;
            
            obj.storeData;
            
            obj.points = obj.points + reward;
            
            WaitSecs(0.2);
            
        end
        
        
        
        function MakeGame(obj, blockNum, gameNum, game)
            
            %obj.fix.draw;
            %
            %Screen(obj.window, 'Flip', [], 1);
            
            
            % obj.mb.draw;
            forcedTrials = game.nforced;
            freeTrials = game.nfree;
            Lrew = game.rewards(1, :);
            Rrew = game.rewards(2, :);
            infoCond = game.infoCond;
            
            
            switch infoCond
                case 1
                    obj.valueCue.draw;
                case 2
                    obj.infoAndValueCue.draw;
            end
            obj.fix.draw;
            
            infoOnTime = Screen(obj.window, 'Flip');
            
            notify(obj, 'startGame');
            
            if freeTrials == 6
                
                obj.rewHistL = obj.rewHistL10;
                obj.rewHistR = obj.rewHistR10;
                
            elseif freeTrials == 1
                
                obj.rewHistL = obj.rewHistL5;
                obj.rewHistR = obj.rewHistR5;
            end
            
            
            for i = 1:length(forcedTrials)
                
                trialNum = i;
                
                obj.clearCurrentData;
                obj.currentData.block = blockNum;
                obj.currentData.game = gameNum; % game number within block
                obj.currentData.trial = trialNum;
                
                obj.forcedTrial(forcedTrials(i), Lrew(i), Rrew(i), obj.rewHistL, ...
                    obj.rewHistR);
                
                if i == length(forcedTrials)
                    switch infoCond
                        case 1
                            obj.valueCue.draw;
                        case 2
                            obj.infoAndValueCue.draw;
                    end
                    
                    obj.rewHistL.draw;
                    obj.rewHistR.draw;
                    obj.fix.draw;
                    obj.currentData.forcedOnTime = ...
                        Screen(obj.window, 'Flip', infoOnTime+1);
                    notify(obj, 'forcedOn');
                    
                end
                obj.currentData.infoOnTime   = infoOnTime;
            
                obj.storeData;
                
            end
            
            WaitSecs(1);
            
            for i = 1:freeTrials
                
                if i == 1
                    infoFlag = true;
                else
                    infoFlag = false;
                end
                
                trialNum = i + length(forcedTrials);
                
                obj.clearCurrentData;
                obj.currentData.block = blockNum;
                obj.currentData.game = gameNum;
                obj.currentData.trial = trialNum;
                
                obj.freeTrial(Lrew(trialNum), Rrew(trialNum), obj.rewHistL, ...
                    obj.rewHistR, infoFlag, infoCond);
                
            end
            WaitSecs(1);
           
            obj.rewHistL.flush;
            obj.rewHistR.flush;
            notify(obj, 'endGame');
            
        end
        
        function MakeBlock(obj, numBlocks, numGames, practice, calibrate)
            
            % practice game: practice = 1
            % real game: practice = 0
            
            saveName = 'iso_allie'
            
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
            
            %..............................................................
            obj.count = 1;
            obj.gameCount = 1;
            obj.points = 0;
            obj.TotalPoints = 0;
            
            if practice == 0
                notify(obj, 'startExperiment');
                obj.makeGameParameters;
            elseif practice == 1
                obj.makePracticeGameParameters;
            end
            
            for n = 1:numBlocks
                
                blockNum = n;
                
                obj.moneybarMax(...
                    [obj.gameCount:obj.gameCount+numGames-1], practice);
                obj.mb.setMaxReward(obj.max);
                obj.mb.resetToZero;
                
                switch obj.language
                    case 'English'
                        obj.talk(['Press space to begin block ' num2str(blockNum) '.']);
                    case 'German'
                        obj.talk(['Drücken Sie die Leertaste um Block ' num2str(blockNum) ' zu starten.']);
                end
                
                Screen(obj.window, 'Flip');
                obj.waitForInput([3], GetSecs + Inf);
                
                if practice == 0
                    notify(obj, 'startBlock');
                end
                    
                for i = 1:numGames
                    gameNum = i;
                    
                    if practice == 0
                        game = obj.game(obj.gameCount);
                    elseif practice == 1
                        game = obj.practiceGame(obj.gameCount);
                    end
                    
                    obj.MakeGame(blockNum, gameNum, game);
                    obj.gameCount = obj.gameCount + 1;
                end
                
                switch obj.language
                    case 'English'
                        obj.talk(['End of block ' num2str(blockNum) ' of ' ...
                            num2str(numBlocks) '. \n\n You won ' num2str(obj.points) ...
                            ' points! \n Press space to continue.']);
                    case 'German'
                        obj.talk(['Ende Block ' num2str(blockNum) ' von ' ...
                            num2str(numBlocks) '. \n\n Sie haben ' num2str(obj.points) ...
                            ' Punkte gewonnen! \n Weiter mit Leertaste.']);
                end
                
                obj.TotalPoints = (obj.TotalPoints + obj.points);
                Screen(obj.window, 'Flip');
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(1);
                
                if practice == 0
                    notify(obj, 'endBlock');
                end
                
                %if blockNum == calibrate
                %    obj.etReCalibrate;
                %    Screen ('Flip', obj.window);
                %    WaitSecs(2);
                %end
                    
                obj.points = 0;
                
                if practice == 0
                    obj.saveData;
                end
            end
            
            if practice == 1
                
                obj.clearCurrentData;
                obj.clearData;
                switch obj.language
                    case 'English'
                        obj.talk(['End of practice game. \n Press space to start '...
                            'the experiment.']);
                    case 'German'
                        obj.talk(['Ende der Übung. \n Leerstaste zum starten '...
                            'des Experiments.']);
                end
                Screen(obj.window, 'Flip');
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(1);
                
            end
            
            if practice == 0
                notify(obj, 'endExperiment');
                obj.moneyWon;
                obj.saveData;
                switch obj.language
                    case 'English'
                        obj.talk(['This is the end of the experiment. Thank you '...
                            'for participating!']);
                    case 'German'
                        obj.talk(['Ende des Experiments. Vielen Dank '...
                            'für Ihre Teilnahme!']);
                end
                Screen(obj.window, 'Flip');
                obj.waitForInput([7], GetSecs + Inf);
            end
            
        end
        
        function runInstructions(obj, nBandits)
            
            switch obj.language
                case 'English'
                    obj.runInstructionsEnglish(nBandits);
                case 'German'
                    obj.runInstructionsGerman(nBandits);
            end
            
        end
        
        function runInstructionsEnglish(obj, nBandits)
            
            [A, B] = Screen('WindowSize', obj.window);
            Screen ('Flip', obj.window);
            obj.nBandits = nBandits;
            
            count = 1;
            endFlag = 0;
            
            while ~endFlag
                
                DrawFormattedText(obj.window, ...
                    ['Page ' num2str(count) ' of 24'], ...
                    [],[B/1.07], obj.textColour, obj.textWidth);
                
                
                switch count
                    
                    case 1
                        % -------------------------------------------------
                        str = ['Welcome! Thank you for volunteering ' ...
                            'for this ' ...
                            'experiment!'];
                        obj.talkAndFlip(str);
                        
                    case 2
                        % -------------------------------------------------
                        str = ['In this experiment you will see stimuli '...
                            ' like these:'];
                        
                        obj.banL.draw;
                        obj.banR.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 3
                        % -------------------------------------------------
                        str = ['Each one of these stimuli represents a ' ...
                            'slot machine.  At any one time, you ' ...
                            'may choose to ' ...
                            'play one of the ' num2str(obj.nBandits) ...
                            ' slot machines for the chance ' ...
                            'to win between 1 and 100 points.'];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.talkAndFlip(str);
                        
                    case 4
                        % -------------------------------------------------
                        str = ['For example, in this case, the ' ...
                            'left slot machine is paying out 77 ' ...
                            'points.'];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.banL.showRewardPlayed(obj.rew(77));
                        obj.talkAndFlip(str);
                        
                    case 5
                        % -------------------------------------------------
                        
                        str = ['Your goal in this task is to ' ...
                            'choose between the slot machines to ' ...
                            'maximize your reward.'];
                        
                        obj.banL.draw;
                        obj.banR.draw;
                        
                        obj.talkAndFlip(str);
                        
                        
                    case 6
                        % -------------------------------------------------
                        
                        switch obj.nBandits
                            case 2
                                str = ['Use the numbers 1 and 2 ' ...
                                    'on the keyboard ' ...
                                    'to choose the slot machine you '...
                                    'want to play.\n' ...
                                    'Choose 1 for the left slot ' ...
                                    'machine.\n' ...
                                    'Choose 2 for the right ' ...
                                    'slot machine.'];
                            case 3
                                str = ['Use the numbers 4, 2 and 6 ' ...
                                    'on the number ' ...
                                    'pad to choose the slot machine you '...
                                    'want to play.\n' ...
                                    'Choose 4 for the top left slot ' ...
                                    'machine.\n' ...
                                    'Choose 2 for the middle ' ...
                                    'slot machine.\n' ...
                                    'Choose 6 for the top right slot ' ...
                                    'machine.'];
                            case 4
                                str = ['Use the numbers 1, 2, 4 and 5 ' ...
                                    'on the number ' ...
                                    'pad to choose the slot machine you '...
                                    'want to play.\n' ...
                                    'Choose 1 for the bottom left slot ' ...
                                    'machine.\n' ...
                                    'Choose 2 for the bottom right ' ...
                                    'slot machine\n' ...
                                    'Choose 4 for the top left slot ' ...
                                    'machine.\n' ...
                                    'Choose 5 for the top right slot ' ...
                                    'machine.'];
                        end
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.talkAndFlip(str);
                        
                        
                    case 7
                        % -------------------------------------------------
                        str = ['In each game, the average ' ...
                            'payoff from each slot machine is fixed, ' ...
                            'but on any given play there is ' ...
                            'variability in the exact amount. ' ...
                            ];
                        obj.banL.draw;
                        obj.banR.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 8
                        % -------------------------------------------------
                        str = ['For example, the mean payoff from ' ...
                            'the left slot machine might be 50 points ' ...
                            'but on any trial you might receive more ' ...
                            'or less than 50 points randomly - say 52 ' ...
                            'points on the first play ...'];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.banL.showRewardPlayed(obj.rew(52));
                        
                        obj.talkAndFlip(str);
                    case 9
                        % -------------------------------------------------
                        str = ['... 56 on the second ...' ...
                            ];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.banL.showRewardPlayed(obj.rew(56));
                        
                        obj.talkAndFlip(str);
                    case 10
                        % -------------------------------------------------
                        str = [...
                            ' ...and 45 on the third.'];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.banL.showRewardPlayed(obj.rew(45));
                        
                        obj.talkAndFlip(str);
                        
                    case 11
                        % -------------------------------------------------
                        str = ['This variability makes it difficult ' ...
                            'to figure out which is the best slot ' ...
                            'machine, but that is exactly what you ' ...
                            'need to do to maximize your payoff from ' ...
                            'the game.'];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.talkAndFlip(str);
                        
                    case 12
                        % -------------------------------------------------
                        str = ['' ...
                            'To help you make your decision, we''ll also ' ...
                            'show you your history of reward from each ' ...
                            'option in these bars ...'];
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                        
                    case 13
                        % -------------------------------------------------
                        str = ['' ...
                            'If you had received 54 from the right option ' ...
                            'on the ' ...
                            'first trial of a game this is what you would ' ...
                            'see. '];
                        
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        obj.rewHistR5.addReward(obj.rew(54));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        %obj.obj.tsk.bandit(1).showRewardPlayed(obj.obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 14
                        % -------------------------------------------------
                        str = ['' ...
                            'If you play the same option again and see ' ...
                            'a reward of 58 you see this ...'];
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        
                        obj.rewHistR5.addReward(obj.rew(54));
                        obj.rewHistL5.addReward(obj.rewXX);

                        obj.rewHistR5.addReward(obj.rew(58));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 15
                        % -------------------------------------------------
                        str = ['' ...
                            'After several plays you might see something ' ...
                            'like this ... your job is to use this ' ...
                            'information to get the most number of points ' ...
                            'over the whole game.'];
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        
                        obj.rewHistR5.addReward(obj.rew(54));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(58));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(49));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(32));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 16
                        % -------------------------------------------------
                        str = ['' ...
                            'In addition to showing you past results ' ...
                            'these bars also show you how many trials ' ...
                            'are in a game. In this experiment you''ll ' ...
                            'play games of length 5 trials ...'];
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 17
                        % -------------------------------------------------
                        str = ['' ...
                            '... and games of length 10 trials.'];
                        
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL10.draw;
                        obj.rewHistR10.draw;
                        
                        obj.talkAndFlip(str);
                        
                        
                    case 18
                        % -------------------------------------------------
                        str = ['To keep things interesting, at the end of ' ...
                            'a game the mean payoff of both slot ' ...
                            'machines changes. When this happens ' ...
                            'the screen will go blank and you will ' ...
                            'only see a cross. '];
                        obj.fix.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 19
                        % -------------------------------------------------
                        str = ['' ...
                            'At the beginning of each game the computer '...
                            'will play the slot machines randomly four times to ' ...
                            'give you information about both options. '...
                            'We will show you these plays like this.'];
                        
                        obj.rewHistL5.addReward(obj.rew(44));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(51));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(49));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(39));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                    
                    case 20
                        % -------------------------------------------------
                        str = ['There will then be a pause before the slot '...
                            'machines appear and you can make your choices.'];
                        
                        obj.rewHistL5.addReward(obj.rew(44));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(51));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(49));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(39));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 21
                        
                        % -------------------------------------------------
                        str = ['On the first free choice trial,' ...
                            ' there are two possibilities: ' ...
                            '(1) You''ll be able to get the value of ' ...
                            'your choice, but won''t actually see the ' ...
                            'outcome. We call this a "Value only" trial.' ...
                            ];
                        
                        %obj.tsk.bandit(1).showReward(obj.tsk.rew(75));
                        obj.rewHistL5.addReward(obj.rew(44));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(51));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(49));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(39));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.valueCue.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        
                        obj.talkAndFlip(str);
                        
                     case 22
                        % -------------------------------------------------
                        str = ['(2) You''ll see the value of your choice ' ...
                            'and it will also be added to your total ' ...
                            'score. We call this an "Info + Value" trial.' ...
                            ];
                        
                        %obj.tsk.bandit(1).showReward(obj.tsk.rew(75));
                        obj.rewHistL5.addReward(obj.rew(44));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(51));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(49));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(39));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.infoAndValueCue.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        obj.talkAndFlip(str);
                        
                        
                        
                        % % -------------------------------------------------
                        % str = ['During the course of the game you will '...
                        %     'see a bar on the side that increases with each '...
                        %     'reward.'];
                        % obj.mb.setMaxReward(1000);
                        % obj.mb.addReward(250);
                        % obj.mb.draw;
                        % obj.talkAndFlip(str);
                        
                    case 23
                        % -------------------------------------------------
                        str = ['Next we''ll play a practice game to ' ...
                            'make sure you''ve got the rules. Good ' ...
                            'luck and thanks again for volunteering!'];
                        obj.banL.draw;
                        obj.banR.draw;
                        
                        obj.talkAndFlip(str);
                        
                        
                    case 24
                        % -------------------------------------------------
                        str = ['Press space to start the practice game.' ...
                            ];
                        obj.talkAndFlip(str);
                        endFlag = 1;
                        
                end
                [KeyNum, when] = obj.waitForInput([3:6], Inf);
                switch KeyNum
                    
                    case 3
                        count = count + 1;
                        
                    case 4
                        count = count - 1;
                        if count < 1
                            count = 1;
                        end
                        endFlag = 0;
                        
                    case 5
                        
                        endFlag = 1;
                        
                    case 6
                        
                        error('User requested escape!  Bye-bye!');
                        
                end
                
                
                obj.rewHistL5.flush;
                obj.rewHistL10.flush;
                obj.rewHistR5.flush;
                obj.rewHistR10.flush;
                obj.mb.resetToZero;
                
            end
            
        end
        
        function runInstructionsGerman(obj, nBandits)
            
            [A, B] = Screen('WindowSize', obj.window);
            Screen ('Flip', obj.window);
            obj.nBandits = nBandits;
            
            count = 1;
            endFlag = 0;
            
            while ~endFlag
                
                DrawFormattedText(obj.window, ...
                    ['Seite ' num2str(count) ' von 24'], ...
                    [],[B/1.07], obj.textColour, obj.textWidth);
                
                
                switch count
                    
                    case 1
                        % -------------------------------------------------
                        str = ['Herzlich Willkommen! Vielen Dank für die Teilnahme ' ...
                            'an diesem ' ...
                            'Experiment!'];
                        obj.talkAndFlip(str);
                        
                    case 2
                        % -------------------------------------------------
                        str = ['In diesem Experiment sehen Sie Bilder von zwei Spielautomanten.'];
                        obj.banL.draw;
                        obj.banR.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 3
                        % -------------------------------------------------
                        str = ['Ihre Aufgabe ist es ' ...
                            'einen der Automaten ' ...
                            'auszuwählen. ' ...
                            'In Abhängigkeit von Ihrer Entscheidung haben Sie die Möglichkeit' ...
                            ' zwischen 1 und 100 Punkten zu gewinnen.'];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.talkAndFlip(str);
                        
                    case 4
                        % -------------------------------------------------
                        str = ['In diesem Beispiel zahlt der linke ' ...
                            'Automat 77 Punkte aus. '];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.banL.showRewardPlayed(obj.rew(77));
                        obj.talkAndFlip(str);
                        
                    case 5
                        % -------------------------------------------------
                        
                        str = ['Ihre Aufgabe ist es den Automaten auszuwählen, der die ' ...
                            'maximale Punktzahl auszahlt.'];
                        
                        obj.banL.draw;
                        obj.banR.draw;
                        
                        obj.talkAndFlip(str);
                        
                        
                    case 6
                        % -------------------------------------------------
                        
                        switch obj.nBandits
                            case 2
                                str = ['Benutzen Sie die Zahlen 1 and 2 ' ...
                                    'auf der Tastatur ' ...
                                    'um einen Automaten auszuwählen.\n' ...
                                    'Drücken Sie 1 für den linken ' ...
                                    'Automaten.\n' ...
                                    'Drücken Sie 2 für den rechten ' ...
                                    'Automaten.'];
                            case 3
                                str = ['Use the numbers 4, 2 and 6 ' ...
                                    'on the number ' ...
                                    'pad to choose the slot machine you '...
                                    'want to play.\n' ...
                                    'Choose 4 for the top left slot ' ...
                                    'machine.\n' ...
                                    'Choose 2 for the middle ' ...
                                    'slot machine.\n' ...
                                    'Choose 6 for the top right slot ' ...
                                    'machine.'];
                            case 4
                                str = ['Use the numbers 1, 2, 4 and 5 ' ...
                                    'on the number ' ...
                                    'pad to choose the slot machine you '...
                                    'want to play.\n' ...
                                    'Choose 1 for the bottom left slot ' ...
                                    'machine.\n' ...
                                    'Choose 2 for the bottom right ' ...
                                    'slot machine\n' ...
                                    'Choose 4 for the top left slot ' ...
                                    'machine.\n' ...
                                    'Choose 5 for the top right slot ' ...
                                    'machine.'];
                        end
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.talkAndFlip(str);
                        
                        
                    case 7
                        % -------------------------------------------------
                        str = ['In jedem Spiel gibt es einen "besseren" ' ...
                            '(mehr Punkte) Automaten und einen "schlechteren" (weniger Punkte) ' ...
                            'Automaten. Die Auszahlung beider Automaten verändert sich ' ...
                            'von einem Spieldurchgang zum nächsten. ' ...
                            ];
                        obj.banL.draw;
                        obj.banR.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 8
                        % -------------------------------------------------
                        str = ['Zum Beispiel kann es sein, dass ' ...
                            'die durchschnittliche Auszahlung des linken Automaten ' ...
                            '50 Punkte beträgt und, dass man beim ersten Spielzug ' ...
                            'zufällig mehr oder weniger als 50 Punkte - z.B. 52 ' ...
                            'Punkte erhält ...'];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.banL.showRewardPlayed(obj.rew(52));
                        
                        obj.talkAndFlip(str);
                    case 9
                        % -------------------------------------------------
                        str = ['...oder 56 Punkte beim zweiten Spielzug' ...
                            ];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.banL.showRewardPlayed(obj.rew(56));
                        
                        obj.talkAndFlip(str);
                    case 10
                        % -------------------------------------------------
                        str = [...
                            ' ...und 45 Punkte beim dritten Zug.'];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.banL.showRewardPlayed(obj.rew(45));
                        
                        obj.talkAndFlip(str);
                        
                    case 11
                        % -------------------------------------------------
                        str = ['Aufgrund dieser Veränderungen kann es schwierig ' ...
                            'sein den besseren Automaten zu erkennen.' ...
                            '\n \n Ihre Aufgabe ist es möglichst viele Punkte zu erzielen.'];
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.talkAndFlip(str);
                        
                    case 12
                        % -------------------------------------------------
                        str = ['' ...
                            'Um Ihnen bei Ihrer Entscheidung zu helfen, werden Ihnen ' ...
                            'die Ergebnisse Ihrer letzten Entscheidungen ' ...
                            'in den zwei Balken angezeigt.'];
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                        
                    case 13
                        % -------------------------------------------------
                        str = ['' ...
                            'Sollten Sie im ersten Durchgang 54 Punkte vom rechten ' ...
                            'Automaten erhalten haben, ' ...
                            'wird Ihnen das Ergebnis wie im Beispiel dargestellt. '];
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        obj.rewHistR5.addReward(obj.rew(54));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        %obj.obj.tsk.bandit(1).showRewardPlayed(obj.obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 14
                        % -------------------------------------------------
                        str = ['' ...
                            'Wenn Sie denselben Automaten nochmal wählen erhalten Sie z.B. ' ...
                            'eine Belohnung von 58 Punkten.'];
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        
                        obj.rewHistR5.addReward(obj.rew(54));
                        obj.rewHistL5.addReward(obj.rewXX);

                        obj.rewHistR5.addReward(obj.rew(58));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 15
                        % -------------------------------------------------
                        str = ['' ...
                            'Nach vier Durchgängen müssen Sie selbst wählen. ' ...
                            'Ihre Aufgabe ist es die angegebenen  ' ...
                            'Informationen zu nutzen um soviele Punkte wie möglich zu erzielen.'];
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        
                        obj.rewHistR5.addReward(obj.rew(54));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(58));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(49));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(32));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 16
                        % -------------------------------------------------
                        str = ['' ...
                            'Zusätzlich zu den Ergebnissen ihrer letzten Entscheidungen ' ...
                            'zeigen Ihnen die Balken auch an, wieviele Züge das jeweilige ' ...
                            'Spiel hat. In diesem Spiel werden Sie fünf Spielzüge durchlaufen.'];
                        obj.rewHistL5.flush;
                        obj.rewHistR5.flush;
                        
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 17
                        % -------------------------------------------------
                        str = ['' ...
                            '... in diesem Spiel zehn Züge'];
                        
                        %obj.tsk.bandit(1).showRewardPlayed(obj.tsk.rew(75));
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.rewHistL10.draw;
                        obj.rewHistR10.draw;
                        
                        obj.talkAndFlip(str);
                        
                        
                    case 18
                        % -------------------------------------------------
                        str = ['Die durchschnittliche Auszahlung verändert sich nach jedem Durchgang. ' ...
                            'Dies wird Ihnen durch ein weißes Kreuz ' ...
                            'auf dem Bildschirm angezeigt.'];
                        obj.fix.draw;
                        
                        obj.talkAndFlip(str);
                        
                    case 19
                        % -------------------------------------------------
                        str = ['' ...
                            'Am Anfang jedes Durchganges '...
                            'triff der Computer für Sie die ersten vier Entscheidungen, ' ...
                            'damit Sie ausreichend Informationen über die beiden Automaten haben. '];
                        
                        obj.rewHistL5.addReward(obj.rew(44));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(51));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(49));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(39));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.fix.draw; %hab ich gemacht
                        
                        obj.talkAndFlip(str);
                        
                        
                       
                    
                    case 20
                        % -------------------------------------------------
                        str = ['Sobald die beiden Automaten auf dem Bildschirm erscheinen '...
                            'können Sie Ihre Entscheidung treffen.'];
                        
                        obj.rewHistL5.addReward(obj.rew(44));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(51));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(49));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(39));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.fix.draw; %hier auch
                        
                        obj.talkAndFlip(str);
                        
                        
                        
                    case 21
                        
                        % -------------------------------------------------
                        str = ['Bei Ihrem ersten freien Zug gibt es zwei Möglichkeiten: ' ...
                            '\n \n Möglichkeit 1: Sie bekommen die Punkte eines Spielzuges gutgeschrieben; ' ...
                            'wir geben Ihnen aber keine Information über die Höhe der Punktzahl. ' ...
                            'Dies nennen wir einen "Nur Punkte" Spielzug.' ...  
                            ];
                        
                        
                        %obj.tsk.bandit(1).showReward(obj.tsk.rew(75));
                        obj.rewHistL5.addReward(obj.rew(44));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(51));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(49));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(39));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.valueCue.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                        
                        obj.fix.draw; %hab ich gemacht
                        
                        
                        obj.talkAndFlip(str);
                        
                     case 22
                        % -------------------------------------------------
                        str = ['Möglichkeit 2: Sie bekommen Ihre Punkte gutgeschrieben und wir informieren Sie über die  ' ...  %Auch mit Ben besprechen!
                            'Höhe der Punktzahl. ' ...
                            'Wir nennen dies einen "Info und Punkte" Spielzug.' ...
                            ];
                        
                        %obj.tsk.bandit(1).showReward(obj.tsk.rew(75));
                        obj.rewHistL5.addReward(obj.rew(44));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(51));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.rewHistR5.addReward(obj.rew(49));
                        obj.rewHistL5.addReward(obj.rewXX);
                        
                        obj.rewHistL5.addReward(obj.rew(39));
                        obj.rewHistR5.addReward(obj.rewXX);
                        
                        obj.banL.draw;
                        obj.banR.draw;
                        obj.infoAndValueCue.draw;
                        obj.rewHistL5.draw;
                        obj.rewHistR5.draw;
                       
                        obj.fix.draw; %hab ich gemacht
                        
                        obj.talkAndFlip(str);
                        
                        
                        
                        
                        % % -------------------------------------------------
                        % str = ['During the course of the game you will '...
                        %     'see a bar on the side that increases with each '...
                        %     'reward.'];
                        % obj.mb.setMaxReward(1000);
                        % obj.mb.addReward(250);
                        % obj.mb.draw;
                        % obj.talkAndFlip(str);
                        
                    case 23
                        % -------------------------------------------------
                        str = ['Sie haben nun die Möglichkeit einen Übungsdurchgang zu durchlaufen, ' ...
                            'um sicherzustellen, dass Sie die Regeln verstanden haben. ' ...
                            'Viel Erfolg!'];
                        obj.banL.draw;
                        obj.banR.draw;
                       
                        obj.fix.draw;
                        
                        obj.talkAndFlip(str);
                        
                        
                    case 24
                        % -------------------------------------------------
                        str = ['Sie starten das Übungsspiel mit der Leertaste.' ...
                            ];
                        obj.talkAndFlip(str);
                        endFlag = 1;
                        
                end
                [KeyNum, when] = obj.waitForInput([3:6], Inf);
                switch KeyNum
                    
                    case 3
                        count = count + 1;
                        
                    case 4
                        count = count - 1;
                        if count < 1
                            count = 1;
                        end
                        endFlag = 0;
                        
                    case 5
                        
                        endFlag = 1;
                        
                    case 6
                        
                        error('User requested escape!  Bye-bye!');
                        
                end
                
                
                obj.rewHistL5.flush;
                obj.rewHistL10.flush;
                obj.rewHistR5.flush;
                obj.rewHistR10.flush;
                obj.mb.resetToZero;
                
            end
            
        end
    end
end
        
