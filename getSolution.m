function getSolution( B )
% solution is saved in pomdp;
%Input:
%     B : (ndim x nr) a set of nr belief points whose dimension is ndim
global pomdp;
horizon = pomdp.rounds;
pomdp.solution = cell(horizon, 1);
horizon = pomdp.rounds;
CurrentSolution.SolutionSet= single(pomdp.L*(1-eye(pomdp.nrStates)));
CurrentSolution.SolutionAction = single([pomdp.nrActions+1:pomdp.nrActions+pomdp.nrStates]);
for i=1:horizon
    disp(i);
    if ~isempty( pomdp.Allobservation{1})
        pomdp.observation = pomdp.Allobservation{horizon - i + 1};
        pomdp.Actions = pomdp.AllActions{horizon - i + 1};
        pomdp.nrActions = pomdp.AllnrActions(horizon - i + 1);
        pomdp.reward = pomdp.Allreward{horizon - i + 1};
        pomdp.indnrobservation = pomdp.Allindnrobservation{horizon - i + 1};
    end
        
    [ pomdp.solution{horizon - i + 1} ] = Backup( B, CurrentSolution );
    CurrentSolution = pomdp.solution{horizon - i + 1};
    for j = 1:pomdp.nrActions+pomdp.nrStates
        pomdp.forPOMCP{horizon - i + 1}{j} = find(CurrentSolution.SolutionAction == j);
    end
    save('./pomdp529.mat');
end
for i = 1:horizon
    pomdp.solution{i}.SolutionSet = double(pomdp.solution{i}.SolutionSet);
    pomdp.solution{i}.SolutionAction = double(pomdp.solution{i}.SolutionAction);
end
pomdp.preferActions = cell(8,1);
for i = 1:pomdp.rounds
    pomdp.preferActions{i} = cell(2,1);
    pomdp.preferActions{i}{1} = zeros(1);
    pomdp.preferActions{i}{2} = zeros(1);
    m = 1;
    for j = 1:pomdp.nrActions
        if ~isempty(pomdp.forPOMCP{i}{j})
            pomdp.preferActions{i}{1}(m) = j;
            m = m+1;
        end
    end
    pomdp.preferActions{i}{2} = setdiff(1:pomdp.nrActions,pomdp.preferActions{i}{1});
end
pomdp.AllnrActions = double(pomdp.AllnrActions);
pomdp.observation = double(pomdp.observation);
pomdp.indnrobservation = double(pomdp.indnrobservation);
pomdp.reward = double(pomdp.reward);
pomdp.nrActions = double(pomdp.nrActions);
pomdp.L = double(pomdp.L);
pomdp.gamma = double(pomdp.gamma);
pomdp.cost = double(pomdp.cost);

end

