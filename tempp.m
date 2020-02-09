for i=1:8  
    for j = 1:pomdp.nrActions+pomdp.nrStates;
        pomdp.forPOMCP{i}{j} = find(pomdp.solution{i}.SolutionAction == j);
    end
    save('./pomdp529.mat');
end