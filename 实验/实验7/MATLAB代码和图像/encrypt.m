function encrypt()
    % 加载二值图像
    secret = imread('b.bmp');
    secret = uint8(secret > 0); % 二值化为0/1

    % 简单XOR加密，密钥硬编码
    key = uint8([1 0 1 1 0 1 0 0]); % 8位密钥
    [rows, cols] = size(secret);
    encrypted = zeros(rows, cols, 'uint8');

    for i = 1:rows
        for j = 1:cols
            % 循环密钥
            k = key(mod(j-1, length(key))+1);
            encrypted(i,j) = bitxor(secret(i,j), k);
        end
    end

    imwrite(encrypted, 'secret_encrypted.bmp');
    disp('加密完成，保存为 secret_encrypted.bmp');
end