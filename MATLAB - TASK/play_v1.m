clear

% game length
T = 1000;

% hazard rate
h = 0.1;

% fixed number of change points per L trials
L = 200;
ncp = h*L;
N = ceil(T / L);

% compute change points 
CP = [];
R = [];
for i = 1:N
    
    % change point locations
    X = false(L,1);
    q = randperm(L);
    X(q(1:ncp)) = true;
    CP = [CP; X];
    
    % values after change point
    Y = nan(L,1);
    
    %Y(q(1:ncp)) = ceil(100*rand(ncp,1));
    Y = ceil(rand_uniformSpread(100, 1, ncp))';
    R = [R; Y];
    
end

XX = nan(size(CP));
XX(find(CP)) = R;
