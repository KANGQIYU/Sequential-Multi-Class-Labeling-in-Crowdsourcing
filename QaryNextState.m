function [ nstate ] = QaryNextState( state, question, answer, varargin )
%Given current state, question and the answer to current current question
%"Which one of the sets question{1,:},question{2,:},...,question{q,:} does x belong to"
%Return next state.
%Input:
%   state   :   (cell)      size 1x(num_error+1). Each element has the set whose members have
%                           falsify index times former questions.
%   question:   (cell)      size qx(num_error+1). Each row represents question set i.
%   answer  :   (integer)   indicate which one x belongs to.
% notinques*:   (cell)      size qx(num_error+1). The members are not in question_i. 
%Output:
%   ntate   :   (cell)      size 1x(num_error+1).
num_error = length(state)-1;
nstate = cell(1, num_error+1);

if length(varargin) == 1
    %ques_index = varargin{1};
    notinques= varargin{1};
    nstate{1} = question{answer,1};
    for i = 1:num_error
        nstate{i+1} = [state{i}(notinques{answer,i}) question{answer,i+1}];
    end
elseif isempty(varargin)
    nstate{1} = question{answer,1};
    for i = 1:num_error
        temp = union(setdiff(state{i},question{answer,i}),question{answer,i+1});
        nstate{i+1} = temp(:)';
    end
else
    error('NextState: wrong input, Pls check');
end

end