load('.\qaryquestion4000');
qary = zeros(9,8,8);
% for i = 1:8
%     for j = 1:8
%         qary(:,j,i) = sum(qaryquestion(:,:,i) == j,1);
%     end
% end
% j = 8;
% for i = 1:9
%     ax = subplot(3,3,i);
%     bar(ax,2:8,qary(i,2:end,j)/sum(qary(i,:,j)));
%     axis([1 9 0 1]);
%     ylabel('ratio');
%     xlabel('q-ary question');
%     title(['round = ' num2str(i)] );
% end
for i  = 79
    %pause(0.7);
    plot(qaryquestion(i,qaryquestion(i,:,1)>0,1),'-*');
    axis([1 9 2 6]);
    %hold on
end
hold off
%find(qaryquestion(:,9,1))
