function [min_out,max_out] = find_AD_extrema(config,alpha_init,dir)
    min_out = []; max_out = [];
    if nargin < 2 || isempty(alpha_init),alpha_init=[config.alpha,config.alpha];end
    if nargin < 3 || isempty(dir), dir = 0; end
    
    nsteps = config.extrema_steps;
    factor = config.extrema_factor;
    config.nsteps = 1;
    config.num_mins = nsteps+1;
    config.max_AD_checks = config.max_extrema_checks;
    config.AD_reps = 1;
    config.AD_quota = 1;
    config.update_min_states = 1;
    
    if dir == 0
        config.alpha = alpha_init(1);
        min_out = get_extreme_alpha(config,factor,-1,nsteps);
        config.alpha = alpha_init(2);
        max_out = get_extreme_alpha(config,factor,1,nsteps);
    elseif dir < 0
        config.alpha = alpha_init(1);
        min_out = get_extreme_alpha(config,factor,-1,nsteps);
    elseif dir > 0
        config.alpha = alpha_init(2);
        max_out = get_extreme_alpha(config,factor,1);
    end  
end

function out = get_extreme_alpha(config,factor,dir,nsteps)
    if dir == -1, goal = 2; end
    if dir == 1, goal = 1; end
    
    ELM_test = gen_ADELM([],config);
    count = 1;
    while count < nsteps && max(ELM_test.min_IDs)==goal
        count = count+1;
        ELM_test = gen_ADELM(ELM_test);
        if dir == -1, goal = goal + 1; end
    end
    out.min_count(1) = max(ELM_test.min_IDs);
    out.alpha_list(1) = config.alpha;
    disp(out.min_count(1));
    disp(out.alpha_list(1));
       
    sgn = 1*(max(ELM_test.min_IDs)==goal);
    cont = sgn;
    while cont == sgn
        if sgn == 0; config.alpha = config.alpha*(factor^dir);
        else, config.alpha = config.alpha/(factor^dir); end      
        ELM_test = gen_ADELM([],config);
        count = 1; 
        if dir == -1, goal = 2; end
        while count < nsteps && max(ELM_test.min_IDs)==goal
            count = count+1;
            ELM_test = gen_ADELM(ELM_test);
            if dir == -1, goal = goal + 1; end
        end
        out.min_count(end+1) = max(ELM_test.min_IDs);
        out.alpha_list(end+1) = config.alpha;
        disp(out.min_count(end));
        disp(out.alpha_list(end));
        cont = 1*(max(ELM_test.min_IDs)==goal);
    end
    
    if sgn == 1, out.alpha = out.alpha_list(end-1);
    else, out.alpha = out.alpha_list(end); end
end

    