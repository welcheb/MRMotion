%
%  function[Image] = LoadMRimage(filename, sizex, sizey)
%
function[Image] = LoadMRimage(filename, sizex, sizey)

ext = GetFileExtension(filename);

switch ext,

case {'cimg', 'bef', 'aft'}
	fid  = fopen(filename,'r','b');
	temp = fread(fid,[2*sizex sizey],'float32');
	Image = temp(1:2:2*sizex,:) + temp(2:2:2*sizex,:)*i;
	Image = rot90(Image,1);
case {'ksp', 'raw'}
	fid  = fopen(filename,'r','b');
	temp = fread(fid,[2*sizex sizey],'float32');
	Image = temp(1:2:2*sizex,:) + temp(2:2:2*sizex,:)*i;
	Image = ifft2(Image);
	Image = rot90(Image,1);
case 'img'
	fid  = fopen(filename,'r','b');
	Image = fread(fid,[sizex sizey],'uint16');
	Image = rot90(Image);
otherwise
	Image = [];
end

