classdef pushButton < handle
    
    properties
        
        window
        centerPosition
        edgeRect
        fillRect
        radius
        
        edgeWidth
        
        edgeColor
        offColor
        onColor
        
        fillFrac
        
        isOn
        
    end
    
    methods
        
        function obj = pushButton()
        end
        
        function setup(obj, window, radius, fillFrac, edgeColor, ...
                onColor, offColor, edgeWidth)
            
            obj.window      = window;
            obj.radius      = radius;
            obj.isOn        = false;
            obj.fillFrac    = fillFrac;
            obj.edgeWidth   = edgeWidth;
            obj.edgeColor   = edgeColor;
            obj.offColor    = offColor;
            obj.onColor     = onColor;
            
        end
        
        function setCenterPosition(obj, centerPosition)
            
            obj.centerPosition  = centerPosition;
            pos                 = centerPosition - obj.radius/2;
            obj.edgeRect        = [pos(1) pos(2) pos(1) pos(2)] + [0 0 1 1]*obj.radius;
            obj.fillRect        = ...
                [obj.centerPosition(1:2) obj.centerPosition(1:2)] ...
                +[-1 -1 +1 +1]*obj.radius/2*obj.fillFrac;
            
        end
        
        function setCornerPosition(obj, pos)
            
            obj.edgeRect        = [pos(1) pos(2) pos(1) pos(2)] + [0 0 1 1]*obj.radius;
            obj.centerPosition  = obj.edgeRect(1:2) + obj.radius/2
            obj.fillRect        = ...
                [obj.centerPosition(1:2) obj.centerPosition(1:2)] ...
                +[-1 -1 +1 +1]*obj.radius/2*obj.fillFrac;
            
        end
        
        function draw(obj)
            
            if obj.isOn
                Screen('FillOval', obj.window, obj.onColor, obj.fillRect);
            else
                Screen('FillOval', obj.window, obj.offColor, obj.fillRect);
            end
            Screen('FrameOval', obj.window, obj.edgeColor, obj.edgeRect, obj.edgeWidth);
            
        end
        
        function check(obj, x, y)
            
            if (x > obj.edgeRect(1)) & (x < obj.edgeRect(3)) ...
                    & (y > obj.edgeRect(2)) & (y < obj.edgeRect(4))
                obj.isOn = ~obj.isOn;
                WaitSecs(0.1);
            end
            
        end
        
    end
    
end