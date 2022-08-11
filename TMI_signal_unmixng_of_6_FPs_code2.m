load('6G_70.mat')

imageWidth = 250;
imageHeight = 250;
imageFrames = 70;
stack = zeros(imageWidth,imageHeight,imageFrames);

for ii = 1:imageFrames
    currentImage = imread('6G_example_downsampled.tif', ii);
    stack(:,:,ii) = currentImage;
end

composition_image1 = zeros(imageWidth,imageHeight);
composition_image2 = zeros(imageWidth,imageHeight);
composition_image3 = zeros(imageWidth,imageHeight);
composition_image4 = zeros(imageWidth,imageHeight);
composition_image5 = zeros(imageWidth,imageHeight);
composition_image6 = zeros(imageWidth,imageHeight);
status_indicator   = zeros(imageWidth,imageHeight) - 10;

options = optimoptions('fmincon', 'Display', 'none');

parfor ii = 1:imageWidth
    for jj = 1:imageHeight
        if stack(ii,jj,1) < 10
	    % ignore background pixels for faster computation
            composition_image1(ii,jj) = 0;
            composition_image2(ii,jj) = 0;
            composition_image3(ii,jj) = 0;
            composition_image4(ii,jj) = 0;
            composition_image5(ii,jj) = 0;
            composition_image6(ii,jj) = 0;
        else
            [predicted_vals, ~, exitflag, ~] = fmincon(@(coeffs) signalseparation6G_fmincon(rsGFE, rsE2E, rsFL, SK62A,Drp,YFP, squeeze(stack(ii,jj,:)), coeffs), ... % obj. fun.
                                        [0 0 0 0 0 0], ... % initial guess
                                        [], [], ... % inequalities (N/A)
                                        [1,1,1,1,1,1], ... % equality constraint left hand side
                                        1, ... % equality constraint right hand side -- this ensures they add up to 1
                                        [0,0,0,0,0,0], ... % lower bounds
                                        [1,1,1,1,1,1], ... % upper bounds
                                        [], ... % nonlinear options (N/A)
                                        options); % see options variable above --  currently only disables print output
              composition_image1(ii,jj) = predicted_vals(1);
              composition_image2(ii,jj) = predicted_vals(2);
              composition_image3(ii,jj) = predicted_vals(3);
              composition_image4(ii,jj) = predicted_vals(4);
              composition_image5(ii,jj) = predicted_vals(5);
              composition_image6(ii,jj) = predicted_vals(6);
              status_indicator(ii, jj)  = exitflag; % we need this value to know if the optimization succeeded
        end
    end
disp(['Done with ' num2str(ii) ' of ' num2str(imageHeight)]);      
end

% Clip the values so that they are all between 0 and 1 inclusive.
% This is technically not necessary for this approach, but we do it anyway
% just to be safe.
composition_image1(composition_image1 <0) = 0;
composition_image1(composition_image1 >1) = 1;
composition_image2(composition_image2 <0) = 0;
composition_image2(composition_image2 >1) = 1;
composition_image3(composition_image3 <0) = 0;
composition_image3(composition_image3 >1) = 1;
composition_image4(composition_image4 <0) = 0;
composition_image4(composition_image4 >1) = 1;
composition_image5(composition_image5 <0) = 0;
composition_image5(composition_image5 >1) = 1;
composition_image6(composition_image6 <0) = 0;
composition_image6(composition_image6 >1) = 1;

% for ii = 1:imageFrames
%     currentImage = imread('6G_YFP4b.tif', ii);
%     stack(:,:,ii) = currentImage;
% end

% Multiply the values with the first frame in the stack
% to compute intensities for each channel.
% Because we strictly defined the values to add up to 1 using
% the MATLAB optimization options and specifying an equality constraint,
% these channels also add up to exactly the original video.
rsGFE_ch = composition_image1.*stack(:,:,1); % rsGreenF-E 
rsE2E_ch = composition_image2.*stack(:,:,1); % rsEGFP2-E
rsFL_ch = composition_image3.*stack(:,:,1);  % rsFastLime
sk62A_ch = composition_image4.*stack(:,:,1); % Skylan62A
Drp_ch = composition_image5.*stack(:,:,1);   % Dronpa
YFP_ch = composition_image6.*stack(:,:,1);   % YFP

% Save resulting new images in the working directory.
imwrite(uint16(rsGFE_ch), 'rsGFE_ch-code2.tif'); % rsGreenF-E
imwrite(uint16(rsE2E_ch), 'rsE2E_ch-code2.tif'); % rsEGFP2-E
imwrite(uint16(rsFL_ch), 'rsFL_ch-code2.tif');   % rsFastLime
imwrite(uint16(sk62A_ch), 'sk62A_ch-code2.tif'); % Skylan62A
imwrite(uint16(Drp_ch), 'Drp_ch-code2.tif');     % Dronpa
imwrite(uint16(YFP_ch), 'YFP_ch-code2.tif');     % YFP

