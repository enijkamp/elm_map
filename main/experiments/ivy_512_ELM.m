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
run_ELM_experiment(config,num_exps,alpha_init);

exp_time = toc(exp_time);
fprintf('Total Experiment Time: %4d hours %4.2f minutes \n',...
                     floor(exp_time/3600), mod(exp_time/60,60));