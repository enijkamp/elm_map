 alpha_seq = 675.6724 * 1.4078.^(0:9);
 config = gen_ADELM_config('ivy/512/');
 nsteps = config.nsteps;
 max_AD_checks = config.max_AD_checks;
 AD_quota = config.AD_quota;
 AD_reps = config.AD_reps;
 %enter experiment restart number here
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