myCluster = parcluster('local');
for i=1:4
jsl = [ '/home/enijkamp/pool/comet' num2str(i) ]
if ((isdir([jsl]) == 0))
    mkdir(jsl)
end
set(myCluster, 'JobStorageLocation', jsl);
saveAsProfile(myCluster,['comet' num2str(i)]);
myCluster
end
