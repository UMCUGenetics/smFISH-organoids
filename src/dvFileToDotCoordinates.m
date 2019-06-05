function [ xyzCoords ] = dvFileToDotCoordinates( dvFile, totalChannels, channel,minimumDotArea )
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

% Go over all thresholds, determine amount of spots for each of these
% thresholds
thresholdCount = 100;
thresholds = (1:100)/thresholdCount;

%Create 3d cube
firstPlane = colocalization_3d_plane_select(dvFile, 1, channel, totalChannels);
megaCube = zeros(planesPerChannel, size(firstPlane,1), size(firstPlane,2));
for plane=1:planesPerChannel
    megaCube(plane,:,:) =  double( colocalization_3d_plane_select(dvFile, plane, channel, totalChannels) ); 
end

spotCounts = zeros( size(thresholds,1));

for thresholdIndex=1:thresholdCount
    binarized3dmatrix = megaCube > stackMax*(thresholds(thresholdIndex)/(thresholdCount/100));
    centroids = regionprops(bwconncomp(bwareaopen(binarized3dmatrix,minimumDotArea)),'Centroid');
    spotCounts(thresholdIndex) = numel(centroids);
end


% Let's plot the threshold as a function of the number of dots
figure(1)
plot(spotCounts);
xlabel('Threshold');
ylabel('Number of spots counted');

title('Click at appropriate x/threshold value and hit return');
[x,~] = getpts;
line([x x],[0 4000]);

selectedThreshold = round(x);  % 100 is the number of thresholds
%Re-binarize our matrix based on the threshold we choose
binarized3dmatrix = megaCube > stackMax*(thresholds(selectedThreshold)/(thresholdCount/100));

% integrate intensity per spot
spotPixels = regionprops( bwconncomp( binarized3dmatrix ), 'PixelIdxList');

[labeledImage,numBlobs] = bwlabeln(binarized3dmatrix);
%numBlobs = max(max(max(labeledImage)))
props = regionprops(labeledImage, megaCube, 'PixelValues');

intensityPerSpot = zeros( size(spotPixels,1),1 );
volumePerSpot = zeros( size(spotPixels,1),1 );
for k = 1 : numBlobs
    thisBlobsValues = props(k).PixelValues;
    volumePerSpot(k) = size(props(k).PixelValues,1);
    intensityPerSpot(k) = sum(thisBlobsValues);
    sprintf('%d, %d, %d', k,  intensityPerSpot(k), volumePerSpot(k ))
end


figure('Name',sprintf('Intensity histogram for channel %d',channel ),'NumberTitle','off')
hold on
hist(intensityPerSpot, 20);
[u,~] = hist(intensityPerSpot, 20);
ylim([0, max(u)+1])
hold off

% plot intensity vs volume
figure('Name',sprintf('Intensity vs volume per dot for channel %d',channel ),'NumberTitle','off')
hold on
scatter( volumePerSpot, intensityPerSpot)
ylabel('Integrated intensity');
xlabel('Volume [pixels]');
lsline
hold off

% Set threshold for dot volume
figure('Name',sprintf('Histogram of dot volumes based on threshold of %0.5f for channel %d', selectedThreshold,channel ),'NumberTitle','off')
hold on
hist( volumePerSpot, 15)
hold off

% Show histogram of dot sizes on unfiltered data:
h = figure('Name',sprintf('[SELECT LOWER THRESHOLD] Histogram of dot volumes based on threshold of %0.5f for channel %d', selectedThreshold,channel ),'NumberTitle','off');
hold on
hist(volumePerSpot)
ylabel('Frequency');
xlabel('Volume [pixels]');
[x,~] = getpts;
close(h)
minimumDotArea = round(x);
hold off

h = figure('Name',sprintf('[SELECT UPPER THRESHOLD] Histogram of dot volumes based on threshold of %0.5f for channel %d', selectedThreshold,channel ),'NumberTitle','off');
hold on
hist(volumePerSpot)
ylabel('Frequency');
xlabel('Volume [pixels]');
[x,~] = getpts;
close(h)
maximumDotArea = round(x);
hold off
figure('Name',sprintf('Histogram of dot sizes based on threshold of %0.5f for channel %d', selectedThreshold,channel ),'NumberTitle','off')
hold on
% Make matrix where everything which we want to capture is removed:
invertedSelectionMatrix = bwareaopen(binarized3dmatrix, maximumDotArea);
sizeFiltered3dMatrix = bwareaopen(binarized3dmatrix - invertedSelectionMatrix, minimumDotArea);

