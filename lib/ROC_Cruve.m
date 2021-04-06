% This code aims to draw the roc cruve of all the algorithms in one image.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function details
% this code can most draw 7 algorithm in one image.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you have any questions, please contact:
% Author: Tianfang Zhang
% Email: sparkcarleton@gmail.com
% Copyright:  University of Electronic Science and Technology of China
% Date: 2018/10/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%* License: Our code is only available for non-commercial research use.

clc;    clear;  close all;

%==========================================================================
% Change the variables HERE!
% folder_pack = {
%     'patchsize20', 'patchsize30', 'patchsize40',...
%     'patchsize50', 'patchsize60'
%     };
% folder_pack = {
%     'len(20)_Frames1'
%     };
alg_pack = {
    'method2(5)','method1(5)','method3(5)','method4(5)','method5(5)','method6(5)','method7(5)','method8(5)','method9(5)'
    };
blg_pack = {
    'Top-hat','LCM','MPCM','IPI','NRAM','RIPT','TMESNN','PSTNN','Proposed'
    };
% alg_pack = {
%     'beta1(6)','beta2(6)','beta3(6)','beta4(6)','beta5(6)'
%     };
% blg_pack = {
%     'β=0.01','β=0.03','β=0.05','β=0.07','β=0.09'
%     };

% alg_pack = {
%     'miu100(6)','miu200(6)','miu300(6)','miu400(6)','miu500(6)'
%     };
% blg_pack = {
%     'μ=100','μ=200','μ=300','μ=400','μ=500'
%     };
lineWidth = 4.5;
fontSize = 13;

% Set save parameter
saveControl = false;
prefix = 'ROC/';    % the type must be 'prefix_'
suffix = '';    % the type must be '_suffix'

% The element of folder pack can be choosen in folder_pack_all
% folder_pack_all = {'Frames1', 'Frames2', 'Frames2_full', 'Frames3', 'Frames4',...
%  'Video2Frames1', 'Video2Frames1_full', 'Video2Frames2', 'Video2Frames3', 'Video2Frames4',...
% 'Video2Frames5', 'Video2Frames6', 'Video2Frames8', 'Video2Frames9',...
% 'Video2Frames10', 'Video2Frames11', 'Video2Frames12', 'Video2Frames13'};
%==========================================================================

% [~, len_folder] = size(folder_pack);
[~, len_alg] = size(alg_pack);
[~, len_blg] = size(blg_pack);
leg = cell(1, len_blg);

LineColor = {'g', 'r', 'b', 'c', 'm', 'k', 'y','b','r'};
% LineSign = { '.', '+', '*'};
LineType = {'-.', '--', ':', '-.', '--', ':', '-.','--','-'};

% for i = 1:len_folder    % loop each folder
	% create a figure and hold on to draw
    figure
    hold on
    
%     folderName = folder_pack{i};
    for j = 1:len_alg   % each alg in one folder draw in one image
        % get the parameter of line (color and type)
        algName = alg_pack{j};
        symbol = strcat(LineColor{j}, LineType{j});
        
        % load data and plot with different line type and width
%         load( ['ROC\', algName, '_', folderName, '.mat'] );
        load( ['E:/研二上/张量/compare/method/', algName, '.mat'] );
%         load( 'E:/研二上/张量/compare/patchsize60.mat' );
        plot(x_plot, y_plot, symbol, 'LineWidth', lineWidth);
        S=trapz(x_plot,y_plot)
        
        % define the name to display
        blgName = blg_pack{j};
        if strcmp(blgName, 'HBMLCM') || strcmp(blgName, 'HBMLCM_Efilter')
            leg{j} = 'HB-MLCM';
        elseif strcmp(blgName, 'DMHB_Efilter') || strcmp(blgName, 'IHBMLCM2')
            leg{j} = 'DMHB';
        else
            leg{j} = blgName;
        end
        
    end
    % set label and the location\font size of legend, then hold off
    xlabel('FPR');   ylabel('TPR');
    xlim([0, 1]);   ylim([0, 1]);
    set(gca, 'box', 'on');
    
    h = legend(leg);
    set(h, 'Location', 'SouthEast', 'FontSize', fontSize);
    hold off
    
    % save the picture
%     if saveControl
%         saveas(gcf, [prefix, folderName, suffix, '.bmp']);
%     end
    
%     saveas(gcf, 'E:/研二上/张量/compare/method/method6.bmp');
    
% end
