function [ B ] = sampleBeliefsSSEABoundEqual( n, depth )
%% approximatelly sample equal number of points in each level.
global pomdp;

nrStates = pomdp.nrStates;
resetpoint = 0;
belief = 1/pomdp.nrStates*ones(pomdp.nrStates,1);
B = zeros(pomdp.nrStates,n);
B(:,1) = belief;
i = 1;
runtime1  = round(n/depth);

for bbb = 1:depth
    if bbb == 1
        istart = 1;
        iend = i;
        runtime = runtime1;
    else
        istart = iend+1;
        iend = i;
        runtime = 1;
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
B = B(:,1:i);

end
