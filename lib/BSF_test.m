clear;
clc;
close all;

%% 计算目标邻域大小 width为长，height为宽
I=imread('E:/研二上/张量/result/target_compare/PSTNN4.bmp');
[L,nm] = bwlabel(I,8);
%根据标定数据找到连通域
i=L(112,158);
[r,c] = find(L == i);
left = min(c);
right = max(c);
top = min(r);
buttom = max(r);
width = right - left;
height = buttom - top;

%% 计算原图灰度标准差
I0=imread('E:/研二上/张量/数据集/data/Video2Frames11/0001.bmp');
I1=I0(top-25:buttom+25,left-25:right+25);
sigma_b=(std2(I1))^2;

%% 计算检测图像灰度标准差
I2o=I(top-25:buttom+25,left-25:right+25);
sigma_bo=(std2(I2o))^2;

%% 计算BSF
BSF=sigma_b/sigma_bo