function [ Bqe ] = GetBqe( M, q, e , numberofworker)
% notice this function is a temporary function to get B_mqe by run
% thousands of trials
hypothese = 1;
%H = 0.6*ones(1,100);
runtimes = 2000;
numofused = zeros(1,runtimes);
enoughworker = ones(1,runtimes) ;
parfor j = 1:runtimes
    state = cell(1,e+1);
    state{1} = [1:M];
    H = 0.6*ones(1,1000);
    for i = 1:numberofworker
        [ question, indexno ] = QaryQuestion( state, q, numberofworker-i+1 );
        [nonzero, truelocation] = Reliability1(hypothese, question, state);
        newq =  sum(nonzero);
        %reliable = zeros(newq,1);
        if truelocation == 0
            reliable = 1/newq*ones(newq,1);
        else
            trueloc = sum(nonzero(1:truelocation));
            reliable = (1-H(newq-1))/(newq-1)*ones(newq,1);
            reliable(trueloc ) = H(newq-1);
        end
        decision = sum(cumsum(reliable)<rand)+1;
        bb = find(nonzero>0);
        decision= bb(decision);
        [ state ] = QaryNextState( state, question, decision, indexno );
        statelement = [];
        for ii = 1:length(state)
            statelement = [statelement state{ii}];
        end
        
        if size(statelement,2)==1
            break;
        elseif size(statelement,2)==0
            disp('what the fuck');
        end
    end
    if i == numberofworker && size(statelement,2)>1
        enoughworker(j) = 0;
        numofused(j) = i;
    else
        numofused(j) = i;
    end
end
if isempty(find(enoughworker<1))
    Bqe = max(numofused);
else
    Bqe = 1000000;
end
end

function [nonzero, truelocation] = Reliability1(hypothese, question, state)
%this function is to get the Reliability of each worker when they decide
%yes or no answer.
q = size(question,1);
num_error = length(state)-1;
allquesmember = cell(q,1);
truelocation = 0;
%reliable = zeros(q,1);
nonzero = zeros(q,1);
for i = 1:q
    for j = 1:num_error+1
        allquesmember{i} = [allquesmember{i} question{i,j}];
    end
    if ~isempty(allquesmember{i})
        nonzero(i) = 1;
        if ismember(hypothese,allquesmember{i})
            truelocation = i;
        end
    end
end
end
