function [ B ] = sampleBeliefsSSRA( n )
global pomdp;
nrStates = pomdp.nrStates;
nrActions = pomdp.nrActions;
observation = pomdp.observation;
resetpoint = 0;
belief = 1/pomdp.nrStates*ones(pomdp.nrStates,1);
B = zeros(pomdp.nrStates,n);
B(:,1) = belief;
i = 1;
while 1
    for b = 1:i
        a = randi(nrActions);
        s = cumsum(B(:,b)');
        srand = rand;
        s = sum(s<srand)+1;
        o = cumsum(observation(s,:,a));
        orand = rand;
        o = sum(o<orand)+1;
        %         disp (['a = ' num2str(a)]);
        %         disp (['o = ' num2str(o)]);
        bnew= NextBeliefPOMDP( B(:,b), a, o) ;
        new = 1;
        for ii = 1:i
            if isequal(round(10000*B(:,ii))/10000,round(10000*bnew)/10000)
            %if isequal(B(:,ii),bnew)
                new = 0;
                break;
            end
        end
        if new == 1
            B(:,i+1) = bnew;
            i = i+1;
            if i == n
                break;
            end
        end
    end
    if i == n
        break;
    end
end
end