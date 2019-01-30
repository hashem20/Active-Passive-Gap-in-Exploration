classdef instructions < handle
    properties
        window
        iStr
        text
        N
    end
    methods
        function obj = instructions(window)
            obj.window = window;
        end
        function setup(obj,text)
            obj.text.textSize = text.textSize;
            obj.text.textWrapat = text.textWrapat;
            obj.text.textColor = text.textColor;
            obj.text.textFont = text.textFont;
        end
        function update(obj,iStr)
            obj.iStr = iStr;
            obj.N = size(iStr,2);
        end
        function run(obj,option)
            count = 1;
            while count <= obj.N
            obj.talkAndFlip(obj.iStr{count},option);
            keyspace = KbName('space');
                            keybackspace =  KbName('delete');
                            % press button to move on or not
                            endFlag = false;
                            while ~endFlag

                                [KeyNum, when] = waitForInput([keyspace,keybackspace], Inf);
                                switch KeyNum

                                    case keyspace % go forwards
                                        count = count +1;
                                            endFlag = true;

                                    case keybackspace % go backwards
                                        count = count - 1;
                                        if count < 1
                                            count = 1;
                                        end
                                            endFlag = true;

            %                         case 5 % skip through
            %                             endFlag = true;
            %                             
            %                         case 6 % quit
            %                             sca
            %                             error('User requested escape!  Bye-bye!');

                                end

                            end
            end
        end
        function talkAndFlip(obj, str, option, pTime)
                    Screen('TextFont', obj.window, 'Arial');
                    Screen('TextSize', obj.window, obj.text.textSize);
                    [A, B] = Screen('WindowSize', obj.window);
                    if exist('pTime') ~= 1
                        pTime = 0.3;
                    end
                    if option == 0
                        [nx, ny] = DrawFormattedText(obj.window, ...
                            ['' str], ...
                            0.05*A,[B*0.02], obj.text.textColor, obj.text.textWrapat);
                        Screen('TextSize', obj.window,round(obj.text.textSize));
                        DrawFormattedText(obj.window, ...
                            ['' ...
                            'Press space to continue or delete to go back'], ...
                            'center', [B*0.93], [150 150 150], obj.text.textWrapat);
                    elseif option == 1
                        [nx, ny] = DrawFormattedText(obj.window, ...
                            ['' str], ...
                            'center','center', obj.text.textColor, obj.text.textWrapat);
                    end
                    Screen('TextSize', obj.window,obj.text.textSize);
                    Screen(obj.window, 'Flip');
                    WaitSecs(pTime);
        end
    end
end