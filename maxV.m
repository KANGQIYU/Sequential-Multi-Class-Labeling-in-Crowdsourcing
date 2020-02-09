function [ index ] = maxV(VN)
    [~,index]=max(VN(1,:));
    index = index - 1; %in C++, starts from 0
end