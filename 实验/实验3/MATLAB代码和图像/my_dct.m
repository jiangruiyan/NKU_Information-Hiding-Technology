clc; clear; close all;

%% 读入图像
I = imread('a.png');
if size(I,3) == 3
    I = rgb2gray(I);
end
I = double(I);

[M, N] = size(I);

%% DCT
C = dct2(I);

ratios = [0.15, 0.30, 0.50, 0.80];
psnr_values = zeros(size(ratios));

figure;

for k = 1:length(ratios)
    r = ratios(k);

    C_mod = C;

    % DCT左上角是低频，右下角是高频
    keep_ratio = sqrt(1 - r);
    m_keep = floor(M * keep_ratio);
    n_keep = floor(N * keep_ratio);

    mask = zeros(M, N);
    mask(1:m_keep, 1:n_keep) = 1;

    C_mod = C_mod .* mask;

    % 逆DCT
    I_rec = idct2(C_mod);

    % 截断
    I_rec = min(max(I_rec, 0), 255);

    % PSNR
    mse = mean((I(:) - I_rec(:)).^2);
    psnr_values(k) = 10 * log10(255^2 / mse);

    subplot(2,2,k);
    imshow(uint8(I_rec));
    title(['DCT 去除 ', num2str(r*100), '%, PSNR=', num2str(psnr_values(k))]);
end

disp('DCT 的 PSNR 结果：');
disp(psnr_values);