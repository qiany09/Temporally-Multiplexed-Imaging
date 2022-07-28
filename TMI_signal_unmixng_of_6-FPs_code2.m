load('6G_70.mat')
stack = zeros(528,528,70);

for ii = 1:70
    currentImage = imread('6G_YFP4.tif', ii);
    stack(:,:,ii) = currentImage;
end

composition_image1 = zeros(528,528);
composition_image2 = zeros(528,528);
composition_image3 = zeros(528,528);
composition_image4 = zeros(528,528);
composition_image5 = zeros(528,528);
composition_image6 = zeros(528,528);
status_indicator   = zeros(528,528) - 10;


options = optimoptions('fmincon', 'Display', 'none');

parfor ii = 1:528
    for jj = 1:528
        if stack(ii,jj,1) < 10
            composition_image1(ii,jj) = 0;
            composition_image2(ii,jj) = 0;
            composition_image3(ii,jj) = 0;
            composition_image4(ii,jj) = 0;
            composition_image5(ii,jj) = 0;
            composition_image6(ii,jj) = 0;
        
        else
            %predicted_vals = fminsearch(@(coeffs) signalseparation4R(rsT,rsFR1,rS,mC,squeeze(stack(ii,jj,:)),coeffs),[1 1 1]/4,optimset('MaxFunEvals', 10000) );
%             [predicted_vals1, fval1] = fminsearch(@(coeffs) signalseparation4R(rsT,rsFR1,rS,mC,squeeze(stack(ii,jj,:)),coeffs),[0 0 1],optimset('MaxFunEvals', 10000) );
%             [predicted_vals2, fval2] = fminsearch(@(coeffs) signalseparation4R(rsT,rsFR1,rS,mC,squeeze(stack(ii,jj,:)),coeffs),[0 1 0],optimset('MaxFunEvals', 10000) );
%             [predicted_vals3, fval3] = fminsearch(@(coeffs) signalseparation4R(rsT,rsFR1,rS,mC,squeeze(stack(ii,jj,:)),coeffs),[1 0 0],optimset('MaxFunEvals', 10000) );
%             predicted_vals_matrix = [predicted_vals1; predicted_vals2; predicted_vals3];
%             [~, idx] = min([fval1,fval2,fval3]);
%             predicted_vals = predicted_vals_matrix(idx,:);
%             composition_image1(ii,jj) = predicted_vals(1);
%             composition_image2(ii,jj) = predicted_vals(2);
%             composition_image3(ii,jj) = predicted_vals(3);
%             composition_image4(ii,jj) = 1 - predicted_vals(1) - predicted_vals(2) - predicted_vals(3);
              
              [predicted_vals, ~, exitflag, ~] = fmincon(@(coeffs) signalseparation6G_fmincon(rsGFE, rsE2E, rsFL, SK62A,Drp,YFP, squeeze(stack(ii,jj,:)), coeffs), ... % obj. fun.
                                        [0 0 0 0 0 0], ... % initial guess
                                        [], [], ... % inequalities (N/A)
                                        [1,1,1,1,1,1], ... % equality constraint left hand side
                                        1, ... % equality constraint right hand side
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
              status_indicator(ii, jj)  = exitflag;
              
        end
      
    end
disp(['Done with ' num2str(ii) ' of 1024']);      
end

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

for ii = 1:70
    currentImage = imread('6G_YFP4b.tif', ii);
    stack(:,:,ii) = currentImage;
end


rsGFE_ch = composition_image1.*stack(:,:,1);
rsE2E_ch = composition_image2.*stack(:,:,1);
rsFL_ch = composition_image3.*stack(:,:,1);
sk62A_ch = composition_image4.*stack(:,:,1);
Drp_ch = composition_image5.*stack(:,:,1);
YFP_ch = composition_image6.*stack(:,:,1);

imwrite(uint16(rsGFE_ch), 'rsGFE_ch.tif');
imwrite(uint16(rsE2E_ch), 'rsE2E_ch.tif');
imwrite(uint16(rsFL_ch), 'rsFL_ch.tif');
imwrite(uint16(sk62A_ch), 'sk62A_ch.tif');
imwrite(uint16(Drp_ch), 'Drp_ch.tif');
imwrite(uint16(YFP_ch), 'YFP_ch.tif');
