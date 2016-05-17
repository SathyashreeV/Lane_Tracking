clear all;
close all;
clc;

%ADAS Computer Vision

video = vision.VideoFileReader('C:\Users\Andrew H\Desktop\Video.mp4'); % Acquire and view video from a video file

video.ImageColorSpace = 'RGB';

video.VideoOutputDataType = 'uint16';

vidplayer = vision.DeployableVideoPlayer('Name', 'RGB Video Player');


% while (~isDone(video))
%     frame = step(video);
%     step(vidplayer, frame);
% end

n = 300;
while true
    for kframes = 1:n
        %Iterate through each video frame using step
        frame = step(video);
        step(vidplayer, frame);
        
        if kframes == 3
            imwrite(frame, 'rawVideoImage.png');
        end

    end
end
% vidplayer2 = VideoWriter('At Least This Works.avi');
%Use vision.blobanalysis

% Cleanup
release(video);
release(vidplayer);

