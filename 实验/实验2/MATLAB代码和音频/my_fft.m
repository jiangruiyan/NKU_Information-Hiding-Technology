clc; clear; close all;

% 1. 读取音频
[x, fs] = audioread('a.wav');

% 转单声道
if size(x,2) == 2
    x = mean(x, 2);
end

N = length(x);

% 2. FFT
X = fft(x);

% 关键：频谱移到中心（低频在中间）
X_shift = fftshift(X);

% 3. 不同比例
ratios = [0.15, 0.30, 0.50, 0.80];
snr_values = zeros(size(ratios));

figure;

for i = 1:length(ratios)
    r = ratios(i);
    
    % 复制频谱
    X_mod = X_shift;
    
    % 要删除的"高频比例"
    cut = floor(N * r / 2);
    
    % 删除两端（高频），保留中间（低频）
    X_mod(1:cut) = 0;
    X_mod(end-cut+1:end) = 0;
    
    % 逆移位
    X_ifft = ifftshift(X_mod);
    
    % 4. IFFT
    x_rec = real(ifft(X_ifft));
    
    % 5. 计算SNR
    snr_values(i) = 10 * log10(sum(x.^2) / sum((x - x_rec).^2));
    
    % 画图
    subplot(4,1,i);
    plot(x_rec);
    title(['去除高频 ', num2str(r*100), '%, SNR=', num2str(snr_values(i), '%.2f'), ' dB']);
end

% 输出SNR
disp('SNR结果（单位：dB）：');
disp(snr_values);