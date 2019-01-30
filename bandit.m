classdef bandit < handle
    properties
        %window
        window
        %draw
        w
        h
        w_lever
        h_lever
        left
        top
        horizon
        rect
        color
        color_highlight
        dotradius
        penwidth
        %font
        textSize
        textColour
        textWrapat
        %task
        numbers
        lever_side
    end
    methods
        function obj = bandit(window, textSize, textColour, textWrapat)
            obj.window = window;
            obj.setTextParameters(textSize, textColour, textWrapat);
        end
        function setTextParameters(obj, textSize, textColour, textWrapat)
            Screen('TextFont', obj.window, 'Arial');
            Screen('TextSize', obj.window, textSize);
            Screen('TextStyle', obj.window, 1);
            obj.textWrapat = textWrapat;
            obj.textSize = textSize;
            obj.textColour = textColour;
        end
        function setup(obj,w,h,w_lever,h_lever,horizon,color,color_highlight,lever_side)
            obj.color = color;
            obj.color_highlight = color_highlight;
            obj.w = w;
            obj.h = h;
            obj.w_lever = w_lever;
            obj.h_lever = h_lever;
            obj.penwidth = 5;
            obj.dotradius = 30;
            obj.horizon = horizon;
            obj.settppos(w/2,0);
            obj.lever_side = lever_side;
        end
        function settppos(obj,cleft,top)
            w = obj.w;
            h = obj.h;
            left = cleft - w/2;
            obj.left = left;
            obj.top = top;
            for i = 1:obj.horizon
                obj.rect(:,i) = [left+0 top+h*(i-1) left+w top+h*i];
            end
        end
        function flush(obj)
            obj.numbers = {};
        end
        function addreward(obj,new)
            obj.numbers = {obj.numbers{:} new};
        end
        function draw(obj,played,forcedchoice)
            if exist('forcedchoice') ~= 1
                forcedchoice = [];
            end
            window = obj.window;
            numbers = obj.numbers;
            rect = obj.rect;
            if (length(forcedchoice) == 0 && length(numbers) < size(rect,2))
                Screen('FillRect', window, obj.color_highlight, rect(:,length(numbers)+1));
            end
            Screen('FrameRect', window, obj.color, rect, obj.penwidth);
            for i = 1:length(numbers)
                
%    original             DrawFormattedText(window, numbers{i}, ...
%    original                 'center',rect(2,i)+7, obj.textColour,obj.textWrapat,0,0,1,0,rect(:,i)');

                DrawFormattedText(window, numbers{i}, ...
                    'center' ,rect(2,i)+34, obj.textColour,obj.textWrapat,0,0,1,0,rect(:,i)');
                
            end
            left = obj.left;
            top = obj.top;
            w = obj.w;
            h = obj.h;
            w_lever = obj.w_lever;
            h_lever = obj.h_lever;
            switch obj.lever_side
                case 'left'
                    fromH = left;
                    toH = fromH - w_lever;
                case 'right'
                    fromH = left + w;
                    toH = fromH + w_lever;
            end
            fromV = top + 5*h/2;
            if played
                toV = fromV + h_lever;
            else
                toV = fromV - h_lever;
            end
            Screen('DrawLine', window, obj.color, fromH, fromV, toH, toV, obj.penwidth);
            Screen('DrawDots', window, [toH toV], obj.dotradius,obj.color, [0 0], 1);
        end
    end
end