function format_min_ims(ELM,inds,im_folder,num)
    delete([im_folder,'*.png']);
    for i = 1:length(inds)
        num_obs = sum(ELM.min_ID_path==inds(i));
        if i==1, viz_basin_ims(ELM,inds(1),im_folder,ELM.config,ELM.config.des_net,min(num,num_obs));
        else, viz_basin_ims(ELM,inds(i),im_folder,ELM.config,ELM.config.des_net,min(num,num_obs),1); end
    end
end