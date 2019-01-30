classdef moneyBar_allie < handle
    
    properties
        
        window
        stimDir
        name
        
        image
        texture
        size
        scaleFactor
        basePosition
        nHigh
        maxR
        
        screenHeight
        screenWidth
        screenCenter
        
        maskBarColour
        
        R
        
    end
    
    methods
        
        function obj = moneyBar_allie(window, stimDir, name, maskBarColour)
            
            if exist('window') == 1
                obj.window = window;
            end
            if exist('stimDir') == 1
                obj.stimDir = stimDir;
            end
            if exist('name') == 1
                obj.name = name;
            end
            if exist('maskBarColour') == 1
                obj.maskBarColour = maskBarColour;
            end
            
            
        end
        
        function setup(obj, nHigh, screenHeight, screenWidth, ...
                screenCenter, basePosition);
            
            %obj.image = imread([obj.stimDir obj.name]);
            obj.image = imread([obj.stimDir obj.name]);
            sz = size(obj.image);
            scaleFactor = 1/nHigh*screenHeight/sz(1);
            
            obj.screenHeight = screenHeight;
            obj.screenWidth = screenWidth;
            obj.screenCenter = screenCenter;
            obj.nHigh = nHigh;
            
            obj.image = imresize(obj.image, scaleFactor);
            
            obj.texture = Screen(obj.window, 'MakeTexture', obj.image);
            sz = size(obj.image);
            obj.size = sz(2:-1:1);
            obj.scaleFactor = scaleFactor;
            
            if exist('basePosition') ~= 1
                obj.basePosition = [100 100];
            else
                obj.basePosition = basePosition;
            end
            obj.R = 0;
            
        end
        
        function setToRightEdge(obj)
            
            obj.basePosition = ...
                [obj.screenCenter(1)+obj.screenWidth/2-obj.size(1) ...
                obj.screenCenter(2)-obj.screenHeight/2];
            
        end
        
        function setToLeftEdge(obj)
            
            obj.basePosition = [obj.screenCenter(1)-obj.screenWidth/2 ...
                obj.screenCenter(2)-obj.screenHeight/2];
            
        end
        
        function setMaxReward(obj, maxR)
            obj.maxR = maxR;
        end
        
        function addReward(obj, r)
            obj.R = obj.R + r;
        end
        
        function resetToZero(obj)
            obj.R = 0;
        end
        
        function draw(obj)
            
            R = obj.R;
            
            for i = 1:obj.nHigh
                bottomLeft = obj.basePosition + [0 (i-1)*obj.size(2)];
                topRight = bottomLeft + obj.size;
                pos = [bottomLeft topRight];
                
                window = obj.window;
                tx = obj.texture;
                
                Screen('DrawTexture', window, tx, [], pos);
            end
            
            if ~isempty(obj.maxR)
                fR = R / obj.maxR;
            else
                fR = R;
            end
               
            rHeight = obj.screenHeight * (1-fR);
            rWidth = obj.size(1);
            rBase = [obj.basePosition(1) ...
                obj.screenCenter(2)-obj.screenHeight/2];
            
            rect = [rBase ...
                rBase+[rWidth rHeight]];
            
            %xcen = floor(wRect(3)/2);
            %ycen = floor(wRect(4)/2);
            %cenRect=[xcen/2 ycen/2 3*xcen/2 3*ycen/2];
            Screen('FillRect', window, obj.maskBarColour, rect);
        end
        
    end
    
    
    
end
