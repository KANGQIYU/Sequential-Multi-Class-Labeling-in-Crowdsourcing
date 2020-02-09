function actions = SampleUlamRenyiActions(nrStates, q, e, horizon, wantnum)
%%Unleaf Node is a 5*1 cell which contains five elements{state,question,QuestionElementNum,isfull,branch}
%                                                           1     2           3               4      5
% question is cell currentq*1, isfull is a indicator vector, branch is a currentq*1 cell which contains the child nodes.
%actions = cell(wantnum,1);
Tree{1} = cell(1,e+1);
Tree{1}{1} = [1:nrStates];
[ question ] = QaryQuestion( Tree{1}, q, horizon);
Tree{2} = question;
nonzero = zeros(q,1);
allquesmember = cell(q,1);
QuestionElementNum = 0;
qq = 1;
for i = 1:q
    for j = 1:e+1
        allquesmember{i} = [allquesmember{i} question{i,j}];
    end
    if ~isempty(allquesmember{i})
        nonzero(i) = 1;
       QuestionElementNum(qq) = length(allquesmember{i});
        qq = qq+1;
    end
end
Tree{2} = question(find(nonzero>0),:);
Tree{3} = QuestionElementNum;
Tree{4} = zeros(q,1);
Tree{5} = cell(q,1);
actions{1,1} = allquesmember;
currentnum = 2;
while currentnum <= wantnum
    if sum(Tree{4}) < size(Tree{2},1)
        [ action, Tree] = QuesTree( Tree, horizon-1, q);
        if ~isempty(action)
            statelement = [];
            fullquestion = action;
            newq = length(action);
            for ii = 1:newq
                statelement = [statelement action{ii}];
            end
            statelement_out = setdiff(1:nrStates,statelement);
            sonum = length(statelement_out);
            indeex = randperm(sonum);
            partition = sort(randi(sonum+1,newq-1,1))-1;
            partition(newq) = sonum;
            endd = 0;
            for j = 1:newq
                begin = endd+1;
                endd = partition(j);
                fullquestion{j} = [fullquestion{j} statelement_out(indeex(begin:endd))];
            end
            actions{currentnum,1} = fullquestion;
            currentnum = currentnum+1;
        end
    else
        break;
    end
end
end