function [KeyNum, when, deltawhen] = waitForInput(validKeys, timeOut)
            % wait for a keypress for TimeOut seconds
            Pressed = 0;
            while ~Pressed && (GetSecs < timeOut)
                [Pressed, when, KeyNum, deltawhen] = KbCheck;
                KeyNum = find(KeyNum,1);
                if ~ismember(KeyNum,validKeys)
                    Pressed = 0;
                end
            end
            if Pressed == 0
                KeyNum = [];
                when = [];
            end
        end