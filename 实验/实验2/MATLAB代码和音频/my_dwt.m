clc; clear; close all;

%% 1. 读取音频
[x, fs] = audioread('a.wav');

if size(x,2) == 2
    x = mean(x, 2);
end

x = x(:);

%% 2. 小波分解
level = 5;
wname = 'db4';

[C, L] = wavedec(x, level, wname);

%% 3. 获取所有高频系数的位置
detail_pos = [];   % 在C中的位置索引

start = 0;

for i = 1:length(L)
    len = L(i);
    
    % 跳过最后一个（近似系数）
    if i ~= length(L)
        detail_pos = [detail_pos, start + (1:len)];
    end
    
    start = start + len;
end

detail_pos = detail_pos(:);

% 提取高频系数
detail_values = C(detail_pos);

%% 4. 删除比例
ratios = [0.15, 0.30, 0.50, 0.80];
snr_values = zeros(size(ratios));

figure;

for i = 1:length(ratios)
    r = ratios(i);
    
    C_mod = C;
    
    % 排序（按幅值）
    [~, idx] = sort(abs(detail_values));
    num_remove = floor(length(detail_values) * r);
    
    remove_idx = idx(1:num_remove);
    
    % 在C中对应位置置零
    C_mod(detail_pos(remove_idx)) = 0;
    
    %% 5. 重构
    x_rec = waverec(C_mod, L, wname);
    x_rec = x_rec(1:length(x));
    
    %% 6. SNR
    snr_values(i) = 10 * log10(sum(x.^2) / sum((x - x_rec).^2));
    
    subplot(4,1,i);
    plot(x_rec);
    title(['去除高频 ', num2str(r*100), '%, SNR = ', num2str(snr_values(i))]);
end

%% 7. 输出
disp('SNR结果：');
disp(snr_values);