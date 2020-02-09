 clear all;%mp.Digits(1000);
% warning off all;
M = 64;
%global Ng;
Ng = 8;
global workers;
workers = 5; %number of workers in each groups
runtimes = 10;
global hypothese;
qq = 2:12;
resultqary = zeros(M,runtimes);
numofused = zeros(M,runtimes);
% 
% clear global pomdp;
global pomdp;
global c;
global matrixC;
global PeMatrix;
global pomcpruntime;
global indnrobservation;
global nrActions;
c = 10;
pomcpruntime = 10000;
global tttt;
tttt = 0;
load('data_M_64_N_8\result');
% 
% %mu = [0.64 0.60 0.57 0.54 0.51 0.48 0.45 0.42 0.39 0.36 0.3 0.27 0.24 0.21 0.21];
mu = 0.75*qq.^-0.2;
% %      2    3     4    5    6    7    8    9    10   11  12   13   14  15    16
% %load('resultofpomdp8_8.mat');
% 
datafolder = ['.\POMCP_M_' num2str(M) '_N_' num2str(Ng) '_500'];
mkdir(datafolder);
% finall = [];
% lowerbound = [];
q = 4; e = 3;
initProblem(M, PeMatrix, matrixC, mu, Ng, q);
delete(gcp('nocreate'));
B = single(sampleBeliefsSSRABound(4000,Ng));
save([datafolder '\B'],'B');
save([datafolder '\pomdp'],'pomdp');
accuracy = zeros(M, 1);
aveused = zeros(M, 1);
final = zeros(M, 1);
getSolution( B );
save([datafolder '\pomdp'],'pomdp');
% qaryquestion = zeros(runtimes,Ng,M);
load([datafolder '\pomdp']);

pomdp.observation = double(pomdp.observation);
pomdp.indnrobservation = double(pomdp.indnrobservation);
pomdp.reward = double(pomdp.reward);
pomdp.nrActions = double(pomdp.nrActions);
pomdp.L = double(pomdp.L);
pomdp.gamma = double(pomdp.gamma);
pomdp.cost = double(pomdp.cost);
indnrobservation = pomdp.indnrobservation;
nrActions = pomdp.nrActions;
for hy = 1:M
    hypothese = hy;
    for i=1:runtimes
        [numofused(hy,i), resultqary(hy,i)] = QaryMonteCarloPOMCP(  1/M*ones(M,1), Ng, pomdp.cost, pomdp.L);
    end
    accuracy(hypothese) = sum(resultqary(hy,:))/runtimes;
    aveused(hypothese) = sum(numofused(hy,:))/runtimes;
    final(hypothese) = aveused(hypothese)*pomdp.cost+(1-accuracy(hypothese))*pomdp.L;
    disp(final(hy));
end
finall = (sum(final)/M)/20 + 1;
%disp(['q = ' num2str(q) '  finall = ' num2str(finall)  '  lowerbound = ' num2str(lowerbound)]);
save([datafolder '\result'],'pomdp','qaryquestion','aveused','accuracy','finall');
