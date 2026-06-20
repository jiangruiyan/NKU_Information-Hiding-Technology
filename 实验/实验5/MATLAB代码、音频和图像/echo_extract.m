clc;
clear;
close all;

%% 读取含水印语音
[y, fs] = audioread('watermarked.wav');

% 转为单声道
if size(y, 2) == 2
    y = mean(y, 2);
end

y = y(:);

%% 参数设置，要和嵌入代码保持一致
d0 = round(0.008 * fs);
d1 = round(0.014 * fs);

frame_len = 4096;
repeat_num = 3;

watermark_str = 'Nankai University';
watermark_len = length(watermark_str) * 8;

extract_raw_bits_len = watermark_len * repeat_num;
extract_raw_bits = zeros(1, extract_raw_bits_len);

%% 倒谱法提取
for i = 1:extract_raw_bits_len
    start_idx = (i - 1) * frame_len + 1;
    end_idx = i * frame_len;

    frame = y(start_idx:end_idx);

    % 加窗，减少频谱泄漏
    frame = frame .* hamming(frame_len);

    % 计算实倒谱
    spectrum = fft(frame);
    log_spectrum = log(abs(spectrum) + eps);
    cepstrum = real(ifft(log_spectrum));

    % 不再只比较单点，而是比较延迟附近一小段区域的能量
    range = 5;

    c0 = sum(abs(cepstrum(d0 - range + 1 : d0 + range + 1)));
    c1 = sum(abs(cepstrum(d1 - range + 1 : d1 + range + 1)));

    if c1 > c0
        extract_raw_bits(i) = 1;
    else
        extract_raw_bits(i) = 0;
    end
end

%% 多数投票，还原原始水印比特
extract_bits = zeros(1, watermark_len);

for i = 1:watermark_len
    start_idx = (i - 1) * repeat_num + 1;
    end_idx = i * repeat_num;

    bits_group = extract_raw_bits(start_idx:end_idx);

    if sum(bits_group) >= 2
        extract_bits(i) = 1;
    else
        extract_bits(i) = 0;
    end
end

%% 二进制转字符串
bit_matrix = reshape(extract_bits, 8, []).';
chars = char(bin2dec(num2str(bit_matrix))).';

%% 显示结果
disp('提取出的水印信息为：');
disp(chars);

disp('提取出的原始水印比特序列为：');
disp(extract_bits);

disp('提取出的重复编码比特序列为：');
disp(extract_raw_bits);

%% 计算误码率 BER
original_bits = reshape(dec2bin(uint8(watermark_str), 8).' - '0', 1, []);
bit_errors = sum(original_bits ~= extract_bits);
BER = bit_errors / length(original_bits);

disp(['误码数：', num2str(bit_errors)]);
disp(['误码率 BER：', num2str(BER)]);