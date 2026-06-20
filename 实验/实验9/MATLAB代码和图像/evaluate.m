clc;
clear;

%% PSNR
cover = imread('dataset/001.bmp');
cover = imresize(cover,[256 256]);
stego = imread('stego.bmp');
PSNR = psnr(stego,cover);

%% SSIM
SSIM = ssim(stego,cover);

%% NC
wm1 = double(imread('watermark.bmp'));
wm2 = double(imread('recovered.bmp'));
NC = sum(sum(wm1.*wm2)) / ...
sqrt(sum(sum(wm1.^2))*sum(sum(wm2.^2)));

%% 输出
fprintf('PSNR = %.4f dB\n',PSNR);
fprintf('SSIM = %.4f\n',SSIM);
fprintf('NC   = %.4f\n',NC);