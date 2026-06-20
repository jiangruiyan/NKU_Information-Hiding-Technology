clc;
clear;
close all;

%% ========== 读取原图 ==========
img = imread('lena.bmp');

if ndims(img) == 3
    img = rgb2gray(img);
end

img = double(img);

[img_h, img_w] = size(img);

%% ========== 读取水印 ==========
watermark = imread('watermark.bmp');

if ndims(watermark) == 3
    watermark = rgb2gray(watermark);
end

% 转二值图
watermark = watermark > 128;

%% ========== 参数 ==========
block_size = 8;
alpha = 15;

%% ========== 自动计算容量 ==========
max_h = floor(img_h / block_size);
max_w = floor(img_w / block_size);

%% ========== 调整水印大小 ==========
watermark = imresize(watermark, [max_h max_w]);

[wm_h, wm_w] = size(watermark);

%% ========== 开始嵌入 ==========
watermarked = img;

for i = 1:wm_h
    for j = 1:wm_w

        row = (i-1)*block_size + 1;
        col = (j-1)*block_size + 1;

        block = img(row:row+7, col:col+7);

        %% DCT
        dct_block = dct2(block);

        %% 选择两个中频系数
        c1 = dct_block(4,5);
        c2 = dct_block(5,4);

        %% bit = 1
        if watermark(i,j) == 1

            if c1 <= c2
                temp = c1;
                c1 = c2 + alpha;
                c2 = temp;
            end

        %% bit = 0
        else

            if c1 >= c2
                temp = c2;
                c2 = c1 + alpha;
                c1 = temp;
            end

        end

        %% 写回系数
        dct_block(4,5) = c1;
        dct_block(5,4) = c2;

        %% IDCT
        new_block = idct2(dct_block);

        %% 放回图像
        watermarked(row:row+7, col:col+7) = new_block;

    end
end

%% ========== 限制像素范围 ==========
watermarked = uint8(min(max(watermarked,0),255));

%% ========== 保存 ==========
imwrite(watermarked, 'watermarked.bmp');

save('wm_size.mat', 'wm_h', 'wm_w');

%% ========== 显示 ==========
figure;

subplot(1,3,1);
imshow(uint8(img));
title('原始图像');

subplot(1,3,2);
imshow(watermark);
title('水印图像');

subplot(1,3,3);
imshow(watermarked);
title('含水印图像');

disp('水印嵌入完成！');