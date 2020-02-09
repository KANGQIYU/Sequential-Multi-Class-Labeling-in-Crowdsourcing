function [ reward ] = RolloutBelief( belief, depth)
%given a history and depth, use rolllout
global pomdp;
global indnrobservation;

if depth <= pomdp.rounds
%    content = POMCPTree.get(h);
%    belief = content(end);
    %Aindex = randi(pomdp.nrActions+1);
    [Aindex, ~, ~] = getAction_Declare(belief, pomdp.solution{depth});
    if ~isempty( pomdp.Allobservation{1})
        if Aindex <= pomdp.AllnrActions(depth)
            s = cumsum(belief');s(end) = 1;
            srand = rand;
            s = sum(s<srand)+1;
            o = cumsum(pomdp.Allobservation{depth}(s,:,Aindex));
            o(indnrobservation(Aindex):end) = 1;
            orand = rand;
            o = sum(o<orand)+1;
            belief= NextBeliefPOMDP( belief, Aindex, o, depth) ;
            reward =  pomdp.cost+pomdp.gamma*RolloutBelief( belief, depth+1); 
        else
            [penalty,~] = max(belief);
            reward = (1-penalty)*pomdp.L;
        end
    else
        if Aindex <= pomdp.nrActions
            s = cumsum(belief');s(end) = 1;
            srand = rand;
            s = sum(s<srand)+1;
            o = cumsum(pomdp.observation(s,:,Aindex));
            o(indnrobservation(Aindex):end) = 1;
            orand = rand;
            o = sum(o<orand)+1;
            belief= NextBeliefPOMDP( belief, Aindex, o, depth) ;
            reward =  pomdp.cost+pomdp.gamma*RolloutBelief( belief, depth+1);
        else
            [penalty,~] = max(belief);
            reward = (1-penalty)*pomdp.L;
        end
    end
else
%    content = POMCPTree.get(h);
%    belief = content(1);
    [penalty,~] = max(belief);
    reward = (1-penalty)*pomdp.L;
end


end

