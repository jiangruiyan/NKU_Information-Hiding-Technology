clc;
clear;

%% 载体图像
cover = imread('dataset/001.bmp');
if size(cover,3)==3
    cover = rgb2gray(cover);
end
cover = imresize(cover,[256 256]);

%% 水印
wm = imread('watermark.bmp');
wm = logical(wm);
wm_big = imresize(double(wm),[256 256]);
wm_big = wm_big > 0.5;

%% LSB嵌入
cover_uint8 = uint8(cover);
stego = bitset(cover_uint8,1,wm_big);
imshowpair(cover_uint8,stego,'montage');
title('Left: Cover    Right: Stego');
imwrite(stego,'stego.bmp');
disp('嵌入完成');