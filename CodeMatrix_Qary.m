function [P_error, C] =  CodeMatrix_Qary(Pe, Nlength, Mspacesize, H, varargin)
% get the codematrix satisfying all the requriment
%Input:
%   H           : (matrix) H_k_i_j is the probability of classifying i as the decision given the j
%                           is the true hypotheis of worker k.
%   Pe          : (function) is the error probability function as the energy function when do simulated
%                            annealing. Please don't use BoundPeBound!!!!!!
%   Nlength     : (scalar) the number of workers.
%   Mspacesize  : (scalar) the size of searching space( number of hypothesis ).
%   [varargin]  : (scalar) optional argument fault_tolerance capacity ratio
%                        equals capacity/Nlength.
%Output:
%   C           : (matrix)  size is Mspacesize*Nlength.
%   P_error     : (scalar) final error probability according to the final matrix C.

narginchk(4, 5);
if length(varargin) == 1
    fault_tole = varagin;
    constraint = 1;
else
    constraint = 0;
end


% Initialization by random
% T = 10;
% alpha = 0.99;
T = 1000;
alpha = 0.99;
%C = round(rand(Mspacesize, Nlength));
C = randi([0 1],Mspacesize, Nlength);
E = Pe(C, H);


% main iteration
while 1
    tempC = C;
    j = 0;
    for i = 0 : 100,
        while 1
            perturb_row =  randi( Mspacesize);
            if rand(1) >0.5,
                perturb_colomn = randperm(Nlength,1);
            else
                perturb_colomn = randperm(Nlength,2);
            end
            C1 = C;
            C1(perturb_row,perturb_colomn) = ~C1(perturb_row,perturb_colomn);
            if constraint == 0,
                break;
            elseif 0<12
                break; %else continue to perturb the codematrix
            end
        end
        
        E1 = Pe(C1, H);
        delta_E =  E1 - E;
        %disp(delta_E);
        if isnan(delta_E)
            if isnan(E1)
                continue;
            else
                C = C1;
                j = j+1;
                E = E1;
            end
        else
           if delta_E < -1e-15
           %if delta_E < 0
                C = C1;
                j = j+1;
                E = E1;
            elseif delta_E> 1e-15
                if rand(1) < exp(-delta_E/T),
                    C = C1;
                    j = j+1;
                    E = E1;
                end
            end
            if j>10
                %disp(j);
                break,
            end
        end
    end
    
    
    T = alpha*T;
    if tempC == C,
        break;
    end
%     if T<1e-5
%         disp(T);
%     end
    
end
%disp(T);
P_error = E;
end