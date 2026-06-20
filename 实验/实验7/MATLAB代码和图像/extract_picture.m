function extract_picture()
    % 读取嵌入后的图像
    stego = imread('stego.bmp');
    if size(stego,3) > 1
        stego = rgb2gray(stego);
    end
    stego = uint8(stego);

    % 假设秘密图像大小与原始秘密图像相同
    secret_size = size(imread('secret_encrypted.bmp'));
    rows = secret_size(1);
    cols = secret_size(2);

    stego_flat = stego(:);
    extracted = zeros(rows*cols,1,'uint8');

    for idx = 1:rows*cols
        byte = stego_flat(idx);
        ones_count = sum(bitget(byte, 1:8));
        % 提取奇偶性作为隐藏位
        extracted(idx) = mod(ones_count,2);
    end

    secret_extracted = reshape(extracted, rows, cols);
    imwrite(secret_extracted*255, 'secret_extracted.bmp'); % 二值图像
    disp('提取完成，保存为 secret_extracted.bmp');
end