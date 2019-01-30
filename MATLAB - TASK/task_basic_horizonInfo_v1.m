classdef task_basic_horizonInfo_v1 < demographics_iso% & showCalibrationScreen
    
    properties
        
        keys
        
        bandit
        nBandits
        banditPositions
        
        fix
        mb
        max
        totalMax
        
        banL
        banR
%         banLplayed
%         banRplayed
        rew
        rewXX
        rewQQ
        
        rewHistL
        rewHistR
        rewHistL10
        rewHistR10
        rewHistL5
        rewHistR5
        
        game
        practiceGame
        
        money
        
        count
        data
        currentData
        
        saveName
        dateAndTime
        computerName
        
    end
    
    methods
        
        function obj = task_basic_horizonInfo_v1
            
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
                rew(i) = picture(obj.window, obj.stimDir, [num2str(i) '.png']);
                rew(i).setup(sfN, [sw/2 sh/2]);
            end
            
            obj.rew = rew;
            obj.rewXX = picture(obj.window, obj.stimDir, 'XX.png');
            obj.rewXX.setup(sfXX, [sw/2 sh/2]);
            obj.rewQQ = picture(obj.window, obj.stimDir, 'QQ.png');
            obj.rewQQ.setup(sfXX, [sw/2 sh/2]);
            
        end
        
        function makeFixationCross(obj)
            
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            win = obj.window;
            stimDir = obj.stimDir;
            
            obj.fix = picture(win, stimDir, 'Fix.png');
            obj.fix.setup(1, [sw/2 sh/3.5]);
            
        end
        
        function makeBandits(obj, banditNum)
                        
            % banditNum = vector of numbers for the names of the bandit
            % files
            
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            
            num1 = banditNum(1);
            num2 = banditNum(2);
            
            % Make left and right bandits
            obj.banL = bandit_allie(obj.window, obj.stimDir, ['bandit' num2str(num1) '.png'], num1);
            obj.banL.setup(1, obj.bgColour);
            obj.banL.setPosition([sw/4 sh/3.5]);
            obj.banL.playedBandit;
            
            obj.banR = bandit_allie(obj.window, obj.stimDir, ['bandit' num2str(num2) '.png'], num2);
            obj.banR.setup(1, obj.bgColour);
            obj.banR.setPosition([sw/1.3 sh/3.5]);
            obj.banR.playedBandit;
            
            % Make played left and right bandits
%             obj.banLplayed = bandit_allie(obj.window, obj.stimDir, ['playedBandit' num2str(num1) '.png']);
%             obj.banLplayed.setup(1, obj.bgColour);
%             obj.banLplayed.setPosition([sw/4 sh/3.5]);
%             
%             obj.banRplayed = bandit_allie(obj.window, obj.stimDir, ['playedBandit' num2str(num2) '.png']);
%             obj.banRplayed.setup(1, obj.bgColour);
%             obj.banRplayed.setPosition([sw/1.3 sh/3.5]);
            
        end
        
        function makeMoneyBar(obj, mbName, dollarsPerBlock)
            
            obj.mb = moneyBar_allie(obj.window, obj.stimDir, ...
                mbName, obj.bgColour);
            obj.mb.setup (dollarsPerBlock, obj.screenHeight, obj.screenWidth, obj.screenCenter);
            obj.mb.setToRightEdge;
            
        end
        
        function moneybarMax(obj, gameInds, practice)
            
            n = 1;
            
            for i = gameInds
                
                if practice == 0
                    game = obj.game(i);
                elseif practice == 1
                    game = obj.practiceGame(i);
                end
                
                for j = 5:game.gameLength
                    
                    if game.rewards(1,j) > game.rewards(2,j)
                        a(n) = game.rewards(1,j);
                    else
                        a(n) = game.rewards(2,j);
                    end
                    
                    n = n + 1;
                end
            end
            
            obj.max = sum(a);
            
            if practice == 0
                obj.totalMax = obj.totalMax + obj.max;
            end
            
        end
        
        function moneyWon(obj)
            
            obj.money = (obj.TotalPoints/obj.totalMax)*12;
