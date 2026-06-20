clc; clear; close all;

%% 1. 读取音频
[x, fs] = audioread('a.wav');

% 转单声道
if size(x,2) == 2
    x = mean(x, 2);
end

x = x(:);   % 转列向量
N = length(x);

%% 2. DCT变换
X = dct(x);

%% 3. 设置去除比例
ratios = [0.15, 0.30, 0.50, 0.80];
snr_values = zeros(size(ratios));

figure;

for i = 1:length(ratios)
    r = ratios(i);
    
    % 拷贝系数
    X_mod = X;
    
    % ===== 关键：删除高频（后半部分）=====
    num_remove = floor(N * r);
    
    % DCT中：前面是低频，后面是高频
    X_mod(end - num_remove + 1 : end) = 0;
    
    %% 4. 逆DCT
    x_rec = idct(X_mod);
    
    % 对齐长度
    x_rec = x_rec(1:N);
    
    %% 5. 计算SNR
    snr_values(i) = 10 * log10(sum(x.^2) / sum((x - x_rec).^2));
    
    %% 6. 绘图
    subplot(4,1,i);
    plot(x_rec);
    title(['DCT 去除高频 ', num2str(r*100), '%, SNR = ', num2str(snr_values(i))]);
end

%% 7. 输出结果
disp('SNR结果：');
disp(snr_values);