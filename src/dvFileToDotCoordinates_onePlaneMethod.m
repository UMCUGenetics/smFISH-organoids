function [ xyzCoords ] = dvFileToDotCoordinates( dvFile, totalChannels, channel, planeForThreshold )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% Read DV files to binary 3d image

%dvFile = bfopen(dvFilePath);

%totalChannels = 4;
planesPerChannel = numel(dvFile{1})/totalChannels/2;
% Choose a threshold
%channel = 3;
%planeForThreshold = 13;

stackMax = 0;
for plane=1:planesPerChannel
    
   stackMax = double(max(stackMax, max(max(double( colocalization_3d_plane_select(dvFile, plane, channel, totalChannels) ))))); 
    
end

dataOfPlane = double(colocalization_3d_plane_select(dvFile, planeForThreshold, channel, totalChannels));

enhancedImage1 = dataOfPlane; %LOG_filter(dataOfPlane);
normalizedImage1 = enhancedImage1/stackMax ;%stackMax; % 

[ selectedThreshold] = determineThreshold( normalizedImage1 );
[dots, coordinates] = getDotCoordinatesFor3d(normalizedImage1, selectedThreshold);

%coordinateMatrix = reshape([coordinates.Centroid], [ size(coordinates, 1), 2]);
coordinatesCopy1 = struct2cell(coordinates);
hold off;
figure('Name',sprintf('Selected dots based on threshold of %0.5f for channel %d', selectedThreshold,channel ),'NumberTitle','off')
imshow(normalizedImage1)
hold on;
for i=1:numel(coordinatesCopy1)
   x1 = coordinatesCopy1{i}(1);
   y1 = coordinatesCopy1{i}(2);
   plot(x1,y1,'r+','MarkerSize',3) 
end


%Go over the z-stack and apply the threshold
allCoordinates = [];
for plane=1:planesPerChannel
    %close all;
    dataOfPlane = double( colocalization_3d_plane_select(dvFile, plane, channel, totalChannels) );
    %figure('Name',sprintf('Channel %d, Plane %d', channel, plane) ,'NumberTitle','off')
    %imshow(normalizedImage1)
    
    enhancedImage =  dataOfPlane/stackMax; %LOG_filter(dataOfPlane);
     [dots, coordinates] = getDotCoordinatesFor3d(enhancedImage, selectedThreshold);
     
     %Convert the list of structs to a matrix, every row is a dot, column
     %one is X column 2 is Y
     %coordinateMatrix = reshape([coordinates.Centroid], [ size(coordinates, 1), 2]);
     coordinatesCopy1 = struct2cell(coordinates);
    %hold on
     for i=1:numel(coordinatesCopy1)
       x1 = coordinatesCopy1{i}(1);
       y1 = coordinatesCopy1{i}(2);
       allCoordinates = vertcat(allCoordinates, [x1,y1,plane]);
       %plot(x1,y1,'r+','MarkerSize',3) 
     end
     %hold off
     
end
figure('Name',sprintf('3d selection of dots for channel %d', channel ),'NumberTitle','off')
scatter3(allCoordinates(:,1),allCoordinates(:,2),allCoordinates(:,3))

% Convert coordinates of dots found in planes to 3d matrix %
binarized3dmatrix = zeros( int16(size(dataOfPlane,1)+1),int16(size(dataOfPlane,2)+1), int16(planesPerChannel));
for index=1:size(allCoordinates,1)
    binarized3dmatrix( int16(allCoordinates(index,1)), int16(allCoordinates(index,2)), allCoordinates(index,3)) = 1;
end
% Remove all singular dots (Require at least presence in two slices
binarized3dmatrix = bwareaopen(binarized3dmatrix,2);

% Obtain 3d coordinates for all remaining dots
centroidStruct = regionprops( bwconncomp(binarized3dmatrix),'Centroid');
centroidCell = struct2cell(centroidStruct);
hold on
xyzCoords = zeros( numel(centroidCell), 3 );
for i=1:numel(centroidCell)
   x1 = centroidCell{i}(2); %% MAGIC??? x=y??
   y1 = centroidCell{i}(1);
   z1 = centroidCell{i}(3);
    xyzCoords(i,:) = [x1,y1,z1];
end
scatter3(xyzCoords(:,1),xyzCoords(:,2),xyzCoords(:,3), 'red', 'filled')

end

