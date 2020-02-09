load('ulam');
%plot(2:8,-final(1:7),'-+r',2:8,ones(7,1)*6.8152);
plot(2:8,-final(1:7),'-+r',2:8,ones(7,1)*4.513,2:8,ones(7,1)*6.75);
ax=legend('Ulam-Renyi','Pomdp','PomdpSimulation');
axis([2 8 4 9]);
xlabel('Q-ary','FontSize',12);ylabel(' Empirical Cost','FontSize',12);