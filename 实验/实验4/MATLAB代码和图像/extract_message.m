clc;
clear;

% 读取含密图像
img = imread('b.bmp');

% 如果图像不是uint8类型，转为uint8
if ~isa(img, 'uint8')
    img = im2uint8(img);
end

% 展平成一维
img_vec = img(:);

% 先读取前32位，得到消息长度
len_bits = zeros(1, 32);
for i = 1:32
    len_bits(i) = bitget(img_vec(i), 1);
end

% 二进制转十进制
msg_len = 0;
for i = 1:32
    msg_len = msg_len * 2 + len_bits(i);
end

% 再读取消息内容，共 msg_len * 8 位
msg_bits = zeros(1, msg_len * 8);
for i = 1:(msg_len * 8)
    msg_bits(i) = bitget(img_vec(32 + i), 1);
end

% 每8位还原一个字符
msg_bytes = zeros(1, msg_len, 'uint8');
for i = 1:msg_len
    byte_val = 0;
    for j = 1:8
        byte_val = byte_val * 2 + msg_bits((i-1)*8 + j);
    end
    msg_bytes(i) = uint8(byte_val);
end

% 转为字符串
msg = char(msg_bytes);

disp('提取出的隐藏信息为：');
disp(msg);