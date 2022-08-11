% The .mat file contains reference traces that we use to resolve the linear combination, so it is required.
load('6G_70.mat');

% Since this is an example file, we hardcode the dimensions based on the size of the example image.

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


parfor ii = 1:imageWidth
    for jj = 1:imageHeight
        if stack(ii,jj,1) < 10
            composition_image1(ii,jj) = 0;
            composition_image2(ii,jj) = 0;
            composition_image3(ii,jj) = 0;
            composition_image4(ii,jj) = 0;
            composition_image5(ii,jj) = 0;
            composition_image6(ii,jj) = 0;
        else
            [predicted_vals1, fval1] = fminsearch(@(coeffs) signalseparation6g(rsGFE,rsE2E,rsFL,SK62A,Drp,YFP,squeeze(stack(ii,jj,:)),coeffs),[1 1 1 1 1 ]/5,optimset('MaxFunEvals', 10000) );
            [predicted_vals2, fval2] = fminsearch(@(coeffs) signalseparation6g(rsGFE,rsE2E,rsFL,SK62A,Drp,YFP,squeeze(stack(ii,jj,:)),coeffs),[1 0 1 0 1 ]/5,optimset('MaxFunEvals', 10000) );
            [predicted_vals3, fval3] = fminsearch(@(coeffs) signalseparation6g(rsGFE,rsE2E,rsFL,SK62A,Drp,YFP,squeeze(stack(ii,jj,:)),coeffs),[0 1 0 1 0 ]/5,optimset('MaxFunEvals', 10000) );
            predicted_vals_matrix = [predicted_vals1; predicted_vals2; predicted_vals3];
            [~, idx] = min([fval1,fval2,fval3]);
            predicted_vals = predicted_vals_matrix(idx,:);
	 
            composition_image1(ii,jj) = predicted_vals(1);
            composition_image2(ii,jj) = predicted_vals(2);
            composition_image3(ii,jj) = predicted_vals(3);
            composition_image4(ii,jj) = predicted_vals(4);
            composition_image5(ii,jj) = predicted_vals(5);
	    % The last channel is determined by subtracting the sum of all other 
	    % channels from 1, so that all channels add up to 1.
            composition_image6(ii,jj) = 1-predicted_vals(1)-predicted_vals(2)-predicted_vals(3)-predicted_vals(4)-predicted_vals(5);
        end
    end
disp(['Done with ' num2str(ii) ' of ' num2str(imageWidth)]);      
end


% Clip the values so that they are all between 0 and 1 inclusive.
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

% Multiply the values with the first frame in the stack
% to compute intensities for each channel.
% Because we strictly defined the values to add up to 1,
% these channels also add up to exactly the original video.
rsGFE_ch = composition_image1.*stack(:,:,1); % rsGreenF-E 
rsE2E_ch = composition_image2.*stack(:,:,1); % rsEGFP2-E
rsFL_ch = composition_image3.*stack(:,:,1);  % rsFastLime
sk62A_ch = composition_image4.*stack(:,:,1); % Skylan62A
Drp_ch = composition_image5.*stack(:,:,1);   % Dronpa
YFP_ch = composition_image6.*stack(:,:,1);   % YFP

% Save resulting new images in the working directory.
imwrite(uint16(rsGFE_ch), 'rsGFE_ch-code1.tif'); % rsGreenF-E
imwrite(uint16(rsE2E_ch), 'rsE2E_ch-code1.tif'); % rsEGFP2-E
imwrite(uint16(rsFL_ch), 'rsFL_ch-code1.tif');   % rsFastLime
imwrite(uint16(sk62A_ch), 'sk62A_ch-code1.tif'); % Skylan62A
imwrite(uint16(Drp_ch), 'Drp_ch-code1.tif');     % Dronpa
imwrite(uint16(YFP_ch), 'YFP_ch-code1.tif');     % YFP

