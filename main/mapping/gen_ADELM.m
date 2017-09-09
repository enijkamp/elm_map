function ELM = gen_ADELM(ELM,config)
  
    ELM_time = tic;
    if nargin < 1 || isempty(ELM)
        %read in config parameters
        if nargin < 2 || isempty(config), config = gen_ADELM_config; end
        des_net = config.des_net;
        gen_net = config.gen_net;
        
        %start chain
        z = randn(config.z_sz,'single');
        [en,im] = get_gen_energy(config,des_net,gen_net,z);
        [min_z,min_im,~,min_en] = find_gen_min(config,des_net,gen_net,z);

        %make new record
        ELM = make_ELM_record(config,min_z);
        ELM = update_ELM_record(ELM,z,im,min_z,min_im,en,min_en,1,1); 
    else
        % load config from old ELM
        config = ELM.config;
        des_net = config.des_net;
        gen_net = config.gen_net;
        ELM.new_chain(end+1) = length(ELM.min_ID_path)+1;
    end
    
    viz_min_ims(ELM.min_ims,config.im_folder);
    for rep = 1:config.nsteps    
        fprintf('\n');
        fprintf('ELM Step %d of %d\n',rep,config.nsteps);
        fprintf('----\n');
        % find new min and classify in each ELM step
        ELM = gen_ADELM_step(config,des_net,gen_net,ELM);
   
        %save results
        viz_min_ims(ELM.min_ims,config.im_folder,1);
        save([config.ELM_folder,config.ELM_str,config.map_str],'ELM');
    end  
    
    ELM_time = toc(ELM_time);
    fprintf('\n');
    fprintf('Total mapping time: %4.2f seconds \n',ELM_time);
    fprintf('%4.2f seconds per ELM iteration \n',ELM_time/config.nsteps);
    fprintf('\n');   
end