function [ B ] = sampleBeliefsSSEA( n )
%sample n belief vectors return B (dim x n)
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
      babelief = ones(nrStates,nrActions);
      ba = 100*ones(nrActions,1);
      for a = 1:nrActions
      	s = cumsum(B(:,b)');
        srand = rand;
      	s = sum(s<srand)+1;
      	o = cumsum(observation(s,:,a));
        orand = rand;
      	o = sum(o<orand)+1;
%         disp (['a = ' num2str(a)]);
%         disp (['o = ' num2str(o)]);
      	bb = NextBeliefPOMDP( B(:,b), a, o) ;
      	[ba(a)] = min(sum(abs(bsxfun(@minus, bb, B)),1));
      	babelief(:,a) = bb;
      end
      [~,I] = max(ba);
      bnew = babelief(:,I);
      B(:,i+1) = bnew;
      i = i+1;
        if i == n
            break;
        end
  end
  if i == n
    break;
  end
end
end


