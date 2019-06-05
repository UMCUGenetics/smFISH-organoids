function [ dataOfPlane, nameOfPlane ] = colocalization_3d_plane_select( dv, plane, channel, totalChannels )
    
    planesPerChannel = numel(dv{1})/totalChannels/2;
    index = (channel-1)*planesPerChannel + plane;
    try
        nameOfPlane = dv{1, 1}{index, 2};
        dataOfPlane = dv{1, 1}{index, 1};
    catch ME
        disp(sprintf('Accessing index %d', index));
        disp(sprintf('Accessing channel %d', channel));
        disp(sprintf('Accessing plane %d', plane));
    end
 
end
