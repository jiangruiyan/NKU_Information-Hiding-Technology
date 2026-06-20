clc;
clear;

load netExtract.mat
img = im2double(imread('attacked.bmp'));
wm_rec = predict(netExtract,img);
wm_rec = wm_rec > 0.5;
wm_rec = imresize(wm_rec,[64 64]);

figure

subplot(1,2,1)
imshow(wm_rec)
title('Recovered Watermark')

subplot(1,2,2)
imshow(imread('watermark.bmp'))
title('Original Watermark')

imwrite(wm_rec,'recovered.bmp');
disp('提取完成');