function [Used, True_False, qaryquestion] =  QaryMonteCarloPOMDP( belief, mu, rounds, hypothese, CC)
%simulation question asking and answersing
%Input:
%      belief   : (vector) nrStates x 1 initial belief vector;
%      H        : (vector) nrStates x 1 workers reliability for different q-ary question
%      rounds   : (scalar) budget
%      hypothese: (scalar) the ture hiden state
%      %%solution : (cell)   rounds x 1 questions or declare in each round
%      CC       : (cell)   nrStates x 1 code matrix
%Output:
%      Used     : (scalar) number of worker groups used actually
%     True_False: (logical)the correctness of the final declaration
global pomdp;
codesize= size(CC{1});
workers = codesize(2);
Used  = 0;
declare = 0;
qaryquestion = zeros(1,rounds);
for i = 1:rounds
    [ question, Aindex ] = QaryQuestionPOMDP( belief , i);%%the solution is in the global pomdp
    if Aindex > pomdp.AllnrActions(i) %%question is empty now, no need to ask questions, time to declare
        declare = Aindex - pomdp.AllnrActions(i);
        Used = i-1;
        break;
    end
    
    [newq, truelocation] = Reliability1(hypothese, question);
    qaryquestion(i) = newq;
    reliable = (1-mu(newq-1))/(newq-1)*ones(newq,1);
    reliable(truelocation) = mu(newq-1);
    
    dist = inf(1, newq);
    B = cumsum(reliable,1);
    workerand = rand(1,workers);
    C = CC{newq-1};
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
    belief1 = belief;
    [belief] = NextBeliefPOMDP( belief, Aindex, decision, i);  
    if isnan(belief(1))
        disp('areyoukidding');
    end
end
if Used == 0&&declare == 0
    Used = rounds;
    [~,declare] = max(belief);
end
if declare == hypothese
    True_False = true;
else
    True_False = false;
end
end


function [q, truelocation] = Reliability1(hypothese, question)
%this function is to get the Reliability of each worker when they decide
%yes or no answer.
q = size(question,1);
truelocation = 0;
for i = 1:q
    if ismember(hypothese,question{i})
        truelocation = i;
        break;
    end
end
end