% Get all connected components in the image:
dotSurfaceSizes = regionprops( bwconncomp( sizeFiltered3dMatrix ), 'Area');
dotSurfaceSizes = [dotSurfaceSizes.Area];

% Get unfiltered sizes:
%sizeFiltered3dMatrix = bwareaopen(binarized3dmatrix - invertedSelectionMatrix, 1);
%dotSurfaceSizesUnfiltered = regionprops( bwconncomp( sizeFiltered3dMatrix ), 'Area');
dotSurfaceSizesUnfiltered = volumePerSpot;

binCount = 75;
xvalues = min(min(dotSurfaceSizesUnfiltered), min(dotSurfaceSizes)):max(max(dotSurfaceSizesUnfiltered), max(dotSurfaceSizes));
[~, binXvalues] = hist(xvalues, binCount);
[xcounts,xcoords] = hist(dotSurfaceSizesUnfiltered,binXvalues);
[ycounts,ycoords] = hist(dotSurfaceSizes,binXvalues);
%histmat = [reshape(xcounts,binCount,1) reshape(ycounts,binCount,1)];

% Dot sizes of data kept in:
b = bar( xcoords, xcounts , 'FaceColor',[0.5 0.5 0.5]);
set(get(b,'Children'),'FaceAlpha',0.5)

% selected data:
b2 = bar( ycoords, ycounts, 'FaceColor',[1 0.2 0.5]);
set(get(b2,'Children'),'FaceAlpha',0.5)

% upper bound (is thrown out):
bar( ycoords, ycounts, 'FaceColor',[1 0.2 0.5]);
set(get(b2,'Children'),'FaceAlpha',0.5)
xlabel('Area of spot');
ylabel('Frequency');
ylim( [0, max(xcounts)+1]);
hold off


%Obtain centroids:
centroidStruct = regionprops(bwconncomp(sizeFiltered3dMatrix),'Centroid');
centroidCell = struct2cell(centroidStruct);
hold off
xyzCoords = zeros( numel(centroidCell), 3 );
for i=1:numel(centroidCell)
   x1 = centroidCell{i}(3); 
   y1 = centroidCell{i}(1);
   z1 = centroidCell{i}(2);
   xyzCoords(i,:) = [x1,y1,z1]; 
end



if false
    viewPlane = 5;
    dataOfPlane = double(colocalization_3d_plane_select(dvFile, viewPlane, channel, totalChannels));

    enhancedImage1 = dataOfPlane; %LOG_filter(dataOfPlane);
    normalizedImage1 = enhancedImage1/stackMax ;%stackMax; % 

    %coordinateMatrix = reshape([coordinates.Centroid], [ size(coordinates, 1), 2]);
    hold off;
    figure('Name',sprintf('Selected dots based on threshold of %0.5f for channel %d', selectedThreshold,channel ),'NumberTitle','off')
    imshow(normalizedImage1)
    hold on;
    coordinates = []
    viewRange = 5
    for coordinate=centroidCell
        x = coordinate{1}(1);
        y = coordinate{1}(2);
        z = coordinate{1}(3);
        if abs(z-viewPlane)<=(viewRange)
                 %plot(x,y,'Color',abs(z-viewPlane),'MarkerSize',3)
                 coordinates = vertcat(coordinates, [x y viewRange-abs(z-viewPlane)] );
        end
    end
end
%scatter(coordinates(:,1),coordinates(:,2), coordinates(:,3));

%sanity check:
if false
    hold off
    figure('Name',sprintf('Unfiltered 3d Selected dots based on threshold of %0.5f for channel %d', selectedThreshold,channel ),'NumberTitle','off')
    [z,y,x]=ind2sub(size(binarized3dmatrix), find(binarized3dmatrix))
    scatter3(x,y,z, 'r+')
    hold on
    [z,y,x]=ind2sub(size(sizeFiltered3dMatrix), find(sizeFiltered3dMatrix))
    scatter3(x,y,z, 'black', 'filled')
    hold off
end
    
figure('Name',sprintf('3d Selected dots based on threshold of %0.5f for channel %d', selectedThreshold,channel ),'NumberTitle','off')
[z,y,x]=ind2sub(size(sizeFiltered3dMatrix), find(sizeFiltered3dMatrix));
scatter3(x,y,z, 'b+')
hold on
scatter3(xyzCoords(:,1),xyzCoords(:,2),xyzCoords(:,3), 'red', 'filled')
hold off

end

