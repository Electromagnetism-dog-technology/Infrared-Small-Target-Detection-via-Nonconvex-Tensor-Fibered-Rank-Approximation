% This function aims to generate a ROC curve to evaluate the performance of
% the algorithm and save the data of ROC.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Paremeter Explanation
% Input: foldername -> name of the folder you test, MUST
%        algname -> name of the algorthm you test, MUST
%        xMax -> the max value of the x axis, MUST
%        r_in -> the target radius, CHOOSE
%        suffix_in -> the suffix you want, CHOOSE, type must be '_string'
% Output: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate details
% About TPR and FPR:
%     I suppose that 
%         FPR = ( sum of pixel values not in the target area  )
%             / ( target numbers, Here suppose the number of files )
%         TPR = ( number of true targets which I detceted more than one piexl )
%             / ( target numbers )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you have any questions, please contact:
% Author: Tianfang Zhang
% Email: sparkcarleton@gmail.com
% Copyright:  University of Electronic Science and Technology of China
% Date: 2018/10/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%* License: Our code is only available for non-commercial research use.

function func_Calculate_ROC(foldername, algname, xMax, r_in, suffix_in)

%==========================================================================
% Change your test folder name and algorithm name HERE!
% Sample
% foldername = 'Video2Frames6';
% algname = 'HBMLCM';
% xMax = 1000;
% % Radius of mask
% Frames1, anno r = 2;  Frames2, anno r = 3; Video2Frames1, anno r = 3;
% r = 3;
%==========================================================================
if nargin == 3
    r = 3;
    suffix = '';
elseif nargin == 4
    r = r_in;
    suffix = '';
elseif nargin == 5
    r = r_in;
    suffix = suffix_in;
else
    error('Input parameters ERROR!');
end

testpath = strcat('E:\研二下\张量\RTRC_TRPCA\results\', algname, '\', foldername);

% % Add path and remove them in the end
addpath( testpath );
addpath( 'E:\研二上\张量\数据集\anno' );
% addpath( '.\algorithm' );

% % Attention : The first one is pixel column, the second is pixel row!!!
[y_target, x_target] = textread( strcat(foldername, '.txt'), '%f %f' );
len = size(x_target, 1);

% % load a mat to get len and construct PreImg
rstImg = double(imread('0001.jpg'));
[m, n] = size(rstImg);
PreImg = zeros(m, n, len);

for i = 1:len
    name = strcat( num2str(i, '%04d'), '.jpg' );
    rstImg = double(imread( name ));
    PreImg(:, :, i) = rstImg;
end

% % Loaded mat is normalized from 0 to 1, so this step can skip
% PreImg = mat2gray(PreImg);

FPR_axis = zeros(1, 100);
TPR_axis = zeros(1, 100);

% % Pixel values range from 0 to 1, so the threshold is
for k = 1:100
    
    num_true = 0;
    num_false = 0;
    num_useless = 0;

    for j = 1:len
        % % Get an image, and obtain a logical image
        preImg = PreImg(:, :, j);
        if sum(preImg(:)) == 0
            num_useless = num_useless + 1;
            continue;
        else
            preImg = preImg ./ max(preImg(:));
        end
        preImg = ( preImg >= k*0.01 );  
        
        % % Construct a mask to count the number of True Target 
        % and sum of other pixel values
        mask = zeros(m, n);
        x = round( x_target(j) ); y = round( y_target(j) );
        
        if x <= r || y <= r || x >= m-r || y >= n-r
            num_useless = num_useless + 1;
            continue;
        end
        
        mask( x-r : x+r, y-r : y+r ) = 1;
        mask_T = logical(mask); 
        mask_F = ~mask_T;
        
        num_true = num_true + double( sum(sum( preImg .* mask_T )) >= 1 );
        num_false = num_false + sum(sum( preImg .* mask_F ));
        
    end
    
    FPR_axis(k) = num_false / (len - num_useless); % X axis
    TPR_axis(k) = num_true / (len - num_useless);  % Y axis
    
end

%==========================================================================
% % FPR_axis may have to many big values and affect observation
% so limit the max of FPR_axis to xMax
% This is the first edtion. Just for show.

% table = [TPR_axis;FPR_axis];
% part = table(2, :) < xMax;
% part1 = table(:, part);
% part2 =  [ [1;xMax], part1, [0;0]];
% part1 = [part1, [0; 0], [0; 0]];
% x_plot = part2(2, :);   y_plot = part2(1, :);
% auc = (part2(2, :)-part1(2, :)) * (part2(1, :)+part1(1, :))' / 2;

% % This the second edtion, you can choose which to use, this is for you to
% compare with other algorithms. And don't forget to comment another code!

table = [TPR_axis;FPR_axis];
part = table(2, :) < xMax;
part1 = table(:, part);

pos1 = part1(:, 1);
x1 = pos1(2);   y1 = pos1(1);

mark = find( table(2, :) == x1 );
if mark ~= 1
    pos2 = table(:,  mark - 1);
    x2 = pos2(2);   y2 = pos2(1);

    if ~( x1 <= xMax && x2 >= xMax )
        error('postion of x1 x2 error!');
    end
    yMax = (y2 - y1) * (xMax - x1) / (x2 - x1) + y1;
else
    yMax = 1;
end

part2 =  [ [yMax;xMax], part1, [0;0]];
part1 = [part1, [0; 0], [0; 0]];
x_plot = part2(2, :);   y_plot = part2(1, :);
auc = (part2(2, :)-part1(2, :)) * (part2(1, :)+part1(1, :))' / 2;

%==========================================================================

% % plot on figure, in function this part can skip
% figure
% ROC = plot(x_plot, y_plot, '.-');
% title( [algname, ' on ', foldername] );
% leg = legend( [algname, ' auc = ', num2str(auc, '%.04f')] );
% set(leg, 'Location', 'SouthEast')
% xlabel( 'FPR' );    ylabel( 'TPR' );
% axis([0, xMax, 0, 1]);

% Save data or picture
savename = strcat( 'E:\研二下\张量\RTRC_TRPCA\results\ROC\', algname, '_', foldername, suffix, '.mat' );
save( savename, 'x_plot', 'y_plot', 'auc');
% plot(FPR_axis, TPR_axis);
% saveas(ROC, [savename, '.png']);

% display the status
disp(['Max auc=', num2str(xMax), '  AUC=', num2str(auc,'%.4f')]);

rmpath( testpath );
rmpath( '.\anno' );
% rmpath( '.\algorithm' );