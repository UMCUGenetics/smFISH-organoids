
function [ dotCount,centroids ] = getDotCoordinatesFor3d( normalizedImage1, threshold )
    
    dotCount = 0;
    bwl = normalizedImage1 > threshold/100;
    centroids = regionprops(bwconncomp(bwl),'Centroid');
    
end

