clc;
clear;
close all;

%% ========== 读取含水印图像 ==========
img = imread('watermarked.bmp');

if ndims(img) == 3
    img = rgb2gray(img);
end

img = double(img);

%% ========== 读取水印尺寸 ==========
load('wm_size.mat');

%% ========== 参数 ==========
block_size = 8;

%% ========== 提取 ==========
extract_wm = zeros(wm_h, wm_w);

for i = 1:wm_h
    for j = 1:wm_w

        row = (i-1)*block_size + 1;
        col = (j-1)*block_size + 1;

        block = img(row:row+7, col:col+7);

        %% DCT
        dct_block = dct2(block);

        %% 读取两个系数
        c1 = dct_block(4,5);
        c2 = dct_block(5,4);

        %% 判决
        if c1 > c2
            extract_wm(i,j) = 1;
        else
            extract_wm(i,j) = 0;
        end

    end
end

%% ========== 显示 ==========
figure;

imshow(extract_wm);

title('提取出的水印');

%% ========== 保存 ==========
imwrite(extract_wm, 'extract_watermark.bmp');

disp('水印提取完成！');