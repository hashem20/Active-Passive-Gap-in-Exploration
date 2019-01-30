classdef picture < handle
      
    properties
        
        size
        window 
        stimDir
        name
        image
        texture
        centrePosition
        scaleFactor
        
    end
    
    
    methods
       
        function obj = picture(window, stimDir, name)
            
            if exist('window') == 1
                obj.window = window;
            end
            if exist('stimDir') == 1
                obj.stimDir = stimDir;
            end
            if exist('name') == 1
                obj.name = name;
            end
            
        end
        
        function setup(obj, scaleFactor, centrePosition);
            
            %obj.image = imread([obj.stimDir obj.name]);
            obj.image = imresize(imread([obj.stimDir obj.name]), ...
                scaleFactor);
            obj.texture = Screen(obj.window, 'MakeTexture', obj.image);
            sz = size(obj.image);
            obj.size = sz(2:-1:1);
            obj.scaleFactor = scaleFactor;
            
            if exist('centrePosition') ~= 1
                obj.centrePosition = [100 100];
            else
                obj.centrePosition = centrePosition;
            end
            
        end
        
        function draw(obj, centrePosition);
            
            % sets actual coords used for drawing based on just the center
            % position for the bandit
            if exist('centrePosition') ~= 1
                centrePosition = obj.centrePosition;
            end
            bottomLeft = centrePosition - obj.size / 2;
            topRight = centrePosition + obj.size / 2;
            pos = [bottomLeft topRight];
            
            window = obj.window;
            tx = obj.texture;
            
            Screen('DrawTexture', window, tx, [], pos);
            
        end
        
        
    end
    
 
end
