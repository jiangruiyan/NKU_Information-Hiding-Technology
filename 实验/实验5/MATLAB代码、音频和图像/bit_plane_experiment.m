clc;
clear;
close all;

%% 读取图像
img = imread('a.bmp');

% 如果是彩色图像，转为灰度图
if size(img, 3) == 3
    img = rgb2gray(img);
end

img = uint8(img);

%% 1. 提取并显示 1~8 任意位平面
figure('Name', '1~8位平面提取结果');

for k = 1:8
    bitPlane = bitget(img, k);          % 提取第 k 位平面
    bitPlaneShow = uint8(bitPlane) * 255; % 转换为可显示图像

    subplot(2, 4, k);
    imshow(bitPlaneShow);
    title(['第 ', num2str(k), ' 位平面']);
end

%% 2. 输入 n
n = input('请输入 n（1~7）：');

if n < 1 || n > 7
    error('n 必须在 1 到 7 之间');
end

%% 3. 显示 1~n 低位平面组成的图像
lowImg = zeros(size(img), 'uint8');

for k = 1:n
    lowImg = lowImg + uint8(bitget(img, k)) * 2^(k-1);
end

figure('Name', '低位平面图像');
imshow(lowImg, []);
title(['由第 1~', num2str(n), ' 位平面组成的图像']);

%% 4. 显示 8~(n+1) 高位平面组成的图像
highImg = zeros(size(img), 'uint8');

for k = n+1:8
    highImg = highImg + uint8(bitget(img, k)) * 2^(k-1);
end

figure('Name', '高位平面图像');
imshow(highImg);
title(['由第 8~', num2str(n+1), ' 位平面组成的图像']);

%% 5. 去掉 1~n 位平面后的图像显示
removeLowImg = img;

for k = 1:n
    removeLowImg = bitset(removeLowImg, k, 0);
end

figure('Name', '去掉低位平面后的图像');
imshow(removeLowImg);
title(['去掉第 1~', num2str(n), ' 位平面后的图像']);

%% 6. 保存实验结果
imwrite(lowImg, ['low_1_to_', num2str(n), '.bmp']);
imwrite(highImg, ['high_', num2str(n+1), '_to_8.bmp']);
imwrite(removeLowImg, ['remove_1_to_', num2str(n), '.bmp']);

disp('实验完成，结果图像已保存。');