function [ matrixC ] = generateCodeMatrix( M, workers, mu)
% generate CodeMatrix for group of workers
for q = 2:M
    Peleast = 100;
    for ii = 1:1
        H = ones(q)*(1-mu(q-1))/(q-1)+eye(q)*(mu(q-1)-(1-mu(q-1))/(q-1));
        [Pe, C] = CodeMatrix_Qary(@Bound9, workers, q, H);
%         if Peleast > Pe
%             Peleast = Pe;
%             Cbest = C;
%         end
    end
%     matrixC{q-1} = Cbest;
    matrixC{q-1} = C;
end
end

