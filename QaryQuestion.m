function [ question,  varargout ] = QaryQuestion( state, q, w )
%Notice this function is different of QaryFakeQuestion. Here the state are made up by
%sets, not a vector
%Return a suitable question, and notinques.
%Input:
%   state   :   (cell)      size 1x(num_error+1). Each element has the set whose members have
%                           falsify index times former questions.
%   q       :   (integer)   question is q-ary.
%   w       :   (integer)   there are w questions left(including the current one).
%Ouput:
%   question:   (cell)      size qx(num_error+1). Each row represents question set i.
%                           Please see the paper for refence
%  varargout:   (cell)      size qx(num_error+1). It's just used for convinience. Giving notinques
%                           to Function QaryNexState will improve the speed.

num_error = length(state);  %actually it's num_error + 1 
question = cell(q, num_error);
varargout{1} = cell(q,num_error);
state_sigma = zeros(1,num_error);
for i = 1:num_error
    state_sigma(i) = length(state{i});
end

quesfake = QaryFakeQuestion( state_sigma, q,  w);

for i = 1:num_error
    if state_sigma(i)>0
        temp = randperm(state_sigma(i));
        tt = 0;
        for j = 1:q
            question{j,i} = state{i}(temp(tt+1:tt+quesfake(j,i)));
            varargout{1}{j,i} = [temp(1:tt) temp(tt+quesfake(j,i)+1:end)];
            tt = tt+quesfake(j,i);
        end
    end
end