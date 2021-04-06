clear;
clc;
close all;

%% 计算目标邻域大小 width为长，height为宽
I=imread('E:/研二上/张量/result/target_compare/PSTNN5.bmp');
[L,nm] = bwlabel(I,8);
%根据标定数据找到连通域
i=L(119,87);
[r,c] = find(L == i);
left = min(c);
right = max(c);
top = min(r);
buttom = max(r);
width = right - left;
height = buttom - top;

%% 计算原图SCR
I0=imread('E:/研二上/张量/数据集/data/Video2Frames1/0001.jpg');
I1=I0(top:buttom,left:right);
I2=I0(top-25:buttom+25,left-25:right+25);
miu_t=mean(mean(I1));
miu_b=mean(mean(I2));
sigma_b=(std2(I2))^2;
SCR_in=abs(miu_t-miu_b)/sigma_b;

%% 计算检测图像SCR
I1o=I(top:buttom,left:right);
I2o=I(top-25:buttom+25,left-25:right+25);
miu_to=mean(mean(I1o));
miu_bo=mean(mean(I2o));
sigma_bo=(std2(I2o))^2;
SCR_out=abs(miu_to-miu_bo)/sigma_bo;

%% 计算SCRG
SCRG=SCR_out/SCR_in
