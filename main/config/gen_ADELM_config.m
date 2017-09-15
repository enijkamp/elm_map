function config = gen_ADELM_config(ELM_str,net_file)
    % location of Coop nets
    if nargin<1 || isempty(ELM_str)
        config.ELM_str = 'ivy/128/'; 
    else
        config.ELM_str = ELM_str;
    end
    % name of net file
    if nargin<2 || isempty(net_file) 
        config.net_file = 'nets.mat'; 
    else
        config.net_file = net_file;
    end
    
    %name of file for results
    config.map_str = 'ELM.mat'; 
    
    %MH parameters
    config.refsig = sqrt(0.3);
    config.MH_eps = 0.05; %step size
    config.MH_type = 'RW'; % 'RW' (random walk) or 'CW' (component-wise/gibbs)

    % parameters for ADELM
    config.nsteps = 1000; % number of ELM iterations
    config.num_mins = config.nsteps+1; % max number of basins on record
    config.AD_heuristic = '1D_bar'; % 1D linear interpolation '1D_bar'
                                       % or Euclidean dist 'dist'
                                      % determines AD order

    %local min search
    config.min_temp = .1; %temperature for min search
    config.min_sweeps = 5000; % max number of sweeps during min search
    config.min_no_improve = 30; % consecutive failed iters to stop search

    %attraction diffusion
    config.AD_temp = 20; % AD temperature parameter
    config.alpha = 1280; % AD magnetization strength
    %4700
    config.max_AD_iter = 5000;  % max iters for AD trial
    config.AD_no_improve = 40; % consecutive iters to stop search
    config.dist_res = .35; % distance from target for successful AD search
    config.max_AD_checks = 10; % number of minima for AD trials
    config.AD_reps = 3; % number of AD attempts for each min 
    config.AD_quota = 1; % number of successful trials needed for membership
    config.update_min_states = 1; % change basin reps (1) or not (0)
    
    %parameters for AD extrema search
    config.extrema_factor = 1.08; %grid search factor (greater than 1)
    config.extrema_steps = 50;
    config.max_extrema_checks = 5;
    
    % parameters for minima consolidation
    config.max_consolidate_checks = 5;
    config.consolidate_reps = 3;
    config.consolidate_quota = 1;
    
    % parameters for barrier estimation
    config.bar_temp = 20;
    config.bar_alpha = 8000; 
    config.bar_factor = 1.05; %grid search factor, greater than 1
    config.bar_AD_reps = 4; % number of AD trials during bar search
    config.max_bar_checks = 15; % number of checks in barrier search
        
    % data location
    config.data_path = '/Users/mitch/Dropbox/coop ADELM/data/';
    % location of Co-op Nets
    config.net_path = '/Users/mitch/Dropbox/coop ADELM/nets/';
    % folder for ELM results
    config.ELM_folder = '/Users/mitch/Dropbox/coop ADELM/maps/';
    % folder for images in generator space
    config.im_folder = '/Users/mitch/Dropbox/coop ADELM/ims/';
    % folder for ELM Trees
    config.tree_folder = '/Users/mitch/Dropbox/coop ADELM/trees/';

    % create results directory
    if ~exist('/Users/mitch/Dropbox/coop ADELM/maps/', 'dir')
        mkdir('/Users/mitch/Dropbox/coop ADELM/maps/')
    end

    if ~exist('/Users/mitch/Dropbox/coop ADELM/ims/', 'dir')
        mkdir('/Users/mitch/Dropbox/coop ADELM/ims/')
    end
    
    if ~exist('/Users/mitch/Dropbox/coop ADELM/trees/', 'dir')
        mkdir('/Users/mitch/Dropbox/coop ADELM/trees/')
    end
    
    %%%read in networks%%%
    %digits nets
    if strcmp(config.ELM_str,'digits/')
        net_wkspc = load([config.net_path,config.ELM_str,config.net_file]);
        config.des_net = net_wkspc.nets.des_net;
        config.gen_net = net_wkspc.nets.gen_net;
        config.mean_im = config.des_net.mean_im;
        config.z_sz = [1,1,8];
        config.im_sz = [64,64,1];
    end
    %ivy nets
    if strcmp(config.ELM_str(1:3),'ivy')
        net_wkspc = load([config.net_path,config.ELM_str,config.net_file]);
        config.des_net = net_wkspc.net1;
        config.gen_net = net_wkspc.net2;
        config.mean_im = config.des_net.mean_im;
        config.z_sz = [1,1,15];
        config.im_sz = [32,32,3];
    end
end