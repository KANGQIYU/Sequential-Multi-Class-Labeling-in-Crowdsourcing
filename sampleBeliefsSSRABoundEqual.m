function [ B ] = sampleBeliefsSSRABoundEqual(  n, depth )
%% approximatelly sample equal number of points in each level.    
global pomdp;
nrStates = pomdp.nrStates;

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
    a = randi(pomdp.AllnrActions(iin));
    s = cumsum(belief');
    s(end) = 1;
    srand = rand;
    s = sum(s<srand)+1;
    if ~isempty( pomdp.Allobservation{1})
        o = cumsum(pomdp.Allobservation{iin}(s,:,a));
        o(pomdp.Allindnrobservation{iin}(a):end) = 1;
    else
        o = cumsum(pomdp.observation(s,:,a));
        o(pomdp.indnrobservation(a):end) = 1;
    end
    orand = rand;
    o = sum(o<orand)+1;
    %         disp (['a = ' num2str(a)]);
    %         disp (['o = ' num2str(o)]);
    belief= NextBeliefPOMDP( belief, a, o, iin) ;    
end

end
%runtime1  = round(n/depth);
% for bbb = 1:depth
%     if bbb == 1
%         istart = 1;
%         iend = i;
%         runtime = runtime1;
%     else
%         istart = iend+1;
%         iend = i;
%         runtime = 1;
%     end
%     for runn = 1:runtime
%         for b = istart:iend
%             a = randi(nrActions);
%             s = cumsum(B(:,b)');
%             srand = rand;
%             s = sum(s<srand)+1;
%             o = cumsum(observation(s,:,a));
%             orand = rand;
%             o = sum(o<orand)+1;
%             %         disp (['a = ' num2str(a)]);
%             %         disp (['o = ' num2str(o)]);
%             bnew= NextBeliefPOMDP( B(:,b), a, o) ;
%             new = 1;
%             for ii = 1:i
%                 if isequal(B(:,ii),bnew)
%                     new = 0;
%                     break;
%                 end
%             end
%             if new == 1
%                 B(:,i+1) = bnew;
%                 i = i+1;
%             end
%         end
%     end
% end
% B = B(:,1:i);
% end