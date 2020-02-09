function [PeMatrix] =  GroupBehaviorMatrix( C, mu)
%get the misclassification matrix given a codematrix C and Mu
% Input: 
%       C       :(matrix)  codematrix, size is Qary*Numworker.
%       mu      :(scalar)  reliability.
% Output:
%       PeM    :(matrix)  size is Qary*Qary. PeM_ij is the probability of
%                           choose  j given i is the correct one
q = size(C,1);
N = size(C,2);
PeMatrix = zeros(q);
for i =1:q
    PeM_i = zeros(q,1);
    for j = 0:N
        tt = nchoosek(1:N,j);
        sp = zeros(q,size(tt,1));
        %sp = zeros(q,1);
        parfor jj = 1:size(tt,1)
            C1 = C;
            u = zeros(1,N);
            u(tt(jj,:)) = 1;
%             pi = xor(u,C1(i,:));
%             temp = (1-mu)^sum(pi)*(mu)^(N-sum(pi));
            temp = 1;
            for k = 1:N
                temp = temp*((1-u(k))+(2*u(k)-1)*(mu*C1(i,k)+(1-mu)/(q-1)*sum(C1([1:i-1 i+1:end],k))));
            end
            dist = zeros(1, q);
            for ii = 1:q
                dist(ii) = pdist2(C1(ii,:), u,'hamming')*N;
            end
            h = 1;
            [sortdist, index] = sort(dist);
            while sortdist(h) == sortdist(h+1)
                h = h+1;
                if h+1>length(dist)
                    break;
                end
            end
            spp = zeros(q,1);
            spp(index(1:h),1) = temp/h;
            sp(:,jj) = spp; 
            
        end
        %disp(sp);
        PeM_i = PeM_i+sum(sp,2);
    end
    PeMatrix(i,:) = PeM_i';
end

