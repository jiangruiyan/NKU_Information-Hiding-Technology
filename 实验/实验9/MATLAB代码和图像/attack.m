clc;
clear;

img = im2double(imread('stego.bmp'));

attacked = imnoise(img,...
    'gaussian',...
    0,...
    0.001);

imshow(attacked);
imwrite(attacked,'attacked.bmp');
disp('攻击完成');