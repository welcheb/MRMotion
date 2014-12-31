%
%  function[CorruptedImage] = ApplyMotionCorruption(ImageFFT, PhaseMot, FrequencyMot)
%
function[CorruptedImage] = ApplyMotionCorruption(ImageFFT, PhaseMot, FrequencyMot)
% Make Image and Motion Compliant With Where DC is 
% in this function and whih way Phase Encode Direction is
CorruptedImage = rot90(fftshift(ImageFFT), 1) ;
PhaseMot = fftshift(PhaseMot);
FrequencyMot = fftshift(FrequencyMot);

% Rotate by 180 degrees
PhaseMot = rot90(PhaseMot,2);
FrequencyMot = rot90(FrequencyMot,2);

[xdim ydim] = size(CorruptedImage);
% Calculate image's center coordinates
xno = (xdim-1)/2;
yno = (ydim-1)/2;

% Calculate kx values (Nyquist is at x=xno)
kx_array = zeros(xdim,1);
for x=1:xdim,    
      if (x-1)<=xno,
         kx_array(x) = (x-1);
      else
         kx_array(x) = (x-1-xdim);
      end
end

% Calculate ky values (Nyquist is at y=yno)
ky_array = zeros(ydim,1);
for y=1:ydim,    
      if (y-1)<=yno,
         ky_array(y) = (y-1);
      else
         ky_array(y) = (y-1-ydim);
      end
end

% Phase Encode Direction is the Y Direction
% by convention

% Angle(kx,ky) = 2*pi*dx*kx/Nx + 2*pi*dy*ky/Ny ;

consx = (2.0*pi/xdim);
consy = (2.0*pi/ydim);
 
for y=1:ydim,
 
   % Calculate the angles
   % We are at a single value in the ky_array
   % whereas all kx_array values occur within a view.
   angle_array = (consx*FrequencyMot(y)).*kx_array + consy*PhaseMot(y)*ky_array(y);
   
   % Rotate the complex numbers by those angles
   sin_ang = sin(angle_array);
   cos_ang = cos(angle_array);
   newr = real(CorruptedImage(:,y)).*cos_ang - imag(CorruptedImage(:,y)).*sin_ang;
   newi = real(CorruptedImage(:,y)).*sin_ang + imag(CorruptedImage(:,y)).*cos_ang;
   CorruptedImage(:,y) = newr + newi*i;
end

% UNDO the original fftshift of this function
CorruptedImage = fftshift( rot90(CorruptedImage,-1) );
