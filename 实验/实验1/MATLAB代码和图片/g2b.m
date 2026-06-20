% 1. 读取彩色图像
img = imread('1.png');

% 2. 转灰度，并转为 double 便于计算
gray = double(rgb2gray(img));

[h, w] = size(gray);

% 3. 误差扩散
for i = 1:h
    for j = 1:w
        old_pixel = gray(i,j);

        % 二值化
        if old_pixel >= 128
            new_pixel = 255;
        else
            new_pixel = 0;
        end

        gray(i,j) = new_pixel;

        % 计算误差
        err = old_pixel - new_pixel;

        % 误差扩散
        if j+1 <= w
            gray(i, j+1) = gray(i, j+1) + err * 7/16;
        end
        if i+1 <= h && j-1 >= 1
            gray(i+1, j-1) = gray(i+1, j-1) + err * 3/16;
        end
        if i+1 <= h
            gray(i+1, j) = gray(i+1, j) + err * 5/16;
        end
        if i+1 <= h && j+1 <= w
            gray(i+1, j+1) = gray(i+1, j+1) + err * 1/16;
        end
    end
end

% 4. 转为 uint8 类型（保存必须）
halftone = uint8(gray);

% 5. 保存为 2.jpg
imwrite(halftone, '2.png');

% 6. 显示结果
imshow(halftone);
title('误差扩散半色调图像');