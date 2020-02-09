clear all;%mp.Digits(1000);
warning off all;
idvsampling = 3; %0 is random, 1 is for each q, 2 is for combineq, 3 is for one specific pair (q,e)
M = 64;
Ng = 8;
workers = 10; %number of workers in each groups
runtimes = 1000;
hypothese = 2;
qq = 2:12;
resultqary = zeros(1,runtimes);
numofused = zeros(1,runtimes);

clear global pomdp;
global pomdp;
load('data_M_64_N_8\result');

%mu = [0.64 0.60 0.57 0.54 0.51 0.48 0.45 0.42 0.39 0.36 0.3 0.27 0.24 0.21 0.21];
mu = 0.75*qq.^-0.2;
%      2    3     4    5    6    7    8    9    10   11  12   13   14  15    16
%load('resultofpomdp8_8.mat');
%%
if idvsampling == 0
    datafolder = ['.\data_M_' num2str(M) '_N_' num2str(Ng)];
    
    mkdir(datafolder);
    % [ matrixC ] = generateCodeMatrix( M, workers, mu);
    % save([datafolder '\matrixC'],'matrixC');
    % for q = 2:M
    %    [PeMatrix{q-1}] =  GroupBehaviorMatrix( matrixC{q-1}, mu(q-1));
    % end
    % save([datafolder '\PeMatrix'],'PeMatrix');
    initProblem(M, PeMatrix, matrixC, mu, Ng);
    save([datafolder '\pomdp'],'pomdp');
    
    
    %load('.\B');
    delete(gcp('nocreate'));
    B = sampleBeliefsSSEABoundEqual(2000,Ng);
    save([datafolder '\B'],'B');
    
    accuracy = zeros(M, 1);
    aveused = zeros(M, 1);
    final = zeros(M, 1);
    getSolution( B );
    save([datafolder '\pomdp'],'pomdp');
    qaryquestion = zeros(runtimes,Ng,M);
    
    for hypothese = 1:M
        for i=1:runtimes
            [numofused(i), resultqary(i), qaryquestion(i,:,hypothese)] = QaryMonteCarloPOMDP(  1/M*ones(M,1), mu, Ng, hypothese, matrixC);
        end
        accuracy(hypothese) = sum(resultqary)/runtimes;
        aveused(hypothese) = sum(numofused)/runtimes;
        final(hypothese) = aveused(hypothese)*pomdp.cost+(1-accuracy(hypothese))*pomdp.L;
    end
    finall = (sum(final)/M)/20 + 1;
    [A, Imax, Value] = getAction_Declare(1/M*ones(M,1), pomdp.solution{1});
    lowerbound = Value/20+1;
    save([datafolder '\result'],'pomdp','finall','PeMatrix','lowerbound','matrixC','qaryquestion');
    save([datafolder '\all']);
elseif idvsampling == 1
 %%   
    datafolder = ['.\idvsamplingdata_M_' num2str(M) '_N_' num2str(Ng)];
    mkdir(datafolder);
    finall = zeros(length(qq),1);
    lowerbound = zeros(length(qq),1);
    for q = qq
        initProblem(M, PeMatrix, matrixC, mu, Ng, q);
        delete(gcp('nocreate'));
        B = sampleBeliefsSSEABoundEqual(2000,Ng);
         %save([datafolder '\B'],'B');
        accuracy = zeros(M, 1);
        aveused = zeros(M, 1);
        final = zeros(M, 1);
        getSolution( B );
        save([datafolder '\pomdp'],'pomdp');
        qaryquestion = zeros(runtimes,Ng,M);
     
        for hypothese = 1:M
            for i=1:runtimes
              [numofused(i), resultqary(i), qaryquestion(i,:,hypothese)] = QaryMonteCarloPOMDP(  1/M*ones(M,1), mu, Ng, hypothese, matrixC);
            end
            accuracy(hypothese) = sum(resultqary)/runtimes;
            aveused(hypothese) = sum(numofused)/runtimes;
            final(hypothese) = aveused(hypothese)*pomdp.cost+(1-accuracy(hypothese))*pomdp.L;
        end
        finall(q-1) = (sum(final)/M)/20 + 1;
        [A, Imax, Value] = getAction_Declare(1/M*ones(M,1), pomdp.solution{1});
        lowerbound(q-1) = Value/20+1;
        disp(['q = ' num2str(q) '  finall = ' num2str(finall(q-1))  '  lowerbound = ' num2str(lowerbound(q-1))]);
        save([datafolder '\pomdp_' num2str(q)],'pomdp','qaryquestion','aveused','accuracy');
    end
    save([datafolder '\result'],'lowerbound','finall');
