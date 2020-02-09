function [ B ] = sampleBeliefsSSRABound( n, depth )
%% approximatelly sample exponentially growing number of points in each level.
global pomdp;
nrStates = pomdp.nrStates;
resetpoint = 0;
belief = 1/pomdp.nrStates*ones(pomdp.nrStates,1);
B = zeros(pomdp.nrStates,n);
B(:,1) = belief;
i = 1;

runtime  = 2;
while 1
    if (runtime^(depth+1)-1)/(runtime-1) > n
        break;
    else
        runtime = runtime+1;
    end
end

for bbb = 1:depth
    if bbb == 1
        istart = 1;
        iend = i;
    else
        istart = iend+1;
        iend = i;
    end
    for runn = 1:runtime
        for b = istart:iend
            a = randi(pomdp.AllnrActions(bbb));
            s = cumsum(B(:,b)');
            s(end) = 1;
            srand = rand;
            s = sum(s<srand)+1;
            if ~isempty( pomdp.Allobservation{1})
                o = cumsum(pomdp.Allobservation{bbb}(s,:,a));
                o(pomdp.Allindnrobservation{bbb}(a):end) = 1;
            else
                o = cumsum(pomdp.observation(s,:,a));
                o(pomdp.indnrobservation(a):end) = 1;
            end
            
            orand = rand;
            o = sum(o<orand)+1;
            %         disp (['a = ' num2str(a)]);
            %         disp (['o = ' num2str(o)]);
            bnew= NextBeliefPOMDP( B(:,b), a, o, bbb) ;
            new = 1;
            for ii = 1:i
                if isequal(round(10000*B(:,ii))/10000,round(10000*bnew)/10000)
                    new = 0;
                    break;
                end
            end
            if new == 1
                B(:,i+1) = bnew;
                i = i+1;
            end
        end
    end
end
if i >= n
    B = B(:,randperm(i,n));
    B(:,1) = belief;
else
    B = B(:,1:i);
end
end