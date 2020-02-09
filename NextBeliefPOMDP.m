function [belief1] = NextBeliefPOMDP( belief, a, o, depth) 
% update the belief.
%Input:
%       belief : (vector) nrStates x 1
%       a      : (integer)action (question)
%       o      : (integer)observation (decision)
global pomdp;
if ~isempty( pomdp.Allobservation{1})
    belief1 = belief.*pomdp.Allobservation{depth}(:,o,a);
else
    belief1 = belief.*pomdp.observation(:,o,a);
end
belief1 = belief1./sum(belief1);

end

