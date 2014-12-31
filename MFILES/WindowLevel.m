function[cmap] = WindowLevel(W,L)

% Add one to W and L because of
% indexing from 1
W = W+1;
L = L+1;

cmap = zeros(256,3);

start= round( max(L,1) );
cmap(1:start,:) = 0.0000;

stop= round( min(L+W,256) );
cmap(stop:256,:) = 1.0000;

inc = 1/W;
len = length( (start+1):(stop-1) );
scale = ( 0:inc:(len*inc - inc) )';

cmap( (start+1):(stop-1),1) = scale;
cmap( (start+1):(stop-1),2) = scale;
cmap( (start+1):(stop-1),3) = scale;

return
