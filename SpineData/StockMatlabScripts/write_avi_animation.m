function out=write_avi_animation(video_file,M)

myVideo = VideoWriter(video_file, 'MPEG-4');
myVideo.FrameRate = 7;  % Default 30
% myVideo.Quality = 100;    % Default 75

open(myVideo);
writeVideo(myVideo, M);
close(myVideo);
out=1;


