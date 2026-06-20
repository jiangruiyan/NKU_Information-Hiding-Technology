clc; clear; close all;

%% 读入图像
I = imread('a.png');
if size(I,3) == 3
    I = rgb2gray(I);
end
I = double(I);

%% 一层二维小波分解
wname = 'db4';
[LL, LH, HL, HH] = dwt2(I, wname);

ratios = [0.15, 0.30, 0.50, 0.80];
psnr_values = zeros(size(ratios));

% 把高频子带拼起来，便于统一按比例删
high_all = [LH(:); HL(:); HH(:)];
num_total = length(high_all);

figure;

for k = 1:length(ratios)
    r = ratios(k);

    LH_mod = LH;
    HL_mod = HL;
    HH_mod = HH;

    % 按幅值从小到大排序，删除前 r 比例
    [~, idx] = sort(abs(high_all));
    num_remove = floor(num_total * r);
    remove_idx = idx(1:num_remove);

    % 构造整体掩码
    mask_all = true(num_total,1);
    mask_all(remove_idx) = false;

    % 映射回三个子带
    n1 = numel(LH);
    n2 = numel(HL);
    n3 = numel(HH);

    mask_LH = reshape(mask_all(1:n1), size(LH));
    mask_HL = reshape(mask_all(n1+1:n1+n2), size(HL));
    mask_HH = reshape(mask_all(n1+n2+1:n1+n2+n3), size(HH));

    LH_mod(~mask_LH) = 0;
    HL_mod(~mask_HL) = 0;
    HH_mod(~mask_HH) = 0;

    % 重构
    I_rec = idwt2(LL, LH_mod, HL_mod, HH_mod, wname, size(I));

    % 截断
    I_rec = min(max(I_rec, 0), 255);

    % PSNR
    mse = mean((I(:) - I_rec(:)).^2);
    psnr_values(k) = 10 * log10(255^2 / mse);

    subplot(2,2,k);
    imshow(uint8(I_rec));
    title(['DWT 去除 ', num2str(r*100), '%, PSNR=', num2str(psnr_values(k))]);
end

disp('DWT 的 PSNR 结果：');
disp(psnr_values);