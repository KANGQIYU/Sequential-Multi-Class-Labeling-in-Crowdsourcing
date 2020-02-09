function [Used, True_False] =  QaryMonteCarloPOMCP( belief, rounds, pomdpcost, pomdpL)
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
global hypothese;
    

% [Used, Declare] = search(belief, rounds, cost);
%tic;
[Used, Declare] = Search(rounds, pomdpcost, pomdpL);
%toc;

if Declare == hypothese
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


