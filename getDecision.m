function [decision] = getDecision( Aindex, depth )
global matrixC;
global PeMatrix;
global workers;
global mu;
global pomdp;

reall = 0;
if ~isempty( pomdp.Allobservation{1})
    question = pomdp.AllActions{depth}{Aindex};
else
    question = pomdp.Actions{Aindex};
end

[newq, truelocation] = Reliability1(question);
if reall == 1
    reliable = (1-mu(newq-1))/(newq-1)*ones(newq,1);
    reliable(truelocation) = mu(newq-1);
    
    dist = inf(1, newq);
    B = cumsum(reliable,1);
    workerand = rand(1,workers);
    C = matrixC{newq-1};
    u = C(logical(sparse(sum(bsxfun(@le,repmat(B,1,workers),workerand),1)+1,1:workers,1,newq,workers)));
    for j = 1:newq
        dist(j) = pdist2(C(j,:), u','hamming')*codesize(2);
    end
    h = 1;
    [sortdist, index] = sort(dist);
    while sortdist(h) == sortdist(h+1)
        h = h+1;
        if h+1>length(dist)
            break;
        end
    end
    if h == 1
        decision = index(1);
    else
        decision = index(randi(h,1,1));
    end
    decision = decision - 1; %in C++, starts from 0
else

    newo = cumsum(PeMatrix{newq-1}(truelocation,:));
    newo(end) = 1;
    orand = rand;
    decision = sum(newo<orand); %ob = ob(in matlab)-1
end

end



function [q, truelocation] = Reliability1(question)
%this function is to get the Reliability of each worker when they decide
%yes or no answer.
global hypothese;

q = size(question,1);
truelocation = 0;
for i = 1:q
    if ismember(hypothese,question{i})
        truelocation = i;
        break;
    end
end
end