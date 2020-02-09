function [ Pe ] = Bound9( codematrix, H )
%get the error bound according to expression (9) given codematrix and H
%Input:
%   codematrix  : (matrix)
%   H           : (matrix) H_i_j is the probability of classifying i as the decision
%                          given the j is the true hypotheis. Pls notice here H is 2D
%                          since H_k_i_j is the same for all k.
%Output:
%   Perror      : (scalar) return error bound (9).
Pe = 0;
codesize= size(codematrix);
pair_dist = pdist2(codematrix, codematrix,'hamming')*codesize(2);
for i = 1:codesize(1)
    for al = 1:codesize(1)
        if al == i,
            continue;
        else
            numerator = (pair_dist(i,:)-pair_dist(al,:))*H(:,i);
%             numerator =0;
%             for k = 1:codesize(1)
%                 numerator = numerator+H(i,k)*(pair_dist(i,k)-pair_dist(al,k));
%             end
            Pe = Pe+(1-(numerator/pair_dist(al,i))^2)^(pair_dist(i,al)/2);
        end
    end
end

Pe = Pe/codesize(1);

end

