function [ Actions ] = ActionSample(set, q , size)
% max = computeStirlingNum(length(set), q);
% if max > wantnum
%    total = log10(total);
    %size = round(total(q-1)/sum(total)*wantnum);
%    size = ceil(total(q-1)/sum(total)*wantnum);
    Actions = ActionSampleSub(set, q, size);
% else
%     Actions = StirlingNumAction(set, q);
% end
end


