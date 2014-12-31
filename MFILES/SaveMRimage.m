function[success] = SaveMRimage(Image, filename)

[sizey sizex] = size(Image);
fid  = fopen(filename,'w','b');

if fid==-1,
  success=0;
  return
end

ext = GetFileExtension(filename);

switch ext,

case {'cimg', 'bef', 'aft'}
	Image = rot90(Image,-1);
	temp(1:2:2*sizex,:) = real(Image);
	temp(2:2:2*sizex,:) = imag(Image);
	fwrite(fid,temp,'float32');
	fclose(fid);
case {'ksp', 'raw'}
	Image = rot90(Image,-1);
	Image = fft2(Image);
	temp(1:2:2*sizex,:) = real(Image);
	temp(2:2:2*sizex,:) = imag(Image);
	fwrite(fid,temp,'float32');
	fclose(fid);
case 'img'
	Image = abs( rot90(Image,-1) );
	fwrite(fid,Image,'uint16');
	fclose(fid);
case {'tif', 'tiff'}
	Image = abs(Image);
	imwrite(Image/max(max(Image)),filename,'tif');
otherwise
	success=0;
	return;
end

success = 1;

