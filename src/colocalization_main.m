
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
addpath('C:/Users/momerzu/Documents/MATLAB');
addpath('C:/Users/momerzu/Documents/MATLAB/colocalization');
addpath('C:/Users/momerzu/Documents/MATLAB/bfmatlab');
addpath('D:/Data/');

[stack1, img1_read] = Tiffread2('L:\momerzu\IF pictures\Exp281_14092018\Matlab\HeLa_G1phase_35_R3D_D3D_PRJ.dv - C=1.tif');
[stack2, img2_read] = Tiffread2('L:\momerzu\IF pictures\Exp281_14092018\Matlab\HeLa_G1phase_35_R3D_D3D_PRJ.dv - C=2.tif');
[dotsInImage1, coordinatesImage1, normalizedImage1] = getDotCoordinates( double(  stack1.data ));
[dotsInImage2, coordinatesImage2, normalizedImage2] = getDotCoordinates( double(  stack2.data ));

colocalizing = 0;
distanceThreshold = 3;
coordinatesCopy1 = struct2cell(coordinatesImage1);
coordinatesCopy2 = struct2cell(coordinatesImage2);

iWantToBreak = true;
twoChannelImage = cat(3,  normalizedImage1,   normalizedImage2,  normalizedImage2);
imshow(twoChannelImage )
hold on;

for i=1:numel(coordinatesCopy1)
   x1 = coordinatesCopy1{i}(1);
   y1 = coordinatesCopy1{i}(2);
   plot(x1,y1,'r+','MarkerSize',3) 
end
for i=1:numel(coordinatesCopy2)
   x1 = coordinatesCopy2{i}(1);
   y1 = coordinatesCopy2{i}(2);
   plot(x1,y1,'g+','MarkerSize',3) 
end

while iWantToBreak
    iWantToBreak = false;
    for i=1:numel(coordinatesCopy1)
        % Edge case: there are more dots close to this dot
        colocalisationsFoundForThisDot = 0;

        for j=1:numel(coordinatesCopy2)
            
            if iWantToBreak
                disp('Noooo :O')
            end
            x1 = coordinatesCopy1{i}(1);
            y1 = coordinatesCopy1{i}(2);

            x2 = coordinatesCopy2{j}(1);
            y2 = coordinatesCopy2{j}(2);

            distance = sqrt((x1-x2)^2 + (y1-y2)^2);
            %We have found a colocalized pair when the distance between two
            %points is smaller than the distance threshold
            if distance<=distanceThreshold
               colocalizing=1+colocalizing;
               coordinatesCopy1(i) = [];
               coordinatesCopy2(j) = [];
               iWantToBreak = true;
               disp('Found colocalization')
               plot(x1,y1,'yx','MarkerSize',10) 
               break
            end;
        end;
        if iWantToBreak
           break
        end;
    end;
end;

colocalizing
dotsInImage1
dotsInImage2

