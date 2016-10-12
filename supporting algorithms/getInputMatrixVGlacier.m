function [ X ] = getInputMatrixVGlacier( D )
%This function takes as input a 4D image stack of size
%mxnx3xt, where mxnxt is an image video sequence; therefore mxnx3xt
%represent 3 image sequences; one in the plane, one directly above the plane and one
%directly below the plane

%The purpose of this function is to generate 3D features for every pixel.
%This function can only handle features for 1 z plane at a time. 

dim1 = size(D,1);
dim2 = size(D,2);
dim4 = size(D,4);

greyLevel = zeros(dim1,dim2,dim4);
Gmag = zeros(dim1,dim2,dim4);
stdWindow = zeros(dim1,dim2,dim4);
medianWindow = zeros(dim1,dim2,dim4);

greyLevel_up = zeros(dim1,dim2,dim4);
Gmag_up = zeros(dim1,dim2,dim4);
stdWindow_up = zeros(dim1,dim2,dim4);
medianWindow_up = zeros(dim1,dim2,dim4);

greyLevel_down = zeros(dim1,dim2,dim4);
Gmag_down = zeros(dim1,dim2,dim4);
stdWindow_down = zeros(dim1,dim2,dim4);
medianWindow_down = zeros(dim1,dim2,dim4);

difference_down =zeros(dim1,dim2,dim4);
difference_up =zeros(dim1,dim2,dim4);

std2_z_slice = zeros(dim1,dim2,dim4);

for t = 1:dim4
    
    greyLevel_down(:,:,t) = D(:,:,1,t);
    [Gmag_down(:,:,t), ~]= imgradient(D(:,:,1,t));
    stdWindow_down(:,:,t) = stdfilt(D(:,:,1,t));
    medianWindow_down(:,:,t) = medfilt2(D(:,:,1,t));
    
    greyLevel(:,:,t)=D(:,:,2,t);
    [Gmag(:,:,t), ~]=imgradient(D(:,:,2,t));
    stdWindow(:,:,t)=stdfilt(D(:,:,2,t));
    medianWindow(:,:,t) = medfilt2(D(:,:,2,t));
    
    greyLevel_up(:,:,t)=D(:,:,3,t);
    [Gmag_up(:,:,t), ~]=imgradient(D(:,:,3,t));
    stdWindow_up(:,:,t)=stdfilt(D(:,:,3,t));
    medianWindow_up(:,:,t) = medfilt2(D(:,:,3,t));
    
    difference_down(:,:,t) = abs(int8(D(:,:,1,t))-int8(D(:,:,2,t)));
    difference_up(:,:,t) = abs(int8(D(:,:,3,t))-int8(D(:,:,2,t)));
    
    std2_z_slice(:,:,t)= std2(D(:,:,2,t));
end

pixelVal = abs(double(greyLevel(:))-127);
gradientVal = Gmag(:);
stdVal = stdWindow(:);
medianVal = abs(double(medianWindow(:))-127);

pixelVal_up = abs(double(greyLevel_up(:))-127);
gradientVal_up = Gmag_up(:);
stdVal_up = stdWindow_up(:);
medianVal_up =  abs(double(medianWindow_up(:))-127);

pixelVal_down = abs(double(greyLevel_down(:))-127);
gradientVal_down = Gmag_down(:);
stdVal_down = stdWindow_down(:);
medianVal_down =  abs(double(medianWindow_down(:))-127);

diffVal_down=double(difference_down(:));
diffVal_up=double(difference_up(:));

ZStdVal = std2_z_slice(:);

X = [pixelVal gradientVal stdVal medianVal ... 
    pixelVal_up gradientVal_up stdVal_up medianVal_up ...
    pixelVal_down gradientVal_down stdVal_down medianVal_down ...
    diffVal_down diffVal_up ZStdVal];

end

