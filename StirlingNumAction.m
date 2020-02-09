%% subsets is cell, in this version, we ensure our sampling will get 5000 
function subsets = StirlingNumAction(set, box)
%% ways to partition a set of  objects into box non-empty subsets
%% return subsets which are two level cells
    
    if size(set,2) == box
        subsets = cell(1,1);
        for i = 1:box
            subsets{1}{i,1} = set(i);
        end
    elseif box == 1
        subsets{1}{1} = set;
    else
        subsubsets1 = StirlingNumAction(set(1:end-1), box);
        subsubsets2 = StirlingNumAction(set(1:end-1), box-1);
        part1num = length(subsubsets1);
        part2num = length(subsubsets2);
        subsets = cell(part1num*box+part2num,1);
        for i = 1:part1num
            for j = 1:box
                subsets{box*(i-1)+j} = subsubsets1{i};
                subsets{box*(i-1)+j}{j} = [subsubsets1{i}{j} set(end)];
            end
        end
        for i = 1:part2num
            subsets{i+part1num*box} = subsubsets2{i};
            subsets{i+part1num*box}{box,1} = set(end);
        end
    end
        
end