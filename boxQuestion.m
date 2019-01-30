classdef boxQuestion < handle
   
    properties
        
        window
        
        qString
        qTextSize
        qTextColor
        qPos
        
        bx
        
    end
    
    methods
        
        function obj = boxQuestion();
        end
        
        function setup(obj, window, qString, nx, ny)
            
            obj.qString     = qString;
            obj.qTextSize   = 50;
            obj.qTextColor  = [1 1 1]*256;
            obj.window      = window;
            
            % to keep this simple have it be a set size
            pos = [100 500];
            %nx = 5;
            %ny = 1;
            edgeWidth_on = 5;
            edgeWidth_off = 2;
            edgeColor_off = [1 1 1]*100;
            edgeColor_on = [1 1 1]*255;
            textSize = 50;
            textColor = [1 1 1]*255;
            bgColor = [0 0 0];
            
            obj.bx = inputTextBox;
            obj.bx.setup(window, pos+[20 100], nx, ny, ...
                edgeWidth_on, edgeWidth_off, edgeColor_on, edgeColor_off, ...
                textSize, textColor, bgColor);

        end
        
        function setCornerPosition(obj, pos)
            
            obj.qPos = pos;
            obj.bx.setCornerPosition(pos+[20 100]);
            
        end
        
        function draw(obj)
            
            sx = obj.qPos(1);
            sy = obj.qPos(2);
            oldTextSize = Screen('TextSize', obj.window, obj.qTextSize);
            DrawFormattedText(obj.window, obj.qString, sx, sy, obj.qTextColor);
            Screen('TextSize', obj.window, oldTextSize);
            obj.bx.draw;
            
        end
        
        function check(obj, x, y)
            
            obj.bx.check(x,y);
            
        end
        
    end
    
end