function [Img,medianImg] = getMedianImgVGlacier( z, t, tEnd, numFrames, imgScaleFactor )
%This function finds the median background in the Image 'Img' by
%calculating the median of a group of integer 'numFrames' images.

%The images are located in the same z-Slice as Img, and at t+/-numFrames.
h = 1;
imgFormat = '.tif';

if z < 10
    zIdx = strcat('00',int2str(z));
else
    zIdx = strcat('0',int2str(z));
end

if numFrames == 0
    if t< 10
        tIdx = strcat('00',int2str(t));
    else
        tIdx = strcat('0',int2str(t));
    end
    imName = strcat('GlacierIce_t',tIdx,'_z',zIdx,imgFormat);
    Img =normalizeGrayscale_127(imresize(imread(imName),imgScaleFactor));
    medianImg = 127;
else
    
    if t<=numFrames
        for k = 1 :numFrames*2+1
            
            %tIdx = int2str(k);
            %imName = strcat(zIdx,' (',tIdx,')',imgFormat);
            if k < 10
                tIdx = strcat('00',int2str(k));
            else
                tIdx = strcat('0',int2str(k));
            end
            imName = strcat('GlacierIce_t',tIdx,'_z',zIdx,imgFormat);
            sampleImgs(:,:,h) =  imresize(imread(imName),imgScaleFactor);
            if t ==k
                i = h;
            end
            h=h+1;
        end
        
    else if t>tEnd-numFrames
            
            for k = tEnd-(2*numFrames) :tEnd
                
                %             tIdx = int2str(k);
                %             imName = strcat(zIdx,' (',tIdx,')',imgFormat);
                
                if k < 10
                    tIdx = strcat('00',int2str(k));
                else
                    tIdx = strcat('0',int2str(k));
                end
                imName = strcat('GlacierIce_t',tIdx,'_z',zIdx,imgFormat);
                sampleImgs(:,:,h) =  imresize(imread(imName),imgScaleFactor);
                if t ==k
                    i = h;
                end
                h=h+1;
            end
            
            
        else
            for k = t-numFrames :t+numFrames
                
                %tIdx = int2str(k);
                %imName = strcat(zIdx,' (',tIdx,')',imgFormat);
                if k < 10
                    tIdx = strcat('00',int2str(k));
                else
                    tIdx = strcat('0',int2str(k));
                end
                imName = strcat('GlacierIce_t',tIdx,'_z',zIdx,imgFormat);
                sampleImgs(:,:,h) =  imresize(imread(imName),imgScaleFactor);
                if t ==k
                    i = h;
                end
                h=h+1;
            end
        end
    end
    
    sampleImgs_n = normalizeGrayscale_127(sampleImgs);
    Img = sampleImgs_n(:,:,i);
    medianImg=getMedianImage(sampleImgs_n);
end
end