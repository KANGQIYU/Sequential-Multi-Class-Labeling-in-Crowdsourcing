function [ NextSolution ] = Backup( B, CurrentSolution )
%BACKUP point-based value backup
%Input: (ndim==nrStates)
%       B : (ndim x nr) a set of nr belief points whose dimension is ndim
%       CurrentSolution : 
%                  .SolutionSet (ndim x sl) a set of sl solution vectors whose
%                     dimension is ndim. It's the solution set of Vn(Taon)
%                  .SolutionAction  (1 x sl)                  
%Output:
%       NextSolution   : 
%                  .SolutionSet (ndim x nsl) a set of nsl solution vectors whose
%                     dimension is ndim. It's the solution set of Vn+1(Taon+1)
%                     The first nrStates vectors in NextSolutionSet is
%                     declare vectors.
%                  .SolutionAction  (1 x sl)    
%notice pomdp.observation must be nrS x nrO x nrA!!!
global pomdp;
mkdir('./temp');
storesize = 4;%G
storenum = 0;
nrBelief = size(B,2);
Vn = size(CurrentSolution.SolutionSet,2);
indnro = pomdp.indnrobservation;
nrA = pomdp.nrActions;
nrS = pomdp.nrStates;
T_a_star = pomdp.reward;  %size dim x a
%T_dim_Vn_o_a = pomdp.gamma*bsxfun(@times,reshape(pomdp.observation,nrS,1,nrO,nrA),CurrentSolution.SolutionSet); %size dim x Vn x a x o
dim_B_a = [];
batch = 1;
i = 1; 
term = 1;
storebatchselection = -inf*ones(nrBelief,3); %first column contains the batch(8G) information, second contains the corresponding index, third is the value.
%finalselection(:,1) = 0;
storeselc = [];
while term
    if i*batch <= nrA
        eeend = i*batch;
    else
        eeend = nrA;
        term = 0;
    end
    selec = (i-1)*batch+1:eeend;
    lengthselec = length(selec);
    nrO = max(indnro(selec));
    tempT_dim_Vn_o_a = pomdp.gamma*bsxfun(@times,reshape(pomdp.observation(:,1:nrO,selec),nrS,1,nrO,lengthselec),CurrentSolution.SolutionSet);
    Multi1 = reshape(B'*tempT_dim_Vn_o_a(:,:),nrBelief,Vn,nrO,lengthselec);
    [~,tempIndex1] = max(Multi1,[],2); % Max1(nrBelief x o x a), Index1(nrBelief x o x a);
    tempIndex1 = reshape(tempIndex1,nrBelief,nrO,lengthselec); 
    temp = reshape(tempT_dim_Vn_o_a,nrS,[]);
    iindexxtemp = repmat(reshape(bsxfun(@times,ones(nrBelief,nrO),1:nrO),nrBelief*nrO,1),lengthselec,1);
    tt = reshape(bsxfun(@times,ones(nrBelief*nrO,lengthselec),1:lengthselec),nrBelief*nrO*lengthselec,1);
    tempdim_B_o_a = reshape(temp(:,...
        sub2ind([Vn nrO lengthselec],...
        tempIndex1(:),...
        iindexxtemp,...
        tt)),...
        nrS,nrBelief,nrO,lengthselec);
    dim_B_a = cat(3,dim_B_a,reshape(sum(tempdim_B_o_a,3),nrS,nrBelief,lengthselec));
    S = whos('dim_B_a');
    storeselc = [storeselc selec];
    if S.bytes/1e9 > storesize || term == 0
        %disp(i);
        storenum = storenum+1;
        dim_B_a = bsxfun(@plus,reshape(T_a_star(:,storeselc),nrS,1,length(storeselc)),dim_B_a);
        B_a = reshape(sum(bsxfun(@times,B,dim_B_a),1),nrBelief,length(storeselc));
        [temp, corAction] = max(B_a,[],2);
        update = temp>storebatchselection(:,3);
        storebatchselection(update,1) = storenum;
        storebatchselection(update,2) = corAction(update);
        storebatchselection(update,3) = temp(update);
        save(['./temp/tmpdata' num2str(storenum)],'dim_B_a');
        dim_B_a = [];
        B_a = [];
        storeselc = [];
    end
    i = i+1;
end
TempNextSolutionSet = [];
action = [];
indexaction = 0;
for i = 1:storenum
    load(['./temp/tmpdata' num2str(i)]);
    ss = (storebatchselection(:,1) == i);
    temp = reshape(dim_B_a,nrS,nrBelief*size(dim_B_a,3));
    corAction = storebatchselection(ss,2);
    TempNextSolutionSet = [TempNextSolutionSet temp(:,sub2ind([nrBelief size(dim_B_a,3)],find(ss>0),corAction))];
    action = [action;indexaction+corAction];
    indexaction = indexaction+size(dim_B_a,3);
    dim_B_a = [];
end
% clear tempdim_B_o_a tempIndex1 tt tempIndex1 temp;
% dim_B_a = bsxfun(@plus,reshape(T_a_star,nrS,1,nrA),dim_B_a);
% clear T_a_star;
% B_a = reshape(sum(bsxfun(@times,B,dim_B_a),1),nrBelief,nrA);
% [~, corAction] = max(round(B_a*100000),[],2);
% delete B_a;
% %TempNextSolutionSet = dim_B_a(:,logical(sparse(1:nrBelief,corAction,1,nrBelief,nrA)));  this is
% %wrong because of the order problem
% temp = reshape(dim_B_a,nrS,nrBelief*nrA);
% TempNextSolutionSet = temp(:,sub2ind([nrBelief nrA],1:nrBelief,corAction'));
clear  dim_B_a temp;
NextSolution.SolutionSet = single(pomdp.L*(1-eye(nrS))); %pomdp.L is a negative value

[TempNextSolution, ia, ~] = unique(transpose(round(TempNextSolutionSet*100000)/100000),'rows');
NextSolution.SolutionSet = [NextSolution.SolutionSet transpose(TempNextSolution)];
% action = corAction(ia);
action = action(ia);
NextSolution.SolutionAction = [nrA+1:nrA+nrS action(:)'];
rmdir('temp','s');
end

