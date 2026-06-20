clc;
clear;
close all;

%% 水印
wm = imread('watermark.bmp');
wm_big = imresize(double(wm),[256 256]);

%% 数据集
files = dir('dataset/*.bmp');
N = length(files);
X = zeros(256,256,1,N);
Y = zeros(256,256,1,N);

for k = 1:N

    img = imread(fullfile('dataset',files(k).name));
    if size(img,3)==3
        img = rgb2gray(img);
    end
    img = imresize(img,[256 256]);

    %% 模拟LSB嵌入
    wm_bin = wm_big > 0.5;
    stego = bitset(uint8(img),1,wm_bin);

    %% 模拟攻击

    stego = im2double(stego);
    attacked = imnoise(stego,...
        'gaussian',...
        0,...
        0.001);
    X(:,:,1,k) = attacked;
    Y(:,:,1,k) = wm_big;

end

%% CNN

layers = [
imageInputLayer([256 256 1],...
'Normalization','none')
convolution2dLayer(3,8,'Padding','same')
reluLayer
convolution2dLayer(3,16,'Padding','same')
reluLayer
convolution2dLayer(3,8,'Padding','same')
reluLayer
convolution2dLayer(3,1,'Padding','same')
sigmoidLayer
regressionLayer

];

options = trainingOptions('adam',...
    'MaxEpochs',10,...
    'MiniBatchSize',4,...
    'InitialLearnRate',1e-3,...
    'Verbose',false,...
    'Plots','training-progress');

netExtract = trainNetwork(...
    X,...
    Y,...
    layers,...
    options);

save netExtract.mat netExtract

disp('训练完成');