classdef inputTextBox < handle
    
    properties
        
        window
        
        cornerPosition
        edgeRect
        borderRect
        edgeWidth_on
        edgeWidth_off
        
        textSize
        
        string
        max_string
        
        bgColor
        textColor
        edgeColor_on
        edgeColor_off
        
        nx 
        ny
        pad
        
        isOn
    end
    
    methods
        
        function obj = inputTextBox()
        end
        
        function setup(obj, window, pos, nx, ny, ...
                edgeWidth_on, edgeWidth_off, edgeColor_on, edgeColor_off, ...
                textSize, textColor, bgColor)
            
            obj.window          = window;
            obj.cornerPosition  = pos;
            obj.nx              = nx;
            obj.ny              = ny;
            obj.edgeWidth_on    = edgeWidth_on;
            obj.edgeWidth_off   = edgeWidth_off;
            obj.textSize        = textSize;
            obj.textColor       = textColor;
            obj.edgeColor_on    = edgeColor_on;
            obj.edgeColor_off   = edgeColor_off;
            obj.bgColor         = bgColor;
            obj.isOn            = false;
           
            
            obj.string          = [];
            
            % make max_string to get bounding box
            max_string(1:nx,1:ny) = 'X';
            for i = 1:ny
                max_string(nx+1:nx+2,i) = '\n';
            end
            obj.max_string = max_string(:)';
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            [~,~,textbounds] = DrawFormattedText(obj.window, obj.max_string, pos(1), pos(2), obj.textColor);
            obj.edgeRect = textbounds;
            
%   original          obj.pad = 40;
            obj.pad = 40;
            obj.borderRect = obj.edgeRect + obj.pad/2*[-1 -1 1 1];
            Screen('TextSize', window, oldTextSize);
            
        end
        
        function setCornerPosition(obj, pos)
            
            obj.cornerPosition = pos;
            edgeRect = obj.edgeRect;
            edgeRect = edgeRect - [edgeRect(1:2) edgeRect(1:2)];
            obj.edgeRect = edgeRect + [pos pos];
            
            obj.borderRect = obj.edgeRect + obj.pad/2*[-1 -1 1 1];
            
        end
        
        function out = enterText(obj)
            
            windowPtr = obj.window;
            x = obj.edgeRect(1);
            y = obj.edgeRect(2);
            textColor = obj.textColor;
            bgColor = obj.bgColor;
            
            
            % Enable user defined alpha blending if a text background color is
            % specified. This makes text background colors actually work, e.g., on OSX:
            oldalpha = Screen('Preference', 'TextAlphaBlending', 1-IsLinux);
            
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            
            
            % Flush the keyboard buffer:
            FlushEvents;
            
            string = obj.string;
            output = [string 'I'];
            
            % Write the initial message:
            Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
            Screen('Flip', windowPtr, [], 1);
            
            
            while true
                
                out = getKbCharOrClick(obj.window);
                
                switch out.what
                    case 'keyPress'
                        char = out.ch;
                        
                        %if isempty(char)
                        %    string = '';
                        %    break;
                        %end
                        
                        switch (abs(char))
                            %case 13%{13, 3, 10}
                                % ctrl-C ONLY 
                                %%%%%% removed: enter, or return
                                %char = '\n';
                                %break;
                            case 8
                                % backspace
                                if ~isempty(string)
                                    % Redraw text string, but with textColor == bgColor, so
                                    % that the old string gets completely erased:
                                    oldTextColor = Screen('TextColor', windowPtr);
                                    Screen('DrawText', windowPtr, output, x, y, bgColor, bgColor);
                                    Screen('TextColor', windowPtr, oldTextColor);
                                    
                                    % Remove last character from string:
                                    string = string(1:length(string)-1);
                                end
                            otherwise
                                string = [string, char]; %#ok<AGROW>
                        end
                        
                        output = [string 'I'];
                        Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
                        
                        Screen('Flip', windowPtr, [], 1);
                        KbReleaseWait(-1, out.secs+0.12);
                        
                    case 'click'
                        
                        % is the click outside THIS box?
                        chk = (out.x > obj.edgeRect(1)) ...
                            & (out.x < obj.edgeRect(3)) ...
                            & (out.y > obj.edgeRect(2)) ...
                            & (out.y < obj.edgeRect(4));
             
                        switch chk
                            case 0
                                % box turned off so click was outside
                                obj.isOn = false;
                                break;
                            
                            case 1
                                % box is still on so click was inside
                                % do nothing
                        end
                        
                        
                end
                
            end
            
            % Restore text alpha blending state if it was altered:
            if ~isempty(bgColor)
                Screen('Preference', 'TextAlphaBlending', oldalpha);
            end
            obj.string = string;
            Screen('TextSize', obj.window, oldTextSize);
            
        end
        
        function draw(obj)
            switch obj.isOn
                case 0
                    Screen('FrameRect', obj.window, obj.edgeColor_off, obj.borderRect, obj.edgeWidth_off);
                case 1
                    Screen('FrameRect', obj.window, obj.edgeColor_on, obj.borderRect, obj.edgeWidth_on);
            end
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            DrawFormattedText(obj.window, obj.string, obj.edgeRect(1), obj.edgeRect(2), obj.textColor);
            Screen('TextSize', obj.window, oldTextSize);
        end
        
        function check(obj, x, y)
            
            if (x > obj.edgeRect(1)) & (x < obj.edgeRect(3)) ...
                    & (y > obj.edgeRect(2)) & (y < obj.edgeRect(4))
                obj.isOn = ~obj.isOn;
                WaitSecs(0.1);
            end
            obj.draw;
            if obj.isOn
                obj.enterText;
            end
            
        end
        
        
    end
    
end
