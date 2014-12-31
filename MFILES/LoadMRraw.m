%
% function[img] = LoadMRraw(filename)
%
%
function[img] = LoadMRraw(filename)

% AN X LINE IS MADE UP OF XRES COMPLEX (i,q) PAIRS,
% I.E. FOR XRES=8 THE DATA WOULD BE:
% i0,q0,i1,q1,i2,q2,i3,q3,i4,q4,i5,q5,i6,q6,i7,q7
%
% AN IMAGE IS MADE UP OF YRES + 1 LINES OF DATA
% A BASELINE IS STORED WITH EVERY IMAGE SET WHETHER
% IT IS USED OR NOT.  IF (NBASE==0) BASELINES ARE NOT
% USED.  IF (NBASE>0) NBSAELINES WERE ACQUIRED AND THE
% BASELINES NEED TO BE DIVIDED BY NBASE BEFORE BEING
% TAKEN OUT OF EVERY Y LINE.
%
% FOR YRES=8 THE DATA SET WOULD LOOK LIKE:
% 
% baseline
% y0
% y1
% y2
% y3
% y4
% y5
% y6
% y7
%
% THIS IS THEN REPEATED FOR MULTIPLE RECEIVERS, NCOILS
% THIS IS THEN REPEATED FOR MULTIPLE ECHOES, NECHOES
% THIS IS THEN REPEATED FOR MULTIPLE SLICES, ZRES
%

% HEADER VARIABLE LOCATIONS (DIVIDE BY 2 BECAUSE HEADER
% IS READ IN AS SHORTS)
H5X_HDR_RDBM_REV		=	0;
H5X_HDR_NECHOES			=	70/2;
H5X_HDR_START_RCV		=	200/2;
H5X_HDR_STOP_RCV		=	202/2;
H5X_HDR_BASELINE_VIEWS		=	76/2;
H5X_HDR_DA_XRES			=	102/2;
H5X_HDR_DA_YRES			=	104/2;
H5X_HDR_NSLICES			=	68/2;
H5X_HDR_DATA_ACQ_TAB		=	10242/2;
H5X_HDR_DATA_ACQ_SIZE		=	40/2;
H5X_HDR_DATA_COLLECT_TYPE	=	56/2;
H5X_HDR_POINT_SIZE		=	82/2;

H5X_HEADER_SIZE_BYTES		=	39940;
H8X_HEADER_SIZE_BYTES		=	39984;

fid = fopen(filename,'r');

% THE FTYPE WILL BE A HEXIDECIMAL STRING
temp = fread(fid,[1 4],'uint8');
ftype = sprintf('%x%x%x%x', temp);

switch ftype,

% 5X RAW DATA
case {'40a66666'}

  frewind(fid);
  header = fread(fid,[1 H5X_HEADER_SIZE_BYTES/2],'short');
  necho = header(H5X_HDR_NECHOES+1);
  ncoils = header(H5X_HDR_STOP_RCV+1) - header(H5X_HDR_START_RCV+1) + 1;
  nbase = header(H5X_HDR_BASELINE_VIEWS+1);
  xres = header(H5X_HDR_DA_XRES+1);
  yres = header(H5X_HDR_DA_YRES+1)-1;
  is3d = header(H5X_HDR_DATA_COLLECT_TYPE+1);

  zres = 0;
  nslices = header(H5X_HDR_NSLICES+1);
  for n=0:(nslices-1),
    j = H5X_HDR_DATA_ACQ_TAB + n*H5X_HDR_DATA_ACQ_SIZE;
    zres = max( zres, header(j+1) );
  end

  % READ BASELINE, AND SKIP IT
  temp = fread(fid,[2*xres 1],'short');

  % READ COMPLEX SHORTS
  temp = fread(fid,[2*xres yres],'short');
  temp = double(temp);
  img = zeros(xres,yres);
  img = temp(1:2:(2*xres),:) + temp(2:2:(2*xres),:)*i;
  img = ifft2(img); 
  temp = zeros(xres,yres);
  temp(1:xres/2,:) = img(xres/2+1:xres,:);
  temp(xres/2+1:xres,:) = img(1:xres/2,:);
  img = temp;

% 5X IMAGE DATA
case {'494d4746'}

% 8X RAW DATA
case {'40e00000'}

otherwise
  error('Invalid Header!');

end

