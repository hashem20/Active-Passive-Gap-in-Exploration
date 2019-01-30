classdef bandit_small < handle
    
    properties
          
        window
        stimDir
        name
        num
        
        image
        imagePlayed
        texture
        texturePlayed
        size
        
        position
        stats
        
        bottomLeft
        topRight
        centerPosition
        
        rectDim
        rewardPosition
        scaleFactor
        bgColour
        
        playedBan
        changePic
        
        visible
        
        changed
        
    end
    
    methods
        
        function obj = bandit_small(window, stimDir, name, changeName);
            
            if exist('window') == 1
                obj.window = window;
            end
            if exist('stimDir') == 1
                obj.stimDir = stimDir;
            end
            if exist('name') == 1
                obj.name = name;
            end
            
            if exist('changeName') == 1
                obj.changePic = picture(window, stimDir, changeName)
            end
            obj.visible = true;
            obj.changed = false;
            
        end
        
        function setup(obj, scaleFactor, bgColour);
            
            if exist('scaleFactor') ~= 1
                scaleFactor = 1;
            end
            if exist('bgColour') ~= 1
                bgColour = [1 1 1]*75;
            end
            obj.image = imresize(imread([obj.stimDir obj.name]), ...
                scaleFactor);
            obj.texture = Screen(obj.window, 'MakeTexture', obj.image);
            sz = size(obj.image);
            obj.size = sz(2:-1:1);
            
            % find position of reward rectangle
            [obj.rectDim] = [0 0 obj.size(1) obj.size(2)];
            %scanPic_v2(obj.image, bgColour);
            
            %obj.changeCue = changeCue;
            obj.scaleFactor = scaleFactor;
            obj.bgColour = bgColour;
            
        end
        
        function tx = setupPlayed(obj, scaleFactor, bgColour);
            
            if exist('scaleFactor') ~= 1
                scaleFactor = 1;
            end
            if exist('bgColour') ~= 1
                bgColour = [1 1 1]*75;
            end
            obj.imagePlayed = imresize(imread([obj.stimDir obj.name]), ...
                scaleFactor);
            tx = Screen(obj.window, 'MakeTexture', ...
                obj.imagePlayed);
            sz = size(obj.imagePlayed);
            obj.size = sz(2:-1:1);
            
            % find position of reward rectangle
            [obj.rectDim] = [0 0 obj.size(1) obj.size(2)];
            %scanPic_v2(obj.imagePlayed, bgColour);
            
        end
        
        function setPosition(obj, centerPosition);
            
            % sets actual coords used for drawing based on just the center
            % position for the bandit
            obj.centerPosition = centerPosition;
            obj.bottomLeft = centerPosition - obj.size / 2;
            obj.topRight = centerPosition + obj.size / 2;
            obj.position = [obj.bottomLeft obj.topRight];
            
            
            % reward position if one reward
            obj.rewardPosition{1}{1}(1) = obj.position(1) + ...
                (obj.rectDim(1)+obj.rectDim(3))/2;
            obj.rewardPosition{1}{1}(2) = obj.position(2) + ...
                (obj.rectDim(2) + obj.rectDim(4))/2;
            
            % reward position if two rewards
            obj.rewardPosition{2}{1}(1) = obj.position(1) + ...
                (obj.rectDim(1)+obj.rectDim(3))/2;
            
            obj.rewardPosition{2}{1}(2) = obj.position(2) + ...
                obj.rectDim(2) ...
                + (obj.rectDim(4)-obj.rectDim(2))/4;
            
            obj.rewardPosition{2}{2}(1) = obj.position(1) + ...
                (obj.rectDim(1)+obj.rectDim(3))/2;
            
            obj.rewardPosition{2}{2}(2) = obj.position(2) + ...
                obj.rectDim(2) ...
                + (obj.rectDim(4)-obj.rectDim(2))/4*3;
            
            
            % reward positions if three rewards
            obj.rewardPosition{3}{1}(1) = obj.position(1) + ...
                (obj.rectDim(1)+obj.rectDim(3))/2;
            obj.rewardPosition{3}{1}(2) = obj.position(2) + ...
                obj.rectDim(2) ...
                + (obj.rectDim(4)-obj.rectDim(2))/6;
            
            obj.rewardPosition{3}{2}(1) = obj.position(1) + ...
                (obj.rectDim(1)+obj.rectDim(3))/2;
            obj.rewardPosition{3}{2}(2) = obj.position(2) + ...
                (obj.rectDim(2) + obj.rectDim(4))/2;
            
            obj.rewardPosition{3}{3}(1) = obj.position(1) + ...
                (obj.rectDim(1)+obj.rectDim(3))/2;
            obj.rewardPosition{3}{3}(2) = obj.position(2) + ...
                obj.rectDim(2) ...
                + (obj.rectDim(4)-obj.rectDim(2))/6*5;
            
        end
        
        function draw(obj, cPos)
            
            if obj.changed
                if exist('cPos') ~= 1
                    obj.drawChange;
                else
                    obj.drawChange(cPos);
                end
            else
                
                if obj.visible
                    window = obj.window;
                    tx = obj.texture;
                    
                    
                    if exist('cPos') ~= 1
                        
                        pos = obj.position;
                        
                    else
                        
                        bottomLeft = cPos - obj.size / 2;
                        topRight = cPos + obj.size / 2;
                        pos = [bottomLeft topRight];
                        
                    end
                    
                    Screen('DrawTexture', window, tx, [], pos);
                end
            end
        end
        
        function setupChange(obj)
            
            obj.changePic.setup(obj.scaleFactor, obj.centerPosition);
            
        end
        
        function drawChange(obj, cPos)
            if obj.visible
                window = obj.window;
                
                tx = obj.texture;
                
                if exist('cPos') ~= 1
                    pos = obj.position;
                    obj.changePic.draw(obj.centerPosition);
                else
                    
                    bottomLeft = cPos - obj.size / 2;
                    topRight = cPos + obj.size / 2;
                    pos = [bottomLeft topRight];
                    obj.changePic.draw(cPos);
                    
                end
                
                Screen('DrawTexture', window, tx, [], pos);
            end
        end
        
        function makeLeftBandit(obj, A, B)
            
            obj.setPosition([A/3 B/2]);
            obj.draw;
        end
        
        function makeRightBandit(obj, A, B)
            
            obj.setPosition([A/1.4 B/2]);
            obj.draw;
        end
        
        function showReward(obj, reward)
            
            if obj.visible
                window = obj.window;
                tx = obj.texture;
                pos = obj.position;
                
                Screen('DrawTexture', window, tx, [], pos);
                
                nRewards = length(reward);
                for i = 1:nRewards
                    reward(i).draw(obj.rewardPosition{nRewards}{i});
                end
                obj.changed = false;
            end
            
        end
        
        function showRewardPlayed(obj, reward)
            
            if obj.visible
                window = obj.window;
                tx = obj.texturePlayed;
                pos = obj.position;
                
                Screen('DrawTexture', window, tx, [], pos);
                
                nRewards = length(reward);
                for i = 1:nRewards
                    reward(i).draw(obj.rewardPosition{nRewards}{i});
                end
                
                obj.changed = false;
                
            end
        end
        
    end
    
end