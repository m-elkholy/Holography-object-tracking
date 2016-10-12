%Test code - Execution -  finding the tracks and plotting them.
% this code will plot the tracks for us, once we are satisfied with our selection of parameters
%-------------------------------------------------------------
clearvars -except b points points2
tic
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
t_tracking_end = 91;
%--------------------------------------------------------------
%Enter image parameters below
%--------------------------------------------------------------
imgScaleFactor = 0.5;
numFrames = 0;
contrastFactor = 1;
pCutoff = 0.07;
minCluster = 40;
lower_threshold= 20;
%-------------------------------------------------------------
%Enter tracking parameters below
%------------------------------------------------------------
max_linking_distance = 15;
max_gap_closing = 3;

z_separation = 2.4;
%-------------------------------------------------------------

zSize = abs(z_tracking_end - z_tracking_start + 1);

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
tSize = abs(t_tracking_end - t_tracking_start + 1);

for t = t_tracking_start:t_tracking_end;
    
    %The loop below creats a 3D matrix at frame t
    
    for z = z_tracking_start-~z_bottom:z_tracking_end+~z_top;
        [imgA,imgB] = getMedianImgVGlacier(z,t,t_dataset_end,numFrames, imgScaleFactor);
        %D(:,:,z) = uint8((int16(imgA) - int16(imgB)).*contrastFactor+127);
        noBackGround= (int16(imgA) - int16(imgB)).*contrastFactor;
        zeroVal = contrastFactor.*lower_threshold;
        uniformBackGround = abs(noBackGround);
        noBackGround(uniformBackGround<zeroVal) = 0;
        D(:,:,z) = uint8(noBackGround+127);
       
    end
    %-------------------------------------------------
    dim1 = size(D,1);
    dim2 = size(D,2);
    dim3 = z_tracking_end;
    dim4 = size(D,4);
    
    y = zeros(dim1*dim2*(z_tracking_start-1),1);
    
    for z = z_tracking_start:z_tracking_end;
        
        if z==z_dataset_start
            input_slice(:,:,1) = D(:,:,z);
        else
            input_slice(:,:,1) = D(:,:,z-1);
        end
        
        input_slice(:,:,2) = D(:,:,z);
        
        if z==z_dataset_end
            input_slice(:,:,3) = D(:,:,z);
        else
            input_slice(:,:,3) = D(:,:,z+1);
        end
        X = getInputMatrixVGlacier(input_slice);
        y = [y; glmval(b,X,'logit')];
        
    end
    D_C = classifyVGlacier(y, pCutoff, minCluster, dim1,dim2,dim3,dim4);

    points{t} = findCentroids(D_C);
    points2{t} = points{t}*[360/dim1 0 0;0 360/dim2 0;0 0 z_separation];
    percent_complete=(t+1-t_tracking_start)*100/tSize
end
%----------------------------------------------------------
[ tracks adjacency_tracks] = simpletracker(points2, ...
    'MaxLinkingDistance', max_linking_distance, ...
    'MaxGapClosing', max_gap_closing);
%The function plotTracks, takes as input adjacency tracks and points to
%to plot the results in a 3D line graph.

[x, y, z]=plotTracksAndVelocity(adjacency_tracks,points2);
daspect([1 1 1])
toc