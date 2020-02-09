function [ action, Tree ] = QuesTree( Tree, roundsleft, q)
%%Unleaf Node is a 5*1 cell which contains five elements{state,question,QuestionElementNum,isfull,branch}
%                                                           1     2           3               4      5
% question is cell currentq*1, isfull is a indicator vector, branch is a currentq*1 cell which contains the child nodes.
if length(Tree)<5
    disp('fuck');
    action = [];
else
if sum(Tree{4}) < length(Tree{3})
    searchindex = find(Tree{4}==0);
    sampleprobability = cumsum(Tree{3}(searchindex)/sum(Tree{3}(searchindex)));
    prand = rand;
    decision = searchindex(sum(sampleprobability<prand)+1);
    if isempty(Tree{5}{decision})
        %Tree{5}{decision} = cell(1,5);
        Tree{5}{decision}{1} = QaryNextState( Tree{1}, Tree{2}, decision);
        statelement = [];
        for ii = 1:length(Tree{5}{decision}{1})
            statelement = [statelement Tree{5}{decision}{1}{ii}];
        end
        if size(statelement,2)==1
            Tree{4}(decision) = 1;   %%this branch is full
            action = [];
        elseif roundsleft > 0
            [ question ] = QaryQuestion( Tree{5}{decision}{1}, q, roundsleft );
            allquesmember = cell(q,1);
            QuestionElementNum = zeros(q,1);
            for i = 1:q
                for j = 1:length(Tree{5}{decision}{1})
                    allquesmember{i} = [allquesmember{i} question{i,j}];
                end
                QuestionElementNum(i) = length(allquesmember{i});
            end
            Tree{5}{decision}{2} = question(QuestionElementNum>0,:);
            Tree{5}{decision}{3} = QuestionElementNum(QuestionElementNum>0);
            Tree{5}{decision}{4} = zeros(length(Tree{5}{decision}{3}),1);
            Tree{5}{decision}{5} = cell(length(Tree{5}{decision}{3}),1);
            action = allquesmember(QuestionElementNum>0,:);
        else
            disp('wrong');
        end
        
    else
        [action, Tree{5}{decision}] = QuesTree (Tree{5}{decision},roundsleft-1,q);
        if sum(Tree{5}{decision}{4}) == length(Tree{5}{decision}{3})
            Tree{4}(decision) = 1;
        end
    end
end

end



