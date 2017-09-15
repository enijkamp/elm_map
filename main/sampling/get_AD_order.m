function AD_order = get_AD_order(config,des_net,gen_net,min_z_mat,min_z,...
                                                        min_ens,min_en)
    if strcmp(config.AD_heuristic,'1D_bar')
        barrier1D = flintmax*ones(1,size(min_z_mat,4));
        %%%%%%%% PARALLEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i = 1:length(barrier1D)          
            barrier1D(i) = max(get_gen_inter_ens(config,des_net,gen_net, ...
                single(min_z_mat(:,:,:,i)),min_z)); % ...
                  %- max([min_en,min_ens(i)]);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [~,AD_order] = sort(barrier1D);
    elseif strcmp(config.AD_heuristic,'dist')
        dists = flintmax*ones(1,size(min_z_mat,4));
        for i = 1:length(dists)
            dists(i) = norm(min_z(:)-reshape(min_z_mat(:,:,:,i),[],1));
        end
        [~,AD_order] = sort(dists);
    else
        error('need correct type for config.AD_heuristic');
    end
end
