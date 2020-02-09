function initProblem(nrStates, PeMatrix, matrixC, mu, horizon, varargin)
% Problem specific initialization function for DesignQuestion.

ulamsampling = 0;
clear global pomdp;
wantnum = 10000;
cost =  -0.05*20;
global pomdp;
%%
if length(varargin) == 0
    pomdp.nrObservations = nrStates;
    pomdp.nrStates = nrStates;
    pomdp.L = -20;
    pomdp.gamma = 1;
    pomdp.cost = cost;
    pomdp.rounds = horizon;
    pomdp.AllActions = cell(horizon,1);
    pomdp.Allobservation = cell(horizon,1);
    pomdp.Allreward = cell(horizon,1);
    pomdp.AllnrActions = zeros(horizon,1);
    pomdp.Allindnrobservation = cell(horizon,1);
    pomdp.solution = [];
    %%
    if ulamsampling == 0
        total = zeros(nrStates-1,1);
        for i = 2:nrStates
            total(i-1) = computeStirlingNum(nrStates, i);
        end
        total = log10(total);
        ssize = ceil(total/sum(total)*wantnum);
        for i = 1:length(ssize)
            if ssize(i) < 0
                ssize(i) = 0;
            end
        end
        numm = zeros(horizon,1);
        for i = 1:horizon
            currentActionNum = 0;
            observation = [];
            indnrobservation = zeros(wantnum,1);
            Actions = [];
            for q = 2:nrStates
                subActions = ActionSample(1:nrStates, q, ssize(q-1));
                Actions = [Actions; subActions];
                subNumAction = length(subActions);
                observation = cat(3,observation,zeros(nrStates,nrStates,subNumAction));
                for IthAction = 1:subNumAction        %%notice that here we haven't consider the case of permutation of q-art question
                    currentaction = subActions{IthAction};
                    for JthQuestion = 1:q
                        observation(currentaction{JthQuestion},1:q,currentActionNum+IthAction) = repmat(PeMatrix{q-1}(JthQuestion,:),length(currentaction{JthQuestion}),1);
                        %notice pomdp.observation must be nrS x nrO x nrA!!!
                    end
                    indnrobservation(currentActionNum+IthAction) = q;
                end
                currentActionNum = currentActionNum+subNumAction;
            end
            pomdp.Allobservation{i} = observation;
            pomdp.AllnrActions(i) = currentActionNum;
            pomdp.AllActions{i} = Actions;
            pomdp.Allreward{i} = pomdp.cost*ones(pomdp.nrStates,pomdp.AllnrActions(i));
            pomdp.Allindnrobservation{i} = indnrobservation;
        end
        pomdp.Actions = [];
        pomdp.nrActions = [];
        pomdp.reward = [];
        pomdp.observation = [];
        pomdp.indnrobservation  = [];
    else
        %% currently we store actions for each horizon wholly. we sampling it by getting sequences of actions in each trial.
        total = zeros(nrStates-1,1);
        for i = 2:nrStates
            total(i-1) = computeStirlingNum(nrStates, i);
        end
        total = log10(total);
        ssize = ceil(total/sum(total)*wantnum);
        for i = 1:length(ssize)
            if ssize(i) < 0
                ssize(i) = 0;
            end
        end
        numm = zeros(horizon,1);
        for q = 2:nrStates
            e = 0;
            while 1
                [ Bqe ] = GetBqe( nrStates, q, e, horizon+1);
                if Bqe > horizon
                    break
                else
                    e = e + 1;
                end
            end
            
            for i=1:ssize(q-1)
                ee = randi([1 e+2]);
                hypothese =randi(nrStates);
                [resultqary, numofused, actionsequence]=  QaryMonteCarloFeedback( nrStates, mu, q, horizon, hypothese, ee, matrixC);
                for j = 1:numofused
                    pomdp.AllActions{j}{numm(j)+1,1} = actionsequence{j};
                    numm(j) = numm(j)+1;
                end
            end
        end
        wantnum = numm(1);
        qsize = cumsum(ssize);
        for i = 1:horizon
            if numm(i)<wantnum
                for jj=1:(wantnum-numm(i))
                    qrand = randi(wantnum);
                    q = sum(qsize<qrand)+2;
                    ee = randi(10);
                    hypothese =randi(nrStates);
                    [resultqary, numofused, actionsequence]=  QaryMonteCarloFeedback( nrStates, mu, q, horizon, hypothese, ee, matrixC);
                    for j = 1:numofused
                        if i+j-1<=horizon
                            pomdp.AllActions{i+j-1}{numm(i+j-1)+1,1} = actionsequence{j};
                            numm(i+j-1) = numm(i+j-1)+1;
                        end
                    end
                end
            end
        end
        for i = 1:horizon
            pomdp.AllnrActions(i) = length(pomdp.AllActions{i});
            pomdp.Allobservation{i} = zeros(nrStates,nrStates,pomdp.AllnrActions(i));
            pomdp.Allindnrobservation{i} = zeros(pomdp.AllnrActions(i),1);
            for IthAction = 1:pomdp.AllnrActions(i)       %%notice that here we haven't consider the case of permutation of q-art question
                currentaction = pomdp.AllActions{i}{IthAction};
                q = length(currentaction);
                for JthQuestion = 1:q
                    pomdp.Allobservation{i}(currentaction{JthQuestion},1:q,IthAction) = repmat(PeMatrix{q-1}(JthQuestion,:),length(currentaction{JthQuestion}),1);
                    %notice pomdp.observation must be nrS x nrO x nrA!!!
                end
                pomdp.Allindnrobservation{i}(IthAction) = q;
            end
            pomdp.Allreward{i} = pomdp.cost*ones(pomdp.nrStates,pomdp.AllnrActions(i));
        end
        %save('.\AllActions','AllActions','');
        pomdp.Actions = [];
        pomdp.nrActions = [];
        pomdp.reward = [];
        pomdp.observation = [];
        pomdp.indnrobservation  = [];
    end
