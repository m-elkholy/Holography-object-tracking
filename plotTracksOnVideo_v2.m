% %function plotTracksOnVideo(tracks, points, numFrames,imgScaleFactor,contrastFactor)
clearvars imStack x0 y0 z0 u v w x1 y1 z1
tStart = 1;
vidSize = 91;
minTrackLength = 1;
tEnd = 91;
z = 15;

allPoints = points;
j = 1;

for i = 1:size(tracks,1)
    if (size(tracks{i},1) - sum(isnan(tracks{i})))>minTrackLength
        if all(isnan(tracks{i}(tStart:tStart+vidSize-1)))
        else
            relTracks{j} = tracks{i};
            j = j+1;
        end
    end
end

for t = tStart:tStart+vidSize-1
%     zIdx = int2str(z);
%     tIdx = int2str(t);
%     imName = strcat(zIdx,' (',tIdx,')','.tif');
%     I(:,:,t) =  imresize(imread(imName),imgScaleFactor);
    
     [imgA,imgB] = getMedianImgVGlacier(z,t,tEnd,numFrames, imgScaleFactor);
     %I(:,:,t) = uint8((int16(imgA) - int16(imgB)).*contrastFactor+127);
     %------------------------------------------------------------------
%      noBackGround= (int16(imgA) - int16(imgB)).*contrastFactor;
%      zeroVal = contrastFactor.*lower_threshold;
%      uniformBackGround = abs(noBackGround);
%      noBackGround(uniformBackGround<zeroVal) = 0;
%      I(:,:,t) = uint8(noBackGround+127);
%----------------------------------------------------------------------
    I(:,:,t) = imgA;
    acquiring_images_percent_completed = (t-tStart)*100/vidSize
end

for i = 1:size(relTracks,2)
    
    for t = tStart+1:tStart+vidSize-1
        if isnan(relTracks{i}(t)) || isnan(relTracks{i}(t-1))
            x0(t,i) = NaN;
            y0(t,i) = NaN;
            z0(t,i) = NaN;
            u(t,i) = NaN;
            v(t,i) = NaN;
            w(t,i) = NaN;
        else
            x0(t,i) = allPoints{t-1}(relTracks{i}(t-1),1);
            y0(t,i) = allPoints{t-1}(relTracks{i}(t-1),2);
            z0(t,i) = allPoints{t-1}(relTracks{i}(t-1),3);
            x1(t,i) = allPoints{t}(relTracks{i}(t),1);
            y1(t,i) = allPoints{t}(relTracks{i}(t),2);
            z1(t,i) = allPoints{t}(relTracks{i}(t),3);
            u(t,i) = x1(t,i)-x0(t,i);
            v(t,i) = y1(t,i)-y0(t,i);
            w(t,i) = z1(t,i)-z0(t,i);
            
            
        end
    end
end
trailSize = 15;

for t = tStart+1:tStart+vidSize-1
    imshow(cropEdges(I(:,:,t),0.03))
    hold on
    %for k = 1:(t-tStart)
        
        for i=1:size(relTracks,2)-2
            if (t-tStart)>trailSize
                r = trailSize;
            else
                r = t;
            end
            
            %q = quiver(x0(t-r+1:t,i),y0(t-r+1:t,i),u(t-r+1:t,i),v(t-r+1:t,i),0);
            q = quiver3(x0(t-r+1:t,i),y0(t-r+1:t,i),z0(t-r+1:t,i),u(t-r+1:t,i),v(t-r+1:t,i),w(t-r+1:t,i),0);
            %set(q,'Color',(de2bi(rem(i,27),3,3))./2);
            %set(q,'Color',(de2bi(rem(i,8),3,2)));
            set(q,'LineStyle','-');
            set(q,'ShowArrowHead','off');
        end
        
    %end

%     if (t-tStart)>trailSize
%         r = trailSize;
%     else
%         r = t;
%     end
%     quiver(x0(t-r+1:t,i),y0(t-r+1:t,i),u(t-r+1:t,i),v(t-r+1:t,i),0)
    f = getframe(gca);
    hold off
    imStack(:,:,:,t-tStart) = (frame2im(f));
    Creating_video_percent_complete = (t-tStart)*100/vidSize
end

% for t = 1:vidSize
%     
%     imshow(cropEdges(I(:,:,tStart+t-1),0.03))
%     %     hold on
%     %     quiver(x0,y0,u,v,0)
%     %     f = getframe(gca);
%     %     hold off
%     hold on
%     for k = 1:size(x0,2)
%         quiver3(x0(:,k),y0(:,k),z0(:,k),u(:,k),v(:,k),w(:,k),0)
%     end
%     f = getframe(gca);
%     hold off
%     imStack(:,:,:,t) = (frame2im(f));
%     
% end
%-----------------------------------------------------------
%Video_out_code below---------------------------------------
%-----------------------------------------------------------
% vid = VideoWriter('GlacierIce_tracks_ISF=0.25.avi');
% vid.FrameRate = 15;
% open(vid);
% writeVideo(vid,permute(imStack,[1 2 3 4]));
% close(vid);
%-----------------------------------------------------------
implay(permute(imStack,[1 2 3 4]))
%end