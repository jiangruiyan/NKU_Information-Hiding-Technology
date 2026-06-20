clc;
clear;

% 读取原图
img = imread('a.bmp');

% 要隐藏的消息
msg = 'Nankai University';

% 如果图像不是uint8类型，转为uint8
if ~isa(img, 'uint8')
    img = im2uint8(img);
end

% 将消息转为 uint8 ASCII 编码
msg_bytes = uint8(msg);
msg_len = length(msg_bytes);   % 字符个数

% 将消息长度转为32位二进制
len_bits = zeros(1, 32);
temp_len = msg_len;
for i = 32:-1:1
    len_bits(i) = mod(temp_len, 2);
    temp_len = floor(temp_len / 2);
end

% 将消息内容转为二进制比特流（每个字符8位）
msg_bits = [];
for i = 1:msg_len
    byte = msg_bytes(i);
    bits = zeros(1, 8);
    temp = byte;
    for j = 8:-1:1
        bits(j) = mod(temp, 2);
        temp = floor(double(temp) / 2);
    end
    msg_bits = [msg_bits, bits];
end

% 最终要嵌入的比特流 = 32位长度 + 消息比特
all_bits = [len_bits, msg_bits];
num_bits = length(all_bits);

% 将图像展平成一维
img_vec = img(:);

% 检查容量是否足够
if num_bits > length(img_vec)
    error('图像容量不足，无法隐藏这么多信息！');
end

% 逐位写入到像素最低位
for i = 1:num_bits
    img_vec(i) = bitset(img_vec(i), 1, all_bits(i));
end

% 恢复图像原形状
stego_img = reshape(img_vec, size(img));

% 保存含密图像
imwrite(stego_img, 'b.bmp');

disp('信息隐藏完成，输出图像为 b.bmp');