clear all;
close all;
clc;

% read in original
image = (imread('barbara_gray_noise.tif'));

% introduce poisson noise
noise = imnoise(image,'salt & pepper');
%figure, imshow(noise);

% write noise file
imwrite(noise, 'barbara_gray_noises.tif');

image = noise;

% padding to odd height/width
[width, height] = size(image);

width_odd = mod(width, 2);
height_odd = mod(height, 2);

height_pad = 0;
width_pad = 0;

if height_odd == 0
    height_pad = 1;
end

if width_odd == 0
    width_pad = 1;
end

%padded_image = padarray(image,[width_pad, height_pad],'symmetric','post');

% padding for Smax for edge/boundary pixels
%[width, height] = size(padded_image);

pad = min([(width+width_pad), (height+height_pad)]);

input = padarray(image,[pad, pad],'symmetric');



% Starts filtering
Smax = floor(pad/2);

[width, height] = size(input);

output = input;

for i = (pad+1):(width-pad)
	for j = (pad+1):(height-pad)
		Smax_reached = 1;
		zxy = input(i, j);
		
		for k = 3:2:Smax
			window_indices = -k:k;
			window = input(i+window_indices, j+window_indices);
			
			zmed = median(window(:));
			zmax = max(window(:));
			zmin = min(window(:));
			
            
			if zmed > zmin && zmed < zmax
				B1 = zxy - zmin;
				B2 = zmax - zxy;
				Smax_reached = 0;
				if zxy > zmin && zxy < zmax
					output(i, j) = zxy;
                    break;
				else
					output(i, j) = zmed;
                    break;
				end
            end
        end
        if Smax_reached == 1
            output(i, j) = zxy;
        end
	end
end

restored = output(pad+1:end-pad, pad+1:end-pad);

diff = image - restored;


imwrite(restored, 'barbara_gray_adaptivemed.tif');

medfiltered = medfilt2(image);

imwrite(medfiltered, 'barbara_gray_med.tif');












