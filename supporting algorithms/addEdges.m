function [ Dout ] = addEdges( D,cropSize )
dim1 = size(D,1);
dim2 = size(D,2);
dim3 = size(D,3);
dim4 = size(D,4);

o_size1 = int16(dim1./(1-(2.*cropSize)));
o_size2 = int16(dim2./(1-(2.*cropSize)));
i = int16(o_size1.*cropSize);
j = int16(o_size2.*cropSize);

Dout = zeros(o_size1,o_size2,dim3,dim4);
Dout(i:o_size1-i,j:o_size2-j,:,:) = D(:,:,:,:);
end