maskidx = sort(unique(mask(:,:,1)));
maskidx(1) = [];
celln = length(maskidx);
FPn=4;

tmp = sort(rand(FPn-1,celln),1);
tmp = padarray(tmp,1,0,'pre');
tmp = padarray(tmp,1,1,'post');
FP_proportion = diff(tmp);

fluor = zeros(size(T,1), celln);
% for nn=1:celln
%     fluor(:,nn) = FP_proportion(1,nn).*GaussTrace(rsGreenFast_E,SD_rsGreenFast_E)...
%         + FP_proportion(2,nn).*GaussTrace(rsEGFP2_E,SD_rsEGFP2_E)...
%         + FP_proportion(3,nn).*GaussTrace(rsFastLime,SD_rsFastLime)...
%         + FP_proportion(4,nn).*GaussTrace(Skylan_62A,SD_Skylan_62A)...
%         + FP_proportion(5,nn).*GaussTrace(Dronpa,SD_Dronpa)...
%         + FP_proportion(6,nn).*GaussTrace(YFP,SD_YFP);
%     disp(nn);
% end
% for nn=1:celln
%     fluor(:,nn) = FP_proportion(1,nn).*GaussTrace(rsGreenFast_E,0)...
%         + FP_proportion(2,nn).*GaussTrace(rsEGFP2_E,0)...
%         + FP_proportion(3,nn).*GaussTrace(rsFastLime,0)...
%         + FP_proportion(4,nn).*GaussTrace(Skylan_62A,0)...
%         + FP_proportion(5,nn).*GaussTrace(Dronpa,0)...
%         + FP_proportion(6,nn).*GaussTrace(YFP,0);
%     disp(nn);
% end
for nn=1:celln
    fluor(:,nn) = FP_proportion(1,nn).*GaussTrace(rsT,0)...
        + FP_proportion(2,nn).*GaussTrace(rsFR1,0)...
        + FP_proportion(3,nn).*GaussTrace(rS,0)...
        + FP_proportion(4,nn).*GaussTrace(mC,0)...
      
    disp(nn);
end

figure;plot(fluor);
%%
video = repmat(img,[1,1,size(T,1)]);
for nn=1:length(maskidx)
    tmp = repmat(mask==maskidx(nn),[1,1,size(T,1)]);
    video(tmp) = reshape(video(tmp),[],size(T,1)).*reshape(fluor(:,nn),1,[]);
    disp(nn);
end
video(repmat(mask==0,[1,1,size(T,1)]))=0;

%%
video = video/65535*3e4*4;
video = imnoise(single(video)*1e-6,'Poisson')*1e6;
video = uint16(video/3e4/4*65535);
imstackwrite(video,'R4.tif');

%%
GT = repmat(img,[1,1,FPn]);
GT(repmat(mask==0,[1,1,FPn]))=0;
for nn=1:length(maskidx)
    tmp = repmat(mask==maskidx(nn),[1,1,FPn]);
    GT(tmp) = reshape(GT(tmp),[],FPn).*reshape(FP_proportion(:,nn),1,[]);
    disp(nn);
end
imstackwrite(uint16(GT),'R4_GT.tif');

%%
%%

function S1 = GaussTrace(m, v)
    S1 = m + randn(size(m)).*v;
end

%%
function imstack=imstackread(filename)

info=imfinfo(filename);
imstack=zeros(info(1).Height,info(1).Width,size(info,1));

if info(1).BitDepth==8
    imstack=uint8(imstack);
else
    imstack=uint16(imstack);
end

for ii=1:size(info)
    imstack(:,:,ii)=imread(filename,'Info',info(ii));
end
disp(['load: ' filename ': finished']);
end

%%
function imstackread(imstack, filename)

imwrite(imstack(:,:,1),filename);
for ii=2:size(imstack,3)
%     ii
    imwrite(imstack(:,:,ii),filename,'WriteMode','append');
end

end