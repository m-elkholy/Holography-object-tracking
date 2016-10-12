function [ newCoords ] = getBugMoreBugCoords( DtrainC,z,t  )
%This function takes as imput a segmented image 'Dtrain', at z slice 'z', 
%and time step 't. It then returns the all the coordinates of one cluster
%within the image and returns the matrix 'newCoords' of size Nx3 where N 
%is the total number of new points. 
%-------------------------------------------------------------------------
newDtrainC = addEdges(DtrainC,0.03);
dim1 = size(newDtrainC,1);
dim2 = size(newDtrainC,2);
imshow(newDtrainC(:,:,z,t))
[x, y] = getpts;
cc=bwconncomp(newDtrainC(:,:,z,t));
pil = cc.PixelIdxList;
point = dim2.*(int32(x)-1)+int32(y);
index = 0;
for i = 1:size(pil,2)
    if size(find(pil{i}==point),1)>0
        index = i;
    end
end
cluster = pil{index};
newCoords = zeros(0,2);
for j = 1:size(cluster,1)
    num = int32(cluster(j));
    y = uint16(rem(num,dim2));
    x = uint16(idivide(num,dim1,'floor'));
    newCoords = [newCoords;x y z];
end
xplot = newCoords(:,1);
yplot = newCoords(:,2);
imshow(newDtrainC(:,:,z,t))
hold on
scatter(xplot,yplot,1,'.')
end
% %-------------------------------------------------