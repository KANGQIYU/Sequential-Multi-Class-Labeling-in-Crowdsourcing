% global pomdp
% pomdp.perferActions = cell(8,1);
% for i = 1:pomdp.rounds
%     pomdp.perferActions{i} = cell(2,1);
%     pomdp.perferActions{i}{1} = zeros(1);
%     pomdp.perferActions{i}{2} = zeros(1);
%     m = 1;
%     for j = 1:pomdp.nrActions
%         if ~isempty(pomdp.forPOMCP{i}{j})
%             pomdp.perferActions{i}{1}(m) = j;
%             m = m+1;
%         end
%     end
%     pomdp.perferActions{i}{2} = setdiff(1:pomdp.nrActions,pomdp.perferActions{i}{1});
% end

% a = zeros(10000,1);
% belief = 1/64*ones(64,1);
% tic;
% VN = rand(2000,4182);
% totalN = 40000;
% tic
% for j = 1:10
% for i = 1:1000
%     a(i+(j-1)*1000) = maxVN( VN((i*2-1):(i*2),:), totalN );
% end
% end
% toc;


% a = zeros(10000,1);
% for i = 1:length(a)
%     a(i) = RolloutBelief(1/64*ones(64,1) , 1);
% end
% max(a)
% min(a)
% max(a)- min(a)


% belief = rand(64,1);
% belief = belief/sum(belief);
% tic;
% Aindex = 2;
% for i = 1:10000
%     %b = sample_discrete(a,1);
%     s = cumsum( belief);
% s(end) = 1;
% srand = rand;
% s =  find(srand <= s, 1, 'first');
% newo = cumsum(pomdp.observation(s,:,Aindex));
% newo(indnrobservation(Aindex):end) = 1;
% orand = rand;
% ob = find(orand<newo, 1, 'first'); %ob = ob(in matlab)-1
% end
% toc;



% belief =  1/64*ones(64,1);
% for depth = 1:8
%     [belief] = NextBeliefPOMDP( belief, de(1,depth), de(2,depth), depth);
% end

load('./POMCP_M_64_N_8_4181/pomdp');
for i = 1:8
    pomdp.solution{i}.SolutionSet = double(pomdp.solution{i}.SolutionSet);
    pomdp.solution{i}.SolutionAction = double(pomdp.solution{i}.SolutionAction);
end
pomdp.preferActions = cell(8,1);
for i = 1:pomdp.rounds
    pomdp.preferActions{i} = cell(2,1);
    pomdp.preferActions{i}{1} = zeros(1);
    pomdp.preferActions{i}{2} = zeros(1);
    m = 1;
    for j = 1:pomdp.nrActions
        if ~isempty(pomdp.forPOMCP{i}{j})
            pomdp.preferActions{i}{1}(m) = j;
            m = m+1;
        end
    end
    pomdp.preferActions{i}{2} = setdiff(1:pomdp.nrActions,pomdp.preferActions{i}{1});
end
pomdp.AllnrActions = double(pomdp.AllnrActions);
pomdp.observation = double(pomdp.observation);
pomdp.indnrobservation = double(pomdp.indnrobservation);
pomdp.reward = double(pomdp.reward);
pomdp.nrActions = double(pomdp.nrActions);
pomdp.L = double(pomdp.L);
pomdp.gamma = double(pomdp.gamma);
pomdp.cost = double(pomdp.cost);



%  clear all;%mp.Digits(1000);
% % warning off all;
% M = 64;
% %global Ng;
% Ng = 8;
% global workers;
% workers = 10; %number of workers in each groups
% runtimes = 5;
% global hypothese;
% qq = 2:12;
% resultqary = zeros(M,runtimes);
% numofused = zeros(M,runtimes);
% % 
% % clear global pomdp;
% global pomdp;
% global c;
% global matrixC;
% global PeMatrix;
% global pomcpruntime;
% global indnrobservation;
% global nrActions;
% c = 20;
% pomcpruntime = 5000;
% global tttt;
% tttt = 0;
% load('data_M_64_N_8\result');
% % 
% % %mu = [0.64 0.60 0.57 0.54 0.51 0.48 0.45 0.42 0.39 0.36 0.3 0.27 0.24 0.21 0.21];
% mu = 0.75*qq.^-0.2;
% % %      2    3     4    5    6    7    8    9    10   11  12   13   14  15    16
% % %load('resultofpomdp8_8.mat');
% % 
% datafolder = ['.\POMCP_M_' num2str(M) '_N_' num2str(Ng)];
% mkdir(datafolder);
% % finall = [];
% % lowerbound = [];
% % q = 4; e = 2;
% % initProblem(M, PeMatrix, matrixC, mu, Ng, q,e);
% % delete(gcp('nocreate'));
% % B = single(sampleBeliefsSSRABoundEqual(2000,Ng));
% % save([datafolder '\B'],'B');
% % save([datafolder '\pomdp'],'pomdp');
% accuracy = zeros(M, 1);
% aveused = zeros(M, 1);
% final = zeros(M, 1);
% % getSolution( B );
% % save([datafolder '\pomdp'],'pomdp');
% % qaryquestion = zeros(runtimes,Ng,M);
% load(['./pomdp714']);
% 
% pomdp.observation = double(pomdp.observation);
% pomdp.indnrobservation = double(pomdp.indnrobservation);
% pomdp.reward = double(pomdp.reward);
% pomdp.nrActions = double(pomdp.nrActions);
% pomdp.L = double(pomdp.L);
% pomdp.gamma = double(pomdp.gamma);
% pomdp.cost = double(pomdp.cost);
% indnrobservation = pomdp.indnrobservation;
% nrActions = pomdp.nrActions;
% 
% a = zeros(10000,1);
% belief = 1/64*ones(64,1);
% tic;
% VN = rand(2000,4182);
% totalN = 40000;
% tic
% for i = 1:10000
%     a(i) = SSSSS(belief);
% end
% toc;
