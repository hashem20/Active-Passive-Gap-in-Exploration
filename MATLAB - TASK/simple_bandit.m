classdef simple_bandit < handle
    
    properties
        
        s_normal
        s_played
        
        col_normal
        col_played
        
        image_normal
        image_played
        
    end
    
    methods
        
        function obj = simple_bandit(s_normal, s_played, col_normal, col_played)
            
            obj.s_normal = s_normal;
            obj.s_played = s_played;
            obj.col_normal = col_normal;
            obj.col_played = col_played;
            
        end
        
        function setup(obj)
            
            
            S = obj.s_normal;
            col = obj.col_normal;
            M = cat(3, ...
                ones(S(1), S(2))*col(1), ...
                ones(S(1), S(2))*col(2), ...
                ones(S(1), S(2))*col(3));
            obj.image_normal = uint8(M);
            
            S = obj.s_played;
            col = obj.col_played;
            M = cat(3, ...
                ones(S(1), S(2))*col(1), ...
                ones(S(1), S(2))*col(2), ...
                ones(S(1), S(2))*col(3));
            obj.image_played = uint8(M);
            
            
            imresize(imread([obj.stimDir obj.name]), ...
                scaleFactor);
            obj.texture = Screen(obj.window, 'MakeTexture', obj.image);
            
            
        end
        
        function 
        
    end
    
end
