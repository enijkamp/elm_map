function [min_viz_ord,viz_mat_x,viz_mat_y] = viz_tree(nodes,min_ims,title_str,prop)
    if nargin < 3, title_str = ''; end
    if nargin < 4, prop = 0.125; end
    %nodes = permute_children(nodes);
    min_viz_ord = get_viz_order(nodes);
    viz_mat_x = [];
    viz_mat_y = [];
    for i = 1:length(nodes)
        if isempty(nodes{i}.children)
            nodes{i}.x = find(min_viz_ord==i);           
        else
            child_inds = nodes{i}.children;
            child1 = nodes{child_inds(1)};
            child2 = nodes{child_inds(2)};
            nodes{i}.x = 0.5*(child1.x+child2.x);
            viz_mat_x(end+1,:) = [child1.x,child1.x,child2.x,child2.x];
            viz_mat_y(end+1,:) = [child1.energy,nodes{i}.energy, ...
                                    nodes{i}.energy,child2.energy];
        end
    end
    
    figure(1);
    plot(viz_mat_x(1,:),viz_mat_y(1,:),'k');
    hold on;
    for i = 2:size(viz_mat_x,1)
        plot(viz_mat_x(i,:),viz_mat_y(i,:),'k');
    end
    min_e = flintmax;
    for i = 1:length(min_viz_ord)
        min_e = min([min_e,nodes{i}.energy]);
    end
    en_marg = (nodes{end}.energy-min_e);
    axis([0,length(min_viz_ord)+1,min_e-en_marg*prop*1.3,nodes{end}.energy+en_marg*prop/3]);
    xticks(1:length(min_viz_ord));
    xticklabels(string(1:length(min_viz_ord)));
    xlabel('Minima Index');
    ylabel('Energy');
    title(title_str);  
    if nargin > 1 
        for i = 1:size(min_ims,4)
            imagesc([i-7/16, i+7/16], [min_e-en_marg*(.3*prop), min_e-en_marg*prop], ...
                            min_ims(:,:,:,min_viz_ord(i)));
            colormap('Gray');
        end
    end
    set(gca,'dataAspectRatio',[7/8,  min_e-en_marg*.3*prop-(min_e-en_marg*prop), 1]);
    hold off;
end

function nodes = permute_children(nodes)
    for i = 1:length(nodes)
        if ~isempty(nodes{i}.children)
            if rand < 0.5
                nodes{i}.children = [nodes{i}.children(2),nodes{i}.children(1)];
            end
        end
    end
    
end

function [min_viz_order] = get_viz_order(nodes)
    ind = length(nodes);
    temp_order = ind;
    while ind > 0 && ~isempty(nodes{ind}.children)
        exp_ind = find(temp_order == ind);
        temp_order=[temp_order(1:(exp_ind-1)),nodes{ind}.children, ...
                        temp_order((exp_ind+1):length(temp_order)) ];
        ind = ind - 1;
    end
    min_viz_order =temp_order;
end