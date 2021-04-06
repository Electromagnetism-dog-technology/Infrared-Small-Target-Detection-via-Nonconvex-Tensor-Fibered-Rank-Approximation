clear;
clc;
close all;

addpath('E:/研二上/张量/LogTFNN/lib/')
addpath('E:/研二上/张量/LogTFNN/lib/ToolBox/')
addpath('E:/研二上/张量/LogTFNN/lib/ToolBox/tensor_toolbox/')
imgpath = 'E:/研二上/张量/LogTFNN/images/';

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
opts.varpi  = 0.3;   % controls \lambda_2  \|T\|_1
opts.omega  = 10000;   % controls \tau       SVT
opts.logtol = 10000;      % \varepsilon in LogTFNN

[tenB,tenT,~,~]=my_LogTFNN(tenD,tenW,opts);
tarImg = res_patch_ten_mean(tenT, img, patchSize, slideStep);
backImg = res_patch_ten_mean(tenB, img, patchSize, slideStep);


%% result
maxv = max(max(double(img)));
E = uint8( mat2gray(tarImg)*maxv );
A = uint8( mat2gray(backImg)*maxv );
subplot(223),imshow(E,[]),title('Target image')
subplot(224),imshow(A,[]),title('Background image')
