classdef task_infiniteBandits < handle
    
    properties
        
        % subject number
        subjectID
        
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
        g_rew
        
        points
        totalPoints
        blockPoints
        totalMoney
        blockMoney
        totalMax
        money
        
        % money bar
        mb
        
        % bandits
        C_ban
        U_ban
        
        % game start / end cues
        gameStartCue
        gameEndCue
        pressSpaceCue
        goCue
        
        
        % list of games
        game
        
        % demographics stuff
        ans
        eye
    end
    
    methods
        
        
        function obj = task_infiniteBandits(stimdir, datadir, savename, subjectID, eye)
            obj.eye = eye;
            
            obj.stimdir = stimdir;
            obj.datadir = datadir;
%             obj.makeSaveName(savename);
            obj.saveName = savename;
            obj.subjectID = subjectID;
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
                ['\n' str], ...
                0.05*A,[B*0.033], obj.textColour, obj.textWidth);
           
                
            Screen('TextSize', obj.window,round(obj.textSize));
            DrawFormattedText(obj.window, ...
                ['' ...
                'Press space to continue or delete to go back'], ...
                'center', [B*0.91], obj.textColour, obj.textWidth);
            
            
            Screen('TextSize', obj.window,obj.textSize);
            Screen(obj.window, 'Flip');
            WaitSecs(pTime);
            
        end
        
        function setWindow(obj, bgColour,window, screenCenter, sw, sh)
            
            whichScreen = 0;
            
