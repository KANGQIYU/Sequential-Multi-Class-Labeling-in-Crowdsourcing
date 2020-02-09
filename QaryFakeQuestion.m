function [ question ] = QaryFakeQuestion( state_sigma, q,  w)
%Give the state sigma, which is simplified in the form of number, return the next question
%Here the question is numbers of course, not the true set.
%!!!!Here please ensure that if the state is not a final or last but one state its weight is a power of q!!!!
%Input:
%state_sigma   : (vector) each element(scalar) of this vector is the size of each
%                         element(set) in the true state.
%q             : (scalar) Q-ary

%Output:
%question      : (matrix) size q*(k+1), each row contains the elements(scalar) in each
%                       question. 

e = length(state_sigma)-1;
question = zeros(q,e+1);
% if length(varargin) == 1
%     w = varargin;
% end
if sum(state_sigma) <=1
    %% this is a final state, no need to ask more questions.
    %enough_ques = 0;
    disp('final state, no need question');
elseif sum(state_sigma<0)>0
    error('state has element less than 0');
elseif w == 0 && sum(state_sigma) >1
    %enough_ques = 0;
    disp('cannot');
    return;
else
    %     if sum(state_sigma(1:end-1)) < 2
    %         disp('NearEnd');
    %     end
%         if Weight(state_sigma, q, w)~= q^w
%             disp('NearEnd');
%         end
    
    tempweight = zeros(q,1);
    a = find(state_sigma>0);
    remainder = mod(state_sigma(a(1)),q);
    quotient = (state_sigma(a(1))-remainder)/q;
    question(1:remainder,a(1)) = quotient+1;
    question(remainder+1:end,a(1)) = quotient;
    %     if quotient == 1
    %         disp('now');
    %     end
    for i = a(1)+1:e+1
        if state_sigma(i)~=0
            temp = bsxfun(@minus, [state_sigma(:,1:i-1) zeros(1, e+1-i+1)], question);
            temp = [zeros(q,1) temp(:,1:end-1)];
            tempstate = temp+question;
            for j = 1:q
                tempweight(j) = Weight(tempstate(j,:), q, w-1);
            end
            %[sortweight, sindex]= sort(tempweight);
            %question = question(sindex,:);
%             diff = ones(q,1)*sortweight(end) - sortweight;
%             %            diffsum = cumsum(diff);
%             diffsum = sum(diff);
            
            unitwe = Weight([zeros(1,i-1) 1 zeros(1,e-i+1)], q, w-1);
            we = unitwe*state_sigma(i);
            H = q*eye(q)-ones(q);
            %f = sum(bsxfun(@minus,sortweight',sortweight),1);
            f = sum(bsxfun(@minus,tempweight',tempweight),1);
            A = -1*eye(q);
            b = zeros(q,1);
            Aeq =  ones(1,q);
            beq = we;
            options = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off','TolX', 1e-2);
            diswe = fix(quadprog(H,f,A,b,Aeq,beq,[],[],[],options));
%             %             largethan0 = (we>=diffsum);
%             %             largethan0index = sum(largethan0);
%             %             tempdiff = [diff(1:largethan0index);zeros(q-largethan0index,1)];
%             %             if largethan0index >0
%             %                 tt = diffsum(largethan0index);
%             %             else
%             %                 tt = 0;
%             %                 largethan0index = 1;
%             %             end
%             %             diswe = [ones(largethan0index,1)*(we-tt)/largethan0index; zeros(q-largethan0index,1)]+tempdiff;
%             if we>=diffsum
%                 diswe = (we-diffsum)/length(diff)+diff;
%             else
%                 diswe = we/diffsum*diff;
%             end
            %             if diffsum(1) ~=0
            %                 question(:,i) = floor(diswe/unitwe);
            %             end
            question(:,i) = fix(diswe/unitwe);
            %disp(['diswe' num2str(state_sigma(i)) ':' num2str(transpose(diswe/unitwe))]);
            tempstate(:,i) = tempstate(:,i)+question(:,i);
            for j = 1:q
                tempweight(j) = Weight(tempstate(j,:), q, w-1);
            end
            [~, sindex]= sort(tempweight);
            question = question(sindex,:);
            %question(:,i) = floor(diswe/unitwe);
            left = state_sigma(i)-sum(question(:,i));
            if left<0
                disp('caonima!');
            end
            if tempweight(1)==tempweight(2)
%                 [~, sindex]= sort(question(:,i));
%                 question = question(sindex,:);
                h = 1;
                while tempweight(h) == tempweight(h+1)
                    h = h+1;
                    if h+1>length(tempweight)
                        break;
                    end
                end
                if h == length(tempweight)
                    [~,iindex] = sort(sum(question,2));
                    question = question(iindex,:);
                end
            end
            remainder = mod(left,q);
            quotient = (left-remainder)/q;
            question(1:remainder,i) = quotient+1+question(1:remainder,i);
            question(remainder+1:end,i) = quotient+question(remainder+1:end,i);
           
            if sum(sum(question<0))>0
                disp('fuck');
            end
           % disp(['last' num2str(transpose(question(:,i)))]);
        end
    end
     [nextstate] = StateAfterQues(state_sigma, question, q);
        if sum(sum(nextstate<0))>0
            disp('fuck');
        end
%     for i = 1:size(nextstate,1)
%         if Weight(nextstate(i,:), q, w-1)~= q^(w-1)
%             enough_ques = 0;
%             return;
%         end
%     end
    
end
end


% function [we] = Weight(state_sigma, q, w)
% e = length(state_sigma)-1;
% we = 0;
% 
% for i = 0:e
%     temp = 0;
%     if e-i>=w
%         for j= 0:w
%             temp = temp+nchoosek(fix(w),j)*(q-1)^j;
%         end
%     else
%         for j= 0:e-i
%             temp = temp+nchoosek(fix(w),j)*(q-1)^j;
%         end
%     end
%     we = we + state_sigma(i+1)*temp;
% end
% end

function [nextstate]= StateAfterQues(state_sigma, question, q)

%e = length(state_sigma)-1;
%nextstate = zeros(q,e+1);
%nextstate(:,1) = question(:,1);
temp = bsxfun(@minus, state_sigma, question);
temp = [zeros(q,1)  temp(:,1:end-1)];
nextstate = temp+question;

end
