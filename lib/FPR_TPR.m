clear;
clc;
close all;

%% 统计不同阈值下的FPR
I=imread("E:\研二上\张量\result\target_compare\LCM4.bmp");
[m,n]=size(I);
s=m*n;
FPR=[];
for i=0.05:0.05:1
    I1=im2bw(I,i);
    num1=sum(sum(I1==1));
    fpr=num1/s;
    FPR=[FPR,fpr];
end

%% 统计不同阈值下的TPR
TPR=[];
for j=0.05:0.05:1
    I2=im2bw(I,j);
    if(I(112,158)==0)
        tpr=0;
    else
        tpr=1;
    end
    TPR=[TPR,tpr];
end

result=[TPR;FPR];




