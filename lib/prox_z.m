% clc;
% clear;
% close all;
% Z=imread('C:/Users/Administrator/Pictures/Camera Roll/QQ图片20200914162324.jpg');
function [X] = prox_z(Z,Y1,Y2,Y3,Y4,L,tho,dV1,dV2,dV3)

sizeD= size(Z);
tenX   = reshape(Z, sizeD);
h = sizeD(1);
w = sizeD(2);
d = sizeD(3);
%% 
Eny_x   = ( abs(psf2otf([+1; -1], [h,w,d])) ).^2  ;
Eny_y   = ( abs(psf2otf([+1, -1], [h,d,w])) ).^2  ;
Eny_z   = ( abs(psf2otf([+1, -1], [w,d,h])) ).^2  ;
Eny_y   =  permute(Eny_y, [1 3 2]);
Eny_z   =  permute(Eny_z, [3 1 2]);
determ  =  Eny_x + Eny_y + Eny_z;

% v1=(psf2otf([+1; -1], [h,w,d]))'.*(dV1+Y2/tho);
% v2=(permute(psf2otf([+1; -1], [h,d,w]),[1 3 2]))'.*(dV2+Y3/tho);
% v3=(permute(psf2otf([+1; -1], [w,d,h]),[3 1 2]))'.*(dV3+Y4/tho);

dfx1=diff(dV1+Y2/tho, 1, 1);
dfy1=diff(dV2+Y3/tho, 1, 2);
dfz1=diff(dV3+Y4/tho, 1, 3);

v1  = zeros(sizeD);
v2  = zeros(sizeD);
v3  = zeros(sizeD);
v1(1:end-1,:,:) = dfx1;
v1(end,:,:)     = tenX(1,:,:) - tenX(end,:,:);
v2(:,1:end-1,:) = dfy1;
v2(:,end,:)     = tenX(:,1,:) - tenX(:,end,:);
v3(:,:,1:end-1) = dfz1;
v3(:,:,end)     = tenX(:,:,1) - tenX(:,:,end);

numer1=L-Y1/tho+v1+v2+v3;
z  = real( ifftn( fftn(numer1) ./ (determ + 1) ) );
X  = reshape(z,sizeD);

