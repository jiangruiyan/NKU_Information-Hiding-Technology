%% LSB 信息隐藏
clc; clear;

% 读取载体图像 a.bmp
cover = imread('a.bmp');

% 读取要隐藏的图像 b.bmp
secret = imread('b.bmp');

%% 处理隐藏图像
if size(secret,3) == 3
    secret = rgb2gray(secret); % 转为灰度
end

if ~islogical(secret)
    level = graythresh(secret);
    secret = imbinarize(secret, level); % 二值化
end

[rows_c, cols_c, ~] = size(cover);
[rows_s, cols_s] = size(secret);

% 检查隐藏图像是否比载体大
if rows_s > rows_c || cols_s > cols_c
    error('隐藏图像尺寸不能大于载体图像');
end

%% 将载体图像转换为 double 以便操作
cover_double = double(cover);

%% 清除载体图像最低位并嵌入隐藏图像（左上角区域）
stego = cover; % 初始化
for ch = 1:size(cover,3)
    region = cover_double(1:rows_s, 1:cols_s, ch);
    region_lsb_cleared = bitand(region, 254);      % 清 LSB
    stego(1:rows_s, 1:cols_s, ch) = uint8(region_lsb_cleared + secret); % 嵌入
end

%% 保存结果
imwrite(stego, 'stego.bmp');
disp('LSB 隐写完成，生成 stego.bmp');