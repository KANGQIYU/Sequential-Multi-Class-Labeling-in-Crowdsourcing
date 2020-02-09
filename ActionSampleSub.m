%% subsets is cell, in this version, we ensure our sampling will get the set whose size is 'size' 
function Actions = ActionSampleSub(set, box, size)
%% ways to partition a set of  objects into box non-empty subsets
%% return subsets which are two level cells
Actions = cell(size,1);
for i = 1:size
    indeex = randperm(length(set));
    partition = sort(randperm(length(set)-1,box-1));
    partition(box) = length(set);
    endd = 0;
    for j = 1:box
        begin = endd+1;
        endd = partition(j);
        Actions{i}{j,1} = set(indeex(begin:endd));       
    end
end   
end