elseif idvsampling == 2
    datafolder = ['.\idvsamplingcombinedata_M_' num2str(M) '_N_' num2str(Ng)];
    mkdir(datafolder);
    finall = [];
    lowerbound = [];
    
    initProblem(M, PeMatrix, matrixC, mu, Ng, qq);
    delete(gcp('nocreate'));
    B = sampleBeliefsSSEABoundEqual(2000,Ng);
    %save([datafolder '\B'],'B');
    accuracy = zeros(M, 1);
    aveused = zeros(M, 1);
    final = zeros(M, 1);
    getSolution( B );
    save([datafolder '\pomdp'],'pomdp');
    qaryquestion = zeros(runtimes,Ng,M);
     
    for hypothese = 1:M
        for i=1:runtimes
            [numofused(i), resultqary(i), qaryquestion(i,:,hypothese)] = QaryMonteCarloPOMDP(  1/M*ones(M,1), mu, Ng, hypothese, matrixC);
        end
        accuracy(hypothese) = sum(resultqary)/runtimes;
        aveused(hypothese) = sum(numofused)/runtimes;
        final(hypothese) = aveused(hypothese)*pomdp.cost+(1-accuracy(hypothese))*pomdp.L;
    end
    finall = (sum(final)/M)/20 + 1;
    [A, Imax, Value] = getAction_Declare(1/M*ones(M,1), pomdp.solution{1});
    lowerbound = Value/20+1;
    %disp(['q = ' num2str(q) '  finall = ' num2str(finall)  '  lowerbound = ' num2str(lowerbound)]);
    save([datafolder '\pomdp_combineq'],'pomdp','qaryquestion','aveused','accuracy');
    save([datafolder '\result'],'lowerbound','finall');
elseif idvsampling == 3;
    datafolder = ['.\specificq_e_M_' num2str(M) '_N_' num2str(Ng)];
    mkdir(datafolder);
    finall = [];
    lowerbound = [];
    q = 4; e = 2;
    initProblem(M, PeMatrix, matrixC, mu, Ng, q,e);
    delete(gcp('nocreate'));
    B = single(sampleBeliefsSSRABoundEqual(20000,Ng));
    save([datafolder '\B'],'B');
    save([datafolder '\pomdp'],'pomdp');
    accuracy = zeros(M, 1);
    aveused = zeros(M, 1);
    final = zeros(M, 1);
    getSolution( B );
    save([datafolder '\pomdp'],'pomdp');
    qaryquestion = zeros(runtimes,Ng,M);
     
    for hypothese = 1:M
        for i=1:runtimes
            [numofused(i), resultqary(i), qaryquestion(i,:,hypothese)] = QaryMonteCarloPOMDP(  1/M*ones(M,1), mu, Ng, hypothese, matrixC);
        end
        accuracy(hypothese) = sum(resultqary)/runtimes;
        aveused(hypothese) = sum(numofused)/runtimes;
        final(hypothese) = aveused(hypothese)*pomdp.cost+(1-accuracy(hypothese))*pomdp.L;
    end
    finall = (sum(final)/M)/20 + 1;
    [A, Imax, Value] = getAction_Declare(1/M*ones(M,1), pomdp.solution{1});
    lowerbound = Value/20+1;
    %disp(['q = ' num2str(q) '  finall = ' num2str(finall)  '  lowerbound = ' num2str(lowerbound)]);
    save([datafolder '\pomdp_combineq'],'pomdp','qaryquestion','aveused','accuracy');
    save([datafolder '\result'],'lowerbound','finall');
end
