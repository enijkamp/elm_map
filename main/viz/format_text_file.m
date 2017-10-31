function format_text_file(ELM,inds,title,scale,num)
    num_obs = zeros(1,length(inds));
    for i = 1:length(inds)
        num_obs(i) = sum(ELM.min_ID_path==inds(i));
    end
    if nargin <4 || isempty(scale), scale = 1; end
    fileID = fopen('/Users/mitch/Dropbox/coop ADELM/main/viz/info.txt','w');
    fprintf(fileID,'\\begin{center} \n');
    fprintf(fileID,['\\textbf{',title,'} \\\\ \n\n']);  
    fprintf(fileID,'\\begin{tabular}{c|c|c|c} \n');
    fprintf(fileID,'\\hline Min. & Basin & Randomly Selected Members & Member \\\\ \n');
    fprintf(fileID,'Index & Rep. & (arranged from low to high energy) & Count \\\\ \n');
    for i = 1:length(inds)
        fprintf(fileID,['\\hline ',num2str(i),' & \\includegraphics[scale = ',num2str(scale),']{basin',num2str(inds(i)),'_min.png} & ']);
        for j = 1:min(num,num_obs(i))
            fprintf(fileID,['\\includegraphics[scale = ',num2str(scale),']{basin',num2str(inds(i)),'_',num2str(j),'.png}']);
            if j == min(num,num_obs(i)), fprintf(fileID,['& ',num2str(num_obs(i)),'\\\\ \n']); else, fprintf(fileID,' '); end
        end
    end
    fprintf(fileID,'\\end{tabular} \n\\end{center}');
    fclose(fileID);
end