elseif length(varargin) == 1
    %%
    qq = varargin{1};
    pomdp.nrObservations = max(qq);
    pomdp.nrStates = nrStates;
    pomdp.L = -20;
    pomdp.gamma = 1;
    pomdp.cost = cost;
    pomdp.rounds = horizon;
    pomdp.AllActions = cell(horizon,1);
    pomdp.Allobservation = cell(horizon,1);
    pomdp.Allreward = cell(horizon,1);
    pomdp.AllnrActions = zeros(horizon,1);
    pomdp.Allindnrobservation = cell(horizon,1);
    pomdp.solution = [];
    %%
    if ulamsampling == 0
        ssize = ceil(wantnum/length(qq))*ones(length(qq),1);
        for i = 1:horizon
            currentActionNum = 0;
            observation = [];
            indnrobservation = zeros(wantnum,1);
            Actions = [];
            for j = 1:length(qq)
                q = qq(j);
                subActions = ActionSample(1:nrStates, q, ssize(j));
                Actions = [Actions; subActions];
                subNumAction = length(subActions);
                observation = cat(3,observation,zeros(nrStates,pomdp.nrObservations,subNumAction));
                for IthAction = 1:subNumAction        %%notice that here we haven't consider the case of permutation of q-art question
                    currentaction = subActions{IthAction};
                    for JthQuestion = 1:q
                        observation(currentaction{JthQuestion},1:q,currentActionNum+IthAction) = repmat(PeMatrix{q-1}(JthQuestion,:),length(currentaction{JthQuestion}),1);
                        %notice pomdp.observation must be nrS x nrO x nrA!!!
                    end
                    indnrobservation(currentActionNum+IthAction) = q;
                end
                currentActionNum = currentActionNum+subNumAction;
            end
            pomdp.Allobservation{i} = observation;
            pomdp.AllnrActions(i) = currentActionNum;
            pomdp.AllActions{i} = Actions;
            pomdp.Allreward{i} = pomdp.cost*ones(pomdp.nrStates,pomdp.AllnrActions(i));
            pomdp.Allindnrobservation{i} = indnrobservation;
        end
        pomdp.Actions = [];
        pomdp.nrActions = [];
        pomdp.reward = [];
        pomdp.observation = [];
        pomdp.indnrobservation  = [];
    else
        %% currently we store actions for each horizon wholly. we sampling it by getting sequences of actions in each trial.
        numm = zeros(horizon,1);
        ssize = ceil(wantnum/length(qq))*ones(length(qq),1);
        tempwantnum = cumsum(ssize);
        
        for jj = 1:length(qq)
            e = 0;
            q = qq(jj);
            while 1
                [ Bqe ] = GetBqe( nrStates, q, e, horizon+1);
                if Bqe > horizon
                    break
                else
                    e = e + 1;
                end
            end
            
            for i=1:ssize(jj)
                ee = randi([1 e+2]);
                hypothese =randi(nrStates);
                [resultqary, numofused, actionsequence]=  QaryMonteCarloFeedback( nrStates, mu, q, horizon, hypothese, ee, matrixC);
                for j = 1:numofused
                    if length(actionsequence{j})== q
                        pomdp.AllActions{j}{numm(j)+1,1} = actionsequence{j};
                        numm(j) = numm(j)+1;
                    end
                end
            end
            for i = 1:horizon
                while numm(i)<tempwantnum(jj)
                    ee = randi(5);
                    hypothese =randi(nrStates);
                    [resultqary, numofused, actionsequence]=  QaryMonteCarloFeedback( nrStates, mu, q, horizon, hypothese, ee, matrixC);
                    for j = 1:numofused
                        if i+j-1<=horizon && length(actionsequence{j}) == q;
                            pomdp.AllActions{i+j-1}{numm(i+j-1)+1,1} = actionsequence{j};
                            numm(i+j-1) = numm(i+j-1)+1;
                        end
                    end
                end
            end
        end
        for i = 1:horizon
            pomdp.AllnrActions(i) = length(pomdp.AllActions{i});
            pomdp.Allobservation{i} = zeros(nrStates,pomdp.nrObservations,pomdp.AllnrActions(i));
            pomdp.Allindnrobservation{i} = zeros(pomdp.AllnrActions(i),1);
            for IthAction = 1:pomdp.AllnrActions(i)       %%notice that here we haven't consider the case of permutation of q-art question
                currentaction = pomdp.AllActions{i}{IthAction};
                q = length(currentaction);
                for JthQuestion = 1:q
                    pomdp.Allobservation{i}(currentaction{JthQuestion},1:q,IthAction) = repmat(PeMatrix{q-1}(JthQuestion,:),length(currentaction{JthQuestion}),1);
                    %notice pomdp.observation must be nrS x nrO x nrA!!!
                end
                pomdp.Allindnrobservation{i}(IthAction) = q;
            end
            pomdp.Allreward{i} = pomdp.cost*ones(pomdp.nrStates,pomdp.AllnrActions(i));
        end
        %save('.\AllActions','AllActions','');
        pomdp.Actions = [];
        pomdp.nrActions = [];
        pomdp.reward = [];
        pomdp.observation = [];
        pomdp.indnrobservation  = [];
    end
