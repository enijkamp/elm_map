file_str = 'ivy/512/';
config = gen_ADELM_config(file_str);

for i = 1:10
    %load complete ELM experiment
    load([config.ELM_folder,file_str,'ELM_exp',...
            num2str(i),'.mat']);
        
    %adjust config
    ELM.config.bar_alpha = ELM.config.alpha * 2;
    ELM.config.max_bar_checks = 15;
    ELM.config.bar_AD_reps = 5;
    ELM.config.bar_temp = 20;
    
    %get barrier mat
    bar_mat = get_barrier_mat_quick(ELM);
    
    %save results
    save([ELM.config.tree_folder,file_str,'/bar_mat',num2str(i),'.mat'],'bar_mat');
end
