function [ELM_out,sorted_inds] = consolidate_minima(ELM)

    num_mins = length(ELM.min_IDs);
    sorted_inds = []; % basins to be consolidated
    
    %pair_ij = [repmat(1:num_mins,1,num_mins)',repelem(1:num_mins,num_mins)'];
    %pair_ij = pair_ij(pair_ij(:,1)<pair_ij(:,2),:);    
    pair_ij = get_pair_ij(ELM);
    
    %%%%%%%%%%%%%%%%%%%%%PARALLELIZE THIS%%%%%%%%%
%     for ind = 1:size(pair_ij,1)
%         ij = pair_ij(ind,:);
%         disp([ij(1),ij(2),ind,size(pair_ij,1)]);
%         mem_ij = [0,0];
%         for k = 1:ELM.config.consolidate_reps
%             [AD_out1,AD_out2]=gen_AD(ELM.config,ELM.config.des_net,...
%                     ELM.config.gen_net,ELM.min_z(:,:,:,ij(1)),ELM.min_z(:,:,:,ij(2)));
%             mem_ij = mem_ij+[AD_out1.mem,AD_out2.mem];
%             if max(mem_ij) >= ELM.config.consolidate_quota
%                 disp('*');
%                 disp(ij);
%                 if mem_ij(1) == mem_ij(2)
%                     [~,ord] = sort([ELM.min_ens(ij(1)),ELM.min_ens(ij(2))]);
%                     sorted_inds(end+1) = ij(ord(2));
%                 else
%                     [~,ord] = sort(mem_ij);
%                     sorted_inds(end+1) = ij(ord(2));
%                 end
%                 disp(sorted_inds(end));
%                 break;
%             end   
%         end
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%PARALLEL%%%%%%%%%
    consolidate_minima_par = size(pair_ij,1);
    tocs = zeros(consolidate_minima_par, 1);
    tstart_parfor = tic;
    
    sorted_inds_par = {}; % changed (en)
    parfor ind = 1:size(pair_ij,1)
        %vl_setupnn();
        sorted_inds = [];
        
        tstart = tic;
        
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
        
        tocs(ind) = toc(tstart);
        sorted_inds_par{ind} = sorted_inds;
    end
    toc_parfor = toc(tstart_parfor);
    disp(['consolidate_minima -> par = ' num2str(consolidate_minima_par) ', parfor toc = ' num2str(toc_parfor) ', max toc = ' num2str(max(tocs))]);
    
    sorted_inds = [];
    for ind = 1:size(pair_ij,1)
        sorted_inds_lab = sorted_inds_par{ind};
        for j = 1:length(sorted_inds_lab)
            sorted_inds(end+1) = sorted_inds_lab(j);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    disp(sorted_inds);
    
    sorted_inds = unique(sorted_inds);
    new_min_z = ELM.min_z(:,:,:,setdiff(1:num_mins,sorted_inds));
    ELM_out = make_ELM_record(ELM.config,new_min_z);
end

function AD_order = get_AD_order(config,des_net,gen_net,min_z_mat,min_z,...
                                                        min_ens,min_en)
    if strcmp(config.AD_heuristic,'1D_bar')
        barrier1D = flintmax*ones(1,size(min_z_mat,4));
        for i = 1:length(barrier1D)          
            barrier1D(i) = max(get_gen_inter_ens(config,des_net,gen_net, ...
                single(min_z_mat(:,:,:,i)),min_z)); % ...
                  %- max([min_en,min_ens(i)]);
        end
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

function pair_ij = get_pair_ij(ELM)
    pair_ij = [];
    for i = 2:length(ELM.min_IDs)
        AD_order = get_AD_order(ELM.config,ELM.config.des_net,ELM.config.gen_net,...
                        ELM.min_z(:,:,:,1:(i-1)),...
                         ELM.min_z(:,:,:,i));
        new_ij = [repelem(i,min(i-1,ELM.config.max_consolidate_checks))',...
                     AD_order(1:min(i-1,ELM.config.max_consolidate_checks))'];
        pair_ij = [pair_ij; new_ij];
    end
end
