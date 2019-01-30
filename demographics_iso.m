classdef demographics_iso< handle
    
    properties
        
        window
        
        textWidth
        textColour
        textSize
        
        screenCenter
        screenWidth
        screenHeight
        Rx
        Ry
        scaleFactor
        
        bgColour
        
        keyName
        
        embodiedFlag
        
        dataname
        
        ans
        
        answers
        
    end
    
    methods
        
        function obj = demographics_iso
            
        end
        
        function setWindow(obj, window, screenCenter, sw, sh);
            
            obj.window = window;
            [A2,B2] = Screen('WindowSize',window);
            
            if exist('screenCenter') ~= 1
                
                screenCenter = [A2 B2]/2;
                sw = A2;
                sh = B2;
                
            end
            
            obj.scaleFactor = min([sw/A2 sh/B2]);
            
            obj.screenCenter = screenCenter;
            obj.screenWidth = sw;
            obj.screenHeight = sh;
            
            
        end
        
        function setKeys(obj, keyName)
            
            for i = 1:length(keyName)
                obj.keys(i) = KbName(keyName{i});
            end
            obj.keyName = keyName;
            
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
        
        
        % ask questions ---------------------------------------------------
        function displayQuestion(obj, Qstr, Astr, keyStr, Q_ypos, A_ypos)
            
            if exist('keyStr') == 0
                keyStr = obj.keyName;
            end
            
            if exist('Q_ypos') == 0
                Q_ypos = obj.screenHeight*1/8;
                A_ypos = obj.screenHeight*3/8;
            end
            
            for i = 1:length(Astr)
                Astr2{i} = ['(' keyStr{i} ') ' Astr{i} '     '];
            end
            Astring = [Astr2{:}];
            
            DrawFormattedText(obj.window, Qstr, ...
                'center', Q_ypos, obj.textColour, obj.textWidth);
            DrawFormattedText(obj.window, Astring, ...
                'center', A_ypos, obj.textColour, obj.textWidth);
            
        end
        
        function displayAnswer(obj, Qstr, Astr, keyNum, keyStr, ...
                Q_ypos, A_ypos)
            
            if exist('keyStr') == 0
                keyStr = obj.keyName;
            end
            
            if exist('Q_ypos') == 0
                Q_ypos = obj.screenHeight*1/8;
                A_ypos = obj.screenHeight*3/8;
            end
            
            Astring = ['(' keyStr{keyNum} ') ' Astr{1} '     '];
            
            DrawFormattedText(obj.window, Qstr, ...
                'center', Q_ypos, obj.textColour, obj.textWidth);
            DrawFormattedText(obj.window, Astring, ...
                'center', A_ypos, obj.textColour, obj.textWidth);
            
        end
        
        function A = askDemographicQuestion(obj, Qnum)
            
            x{1} = 'center'; x{2} = 'center';
            y{1} = obj.screenHeight*1/8;
            y{2} = obj.screenHeight*3/8;
            
            switch Qnum
                
                case 1 % age
                    
                    A = -1;
                    
                    while ~ismember(A, [1:100]);
                        
                        Qstr = 'Please enter your age in years and hit enter';
                        s = GetEchoString_bob(obj.window, Qstr, ...
                            x, y, obj.textColour, 60)
                        Screen(obj.window, 'Flip');
                        A = str2num(s);
                        if isempty(A)
                            A = -1;
                        end
                        
                    end
                    
                    
                case 2 % gender
                    for i = 1:2
                        keyStr{i} = obj.keyName{i}(1);
                    end
                    
                    Question = 'What is your gender?';
                    Answers = {'female' 'male'};
                    obj.displayQuestion(Question, Answers, keyStr);
                    tQ = Screen(obj.window, 'Flip');
                    
                    validKeys = [1:length(Answers)];
                    [KeyNum, when] = obj.waitForInput(validKeys, GetSecs+Inf)
                    
                    RT = when-tQ;
                    
                    A = Answers{KeyNum};
                    
                    obj.displayAnswer(Question, {Answers{KeyNum}}, ...
                        KeyNum, keyStr);
                    Screen(obj.window, 'Flip');
                    
                    WaitSecs(1);
                    
                case 3 % maths classes
                    
                    A = -1;
                    
                    while ~ismember(A, [0:100])
                        
                        Qstr = ['How many college level ' ...
                            'math classes have you taken?'];
                        
                        s = GetEchoString_bob(obj.window, Qstr, ...
                            x, y, obj.textColour, 60)
                        
                        A = str2num(s);
                        if isempty(A)
                            A = -1;
                        end
                        
                        
                    end
                    
                    
            end
            
            
        end
        
        function talk(obj, str, tp)
            
            if exist('tp') == 0
                DrawFormattedText(obj.window, str, ...
                    'center','center', obj.textColour, 70);
            else
                DrawFormattedText(obj.window, str, ...
                    tp{1},tp{2}, obj.textColour, 70);
                
            end
            
        end
        
        function demographicQuestionNavigator(obj)
            
            flag = 0;
            
            obj.talk(['Before we begin we''d like to ask '...
                'three questions about you ...'], {'center' 50})
            obj.talk(['[Press space to continue]'], {'center' 150})
            Screen(obj.window, 'Flip');
            WaitSecs(0.2);
            validKeys = [3];
            [KeyNum, when] = obj.waitForInput(validKeys, GetSecs+Inf);
            
            
            while ~flag
                
                A1 = obj.askDemographicQuestion(1);
                A2 = obj.askDemographicQuestion(2);
                A3 = obj.askDemographicQuestion(3);
                
                % this is hard coded - but it's OK!
                obj.talk(['Age : ' num2str(A1)], {'center' 50})
                obj.talk(['Gender : ' A2], {'center' 100})
                obj.talk(['# math classes : ' num2str(A3)], {'center' 150})
                str = ['If this is correct press space.  ' ...
                    'To re-enter information press delete'];
                obj.talk(str, {'center' 200})
                Screen(obj.window, 'Flip');
                
                validKeys = [3,4];
                [KeyNum, when] = obj.waitForInput(validKeys, GetSecs+Inf);
                if KeyNum == 3
                    flag = 1;
                end
                
                
            end
            
            obj.ans.age = A1;
            obj.ans.gender = A2;
            obj.ans.mathClasses = A3;
            
        end
        
        function runSubject(obj)
            
            % randomly decide whether it's embodied or described
            obj.embodiedFlag = rand < 0.5;
            
            if obj.embodiedFlag
                obj.talk('e');
            else
                obj.talk('d');
            end
            Screen(obj.window, 'Flip')
            % press space 1st
            validKeys = [3];
            [KeyNum, when] = obj.waitForInput(validKeys, GetSecs+Inf);
            
            % then secret key! press 7 
            validKeys = [5];
            [KeyNum, when] = obj.waitForInput(validKeys, GetSecs+Inf);
            
            obj.instructionNavigator;
            obj.demographicQuestionNavigator;
            
            obj.ellsbergQuestionNavigator;
            
            obj.save;
            obj.showResults;
            
            % secret key! press 7 to end subject
            validKeys = [5];
            [KeyNum, when] = obj.waitForInput(validKeys, GetSecs+Inf);
            
        end
        
        function demographicQuestionCommand(obj)
            
            x = 0;
            
            while x ~= 1
                obj.ans.age = input('What is your age? ');
                obj.ans.gender = input('What is your gender? ', 's');
                obj.ans.math = input('How many college level math classes have you taken? ');
                
                x = input('Is this information correct? Type 0 for no and 1 for yes ');
            end
            
        end
            
        
        
    end
    
    
    
end