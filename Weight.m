function [we] = Weight(state_sigma, q, w)
e = length(state_sigma)-1;
we = 0;

for i = 0:e
    temp = 0;
    if e-i>=w
        for j= 0:w
            temp = temp+nchoosek(fix(w),j)*(q-1)^j;
        end
    else
        for j= 0:e-i
            temp = temp+nchoosek(fix(w),j)*(q-1)^j;
        end
    end
    we = we + state_sigma(i+1)*temp;
end
end