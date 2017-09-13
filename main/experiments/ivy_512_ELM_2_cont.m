function [] = ivy_512_ELM_2_cont()

rng(123);

addpath(genpath('../../matconvnet-1.0-beta16/'));
addpath(genpath('../../main/'));
vl_setupnn();
vl_compilenn();

exp_time = tic;
%%%%%use the coop net 512_7 %%%%%%%
%set up config
file_str = 'ivy/512/';
config = gen_ADELM_config(file_str);
%refsig %%%%IMPORTANT: sqrt(0.3) for 512_7%%%%
config.refsig = sqrt(0.3);
%ELM params
config.nsteps = 1000;
config.num_mins = config.nsteps+1;
%AD params
config.alpha = 2500;
config.max_AD_checks = 10;
config.AD_reps = 3;
config.AD_quota = 1;
%AD extrema params
config.extrema_factor = 1.08; %grid search factor (greater than 1)
config.extrema_steps = 50;
config.max_extrema_checks = 5;
%consolidate params
config.max_consolidate_checks = 5;
config.consolidate_reps = 3;
config.consolidate_quota = 1;

%number of different magnetization strengths to be tested
num_exps = 10;
%upper and lower resolution for scale space boundary
alpha_init = [config.alpha,config.alpha];

%run experiment
no_workers = 24;

pool = gcp('nocreate');
delete(pool);
pool = parpool('comet3', no_workers, 'IdleTimeout', Inf);
parfor i = 1:no_workers
    vl_setupnn();
end

 %%%%%%%%%%%%%%%%%%%%%%%%%%
 alpha_seq = 675.6724 * 1.4078.^(0:9);
 config = gen_ADELM_config(file_str);
 nsteps = config.nsteps;
 max_AD_checks = config.max_AD_checks;
 AD_quota = config.AD_quota;
 AD_reps = config.AD_reps;
 %%%%%%%%%%%%%
 num_restart = 8;
 %%%%%%%%%%%%%
 
 for i = num_restart:10
    config.alpha = alpha_seq(i);
    config.map_str = ['ELM_burnin',num2str(i),'.mat'];
    config.nsteps = floor(nsteps/2);
    config.max_AD_checks = floor(max_AD_checks/2);
    config.AD_quota = 1;
    config.AD_reps = 1;
    ELM_burnin = gen_ADELM([],config);
    ELM_test = consolidate_minima(ELM_burnin);
    ELM_test.config.map_str = ['ELM_exp',num2str(i),'.mat'];
    ELM_test.config.nsteps = nsteps;
    ELM_test.config.max_AD_checks = max_AD_checks;
    ELM_test.config.AD_quota = AD_quota;
    ELM_test.config.AD_reps = AD_reps;
    gen_ADELM(ELM_test);

 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%


delete(pool);

exp_time = toc(exp_time);
fprintf('Total Experiment Time: %4d hours %4.2f minutes \n',...
                     floor(exp_time/3600), mod(exp_time/60,60));
                 
end
