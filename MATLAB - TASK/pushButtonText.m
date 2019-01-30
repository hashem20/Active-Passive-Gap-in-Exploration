classdef pushButtonText < handle
    
    properties
        
        window
        
        textSize
        textPosition
        textColor
        string
        
        margin
        
        cornerPosition
        
        but
        
    end
    
    methods
        
        function obj = pushButtonText();
            obj.but = pushButton();
        end
        
        function setup(obj, window, textSize, textColor, string, margin, radius, fillFrac, edgeColor, ...
                onColor, offColor, edgeWidth)
            
            obj.window      = window;
            obj.textSize    = textSize;
            obj.textColor   = textColor;
            obj.string      = string;
            obj.margin      = margin;
            
            obj.but.setup(window, radius, fillFrac, edgeColor, ...
                onColor, offColor, edgeWidth);
            
        end
        
        function setCornerPosition(obj, pos)
            
            obj.but.setCornerPosition(pos);
            obj.cornerPosition  = pos;
            obj.textPosition    = obj.but.centerPosition+[obj.but.radius/2+obj.margin -obj.textSize*0.65];
            
            
            
        end
        
        function draw(obj)
            
            sx = obj.textPosition(1);
            sy = obj.textPosition(2);
            oldTextSize = Screen('TextSize', obj.window, obj.textSize);
            DrawFormattedText(obj.window, obj.string, sx, sy, obj.textColor);
            Screen('TextSize', obj.window, oldTextSize);
            obj.but.draw;
            
        end
        
        function check(obj, x, y)
            
            obj.but.check(x,y);
            
        end
        
    end
    
end
