function [ B ] = sampleBeliefsSSEABound( n, depth )
%% approximatelly sample exponentially growing number of points in each level. 
global pomdp;

nrStates = pomdp.nrStates;
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
            babelief = ones(nrStates,pomdp.AllnrActions(bbb));
            ba = 100*ones(pomdp.AllnrActions(bbb),1);
            for a = 1:pomdp.AllnrActions(bbb)
                s = cumsum(B(:,b)');
                srand = rand;
                s = sum(s<srand)+1;
                o = cumsum(pomdp.Allobservation{bbb}(s,:,a));
                orand = rand;
                o = sum(o<orand)+1;
                %         disp (['a = ' num2str(a)]);
                %         disp (['o = ' num2str(o)]);
                bb = NextBeliefPOMDP( B(:,b), a, o, bbb) ;
                [ba(a)] = min(sum(abs(bsxfun(@minus, bb, B)),1));
                babelief(:,a) = bb;
            end
            [~,I] = max(ba);
            bnew = babelief(:,I);
            B(:,i+1) = bnew;
            i = i+1;
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