%             [window, rect] = Screen('OpenWindow', whichScreen, bgColour);
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
            Screen('TextFont', obj.window, 'Arial');
            Screen('TextStyle', obj.window, 0);
            
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
            obj.fix.setup(1, [sw/2 sh/2]);
            
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
        
        % demographics ====================================================
        function demographicQuestionCommand_OLD(obj)
            
            x = 0;
            
            while x ~= 1
                obj.ans.age = input('What is your age? ');
                obj.ans.gender = input('What is your gender? ', 's');
                obj.ans.math = input('How many college level math classes have you taken? ');
                
                x = input('Is this information correct? Type 0 for no and 1 for yes ');
            end
            
        end
        
        function demographicQuestionCommand(obj)
            obj.ans = getDemographics_v1(obj.window);
        end
        
        function inputSubjectNumber(obj)
            out = getSubjectID(obj.window);
            
            obj.subjectID = str2num(out.subjectID);
            if isempty(obj.subjectID) 
                % if input was not a number - assign subjectID randomly
                obj.subjectID = round(rand)+10000;
            end
            %obj.sessionNum = out.sessionNum;
            %
            %if isempty(obj.sessionNum) | (length(obj.sessionNum)>1)
            %    sca
            %    error('Try again - enter a session number')
            %end
            
            % make the filename for the data
            ds = datestr(now);
            ds(ds==':') = [''];
            ds(ds==' ') = '_';
            ds(ds=='-') = '';
            obj.saveName = ['INF' num2str(obj.subjectID) '_' ds];
            
        end
        
        
        % instructions ====================================================
        function instructionList(obj)
            
            i = 0;
            
            i=i+1; ev{i} = 'blank';      iStr{i} = 'Welcome! Thank you for volunteering for this experiment.';
            i=i+1; ev{i} = 'L_R';        iStr{i} = 'The task you will perform involves playing a series of games in which you have to make decisions about which of two boxes to open - a box on the left and the box on the right.';
            i=i+1; ev{i} = 'L_R75';      iStr{i} = 'Every time you open a particular box you get between 1 and 100 points.  For example, here the right option is paying out 75 points.  Your job is to make the best choices you can to maximize the number of points you earn.';
            i=i+1; ev{i} = 'L_R';        iStr{i} = 'Press <- to open the left box and -> to open the right box.';
            i=i+1; ev{i} = 'L_RQQ';      iStr{i} = 'One of the boxes is labelled with two question marks, ??, and gives completely random rewards, i.e. if you open it, any reward between 1 and 100 points is possible.';
            i=i+1; ev{i} = 'LG64_RQQ';   iStr{i} = 'The other box always gives certain rewards.  For this option we will show you the reward available in gray even before you choose it.';
            i=i+1; ev{i} = 'LG64_RQQ';   iStr{i} = 'On any trial, the position of the two boxes is random, it could be certain on the left and uncertain on the right ...';
            i=i+1; ev{i} = 'LQQ_RG64';   iStr{i} = '... or certain on the right and uncertain on the left.';
            i=i+1; ev{i} = 'LQQ_RW64';   iStr{i} = 'If you choose the certain box, the number will brighten to indicate your choice and the points will be added to your total.';
            i=i+1; ev{i} = 'LQQ_RG64';   iStr{i} = 'The value in the certain box is usually the best score you have previously seen ...';
            i=i+1; ev{i} = 'L3_RQQ';     iStr{i} = 'For example, suppose on a particular trial you are faced with this decision between 3 points (for sure) on the left and a random number of points on the right ...';
            i=i+1; ev{i} = 'L3_R20';     iStr{i} = 'Now suppose you choose the right box and get 20 points ...';
            i=i+1; ev{i} = 'LQQ_R20';    iStr{i} = 'On the next trial, since 20 is the highest score you''ve seen so far, the certain option (which is on the right for this trial) is now worth 20 points ...';
            i=i+1; ev{i} = 'L10_R20';    iStr{i} = 'Suppose on the next trial you choose the uncertain option again and get 10 points ...';
            i=i+1; ev{i} = 'LQQ_R20';    iStr{i} = 'This time, on the next trial, the certain option stays at 20 points because 20 is still the highest score you''ve seen so far.';
            i=i+1; ev{i} = 'L_change_R'; iStr{i} = 'Finally, to keep things interesting, occasionally the certain reward will change.  When a change occurs, the new offer value can be anywhere from 1 to 100.';
            i=i+1; ev{i} = 'blank';      iStr{i} = 'We''ll give you a short practice game to make sure you understand everything.';
            i=i+1; ev{i} = 'blank';      iStr{i} = 'After that you''ll play the game for real, which will last about 20 minutes each.';
            i=i+1; ev{i} = 'blank';      iStr{i} = 'Press space when you are ready to begin.  Good luck!';
            
            obj.iStr = iStr;
            obj.iEv = ev;
            
        end
        
        function instructions(obj)
            

            rew = obj.rew;
            g_rew = obj.g_rew
            rewXX = obj.rewXX;
            rewQQ = obj.rewQQ;
            C_ban = obj.C_ban(1);
            U_ban = obj.U_ban(2);
            
            % move everything down by dy
            %dy = 200;
            %obj.C_ban.setPosition( obj.C_ban.centerPosition + [0 dy]);
            %obj.U_ban.setPosition( obj.U_ban.centerPosition + [0 dy]);
            
            obj.instructionList;
            
            iStr = obj.iStr;
            ev = obj.iEv;
            
            endFlag = false;
            count = 1;
            
            while ~endFlag
                [A, B] = Screen('WindowSize', obj.window);
                
                DrawFormattedText(obj.window, ...
                    ['        Page ' num2str(count) ' of ' num2str(length(iStr))], ...
                    [],[B*0.91], obj.textColour, obj.textWidth);
                
                
                ef = false;
                switch ev{count}
                    
                    case 'blank' % blank screen
                        obj.talkAndFlip(iStr{count});
                      
                    case 'L_R' % bandits example
                        C_ban.draw;
                        C_ban.showReward(rewXX);
                        U_ban.draw;
                        U_ban.showReward(rewXX);
                        
                        obj.talkAndFlip(iStr{count});
                        
                    case 'L_R75' % bandits with 75 in right
                        
                        C_ban.draw;
                        C_ban.showReward(rewXX);
                        U_ban.draw;
                        U_ban.showReward(rew(75));
                        obj.talkAndFlip(iStr{count});
                    
                    case 'L_RQQ'
                        C_ban.draw;
                        C_ban.showReward(rewXX);
                        U_ban.draw;
                        U_ban.showReward(rewQQ);
                        obj.talkAndFlip(iStr{count});
                        
                    
                    case 'LG64_RQQ' % 64 gray left
                        
                        C_ban.draw;
                        C_ban.showReward(g_rew(64));
                        U_ban.draw;
                        U_ban.showReward(rewQQ);
                        obj.talkAndFlip(iStr{count});
                        
                    case 'LQQ_RG64' % 64 gray right
                        
                        C_ban.draw;
                        C_ban.showReward(rewQQ);
                        U_ban.draw;
                        U_ban.showReward(g_rew(64));
                        obj.talkAndFlip(iStr{count});
                        
                    case 'LQQ_RW64' % 64 gray right
                        
                        C_ban.draw;
                        C_ban.showReward(rewQQ);
                        U_ban.draw;
                        U_ban.showReward(rew(64));
                        obj.talkAndFlip(iStr{count});
                        
                    case 'LW64_R' % 64 white left
                        
                        C_ban.draw;
                        C_ban.showReward(rew(64));
                        U_ban.draw;
                        obj.talkAndFlip(iStr{count});
                        
                    case 'L3_RQQ' % 64 white left
                        
                        C_ban.draw;
                        C_ban.showReward(g_rew(3));
                        U_ban.draw;
                        U_ban.showReward(rewQQ);
                        obj.talkAndFlip(iStr{count});
                        
                    case 'L3_R20' % 64 white left
                        
                        C_ban.draw;
                        C_ban.showReward(g_rew(3));
                        U_ban.draw;
                        U_ban.showReward(rew(20));
                        obj.talkAndFlip(iStr{count});
                        
                    case 'LQQ_R20' % 64 white left
                        
                        C_ban.draw;
                        C_ban.showReward(rewQQ);
                        U_ban.draw;
                        U_ban.showReward(g_rew(20));
                        obj.talkAndFlip(iStr{count});
                        
                    case 'L10_R20' % 64 white left
                        
                        C_ban.draw;
                        C_ban.showReward(rew(10));
                        U_ban.draw;
                        U_ban.showReward(g_rew(20));
                        obj.talkAndFlip(iStr{count});
                        
                    case 'LQQ_R20' % 64 white left
                        
                        C_ban.draw;
                        C_ban.showReward(rewQQ);
                        U_ban.draw;
                        U_ban.showReward(rew(20));
                        obj.talkAndFlip(iStr{count});
                        
                        
                    case 'L_change_R' % change point
                        
                        C_ban.changed = 0;
                        C_ban.draw;
                        C_ban.showReward(rewQQ);
                        U_ban.draw;
                        U_ban.showReward(g_rew(82));
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
            %for i = 1:length(obj.ban)
            %    obj.ban(i).setPosition( obj.ban(i).centerPosition - [0 dy]);
            %end
            
            WaitSecs(0.1);
            
        end
        
        % setup functions =================================================
        function setup_taskParameters(obj)
            
            % trials per game
            T = [10 500];
            
            % hazard rates (constant for all blocks)
            h = [0.1 0.1];
            
            % timings
            d1 = [0.5 0.5 ];
            d2 = [0.4 0.4 ];
            
            % repetition time scale
            tau = 200;
            
            % make game
            for i = 1:length(h)
                if i == 1
                    obj.game = obj.make_game(h(i), T(i), tau);
                else
                    obj.game(i) = obj.make_game(h(i), T(i), tau);
                end
            end
            for i = 1:length(obj.game)
                obj.game(i).gameNumber = i;
            end
            obj.game(1).practice = true;
            for i = 2:length(obj.game)
                obj.game(i).practice = false;
            end
            for i = 1:length(d1)
                obj.game(i).d1 = d1(i);
                obj.game(i).d2 = d2(i);
            end
            
        end
        
        function [CP, RR] = getChangePoints(obj, h, T, tau)
            
            % number of change points in L trials
            ncp = h*tau;
            N = ceil(T / tau);
            
            % compute change points
            CP = [];
            R = [];
            for i = 1:N
                
                % change point locations
                X = false(tau,1);
                q = randperm(tau);
                X(q(1:ncp)) = true;
                CP = [CP; X];
                
                % values after change point
                Y = nan(tau,1);
                
                %Y(q(1:ncp)) = ceil(100*rand(ncp,1));
                Y = ceil(rand_uniformSpread(100, 1, ncp))';
                R = [R; Y];
                
            end
            
                        
            RR = nan(size(CP));
            RR(find(CP)) = R;

        end
        
        function game = make_game(obj, h, T, L)
            
            %h = 0.1; T = 1000; L = 100;
            
            game.T = T;
            game.h = h;
            game.L = L;
            
            % get change points
            [CP, R] = obj.getChangePoints(h, T, L);
            
            % change point locations
            game.CP = CP;
            
            % new reward after change point
            game.R = R;
            
            % preallocate space to store actions
            game.a = nan(T,1);
            
            % preallocate space to store outcomes
            game.o = nan(T,1);
            
            % preallocate space to store times
            game.ts = nan(T,1); % trial start
            game.tc = nan(T,1); % certain option reveal time
            game.tp = nan(T,1); % key press
            game.to = nan(T,1); % outcome on
            game.RT = nan(T,1); % reaction time
            
            
            % predefine the uniform bandit outcomes (if it is played)
            game.U = ceil(100*rand(T,1));
            
            % trial number within a game
            game.t = [1:T]';
            
            % what's on the certain bandit
            game.C = nan(T,1);
            game.C(1) = ceil(100*rand);
            
            % where is are the certain and uncertain bandits?
            % counterbalance across all trials
            B = [ones(T/2,1); 2*ones(T/2,1)];
            I = randperm(length(B));
            game.Cid = B(I);
            game.Uid = 3 - B(I);
            
        end
        
        function setup(obj,window)
            
            obj.scaleFactor = 0.75;
            obj.setWindow([0 0 0],window);

