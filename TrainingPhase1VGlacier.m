% %Training code - phase 1 - bug identification
% % this code will train our classifyer by presenting examples for the user.
%-------------------------------------------------------------------------
% First we must define our training data set.
%-------------------------------------------------------------------------
%-------------------------------------------------------------
clearvars -except b points points2 bugCoords Dtrain

%-------------------------------------------------------------
%Variable Declarations - things to consider:
%Now we are dealing with 3D data, therefore the variables must take that
%into account.
%----------------------------------------------------------------
%Enter Dataset size below
%----------------------------------------------------------------
z_dataset_start = 1;
z_dataset_end = 33;
t_dataset_start = 1;
t_dataset_end = 91;
%---------------------------------------------------------------
%Enter a subsection of the dataset to track below
%--------------------------------------------------------------
z_tracking_start = 1;
z_tracking_end = 33;
t_tracking_start = 1;
t_tracking_end = 1;
%--------------------------------------------------------------
%Enter image parameters below
%--------------------------------------------------------------
imgScaleFactor = 0.5;
numFrames = 0;
contrastFactor = 1;
pCutoff = 0.0002;
minCluster = 12;
lower_threshold= 20;
%-------------------------------------------------------------
%Enter tracking parameters below
%------------------------------------------------------------
max_linking_distance = 25;
max_gap_closing = 2;


%-------------------------------------------------------------
%------------------------------------------------------------------------
%tEnd is the highest time frame available in all zslices of the dataSet
%-----------------------------------------------------------------------
%Variable contrastFactor enhances the contrast of the image after median
%subtraction to make the features more distinguishable from the background.
%Default value is contrastFactor = 3
%------------------------------------------------------------------------
%imgScaleFactor, contrastFactor, tEnd and numFrames must be constant throughout training and
%testing
%------------------------------------------------------------------------
%------------------------------------------------------------------------
%Variable sections is an intger which splits the image into sections^2
%pieces to make identification more accurate. Default value is sections =
%2, which would result in splitting the image into 4 quadrants
%------------------------------------------------------------------------
sections = 1;
%----------------------------------------------------------------------
if z_tracking_start>z_dataset_start
    z_bottom = 0;
else
    z_bottom = 1;
end

if z_tracking_end<z_dataset_end
    z_top = 0;
else
    z_top = 1;
end
%-------------------------------------------------------------------------
%End of variable declaration
%-----------------------------------------------------------------------
for t = t_tracking_start:t_tracking_end
    for z = z_tracking_start-~z_bottom:z_tracking_end+~z_top;
        [imgA,imgB] = getMedianImgVGlacier(z,t,t_dataset_end,numFrames, imgScaleFactor);
        %Dtrain(:,:,z) = uint8((int16(imgA) - int16(imgB)).*contrastFactor+127);
        
        noBackGround= (int16(imgA) - int16(imgB)).*contrastFactor;
        zeroVal = contrastFactor.*lower_threshold;
        uniformBackGround = abs(noBackGround);
        noBackGround(uniformBackGround<zeroVal) = 0;
        Dtrain(:,:,z) = uint8(noBackGround+127);
        creating_training_dataSet_percent_completed = z*100/(z_tracking_end-z_tracking_start+1)
    end
end
%-----------------------------------------------------------------------
    implay(permute(Dtrain,[1 2 4 3]))
    % %-------------------------------------------------
    
    
    %bugCoords = getBugCoords2(Dtrain,sections);
    
    dim1 = size(Dtrain,1);
    dim2 = size(Dtrain,2);
    dim3 = z_tracking_end;
    dim4 = size(Dtrain,4);
    
    Xtrain = zeros(dim1*dim2*(z_tracking_start-1),12);
    
     for z = z_tracking_start:z_tracking_end;
        
        if z==z_dataset_start
            input_slice(:,:,1) = Dtrain(:,:,z);
        else
            input_slice(:,:,1) = Dtrain(:,:,z-1);
        end
        
        input_slice(:,:,2) = Dtrain(:,:,z);
        
        if z==z_dataset_end
            input_slice(:,:,3) = Dtrain(:,:,z);
        else
            input_slice(:,:,3) = Dtrain(:,:,z+1);
        end
        Xtrain = [Xtrain; getInputMatrixVGlacier(input_slice)];
        getting_Xtrain_percent_complete = z *100/z_tracking_end
     end
        
     
    yCoords = zeros(dim1,dim2,dim3);
    
    for i = 1:size(bugCoords,1)
        xval = bugCoords(i,1);
        yval = bugCoords(i,2);
        zval = bugCoords(i,3);
        
        yCoords(yval,xval,zval) = 1;
    end
    
    %The code below generates the input X matrix of the features in the
    %training data set Dtrain. X = [pixelvalue 1stDerivative 2ndDerivative]. X
    %is of size N x 3 where N = the total number of pixels in the training set
    %Dtrain = dim1*dim2*dim3 = N
    
    %We will now create the yTrain vetor from yCoords Matrix
    yTrain = yCoords(:);
    
    %The code below finds the vector b: the weights of the parameters of
    %logistic regression using Xtrain and Ytrain.
    %The vector yTrainFit is generated using Xtrain and the parameter values
    %found in vector b. The difference between yTrain and yTrainFit is the
    %training error.
    tic
    %[b,dev] = glmfit(Xtrain,yTrain,'binomial','link','logit');
    toc