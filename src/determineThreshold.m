function [ selectedThreshold ] = determineThreshold( normalizedImage1 )
    
    % Now run the data through a linear filter to enhance particles
    %enhancedImage1 = LOG_filter(image1);
    %normalizedImage1 = enhancedImage1/maxZStackValue;

    
    % This function call will find the number of mRNAs for all thresholds
    thresholdFunction1 = multithreshstack(normalizedImage1);
    
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
    
    selectedThreshold = x(1);
    imshow(normalizedImage1>selectedThreshold/100);
end