%             obj.inputSubjectNumber;
%             obj.demographicQuestionCommand;

            obj.setTextParameters(40, 70, [1 1 1]*256);
            obj.setKeys({'leftarrow' 'rightarrow' 'space' 'delete' 'p' 'q' '7&'});
            obj.setRewards(obj.scaleFactor, obj.scaleFactor);  %%%
            obj.makeFixationCross;
            obj.makeBandits;
            %obj.makeMoneyBar;

            obj.setup_taskParameters;
            obj.totalMoney = 0;
            
        end
        
        function makeMoneyBar(obj)
            obj.mb = moneyBar(obj.window, obj.stimdir, 'dollarBill.png', [0 0 0]);
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
            
            for i = 1:100;
                g_rew(i) = picture(obj.window, obj.stimdir, ...
                    ['g' num2str(i) '.png']);
                g_rew(i).setup(sfN, [sw/2 sh/2]);
            end
            
            obj.rew = rew;
            obj.g_rew = g_rew;
            obj.rewXX = picture(obj.window, obj.stimdir, 'XX.png');
            obj.rewXX.setup(sfXX, [sw/2 sh/2]);
            obj.rewQQ = picture(obj.window, obj.stimdir, 'QQ.png');
            obj.rewQQ.setup(sfXX, [sw/2 sh/2]);
            
        end
        
        function makeBandits(obj)
            
            % banditNum = vector of numbers for the names of the bandit
            % files
            
            sw = obj.screenWidth;
            sh = obj.screenHeight;
            
            dx = [2:-1:1]*150;
            dx = dx - mean(dx);
            dx = dx * obj.scaleFactor;
            
            dy = 0;
            
            % Make left and right bandits
            % left certain bandit
            ban(1) = bandit_small(obj.window,obj.stimdir,'bandit1.png','changed.png');
            
            % right certain bandit
            ban(2) = bandit_small(obj.window,obj.stimdir,'bandit1.png','changed.png');
            
            % left uncertain bandit
            ban(3) = bandit_small(obj.window,obj.stimdir,'bandit1.png','changed.png');
            
            % right uncertain bandit
            ban(4) = bandit_small(obj.window,obj.stimdir,'bandit1.png','changed.png');
            
            % setup other stuff on bandits
            for i = 1:length(ban)
                ban(i).setup(obj.scaleFactor, obj.bgColour);
                ban(i).setupChange;
                ban(i).visible = true;
            end
            
            ban(1).setPosition([sw/2-dx(1) sh/2-dy]);
            ban(2).setPosition([sw/2-dx(2) sh/2-dy]);
            ban(3).setPosition([sw/2-dx(1) sh/2-dy]);
            ban(4).setPosition([sw/2-dx(2) sh/2-dy]);
            
            
            % put bandits on task object
            obj.C_ban    = ban(1); % left
            obj.C_ban(2) = ban(2); % right
            obj.U_ban    = ban(3); % left
            obj.U_ban(2) = ban(4); % right
            
        end
        
        % task functions ==================================================
        function run(obj)
            
            for b = 1:length(obj.game)
                
                if b == 1
                    obj.talk([...
                        'Press space to begin practice block']);
                else
                    obj.talk([...
                        'Starting Game ' num2str(b-1) ...
                        ' of ' num2str(length(obj.game)-1)...
                        '\nPress space to begin.']);
                end
                Screen(obj.window, 'Flip');
                
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(0.5);
                
                obj.eye.marker ('Begin_Block2');
                obj.run_block(b);
                
                r = nanmean([obj.game(b).o]);
                best = nanmean(max([obj.game(b).C obj.game(b).U],[],2));
                worst = nanmean(min([obj.game(b).C obj.game(b).U],[],2));
                
                if b > 1
                    % only record score from real blocks - ignore practice
                    % block
                    S = (r - worst) / (best - worst);
                    R(b-1) = S;
                end
                obj.talk([...
                    'Well done! You got ' num2str(round(r/best*100)) ...
                    '% of the points!'...
                    '\nPress space to continue.']);
                Screen(obj.window, 'Flip');
                obj.waitForInput([3], GetSecs + Inf);
                WaitSecs(0.2);
                
                
            end
            
            % compute the total reward
            %money = round(mean(R) * 3);
            %disp(['You earned $' num2str(money)])
        end
        
        function run_block(obj, b)
            
            for t = 1:obj.game(b).T

                % delays in this game
                d1 = obj.game(b).d1;
                d2 = obj.game(b).d2;
                
                % is there a CP and what is it to?
                R = obj.game(b).R(t);
                
                % what's on the certain bandit?
                if isnan(R)
                    % no change
                    C = obj.game(b).C(t);
                else
                    % change point so also change what's stored in game
                    C = R;
                    obj.game(b).C(t) = C;
                end
                
                % what's under the uncertain bandit?
                U = obj.game(b).U(t);
                
                Cid = obj.game(b).Cid(t);
                Uid = obj.game(b).Uid(t);
                
                % run the trial and get the outcome
                
                obj.eye.marker ('Begin_Trial2');
                [o, a, ts, tc, tp, to, RT] = obj.run_trial(C, U, R, Cid, Uid, d1, d2);
                
                % if outcome is better than C then reset C
                if t < obj.game(b).T
                    % NOTE - only update if you're going to play the trial
                    if o > C
                        obj.game(b).C(t+1) = o;
                    else
                        obj.game(b).C(t+1) = C;
                    end
                end
                % record stuff
                obj.game(b).a(t) = a;
                obj.game(b).o(t) = o;
                obj.game(b).ts(t) = ts;
                obj.game(b).tc(t) = tc;
                obj.game(b).tp(t) = tp;
                obj.game(b).to(t) = to;
                obj.game(b).RT(t) = RT;
                
                obj.save;
            end
            
        end
        
        function [o, a, ts, tc, tp, to, RT] = run_trial(obj, C, U, R, Cid, Uid, d1, d2)
            
            C_ban = obj.C_ban(Cid);
            U_ban = obj.U_ban(Uid);
            rew = obj.rew;
            g_rew = obj.g_rew;
            g_QQ = obj.rewQQ;
            g_XX = obj.rewXX;
            
            % is there a change-point?
            %CP = ~isnan(R);
            %if CP
            %    C_ban.changed = 1;
            %else
            %    C_ban.changed = 0;
            %end
            % first show closed boxes
            C_ban.draw;
            C_ban.showReward(g_XX);
            U_ban.draw;
            U_ban.showReward(g_XX);
            
            % flip
            banditOnTime = Screen(obj.window, 'Flip');
            obj.eye.marker('banditon2');
            % then reveal certain reward
            C_ban.draw;
            C_ban.showReward(g_rew(C));
            U_ban.draw;
            U_ban.showReward(g_QQ);
            % flip
            WaitSecs(d1);
            certainOnTime = Screen(obj.window, 'Flip');
            obj.eye.marker('certainon');
            
            % wait for input
            [KeyNum, pressTime] = obj.waitForInput([1:2], GetSecs +Inf);
            obj.eye.marker('keypress2');
            % get reward based on input
            C_ban.draw;
            U_ban.draw;
            
            if KeyNum == Cid
                reward = C;
                C_ban.showReward(rew(reward));
                U_ban.showReward(g_QQ);
            elseif KeyNum == Uid
                reward = U;
                C_ban.showReward(g_rew(C));
                U_ban.showReward(rew(reward));
            else
                error('key press not recognized');
            end
            
            % flip
            rewardOnTime = Screen(obj.window, 'Flip');
            obj.eye.marker('rewardon2');
            % outputs are:
            
            % outcome
            o = reward;
            
            % action
            a = KeyNum;
            
            % trial start time
            ts = banditOnTime;
            
            % certain on time
            tc = certainOnTime;
            
            % press time
            tp = pressTime;
            
            % reaction time
            RT = tp - tc;
            
            % outcome on time
            to = rewardOnTime;
            
            WaitSecs(d2);
            
        end
        
        function save(obj)
            
            game        = obj.game;
            ans         = obj.ans;
            subjectID   = obj.subjectID;
            savename    = obj.saveName;
            
            save([savename], 'savename', 'subjectID', 'ans', 'game');
            
        end
        
        
        
    end
    
end
