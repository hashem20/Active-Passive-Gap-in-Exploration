classdef analysis_tools < handle
    properties
    end
    methods
        function obj = analysis_tools()
        end
        function [y_new, mx] = curve_smooth(obj, y, x, x_new, sigma)
            te = obj.denan([x, y]);
            x = te(:,1); y = te(:,2);
            [x, y] = obj.curve_unique(x, y);
            for i = 1:length(x_new)
                [px, mx(i)] = obj.dis_gaussian(x, x_new(i), sigma);
                y_new(i) = sum(px.*y);
            end

        end
        function [px, mx] = dis_gaussian(obj, x, mu, sigma)
            px = normpdf(x, mu, sigma);
            px = px/sum(px);
            mx = sum(px.*x);
        end
        function [rx, ry] = curve_unique(obj, x, y)
            [x, ind] = sort(x);
            y = y(ind);
            rx = unique(x);
            ry = zeros(size(rx));
            for i = 1:length(rx)
                ind = x == rx(i);
                ry(i) = mean(y(ind));
            end
        end
        function x = denan(obj, x)
            ind = ~isnan(sum(x,2));
            x = x(ind,:);
        end
    end
end