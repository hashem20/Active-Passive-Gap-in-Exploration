function r = rand_uniformSpread(r_max, r_min, K)

% r = rand_uniformSpread(r_max, r_min, K)
%
% 

% Robert Wilson
% 16/04/13

dr = (r_max-r_min) / K;

rb = [r_min:dr:r_max-dr];
r = dr*rand(1,K) + rb;
r = r(randperm(length(r)));