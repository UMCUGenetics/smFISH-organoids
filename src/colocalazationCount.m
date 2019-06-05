function [ imgAdotCount, imgBdotCount, colocalizedDotCount ] = colocalazationCount( img1, img2, maxDist )
%This function takes two channel images, a threhold is manually selected
%and the images are binarized. This function returns the amount of
%connected components in both images and the amount of colocalized dots

    % Convert to double.
    image1 = double(img1);
    image2 = double(img2);
    
    % Now run the data through a linear filter to enhance particles
    enhancedImage1 = LOG_filter(image1);
    enhancedImage2 = LOG_filter(image2);
    
    normalizedImage1 = enhancedImage1/max(enhancedImage1(:));
    normalizedImage2 = enhancedImage2/max(enhancedImage2(:));
    
    % This function call will find the number of mRNAs for all thresholds
    thresholdFunction1 = multithreshstack(normalizedImage1);
    thresholdFunction2 = multithreshstack(normalizedImage2);
    
    % These are the thresholds
    thresholds = (1:100)/100;

    % Let's plot the threshold as a function of the number of mRNAs
    figure(1)
    plot(thresholds, thresholdFunction1);
    xlabel('Threshold');
    ylabel('Number of spots counted');

    % Zoom in on important area
    ylim([0 1000]);

    % In this case, the appropriate threshold is around 0.23 or so.
    % This code helps extract the number of mRNA from the graph

    title('Click at appropriate x/threshold value and hit return');
    [x,y] = getpts;
    line([x x],[0 4000]);

    x = round(x*100);  % 100 is the number of thresholds
    dotsInImage1 = thresholdfn(x);
    

    % Changed code by bdb
    %

    normalizedImage = ims2/max(ims2(:));
    bwl = normalizedImage > x(1)/100;
    centroids = regionprops(bwconncomp(bwl),'Centroid');


end

