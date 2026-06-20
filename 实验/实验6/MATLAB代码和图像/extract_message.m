%% LSB 信息提取
clc; clear;

% 读取嵌入后的图像
stego = imread('stego.bmp');

% 读取原隐藏图像尺寸
% 方法：这里假设我们已知隐藏图像尺寸 rows_s, cols_s
% 或者可以读取 secret.bmp 预览尺寸
secret_ref = imread('b.bmp');  % 用原隐藏图像获取尺寸
[rows_s, cols_s] = size(secret_ref);

% 提取最低位
if size(stego,3) == 3
    extracted = zeros(rows_s, cols_s, 'uint8');
    for ch = 1:3
        % 每个通道都提取并叠加（逻辑 OR 也可以）
        extracted_channel = bitand(stego(1:rows_s, 1:cols_s, ch), 1);
        extracted = extracted | uint8(extracted_channel); % 合并到单通道
    end
else
    extracted = bitand(stego(1:rows_s, 1:cols_s), 1);
end

% 转为 0/255 二值图像
extracted_img = extracted * 255;

% 保存
imwrite(extracted_img, 'extract.bmp');
disp('提取完成，生成 extract.bmp');