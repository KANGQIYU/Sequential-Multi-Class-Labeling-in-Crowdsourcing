function [ question, Aindex] = QaryQuestionPOMDP( belief,  w )
%Return a suitable question, and notinques.
%Input:
%   belief   :  (vector)  nrStates x 1     
%   w       :   (integer) there are w questions left(including the current one).
%Ouput:
%   question:   (cell)    return a question cell
global pomdp;
[Aindex, ~, ~] = getAction_Declare(belief, pomdp.solution{w});
if ~isempty( pomdp.Allobservation{1})
    if Aindex > pomdp.AllnrActions(w)
        question = [];
    else
        question = pomdp.AllActions{w}{Aindex};
    end
else
    if Aindex > pomdp.nrActions
        question = [];
    else
        question = pomdp.Actions{Aindex};
    end
end

end

