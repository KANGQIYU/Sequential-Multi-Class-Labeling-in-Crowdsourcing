function [Declare] = getDeclare(belief)
    [mmax] = max(belief);
    same = find(round(mmax*1000000)/1000000 == round(belief*1000000)/1000000);
    Declare = same(randi(length(same)));
end