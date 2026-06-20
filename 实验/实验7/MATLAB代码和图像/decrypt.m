function decrypt()
    % 读取提取的加密图像
    encrypted = imread('secret_extracted.bmp');
    encrypted = uint8(encrypted > 0); % 二值化

    % 使用同样的XOR密钥解密
    key = uint8([1 0 1 1 0 1 0 0]); % 同加密
    [rows, cols] = size(encrypted);
    decrypted = zeros(rows, cols, 'uint8');

    for i = 1:rows
        for j = 1:cols
            k = key(mod(j-1,length(key))+1);
            decrypted(i,j) = bitxor(encrypted(i,j), k);
        end
    end

    imwrite(decrypted*255, 'b_recovered.bmp');
    disp('解密完成，保存为 b_recovered.bmp');
end