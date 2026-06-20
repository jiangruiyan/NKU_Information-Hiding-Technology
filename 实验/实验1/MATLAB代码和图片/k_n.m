% 读取图像并二值化
I = imread('2.png');
if size(I,3) == 3
    I = rgb2gray(I);
end
thresh = graythresh(I);
I = im2bw(I, thresh);     % 转0/1
I = imresize(I,[256,256]);
[rows, cols] = size(I);

% 输入参数
t = input('请输入门限子图数量 t: '); % ≥ t 张才能恢复
n = input('请输入子图总数 n: ');

rng(1); % 固定随机种子

% 子图尺寸（像素扩展2x2）
new_rows = rows*2;
new_cols = cols*2;

% 初始化子图
children = cell(1,n);
for i = 1:n
    children{i} = ones(new_rows, new_cols, 'uint8'); % 白色初始
end

% 随机位置记录
rand_matrix = zeros(rows, cols);

% 生成子图
for i = 1:rows
    for j = 1:cols
        bool0 = randi([1,4]);
        rand_matrix(i,j) = bool0;

        if I(i,j) == 0
            idx = randperm(n,n);
        else
            idx = randperm(n,t-1);
        end

        % 设置主要像素
        for k = idx
            switch bool0
                case 1, children{k}(2*i-1,2*j-1)=0;
                case 2, children{k}(2*i-1,2*j)=0;
                case 3, children{k}(2*i,2*j-1)=0;
                case 4, children{k}(2*i,2*j)=0;
            end
        end

        % 随机扰动
        random_numbers = randi([1,4],1,n);
        for k = 1:n
            switch bool0
                case 1, children{k} = assignPixels1(random_numbers(k),i,j,children{k});
                case 2, children{k} = assignPixels2(random_numbers(k),i,j,children{k});
                case 3, children{k} = assignPixels3(random_numbers(k),i,j,children{k});
                case 4, children{k} = assignPixels4(random_numbers(k),i,j,children{k});
            end
        end
    end
end

% 保存子图
for i = 1:n
    imwrite(children{i}*255, ['share', num2str(i), '.png']);
end

% 保存随机矩阵和参数，用于恢复
save('share_info.mat','rand_matrix','t','n');

disp(['生成完成：share1.png ~ share', num2str(n), '.png']);