function[x] = loadMOT(filename)

fid = fopen(filename,'r');
data = fread(fid,[512 64],'int16');

% FIND FIRST ZERO COLUMN OF DATA ARRAY
stop1 = min( find( sum( abs(data) )==0 ) );
N = stop1-1;

% FIND STARTING POINT OF SMOOTHED DATA
start2 = min( find( sum( abs(data(:,stop1:end)) )~=0 ) );

x.filename = filename;
x.mot  = data(1:384,1:N)./100;
x.smot = data(1:384,start2:(start2+N-1))./100;
x.units = 'PIXELS';
