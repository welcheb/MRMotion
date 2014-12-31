function[ext] = GetFileExtension(filename)

dots = find(filename=='.');

if isempty(dots) | dots(length(dots))==length(filename),
	ext = '';
else
	ext = filename( (dots(length(dots))+1):length(filename) );
end
