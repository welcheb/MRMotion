function[Image] = LoadCIMG(filename)

fid = fopen(filename,'r','b');
temp = fread(fid,[512 256],'float32');
Image = temp(1:2:512,:) + temp(2:2:512,:)*i;

