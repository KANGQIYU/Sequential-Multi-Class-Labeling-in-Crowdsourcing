clear all;%mp.Digits(1000);
warning off all;
M = 8;
Ng = 9;
workers = 10; %number of workers in each groups
runtimes = 10000;
hypothese = 2;
qq = 2:11;
resultqary = zeros(1,runtimes);
numofused = zeros(1,runtimes);


%mu1 = [0.6 0.58 0.56 0.54 0.53 0.52 0.51 0.50 0.49 0.48];
E =   [2     2    2    2    2    2    2 ]   ;%2    2    3    3  3 3 3];
%E =   [0     0    1    1    1    1    1    1    1    1    1  2];

mu1 = [0.64 0.60 0.57 0.54 0.51 0.48 0.45 0.42 0.39 0.36 0.33];
%       2     3    4    5    6    7    8    9   10   11   12



accuracy = zeros(length(qq), 1);
aveused = zeros(length(qq), 1);
final = zeros(length(qq), 1);
load('.\newdata\matrixC.mat');
load('.\newdata\pomdp.mat');
for k = 1:7%10%:length(qq)
    q = qq(k);

    for e = E(k)%E:E+1
        for hypothese = 1:M
            parfor i=1:runtimes
                [resultqary(i), numofused(i)]=  QaryMonteCarloFeedback( M, mu1, q, 10, hypothese, e, matrixC);
            end
            accuracy(k) = accuracy(k)+sum(resultqary)/runtimes;
            aveused(k) = aveused(k)+sum(numofused)/runtimes;
            final(k) = final(k)+aveused(k)*pomdp.cost+(1-accuracy(k))*pomdp.L;
        end
       accuracy(k) = accuracy(k) /M;
       aveused(k) = aveused(k)/M;
       final(k) = final(k)/M;
        disp(['q = ' num2str(q) '    e = ' num2str(e) '    accuracy = '  num2str(accuracy(k)) '   numofused = ' num2str(max(numofused)) '   average = ' num2str(aveused(k)) '    final = ' num2str(final(k))]);
    
        
    end
end
%save(['feedbackM' num2str(M) '_workers' num2str(groups) 'mu' num2str(mu(j)) '.mat'],'right');
%delete(gcp('nocreate'));
