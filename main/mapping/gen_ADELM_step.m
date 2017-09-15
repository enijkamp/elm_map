function ELM = gen_ADELM_step(config,des_net,gen_net,ELM)    
    %generate z from latent normal distribution
    z = randn(config.z_sz,'single');
    [en,im] = get_gen_energy(config,des_net,gen_net,z);
    imwrite(im/256,[config.im_folder,'gen_im.png']);
    
    % find local min of z in generator space
    disp('Finding local min');
    min_search_time = tic;
    [min_z,min_im,~,min_en] = find_gen_min(config,des_net,gen_net,z);
    min_search_time = toc(min_search_time);
    fprintf('%4.2f seconds \n',min_search_time);
    fprintf('----\n');
    
    imwrite(min_im/256,[config.im_folder,'min_im.png']);
   
    % determine if this local min can be identified with previous min
    disp('Checking minimum membership');
    AD_time = tic;
    [ELM,min_index,AD_inds] = check_membership(config,des_net,gen_net,...
                                    ELM,min_z,min_en,min_im);
    AD_time = toc(AD_time);
    fprintf('%4.2f seconds \n',AD_time);
    
    %include the new minimum in the mapping record
    if min_index <= config.num_mins
        ELM = update_ELM_record(ELM,z,im,min_z,min_im,en,min_en,...
                ELM.min_IDs(min_index),AD_inds); 
    end
    fprintf('----\n');
end

function [ELM,min_index,AD_inds] = check_membership(config,des_net,gen_net,ELM,...
                                                min_z,min_en,min_im)
    min_index = 0;
    AD_inds = [];
    % use heuristic (1D barrier or distance) to find order for AD
    AD_order = get_AD_order(config,des_net,gen_net,ELM.min_z,min_z,...
                                                ELM.min_ens,min_en);  
    
    %check membership according to the energy of the n closest local
    %minima, according to heuristic (config.max_AD_checks)
    AD_mem = zeros(min(config.max_AD_checks,length(AD_order)),2);
    AD_bars = flintmax*ones(1,min(config.max_AD_checks,length(AD_order)));
    for rep = 1:config.AD_reps
        
        %%%%%%%%%%%%%%%%%%%%PARALLELIZE%%%%%%%%%%%%
%         for i = 1:min(config.max_AD_checks,length(AD_order)) 
%             AD_index = AD_order(i);
%             
%             % AD diffusion between new and previously found minima
%             [AD_out1,AD_out2]=gen_AD(config,des_net,gen_net,min_z,...
%                         ELM.min_z(:,:,:,AD_index));
%             AD_mem(i,:) = [AD_out1.mem,AD_out2.mem];
%             AD_bars(i) = min([max(AD_out1.ens),max(AD_out2.ens)]);
%         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%PARALLEL%%%%%%%%%%%%%%%%%%
        gen_AD_par = min(config.max_AD_checks,length(AD_order));
        tocs = zeros(gen_AD_par, 1);
        tstart_parfor = tic;
        parfor i = 1:min(config.max_AD_checks,length(AD_order))
            tstart = tic;
            
            AD_index = AD_order(i);
            % AD diffusion between new and previously found minima
            [AD_out1,AD_out2]=gen_AD(config,des_net,gen_net,min_z,...
                        ELM.min_z(:,:,:,AD_index));
            AD_mem(i,:) = [AD_out1.mem,AD_out2.mem];
            AD_bars(i) = min([max(AD_out1.ens),max(AD_out2.ens)]);
            
            tocs(i) = toc(tstart);
        end
        toc_parfor = toc(tstart_parfor);
        disp(['check_membership -> par = ' num2str(gen_AD_par) ', parfor toc = ' num2str(toc_parfor) ', max toc = ' num2str(max(tocs))]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %check if successful diffusion quota for membership is reached
        if max(sum(AD_mem,2)) >= config.AD_quota
            mem_inds = find(sum(AD_mem,2)==max(sum(AD_mem,2)));
            AD_inds = AD_order(mem_inds);
            fprintf('successful diffusion to: %s\n',sprintf('%d ',...
                                        AD_order(mem_inds)));
            min_index = AD_order(mem_inds(find(AD_bars(mem_inds)==...
                                    min(AD_bars(mem_inds)),1,'first')));            
            fprintf('min sorted to basin %d\n',min_index);
            % if the new min has lower energy than the previous
            % basin rep, it becomes the new basin rep
            if min_en < ELM.min_ens(min_index) && config.update_min_states==1
                fprintf('basin %d rep updated \n',min_index);
                ELM.min_ims(:,:,:,min_index) = min_im;
                ELM.min_z(:,:,:,min_index) = min_z;
                ELM.min_ens(min_index) = min_en;
            end
            break;
        end
    end

    %if no AD chain is successful, start a new min group
    if min_index == 0
        if length(ELM.min_IDs) < config.num_mins
            min_index = length(ELM.min_IDs)+1;
            fprintf('new min found (ID %d)\n',min_index);
            ELM.min_ens(min_index) = min_en;
            ELM.min_ims(:,:,:,min_index) = min_im;
            ELM.min_z(:,:,:,min_index) = min_z;
            ELM.min_IDs(min_index) = max(ELM.min_IDs)+1;
        elseif min_en < max(ELM.min_ens)
            min_index = find(ELM.min_ens==max(ELM.min_ens),1,'first');
            fprintf('new min found (ID %d)\n',min_index);
            ELM.min_ens(min_index) = min_en;
            ELM.min_ims(:,:,:,min_index) = min_im;
            ELM.min_z(:,:,:,min_index) = min_z;
            ELM.min_IDs(min_index) = max(ELM.min_IDs)+1;
        else
            fprintf('min discarded \n');
            ELM.mins_discarded = ELM.mins_discarded+1;
            min_index = config.num_mins+1;
        end
    end
end