elseif length(varargin) == 2  %% THis is sampling with a specific q and e
    %first we sampling in a question tree in of (M,q,e)Ulam-Renyi Tree.
    % if the nodes is less than wantnum, we let action set contain all
    % node, otherwise we sampling wantnum nodes.
    qq = varargin{1};
    e = varargin{2};
    pomdp.nrObservations = qq;
    pomdp.nrStates = nrStates;
    pomdp.L = -20;
    pomdp.gamma = 1;
    pomdp.cost = cost;
    pomdp.rounds = horizon;
    pomdp.AllActions = cell(horizon,1);
    pomdp.Allobservation = cell(horizon,1);
    pomdp.Allreward = cell(horizon,1);
    pomdp.Allindnrobservation = cell(horizon,1);
    pomdp.solution = [];
    pomdp.Actions = SampleUlamRenyiActions(nrStates, qq, e, horizon, wantnum);
    pomdp.nrActions = length(pomdp.Actions);
    pomdp.reward = pomdp.cost*ones(pomdp.nrStates,pomdp.nrActions);
    pomdp.observation = zeros(nrStates,pomdp.nrObservations,pomdp.nrActions);
    pomdp.indnrobservation = zeros(pomdp.nrActions,1);
    for IthAction = 1:pomdp.nrActions
        currentaction = pomdp.Actions{IthAction};
        q = length(currentaction);
        for JthQuestion = 1:q
            pomdp.observation(currentaction{JthQuestion},1:q,IthAction) = repmat(PeMatrix{q-1}(JthQuestion,:),length(currentaction{JthQuestion}),1);
            %notice pomdp.observation must be nrS x nrO x nrA!!!
        end
        pomdp.indnrobservation(IthAction) = q;
    end
    pomdp.AllnrActions = single(pomdp.nrActions*ones(horizon,1));
    pomdp.observation = single(pomdp.observation);
    pomdp.indnrobservation = single(pomdp.indnrobservation);
    pomdp.reward = single(pomdp.reward);
    pomdp.nrActions = single(pomdp.nrActions);
    pomdp.L = single(pomdp.L);
    pomdp.gamma = single(pomdp.gamma);
    pomdp.cost = single(pomdp.cost);
end
