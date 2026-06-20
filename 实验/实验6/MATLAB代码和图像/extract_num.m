%% 提取整数
clc; clear;

% 读取嵌入后的图像
stego = imread('stego_integer.bmp');

% 嵌入的二进制长度（需要和隐藏时一致）
numBits = length(dec2bin(2313546));

% 展平成一维
stego_flat = stego(:);

% 提取前 numBits 位
binArray = bitand(stego_flat(1:numBits), 1);

% 转换为二进制字符串
binStr = char(binArray' + '0');  % 转置成行向量，避免 horzcat 错误

% 转换为整数
num_extracted = bin2dec(binStr);

% 输出
fprintf('提取出的整数为: %d\n', num_extracted);