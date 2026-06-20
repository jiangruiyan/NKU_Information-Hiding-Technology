% 加载随机矩阵和参数
load('share_info.mat','rand_matrix','t','n');

% 读取子图
children = cell(1,n);
for i = 1:n
    children{i} = imread(['share', num2str(i), '.png']);
    children{i} = children{i} > 0;  % 转逻辑矩阵0/1
end

[rows2, cols2] = size(children{1});
rows = rows2/2; % 恢复原图尺寸
cols = cols2/2;

% 随机选择 k 张子图
k = input('请输入子图数量 k: ');
selected_shares = randperm(n,k);

% 初始化恢复图
final_real = ones(rows, cols, 'logical');

% 恢复逻辑
for i = 1:rows
    for j = 1:cols
        counter = 0;
        switch rand_matrix(i,j)
            case 1
                for idx = selected_shares
                    if children{idx}(2*i-1,2*j-1)==0
                        counter = counter + 1;
                    end
                end
            case 2
                for idx = selected_shares
                    if children{idx}(2*i-1,2*j)==0
                        counter = counter + 1;
                    end
                end
            case 3
                for idx = selected_shares
                    if children{idx}(2*i,2*j-1)==0
                        counter = counter + 1;
                    end
                end
            case 4
                for idx = selected_shares
                    if children{idx}(2*i,2*j)==0
                        counter = counter + 1;
                    end
                end
        end

        if counter >= t
            final_real(i,j) = 0;
        end
    end
end

% 保存恢复图像
imwrite(final_real*255,'recovered.png');
imshow(final_real);
title(['恢复图像 (t=', num2str(t), ', n=', num2str(n), ')']);
disp('恢复完成，保存为 recovered.png');