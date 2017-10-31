function barrier_mat = get_barrier_mat_quick(ELM)
    %NOTE: gives the raw energy at the barriers between nodes, NOT
    % the difference in energy between min state and energy at barrier
    config = ELM.config;
    des_net = config.des_net;
    gen_net = config.gen_net;
    min_z = ELM.min_z;
    
    config.alpha = config.bar_alpha;
    num_mins = size(min_z,4);
    
    if num_mins == 1
        barrier_mat = get_gen_energy(config,des_net,gen_net,single(min_z(:,:,:,1)));
        return; 
    end
    
    barrier_mat = flintmax*ones(num_mins,num_mins);
    pair_ij = get_pair_ij(ELM);
    
%     %%%%% Parallelize %%%%%%%%%%%%
%     for rep = 1:size(pair_ij,1)
%         ij = pair_ij(rep,:);
%         z_i = single(min_z(:,:,:,ij(1)));
%         z_j = single(min_z(:,:,:,ij(2)));            
%         disp('****');
%         disp([ij,rep,size(pair_ij,1)]);
% 
%         [AD_out1,AD_out2] = gen_AD(config,des_net,gen_net,z_i,z_j);            
%         bar1 = flintmax;
%         if AD_out1.mem == 1, bar1 = max(AD_out1.ens); end
%         bar2 = flintmax;
%         if AD_out2.mem == 1, bar2 = max(AD_out2.ens); end
%         min_bar = min(bar1,bar2);
%         disp(min_bar);
%         if AD_out1.mem==1 || AD_out2.mem ==1
%             for k = 1:(config.bar_AD_reps-1)
%                 disp(k+1);
%                 [AD_out1,AD_out2] = gen_AD(config,des_net,gen_net,z_i,z_j);            
%                 if AD_out1.mem == 1, bar1 = max(AD_out1.ens); end
%                 bar2 = flintmax;
%                 if AD_out2.mem == 1, bar2 = max(AD_out2.ens); end
%                 min_bar = min([min_bar,bar1,bar2]);
%                 disp(min_bar);
%             end
%         end
%         barrier_mat(ij(1),ij(2)) = min_bar;
%         barrier_mat(ij(2),ij(1)) = barrier_mat(ij(1),ij(2));
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%

    %%%%% Parallel %%%%%%%%%%%%
    tocs = zeros(size(pair_ij,1), 1);
    tstart_parfor = tic;
    
    barrier_mat_seq = ones(size(pair_ij,1), 3);
    parfor rep = 1:size(pair_ij,1)
        tstart = tic;
        
        ij = pair_ij(rep,:);
        z_i = single(min_z(:,:,:,ij(1)));
        z_j = single(min_z(:,:,:,ij(2)));            
        disp([num2str(rep) ' ****']);
        disp([num2str(rep) ' ',num2str(ij(1)),num2str(ij(2)),num2str(size(pair_ij,1))]);

        [AD_out1,AD_out2] = gen_AD(config,des_net,gen_net,z_i,z_j);            
        bar1 = flintmax;
        if AD_out1.mem == 1, bar1 = max(AD_out1.ens); end
        bar2 = flintmax;
        if AD_out2.mem == 1, bar2 = max(AD_out2.ens); end
        min_bar = min(bar1,bar2);
        disp([num2str(rep) ' min_bar=' num2str(min_bar)]);
        if AD_out1.mem==1 || AD_out2.mem ==1
            for k = 1:(config.bar_AD_reps-1)
                disp([num2str(rep) ' k+1=' num2str(k+1)]);
                [AD_out1,AD_out2] = gen_AD(config,des_net,gen_net,z_i,z_j);            
                if AD_out1.mem == 1, bar1 = max(AD_out1.ens); end
                bar2 = flintmax;
                if AD_out2.mem == 1, bar2 = max(AD_out2.ens); end
                min_bar = min([min_bar,bar1,bar2]);
                disp([num2str(rep) ' min_bar=' num2str(min_bar)]);
            end
        end
        % requires sequential access for parfor
        %barrier_mat(ij(1),ij(2)) = min_bar;
        %barrier_mat(ij(2),ij(1)) = barrier_mat(ij(1),ij(2));
        barrier_mat_seq(rep, :) = [ij(1), ij(2), min_bar];
        
        tocs(rep) = toc(tstart);
    end
    
    toc_parfor = toc(tstart_parfor);
    disp(['get_barrier_mat_quick -> par = ' num2str(size(pair_ij,1)) ', parfor toc = ' num2str(toc_parfor) ', max toc = ' num2str(max(tocs))]);

    for rep = 1:size(pair_ij,1)
        ij = barrier_mat_seq(rep, 1:2);
        min_bar = barrier_mat_seq(rep, 3);
        
        barrier_mat(ij(1),ij(2)) = min_bar;
        barrier_mat(ij(2),ij(1)) = barrier_mat(ij(1),ij(2));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    for i = 1:num_mins
        barrier_mat(i,i) = get_gen_energy(config,des_net,gen_net,...
                                single(min_z(:,:,:,i))); 
    end   
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
        new_ij = [repelem(i,min(num_mins-1,ELM.config.max_bar_checks))',...
                     AD_order(1:min(num_mins-1,ELM.config.max_bar_checks))'];
        new_ij = sort(new_ij,2);
        pair_ij = [pair_ij; new_ij];
    end
    pair_ij = unique(pair_ij,'rows');
end