%             obj.talk(['\n You won $' num2str(round(obj.money)) '!']);
            
        end
        
        function makeRewardHistory(obj, rewHistNum)
                        
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            
            numL = rewHistNum(1);
            numR = rewHistNum(2);
            
            lx = sw*0.4;
            rx = sw*0.6;
            
            obj.rewHistL10 = rewardHistory_allie(obj.window, obj.stimDir, 10, 1);
            obj.rewHistL10.setup(['rewHistBackground' num2str(numL) '.png'], 'blankNumber.png', 1);
            obj.rewHistL10.setPositionByTop([lx sh/30]);
            
            obj.rewHistR10 = rewardHistory_allie(obj.window, obj.stimDir, 10, 1);
            obj.rewHistR10.setup(['rewHistBackground' num2str(numR) '.png'], 'blankNumber.png', 1);
            obj.rewHistR10.setPositionByTop([rx sh/30]);
            
            obj.rewHistL5 = rewardHistory_allie(obj.window, obj.stimDir, 5, 1);
            obj.rewHistL5.setup(['rewHistBackground' num2str(numL) '.png'], 'blankNumber.png', 1);
            obj.rewHistL5.setPositionByTop([lx sh/30]);
            
            obj.rewHistR5 = rewardHistory_allie(obj.window, obj.stimDir, 5, 1);
            obj.rewHistR5.setup(['rewHistBackground' num2str(numR) '.png'], 'blankNumber.png', 1);
            obj.rewHistR5.setPositionByTop([rx sh/30]);
            
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
            
            for j = 1:T
                
                mainMean = var(1).x_cb;
                mainBan = var(2).x_cb;
                deltaMu = var(3).x_cb;
                gameLength = var(4).x_cb;
                ambCond = var(5).x_cb;
                
                obj.game(j).gameLength = gameLength(j);
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
        
        function makePracticeParameters(obj)
            
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
            
            for j = 1:6
                
                mainMean = var(1).x_cb;
                mainBan = var(2).x_cb;
                deltaMu = var(3).x_cb;
                gameLength = var(4).x_cb;
                ambCond = var(5).x_cb;
                
                obj.practiceGame(j).gameLength = gameLength(j);
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
                
                obj.practiceGame(j).rewards = [(round(randn(gameLength(j),1)*sig_risk...
                    + mu(1)))'; (round(randn(gameLength(j),1)*sig_risk + mu(2)))'];
                    
            end
        
        end
            
        function makeData(obj)
            
            obj.data.block = [];
            obj.data.game = [];
            obj.data.trial = [];
            obj.data.type = [];
            obj.data.choice = [];
            obj.data.banditOnTime = [];
            obj.data.infoOnTime = [];
            obj.data.responseTime = [];
            obj.data.rewardOnTime = [];
            obj.data.forcedOnTime = [];
            obj.data.reward = [];
            obj.data.totalRew = [];
            
            obj.currentData.block = [];
            obj.currentData.game = [];
            obj.currentData.trial = [];
            obj.currentData.type = [];
            obj.currentData.choice = [];
            obj.currentData.banditOnTime = [];
            obj.currentData.infoOnTime = [];
            obj.currentData.responseTime = [];
            obj.currentData.rewardOnTime = [];
            obj.currentData.forcedOnTime = [];
            obj.currentData.reward = [];
            obj.currentData.totalRew = [];
            
        end
        
        function clearCurrentData(obj)
            
            obj.currentData.block = [];
            obj.currentData.game = [];
            obj.currentData.trial = [];
            obj.currentData.type = [];
            obj.currentData.choice = [];
            obj.currentData.banditOnTime = [];
            obj.currentData.infoOnTime = [];
            obj.currentData.responseTime = [];
            obj.currentData.rewardOnTime = [];
            obj.currentData.forcedOnTime = [];
            obj.currentData.reward = [];
            obj.currentData.totalRew = [];
            
        end
        
        function clearData(obj)
            
            for i = 1:length(obj.data)
                obj.data(i).block = [];
                obj.data(i).game = [];
                obj.data(i).trial = [];
                obj.data(i).type = [];
                obj.data(i).choice = [];
                obj.data(i).banditOnTime = [];
                obj.data(i).infoOnTime = [];
                obj.data(i).responseTime = [];
                obj.data(i).rewardOnTime = [];
                obj.data(i).forcedOnTime = [];
                obj.data(i).reward = [];
                obj.data(i).totalRew = [];
            end
            
        end
        
        function storeData(obj)
            
            obj.data(obj.count) = obj.currentData;
            obj.count = obj.count + 1;
            
        end
        
        function saveData(obj)
            
            data = obj.data;
            TotalPoints = obj.TotalPoints;
            totalMax = obj.totalMax;
            answers = obj.ans;
            game = obj.game;
            money = round(obj.money);
            %locations = obj.locations;
            
            save([obj.datadir obj.saveName], 'data', 'TotalPoints', 'answers',...
                'game', 'totalMax', 'money');%, 'locations');
            
        end
        
        function makeTooSlow(obj)
            
            win = obj.window;
            stimDir = obj.stimDir;
            
            obj.tooSlow = picture(win, stimDir, 'Slow.png');
            obj.tooSlow.setup(obj.scaleFactor);
            
        end
        
        function makeGameChange(obj)
            
            win = obj.window;
            stimDir = obj.stimDir;
            
            obj.gameChange = picture(win, stimDir, 'gameChange.png');
            obj.gameChange.setup(obj.scaleFactor);
            
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
        
        function drawOutcome(obj, r, choice)
            
            %for i = 1:obj.nBandits
            %    obj.bandit(i).draw;
            %end
            obj.bandit(choice).showReward(obj.rew(r));
            
        end
        
        function drawChange(obj, whichBandit, nRew)
            
            % sample nRew rewards and display them
            for i = 1:obj.nBandits
                obj.bandit(i).draw;
            end
            
            if nRew > 0
                
                r = obj.S.sampleReward(whichBandit, nRew);
                obj.bandit(whichBandit).signalChange(obj.rew(r));
                
            else
                
                obj.bandit(whichBandit).signalChange([]);
                
            end
            
            
        end
                
        function computeBanditPositions(obj, Rx, Ry)
            
            
            if ( exist('Rx') == 1 ) & (exist('Ry') == 1)
                
                obj.Rx = Rx;
                obj.Ry = Ry;
                
            else
                
                % phi is phase offset
                obj.Rx = obj.screenWidth / 4;
                obj.Ry = obj.screenHeight / 4;
                
                Rx = obj.Rx;
                Ry = obj.Ry;
            end
            
            nB = obj.nBandits;
            
            switch nB
                
                case 2
                    phi = 0;
                case 3
                    phi = pi/2;
                case 4
                    phi = pi/4;
                otherwise
                    
                    phi = pi/nB;
            end
            
            screenCenter = obj.screenCenter;
            
            theta = 2 * pi * [0:nB-1] / nB + phi;
            
            for i = 1:nB
                obj.banditPositions(i,:) ...
                    = [Rx Ry].*[cos(theta(i)) sin(theta(i))] ...
                    + screenCenter;
            end
        end
        
        function talkAndFlip(obj, str, pTime)
            
            [A, B] = Screen('WindowSize', obj.window);
            
            if exist('pTime') ~= 1
                pTime = 0.3;
            end
            [nx, ny] = DrawFormattedText(obj.window, ...
                ['\n\n' str], ...
                'center',[B/2], obj.textColour, obj.textWidth);
            Screen('TextSize', obj.window,round(obj.textSize/3*2));
            switch obj.language
                case 'English'
                    DrawFormattedText(obj.window, ...
                        ['' ...
                        'Press space to continue or delete to go back'], ...
                        'center', [B/1.1], [150 150 150], obj.textWidth);
                case 'German'
                    DrawFormattedText(obj.window, ...
                        ['' ...
                        'Weiter mit Leertaste oder zurück mit Löschen'], ...
                        'center', [B/1.1], [150 150 150], obj.textWidth);
            end
            Screen('TextSize', obj.window,obj.textSize);
            Screen(obj.window, 'Flip');
            WaitSecs(pTime);
            
        end
    end
end
