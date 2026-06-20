function child = assignPixels1(randNum,i,j,child)
    % 对 2x2 块左上角像素进行随机扰动
    % randNum = 1~4，随机选择扰动模式
    pixels = [2*i-1,2*j; 2*i,2*j-1; 2*i,2*j]; % 剩下三像素
    idx = randperm(3, randNum-1);             % 选 idx 个像素置0
    for k = idx
        child(pixels(k,1), pixels(k,2)) = 0;
    end
end
