function StirlingNumber = computeStirlingNum(n, box)
StirlingNumber = 0;
for j = 1:box
    StirlingNumber = StirlingNumber + (-1)^(box-j)*nchoosek(box,j)*j^n;
end
StirlingNumber = StirlingNumber/ factorial(box);
end