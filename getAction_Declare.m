function [ A, IMax, Value] = getAction_Declare( beliefs, solution)
% getAction - extract actions for a belief set from a policy
%
%Input:
%       beliefs   : (matrix) nrStates x nrBelief belief set to consider
%       solution : (struct) it has two fields
%                  .SolutionSet (nrStates x sl) a set of sl solution vectors whose
%                     dimension is nrStates.
%                  .SolutionAction  (1 x sl)
%
%Output:
%       A       :(n x 1) the action for each belief in beliefs
%       IMax    :(n x 1) index of maximizing vector in solution
%       Value   :(n x 1) the optimal value
VdotB=beliefs'*solution.SolutionSet;
[Value,IMax]=max(VdotB,[],2);
A = solution.SolutionAction(IMax);
end

