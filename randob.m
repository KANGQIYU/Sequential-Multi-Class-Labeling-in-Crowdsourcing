function [ ob ] = randob( Aindex, belief )
global pomdp;
global indnrobservation;
s = cumsum( belief);
s(end) = 1;
srand = rand;
s = sum(s<srand)+1;
newo = cumsum(pomdp.observation(s,:,Aindex));
newo(indnrobservation(Aindex):end) = 1;
orand = rand;
ob = sum(newo<orand); %ob = ob(in matlab)-1
end