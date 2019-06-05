
%  count_mrna.m
%  8/25/2008, Arjun Raj
%  
%  This program counts the number of mRNA spots in the image file
%  
%  test_mrna_image.mat
%  
%  available online at www.math.nyu.edu/~arjunraj/raj_2008_software/
%  
%  This MATLAB script is self-contained and should be easily
%  adapatable to other mRNA spot images.
%  
%  See readme.txt for more information, and please e-mail
%  arjunraj@cims.nyu.edu if you have any questions.


% The following line loads the test image data, which is similar to
% those described in the paper.  The images are stored as a 3-D matrix 
% of 16 bit values taken using fluorescence microscopy.  Depending on 
% the software you use to acquire your images, the procedure to import
% data into MATLAB will be different.
% load test_mrna_image.mat

[stack, img_read] = Tiffread2('C:\Data\Edited\Exp99\0 min\MATLAB\Hek_0min_04_R3D_D3D_PRJ.dv - APCFL.tif')

% The images are now contained in the variable "ims"

% Convert to double.
ims = double(stack.data);

% Now run the data through a linear filter to enhance particles
ims2 = LOG_filter(ims);

% Normalize ims2
ims2 = ims2/max(ims2(:));

% This function call will find the number of mRNAs for all thresholds
thresholdfn = multithreshstack(ims2);

% These are the thresholds
thresholds = (1:100)/100;

% Let's plot the threshold as a function of the number of mRNAs
figure(1)
plot(thresholds, thresholdfn);
xlabel('Threshold');
ylabel('Number of spots counted');
% Zoom in on important area
ylim([0 1000]);

% In this case, the appropriate threshold is around 0.23 or so.

% This code helps extract the number of mRNA from the graph

title('Click at appropriate x/threshold value and hit return')

[x,y] = getpts;
line([x x],[0 4000]);

x = round(x*100);  % 100 is the number of thresholds
number_of_mrna = thresholdfn(x)

% Enjoy playing with your own mRNA images!
%                         --Arjun



