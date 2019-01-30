classdef rewardHistory_allie < handle
    
    properties
        
        bgpic
        blankpic
        
        stimDir
        window
        
        N % number of numbers that can be stored
        sf % scale factor
        counter
        
        rewHist
        
        centerPosition
        cps % center positions for bins
        topPosition
        
    end
    
    methods
        
        function obj = rewardHistory_allie(window, stimDir, N, sf)
            
            if exist('stimDir') == 1
                obj.stimDir = stimDir;
            end
            if exist('window') == 1
                obj.window = window;
            end
            if exist('N') == 1
                obj.N = N;
            end
            if exist('sf') == 1
                obj.sf = sf;
            end
            
        end
        
        function setup(obj, bgPicName, blankPicName, sf)
            
            if exist('bgPicName') ~= 1
                bgPicName = 'changed.png';
            end
            
            if exist('blankPicName') ~= 1
                blankPicName = '1.png';
            end
            
            for i = 1:obj.N
                bgpic(i) = picture(obj.window, ...
                    obj.stimDir, bgPicName);
                blankpic(i) = picture(obj.window, ...
                    obj.stimDir, blankPicName);
                bgpic(i).setup(obj.sf);
                blankpic(i).setup(sf);
            end
            
            obj.bgpic = bgpic;
            obj.blankpic = blankpic;
            obj.counter = 1;
            
        end
        
        function setPosition(obj, centerPosition)
            
            obj.centerPosition = centerPosition;
            
            for i = 1:obj.N
                sz1(i) = obj.bgpic(i).size(1);
                sz2(i) = obj.bgpic(i).size(2);
            end
            
            p_h = sz2; % picture_heights
            p_w = sz1; % picture_widths
            
            rh_cp_h = centerPosition(2); % reward history center pos height
            rh_cp_w = centerPosition(1); % reward history center pos width
            
            h = sum(p_h);
            w = sum(p_w);
            
            top = h/2 + rh_cp_h;
            bot = rh_cp_h - h/2;
            
            for i = 1:obj.N
                cp_h(i) = bot + sum(p_h(1:i));
                cp_w(i) = rh_cp_w;
            end
            
            obj.cps = [cp_w', cp_h'];
            
            
        end
        
        function setPositionByTop(obj, topPosition)
            
            obj.topPosition = topPosition;
            
            for i = 1:obj.N
                sz1(i) = obj.bgpic(i).size(1);
                sz2(i) = obj.bgpic(i).size(2);
            end
            
            p_h = sz2; % picture_heights
            p_w = sz1; % picture_widths
            
            h = sum(p_h);
            w = sum(p_w);
            
            rh_cp_w = topPosition(1);
            
            top = topPosition(2);
            bot = topPosition(2) + h;
            
            for i = 1:obj.N
                cp_h(i) = top + sum(p_h(1:i));
                cp_w(i) = rh_cp_w;
            end
            
            obj.cps = [cp_w', cp_h'];
            
        end
        
        function addReward(obj, rew)
            
            obj.rewHist{obj.counter} = rew;
            obj.counter = obj.counter + 1;
            
        end
        
        function flush(obj)
            
            obj.counter = 1;
            obj.rewHist = {};
            
        end
        
        function draw(obj)
            
            cps = obj.cps;
            
            % draw background
            for i = 1:obj.N
                obj.bgpic(i).draw(cps(i,:));
            end
            
            % draw rewards in reward history
            for i = 1:obj.counter-1
                obj.rewHist{i}.draw(cps(i,:));
            end
            
            % draw blank spots
            for i = obj.counter:obj.N
                obj.blankpic(i).draw(cps(i,:));
            end
            
            
        end
        
        
        
        
        
    end
    
    
end
