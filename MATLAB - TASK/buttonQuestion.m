classdef buttonQuestion < handle
    
    properties
        
        window
        
        qString
        qTextSize
        qTextColor
        qPos
        
        bt
        
    end
    
    methods
        
        function obj = buttonQuestion()
        end
        
        function setup(obj, window, qString, aString)
            
            obj.qString     = qString;
            obj.qTextSize   = 50;
            obj.qTextColor  = [1 1 1]*256;
            obj.window      = window;
            
            % to keep this simple have it be a set size
            textSize    = 30;
            textColor   = [1 1 1]*256;
            margin      = 10;
            radius      = 20;
            fillFrac    = 0.6;
            edgeWidth   = 2;
            edgeColor   = [1 1 1]*256;
            onColor     = [1 1 1]*256;
            offColor    = [0 0 0];
            
            for i = 1:length(aString)
                string          = aString{i};
                if i == 1
                    obj.bt      = pushButtonText;
                else
                    obj.bt(i)   = pushButtonText;
                end
                obj.bt(i).setup(window, textSize, textColor, string, margin, radius, ...
                    fillFrac, edgeColor, onColor, offColor, edgeWidth)
            end
            
        end
        
        function setCornerPosition(obj, pos)
            
            obj.qPos = pos;
            for i = 1:length(obj.bt)
                obj.bt(i).setCornerPosition([pos(1) obj.qTextSize*1.1+pos(2)+i*obj.bt(i).textSize*1.1]);
            end
            
        end
        
        function draw(obj)
            
            sx = obj.qPos(1);
            sy = obj.qPos(2);
            oldTextSize = Screen('TextSize', obj.window, obj.qTextSize);
            DrawFormattedText(obj.window, obj.qString, sx, sy, obj.qTextColor);
            Screen('TextSize', obj.window, oldTextSize);
            for i = 1:length(obj.bt)
                obj.bt(i).draw;
            end
            
        end
        
        function check(obj, x, y)
            
            for i = 1:length(obj.bt)
                obj.bt(i).check(x,y);
            end
            
        end
        
    end
    
end
