classdef clickBox < handle
    
    properties
        
        window
        rect
        edgeColor
        fillColor_on
        fillColor_off
        textColor
        textSize
        string
        edgeWidth
        
        isOn
    end
    
    
    methods
        
        function obj = clickBox
        end
        
        function setup(obj, window, string, textColor, edgeColor, fillColor_on, fillColor_off, textSize, rect)
            obj.window = window;
            obj.string = string;
            obj.textColor = textColor;
            obj.edgeColor = edgeColor;
            obj.fillColor_on = fillColor_on;
            obj.fillColor_off = fillColor_off;
            obj.textSize = textSize;
            obj.rect = rect;
            obj.edgeWidth = 2;
            obj.isOn = false;
        end
        
        function draw(obj)
            
            win = obj.window;
            tstring = obj.string;
            sx = 'center';
            sy = 'center';
            color = obj.textColor;
            rect = obj.rect;
            
            if obj.isOn
                Screen('FillRect', obj.window, obj.fillColor_on, obj.rect, obj.edgeWidth);
            else
                Screen('FillRect', obj.window, obj.fillColor_off, obj.rect, obj.edgeWidth);
            end
            Screen('FrameRect', obj.window, obj.edgeColor, obj.rect, obj.edgeWidth);
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            DrawFormattedText(win, tstring, sx, sy, color, inf, 0, 0, 1, 0, rect)
            Screen('TextSize', obj.window, oldTextSize);
            
        end
        
        function setCornerPosition(obj, pos)
            rect = obj.rect;
            obj.rect = rect-[rect(1:2) rect(1:2)]+[pos pos];
            
        end
        
         
        function check(obj, x, y)
            
            if (x > obj.rect(1)) & (x < obj.rect(3)) ...
                    & (y > obj.rect(2)) & (y < obj.rect(4))
                obj.isOn = ~obj.isOn;
                WaitSecs(0.1);
            end
            obj.draw;
            
        end
        
        
    end
    
    
end