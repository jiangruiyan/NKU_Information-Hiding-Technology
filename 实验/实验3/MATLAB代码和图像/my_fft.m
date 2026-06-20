clc; clear; close all;

%% 读入图像
I = imread('a.png');
if size(I,3) == 3
    I = rgb2gray(I);
end
I = double(I);

[M, N] = size(I);

%% FFT
F = fftshift(fft2(I));

ratios = [0.15, 0.30, 0.50, 0.80];
psnr_values = zeros(size(ratios));

figure;

for k = 1:length(ratios)
    r = ratios(k);

    F_mod = F;

    % 保留中心低频区域，删除外围高频
    keep_ratio = sqrt(1 - r);   % 面积比例换算成边长比例
    h = floor(M * keep_ratio / 2);
    w = floor(N * keep_ratio / 2);

    cx = floor(M/2) + 1;
    cy = floor(N/2) + 1;

    mask = zeros(M, N);
    mask(cx-h:cx+h, cy-w:cy+w) = 1;

    F_mod = F_mod .* mask;

    % 逆FFT
    I_rec = real(ifft2(ifftshift(F_mod)));

    % 截断到合法范围
    I_rec = min(max(I_rec, 0), 255);

    % PSNR
    mse = mean((I(:) - I_rec(:)).^2);
    psnr_values(k) = 10 * log10(255^2 / mse);

    subplot(2,2,k);
    imshow(uint8(I_rec));
    title(['FFT 去除 ', num2str(r*100), '%, PSNR=', num2str(psnr_values(k))]);
end

disp('FFT 的 PSNR 结果：');
disp(psnr_values);