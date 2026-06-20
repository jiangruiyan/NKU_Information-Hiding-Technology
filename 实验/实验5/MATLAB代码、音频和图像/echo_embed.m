clc;
clear;
close all;

%% 读取原始语音
[x, fs] = audioread('a.wav');

% 转为单声道
if size(x, 2) == 2
    x = mean(x, 2);
end

x = x(:);

%% 水印信息
watermark_str = 'Nankai University';

% 字符串转二进制
watermark_bits = reshape(dec2bin(uint8(watermark_str), 8).' - '0', 1, []);

%% 重复编码：每个比特重复3次，提高鲁棒性
repeat_num = 3;
embed_bits = repelem(watermark_bits, repeat_num);

%% 参数设置
alpha = 0.4;                 % 回声衰减系数
d0 = round(0.008 * fs);      % 比特0对应延迟，约8ms
d1 = round(0.014 * fs);      % 比特1对应延迟，约14ms

frame_len = 4096;            % 每帧长度
num_bits = length(embed_bits);

needed_len = num_bits * frame_len;

% 如果音频长度不够，补零
if length(x) < needed_len
    x = [x; zeros(needed_len - length(x), 1)];
end

%% 回声隐藏嵌入
y = x;

for i = 1:num_bits
    start_idx = (i - 1) * frame_len + 1;
    end_idx = i * frame_len;

    frame = x(start_idx:end_idx);

    if embed_bits(i) == 0
        delay = d0;
    else
        delay = d1;
    end

    echo_frame = frame;

    for n = delay + 1:frame_len
        echo_frame(n) = frame(n) + alpha * frame(n - delay);
    end

    y(start_idx:end_idx) = echo_frame;
end

%% 防止幅度溢出
y = y / max(abs(y)) * 0.95;

%% 保存含水印语音
audiowrite('watermarked.wav', y, fs);

%% 显示信息
disp('水印嵌入完成！');
disp(['原始水印信息：', watermark_str]);
disp(['原始水印比特数：', num2str(length(watermark_bits))]);
disp(['实际嵌入比特数：', num2str(length(embed_bits))]);
disp(['采样率 fs = ', num2str(fs)]);
disp(['d0 = ', num2str(d0), ' 个采样点']);
disp(['d1 = ', num2str(d1), ' 个采样点']);

%% 画图对比
t = (0:length(x)-1) / fs;

figure;
subplot(2,1,1);
plot(t, x);
title('原始语音波形');
xlabel('时间/s');
ylabel('幅度');

subplot(2,1,2);
plot(t, y);
title('嵌入回声水印后的语音波形');
xlabel('时间/s');
ylabel('幅度');