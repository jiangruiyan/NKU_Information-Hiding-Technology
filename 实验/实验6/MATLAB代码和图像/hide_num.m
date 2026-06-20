%% 隐藏整数到图像 LSB
clc; clear;

cover = imread('a.bmp');  % 载体图像
num = 2313546;             % 要嵌入的整数

% 转二进制
binStr = dec2bin(num);
binArray = binStr - '0';
binArray = binArray(:);    % 转为列向量

numBits = length(binArray);

[rows, cols, channels] = size(cover);
totalPixels = rows * cols * channels;
if numBits > totalPixels
    error('载体图像太小，无法嵌入该整数');
end

% 转一维
cover_flat = cover(:);

% 清除最低位并嵌入
cover_flat(1:numBits) = bitand(cover_flat(1:numBits), 254) + uint8(binArray);

% 恢复原形状
stego = reshape(cover_flat, size(cover));

imwrite(stego, 'stego_integer.bmp');
disp(['整数 ', num2str(num), ' 已嵌入到 stego_integer.bmp']);