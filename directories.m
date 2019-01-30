%% Set up directories -----------------------------------------------------

computerName = evalc('!hostname');
computerName = computerName(1:end-1);
switch computerName
    
    
    case 'banjo.csbmb.princeton.edu'
        
        remote_pc = 'BanjoASL.pni.Princeton.edu';
    
    case 'jug.csbmb.princeton.edu'
        
        remote_pc = 'JugASL.pni.Princeton.edu';
    
    case 'jawharp.csbmb.princeton.edu'
        
        remote_pc = 'JawharpASL.pni.Princeton.edu';
    
    otherwise
        remote_pc = [];
        
end

maindir = ['/Users/wilsonlab/Box Sync/2016_Fall/experiments/019-Explore-Exploit/'];
% banditsXdir = [maindir 'banditsX_toolbox/v2/code/core/'];

% change this if you change the location of the file
taskdir = [maindir];;
% taskdir = [maindir '2015_Fall/017_infiniteBanditsUpdate/'];;
fundir = [taskdir 'functions/'];
% fundir_2 = [maindir 'alliesTask/functions/'];


% addpath(banditsXdir)
addpath(taskdir)
addpath(fundir)
% addpath(fundir_2)

stimdir = [taskdir 'stimuli/'];
stimdir_bw = [taskdir 'stimuli/bw/'];
stimdir_col = [taskdir 'stimuli/col/'];
stimdir_iso = [taskdir 'stimuli/iso/'];
stimdir_pics = [taskdir 'stimuli/pics/'];
sounddir = [taskdir 'stimuli/sounds/'];

datadir = [taskdir 'data/'];
