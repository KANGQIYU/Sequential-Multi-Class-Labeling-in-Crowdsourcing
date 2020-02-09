function [ index ] = maxVN( VN, totalN )
global c;
    [~,index]=max(VN(1,:)+c*sqrt(log2(totalN)./VN(2,:)));
    index = index - 1; %in C++, starts from 0
end