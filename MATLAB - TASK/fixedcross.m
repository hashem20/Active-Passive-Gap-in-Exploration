classdef fixedcross < handle
    properties
        window
        fixCrossDimPix
        lineWidthPix
        color
        center
        smooth
    end
    methods
        function obj = fixedcross(window)
            obj.window = window;
        end
        function setup(obj,fixCrossDimPix, lineWidthPix, color, center, smooth)
            obj.fixCrossDimPix = fixCrossDimPix;
            obj.lineWidthPix = lineWidthPix;
            obj.color = color;
            obj.center = center;
            obj.smooth = smooth;
        end
        function draw(obj)
            fixCrossDimPix = obj.fixCrossDimPix;
            xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
            yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
            Coords = [xCoords; yCoords];
            Screen('DrawLines', obj.window, Coords, obj.lineWidthPix, obj.color, obj.center, obj.smooth);
        end
    end
end
