function [ELM_out,sorted_inds] = consolidate_minima(ELM)

    num_mins = length(ELM.min_IDs);
    sorted_inds = []; % basins to be consolidated
    
    %pair_ij = [repmat(1:num_mins,1,num_mins)',repelem(1:num_mins,num_mins)'];
    %pair_ij = pair_ij(pair_ij(:,1)<pair_ij(:,2),:);    
    pair_ij = get_pair_ij(ELM);
    
    %%%%%%%%%%%%%%%%%%%%%PARALLELIZE THIS%%%%%%%%%
    for ind = 1:size(pair_ij,1)
        ij = pair_ij(ind,:);
        disp([ij(1),ij(2),ind,size(pair_ij,1)]);
        mem_ij = [0,0];
        for k = 1:ELM.config.consolidate_reps
            [AD_out1,AD_out2]=gen_AD(ELM.config,ELM.config.des_net,...
                    ELM.config.gen_net,ELM.min_z(:,:,:,ij(1)),ELM.min_z(:,:,:,ij(2)));
            mem_ij = mem_ij+[AD_out1.mem,AD_out2.mem];
            if max(mem_ij) >= ELM.config.consolidate_quota
                disp('*');
                disp(ij);
                if mem_ij(1) == mem_ij(2)
                    [~,ord] = sort([ELM.min_ens(ij(1)),ELM.min_ens(ij(2))]);
                    sorted_inds(end+1) = ij(ord(2));
                else
                    [~,ord] = sort(mem_ij);
                    sorted_inds(end+1) = ij(ord(2));
                end
                disp(sorted_inds(end));
                break;
            end   
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    sorted_inds = unique(sorted_inds);
    new_min_z = ELM.min_z(:,:,:,setdiff(1:num_mins,sorted_inds));
    ELM_out = make_ELM_record(ELM.config,new_min_z);
end

function pair_ij = get_pair_ij(ELM)
    pair_ij = [];
    num_mins = length(ELM.min_IDs);
    inds = 1:num_mins;
    for i = inds
        i_inds = setdiff(inds,i);
        AD_order = get_AD_order(ELM.config,ELM.config.des_net,ELM.config.gen_net,...
                        ELM.min_z(:,:,:,i_inds),ELM.min_z(:,:,:,i));
        AD_order = i_inds(AD_order);
        new_ij = [repelem(i,min(num_mins-1,ELM.config.max_consolidate_checks))',...
                     AD_order(1:min(num_mins-1,ELM.config.max_consolidate_checks))'];
        new_ij = sort(new_ij,2);
        pair_ij = [pair_ij; new_ij];
    end
    pair_ij = unique(pair_ij,'rows');
end