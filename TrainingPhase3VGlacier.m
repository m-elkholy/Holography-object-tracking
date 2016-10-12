% %Training code - phase 3 -  Adding more bugCoords and updating the b
% value.
% After new bugCoords have been added, repeat training Phase 2,
% followed by training phase 3, until satisfaction. 

clearvars -except z_tracking_start z_tracking_end  imgScaleFactor b new_b z contrastFactor Dtrain DtrainC yTrain Xtrain bugCoords
%-------------------------------------------------------------------------
% 
%-------------------------------------------------------------------------
%------------------------------------------------------------------------
%The parameters zVal and tVal represent the z-slice and timestep values
%respectively of the image we would like to obtain more training pixels
%from. 
%-------------------------------------------------------------------------
zVal = 3;
tVal = 1;
%End of Variable declaration
%------------------------------------------------------------------------
[ newCoords ] = getBugMoreBugCoords( DtrainC,zVal,tVal  );

prompt = 'Would you like to add these points to bugCoords? Y/N: ';
str = input(prompt,'s');

if str == 'Y'
    bugCoords = [bugCoords; newCoords];
    
    
    dim1 = size(Dtrain,1);
    dim2 = size(Dtrain,2);
    dim3 = z_tracking_end;
    dim4 = size(Dtrain,4);
    
    yCoords = zeros(dim1,dim2,dim3);
    
    for i = 1:size(bugCoords,1)
        xval = bugCoords(i,1);
        yval = bugCoords(i,2);
        zval = bugCoords(i,3);
        
        yCoords(yval,xval,zval) = 1;
    end
    
    yTrain = yCoords(:);
    status = 'Calculating new parameter values...'
    tic
    [new_b,dev] = glmfit(Xtrain,yTrain,'binomial','link','logit');
    toc
    
    percentage_change = (b-new_b).*100./new_b
    
    prompt = 'Would you like to update your b value Y/N: ';
    str = input(prompt,'s');
    
    if str == 'Y'
        b = new_b;
    end
end
