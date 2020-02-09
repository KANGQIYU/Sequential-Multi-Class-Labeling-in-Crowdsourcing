function [VN, totalN] = initVN (belief, depth)
global pomdp;
VN = ones(2,pomdp.nrActions+1);
% VdotB = belief'*pomdp.solution{depth}.SolutionSet;
% for j = 1:pomdp.nrActions
%     temp = max(VdotB(pomdp.forPOMCP{depth}{j}));
%     if isempty(temp)
%         VN(1,j) = -50;
%         VN(2,j) = 1;
%     else
%         VN(1,j) = temp;
%         VN(2,j) = 5;
%     end
% end
VN(1,pomdp.preferActions{depth}{1}) = -5.93;
VN(2,pomdp.preferActions{depth}{2}) = 10;
VN(1,pomdp.preferActions{depth}{2}) = -26.46;

VN(1,pomdp.nrActions+1) = (1-max(belief))*pomdp.L;
VN(2,pomdp.nrActions+1) = 1;

totalN = sum(VN(2,:));

end