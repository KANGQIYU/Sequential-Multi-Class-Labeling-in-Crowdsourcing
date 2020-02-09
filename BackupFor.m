function [ NextSolution ] = BackupFor( B, CurrentSolution )
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
nrBelief = size(B,2);
Vn = size(CurrentSolution.SolutionSet,2);
nrO = pomdp.nrObservations;
nrA = pomdp.nrActions;
nrS = pomdp.nrStates;
T_a_star = pomdp.reward;  %size dim x a
%T_dim_Vn_o_a = pomdp.gamma*bsxfun(@times,reshape(pomdp.observation,nrS,1,nrO,nrA),CurrentSolution.SolutionSet); %size dim x Vn x o x a
% T_dim_Vn_o_a = zeros(nrS,Vn,nrO,nrA);
% for i = 1:nrA
%     for j = 1:nrO
%         for k = 1:Vn
%             T_dim_Vn_o_a(:,k,j,i) = pomdp.gamma*pomdp.observation(:,j,i).*CurrentSolution.SolutionSet(:,k);
%         end
%     end
% end
% TempNextSolutionSet = zeros(nrS,nrBelief);
% corAction = zeros(1,nrBelief);
% for b = 1:nrBelief
%     belief  = B(:,b);
%     T_b_a = T_a_star;
%     for a = 1:nrA
%         for o = 1:nrO
%             [~,I] = max(belief'*T_dim_Vn_o_a(:,:,o,a));
%             T_b_a(:,a) = T_b_a(:,a) + T_dim_Vn_o_a(:,I,o,a);
%         end
%     end
%     [~,I] = max(belief'*T_b_a);
%     corAction(b) = I;
%     TempNextSolutionSet(:,b) = T_b_a(:,I);
% end
T_dim_Vn = zeros(nrS,Vn);
TempNextSolutionSet = zeros(nrS,nrBelief);
corAction = zeros(1,nrBelief);
solutionset = CurrentSolution. SolutionSet;
gamma = pomdp.gamma;
for b = 1:nrBelief
    belief  = B(:,b);
    T_b_a = T_a_star;
    for a = 1:nrA
        for o = 1:nrO          
            observa = pomdp.observation(:,o,a);
            for k = 1:Vn
                T_dim_Vn(:,k) = gamma*observa.*solutionset(:,k);
            end
            [~,I] = max(belief'*T_dim_Vn);
            T_b_a(:,a) = T_b_a(:,a) + T_dim_Vn(:,I);
        end
    end
    [~,I] = max(belief'*T_b_a);
    corAction(b) = I;
    TempNextSolutionSet(:,b) = T_b_a(:,I);
end



NextSolution.SolutionSet = pomdp.L*(1-eye(nrS)); %pomdp.L is a negative value

[TempNextSolution, ia, ~] = unique(transpose(round(TempNextSolutionSet*100000)/100000),'rows');
NextSolution.SolutionSet = [NextSolution.SolutionSet transpose(TempNextSolution)];
action = corAction(ia);
NextSolution.SolutionAction = [nrA+1:nrA+nrS action(:)'];

end
