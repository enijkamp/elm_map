file_str = 'ivy/512/';
config = gen_ADELM_config(file_str);

for i = 1:10
    %load complete ELM experiment
    load([config.ELM_folder,file_str,'ELM_exp',num2str(i),'.mat']);
        
    %adjust config
    ELM.config.max_consolidate_checks = 10;
    ELM.config.consolidate_reps = 8;
    
    %get barrier mat
    ELM = consolidate_minima(ELM);
    
    %save results
    save([ELM.config.ELM_folder,file_str,'ELM_consolidate',num2str(i),...
            '.mat'],'ELM');
end
