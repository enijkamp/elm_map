function alpha_seq=run_ELM_experiment(config,num_exps,alpha_init)
    nsteps = config.nsteps;
    max_AD_checks = config.max_AD_checks;
    AD_reps = config.AD_reps;
    AD_quota = config.AD_quota;
    %load config for ELM experiments. only alpha and map_str will change
    if nargin<3 || isempty(alpha_init),alpha_init=[config.alpha,config.alpha]; end
    %find lower (infinite mins) and upper (single basin) bounds 
    % of magnetization strength for ADELM
    disp('### (0) find_AD_extrema ###');
    tic;
    [min_out,max_out] = find_AD_extrema(config,alpha_init);    
    toc;
    %alpha_seq = linspace(min_out.alpha,max_out.alpha,num_exps);
    alpha_seq = exp(linspace(log(min_out.alpha),log(max_out.alpha),num_exps));
    for i = 1:num_exps
        disp(['### (1) exp ' num2str(i) ' -> burn-in ###']);
        tic;
        config.alpha = alpha_seq(i);
        config.map_str = ['ELM_burnin',num2str(i),'.mat'];
        config.nsteps = floor(nsteps/2);
        config.max_AD_checks = floor(max_AD_checks/2);
        config.AD_quota = 1;
        config.AD_reps = 1;
        ELM_burnin = gen_ADELM([],config);
        toc;
        
        disp(['### (2) exp ' num2str(i) ' -> consolidate ###']);
        tic;
        ELM_test = consolidate_minima(ELM_burnin);
        toc;
        
        disp(['### (3) exp ' num2str(i) ' -> test ###']);
        tic;
        ELM_test.config.map_str = ['ELM_exp',num2str(i),'.mat'];
        ELM_test.config.nsteps = nsteps;
        ELM_test.config.max_AD_checks = max_AD_checks;
        ELM_test.config.AD_quota = AD_quota;
        ELM_test.config.AD_reps = AD_reps;
        gen_ADELM(ELM_test);
        toc;
    end
end