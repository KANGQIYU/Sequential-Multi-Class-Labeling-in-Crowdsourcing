function [True_False, used, actionsequence] =  QaryMonteCarloFeedback( astate, H, q, rounds, hypothese, num_error, varargin)
%If H is 1 dimensional vector, then this is the average reliability of worker for each q
%Input:
%state      :(scalar) is the size of the classification space.
%H          :(matrix) average reliability of worker for each q
%hypothese  :(scalar) set a num between 1-M as a hypothese.
%rounds     :(scalar) num of groups
%num_error  :(scalar) parameter of ulam-renyi game
%varargin   :(cell)  q code matrix
%
%Output:
%True_False :(scalar) if we finally get the correct answer.
%used       :(scalar) stop time (num of used groups )
%
True_False = false;
actionsequence = cell(1,1);
if isa(astate,'double')
    state = cell(1,num_error+1);
    state{1} = [1:astate];
    M = astate;
else
    state = astate;
    M = 0;
    for i = 1:length(astate)
        M = M + length(astate{i});
    end
end
%%
if size(H,1)>1&&size(H,2)>1
    if length(varargin) == 1
        C = varargin{1};
        codesize= size(C);
        workers = codesize(2);
        for i = 1:rounds
            [ question, indexno ] = QaryQuestion( state, q, rounds-i+1 );
            reliable = Reliability(hypothese, H, question, state);
            dist = zeros(1, q);
            B = cumsum(reliable,1);
            workerand = rand(1,workers);
            u = C(logical(sparse(sum(bsxfun(@le,repmat(B,1,workers),workerand),1)+1,1:workers,1,q,workers)));
            for j = 1:q
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
            [ state ] = QaryNextState( state, question, decision, indexno );
            statelement = [];
            for ii = 1:length(state)
                statelement = [statelement state{ii}];
            end
            if size(statelement,2)==1
                if statelement == hypothese
                    True_False = true;
                    break;
                else
                    True_False= false;
                    break;
                end
            end      %In real, the process stops only when there is one element(not necessarily is hypothese) in the state.
        end
        used = i;
    else
        error('one worker case, need to update');
    end
    
    
    %%
elseif size(H,1)==1||size(H,2)==1
    if length(varargin) == 1
        CC = varargin{1};
        codesize= size(CC{q-1});
        workers = codesize(2);
        for i = 1:rounds
            %             if i ==10
            %                 disp('what???!!!');
            %             end
            [ question, indexno ] = QaryQuestion( state, q, rounds-i+1 );
            [nonzero, truelocation, fullquestion] = Reliability1(hypothese, question, state, M);
            newq =  sum(nonzero);
            %reliable = zeros(newq,1);
            if truelocation == 0
                reliable = 1/newq*ones(newq,1);
            else
                trueloc = sum(nonzero(1:truelocation));
                reliable = (1-H(newq-1))/(newq-1)*ones(newq,1);
                reliable(trueloc ) = H(newq-1);
            end
            dist = inf(1, newq);
            B = cumsum(reliable,1);
            workerand = rand(1,workers);
            C = CC{newq-1};
            u = C(logical(sparse(sum(bsxfun(@le,repmat(B,1,workers),workerand),1)+1,1:workers,1,newq,workers)));
            for j = 1:newq
                if reliable(j) > 0
                    dist(j) = pdist2(C(j,:), u','hamming')*codesize(2);
                end;
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
            bb = find(nonzero>0);
            decision= bb(decision);
            [ state ] = QaryNextState( state, question, decision, indexno );
            statelement = [];
            for ii = 1:length(state)
                statelement = [statelement state{ii}];
            end
            actionsequence{i} = fullquestion;
            if size(statelement,2)==1
                if statelement == hypothese
                    True_False = true;
                    break;
                else
                    True_False= false;
                    break;
                end
                %elseif size(statelement,2)<q&&size(statelement,2)>3
                %        disp('???');
            end      %In real, the process stops only when there is one element(not necessarily is hypothese) in the state.
            
            if size(statelement,2)==0
                disp('what the fuck');
            end
            
        end
        used = i;
    else
        error('one worker case, need to update');
    end
    
else
    error('Pls check the input argument and read the introduction');
end

end

function [reliable] = Reliability(hypothese, H, question, state)
%this function is to get the Reliability of each worker when they decide
%yes or no answer.
q = size(question,1);
num_error = length(state)-1;
allquesmember = cell(q,1);
allstatemember = [];
reliable = zeros(q,1);
for j = 1:num_error+1
    allstatemember = [allstatemember state{j}];
    for i = 1:q
        allquesmember{i} = [allquesmember{i} question{i,j}];
    end
end
all = sum(H(allstatemember,hypothese));
for i = 1:q
    reliable(i) = sum(H(allquesmember{i},hypothese))/all;
end

end


function [nonzero, truelocation, fullquestion] = Reliability1(hypothese, question, state, M)
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
newq= sum(nonzero);
fullquestion = allquesmember(nonzero>0);
statelement = [];
for ii = 1:length(state)
    statelement = [statelement state{ii}];
end
statelement_out = setdiff(1:M,statelement);
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
% if truelocation == 0
%     reliable(nonzero>0) = 1/sum(nonzero);
% else
% %     reliable(nonzero>0) = (1-H)/(q-1)+(1-H)/(q-1)*(q-sum(nonzero))/sum(nonzero);
% %     reliable(truelocation) = H+(1-H)/(q-1)*(q-sum(nonzero))/sum(nonzero);
% %     reliable(nonzero>0) = (1-H)/(q-1)+(1-H)/(q-1)*(q-sum(nonzero))/(sum(nonzero)-1);
% %     reliable(truelocation) = H;
% %     reliable(nonzero>0) = (1-H)/(q-1);
% %     reliable(truelocation) = H+(1-H)/(q-1)*(q-sum(nonzero));
%       a =  sum(nonzero);
%       reliable(nonzero>0) = (1-H(a-1))/(a-1);
%       reliable(truelocation) = H(a-1);
%
% end

end