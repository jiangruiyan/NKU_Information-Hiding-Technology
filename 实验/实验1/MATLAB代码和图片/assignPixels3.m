function child = assignPixels3(randNum,i,j,child)
    % 对 2x2 块左下角像素扰动
    pixels = [2*i-1,2*j-1; 2*i-1,2*j; 2*i,2*j];
    idx = randperm(3, randNum-1);
    for k = idx
        child(pixels(k,1), pixels(k,2)) = 0;
    end
end