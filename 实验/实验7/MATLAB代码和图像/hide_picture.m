function hide_picture()
    % 读取载体图像
    carrier = imread('a.bmp');
    if size(carrier,3) > 1
        carrier = rgb2gray(carrier); % 转灰度
    end
    carrier = uint8(carrier);

    % 读取加密图像
    secret = imread('secret_encrypted.bmp');
    secret = uint8(secret > 0); % 确保是0/1

    [rows, cols] = size(secret);

    % 确保载体足够大
    if numel(carrier) < rows*cols
        error('载体图像太小，无法嵌入');
    end

    carrier_flat = carrier(:);

    for idx = 1:rows*cols
        bit = secret(idx);
        byte = carrier_flat(idx);

        % 设置奇偶校验位
        ones_count = sum(bitget(byte, 1:8));
        if mod(ones_count,2) ~= bit
            % 翻转最低有效位，改变奇偶性
            byte = bitxor(byte, 1);
        end

        carrier_flat(idx) = byte;
    end

    stego = reshape(carrier_flat, size(carrier));
    imwrite(stego, 'stego.bmp');
    disp('嵌入完成，保存为 stego.bmp');
end