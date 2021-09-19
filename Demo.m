%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Paremeter Explanation
% If the detection effect is not good, you can adjust these parameters:
% Input: opts.sigma  = sigma;
% opts.theta  = 0.00001-0.0001;   % controls \alpha     weight of fibered-rank
% opts.varpi  = 0.03-0.6;   % controls \lambda_2  \|T\|_1
% opts.omega  = 10000;   % controls \tau       SVT
% opts.logtol = 0.000001;      % \varepsilon in LogTFNN
% Output: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you have any questions, please contact:
% Author: Xuan Kong
% Email: 13558713606@163.com
% Copyright:  University of Electronic Science and Technology of China
% Date: 2021/3/19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%* License: Our code is only available for non-commercial research use.
clear;
clc;
close all;

addpath('E:\研二上\张量/LogTFNN/lib/')
addpath('E:\研二上\张量/LogTFNN/lib/ToolBox/')
addpath('E:\研二上\张量/LogTFNN/lib/ToolBox/tensor_toolbox/')
imgpath = 'E:\研二上\张量/LogTFNN/images/';

imgDir = dir([imgpath '8.bmp']);

% patch parameters
patchSize = 40;
slideStep = 40;

img = imread([imgpath imgDir.name]);
figure,subplot(221)
imshow(img),title('Original image')

if ndims( img ) == 3
   img = rgb2gray( img );
end
img = double(img);

%% constrcut patch tensor of original image
tenD = gen_patch_ten(img, patchSize, slideStep);
[n1,n2,n3] = size(tenD);  
  
%% calculate prior weight map
%      step 1: calculate two eigenvalues from structure tensor
[lambda1, lambda2] = structure_tensor_lambda(img, 3);
%      step 2: calculate corner strength function
cornerStrength = (((lambda1.*lambda2)./(lambda1 + lambda2)));
%      step 3: obtain final weight map
maxValue = (max(lambda1,lambda2));
priorWeight = mat2gray(cornerStrength .* maxValue);
subplot(222),imshow(priorWeight,[]),title('priorWeight image')
%      step 4: constrcut patch tensor of weight map
tenW = gen_patch_ten(priorWeight, patchSize, slideStep);
    
%% The proposed model
Nway = size(tenD);
sigma=1;

opts=[];
opts.sigma  = sigma;
opts.theta  = 0.00001;   % controls \alpha     weight of fibered-rank
opts.varpi  = 0.15;   % controls \lambda_2  \|T\|_1
opts.omega  = 10000;   % controls \tau       SVT
opts.logtol = 0.000001;      % \varepsilon in LogTFNN

[tenB,tenT,~,~]=my_LogTFNN(tenD,tenW,opts);
tarImg = res_patch_ten_mean(tenT, img, patchSize, slideStep);
backImg = res_patch_ten_mean(tenB, img, patchSize, slideStep);


%% result
maxv = max(max(double(img)));
E = uint8( mat2gray(tarImg)*maxv );
A = uint8( mat2gray(backImg)*maxv );
subplot(223),imshow(E,[]),title('Target image')
subplot(224),imshow(A,[]),title('Background image')
