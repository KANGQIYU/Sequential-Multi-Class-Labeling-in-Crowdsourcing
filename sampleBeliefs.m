function [ B ] = sampleBeliefs( n, depth )
%sample n belief vectors return B (dim x n)
global pomdp;

belief = 1/pomdp.nrStates*ones(pomdp.nrStates,1);
B = zeros(pomdp.nrStates,n);
i = 0;
iin = 0;
while 1
    new = 1;
    for ii = 1:i
        if isequal(round(10000*B(:,ii))/10000,round(10000*belief)/10000)
            new = 0;
            break;
        end
    end
    if new == 1
        B(:,i+1) = belief;
        i = i+1;
        if i == n
            break;
        end
    end
    
    iin = iin+1;
    if iin == depth+1
        belief = 1/pomdp.nrStates*ones(pomdp.nrStates,1);
        iin = 1;
    end
    a = randi(pomdp.nrActions);
    o = randi(length(pomdp.Actions{a}));
    [belief] = NextBeliefPOMDP( belief, a, o) ;
end
end
% a = randi(pomdp.nrActions);
% o = randi(length(pomdp.Actions{a}));
% [belief] = NextBeliefPOMDP( belief, a, o) ;
% B(:,1) = belief;


