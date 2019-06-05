
addpath('C:/Users/momerzu/Documents/MATLAB');
addpath('C:/Users/momerzu/Documents/MATLAB/colocalization');
addpath('C:/Users/momerzu/Documents/MATLAB/bfmatlab');
addpath('D:/Data/');
dvFile = bfopen('L:\momerzu\IF pictures\Exp121_26012017\D3D\3andfar3_1_R3D_D3D.dv');


channel = 2;
totalChannels = 4;
planesPerChannel = numel(dvFile{1})/totalChannels/2;

stackMax = 0;
for plane=1:planesPerChannel
    
   stackMax = double(max(stackMax, max(max(double( colocalization_3d_plane_select(dvFile, plane, channel, totalChannels) ))))); 
    
end

firstPlane = colocalization_3d_plane_select(dvFile, 1, channel, totalChannels);
megaCube = zeros(planesPerChannel, size(firstPlane,1), size(firstPlane,2));
for plane=1:planesPerChannel
    megaCube(plane,:,:) =  double( colocalization_3d_plane_select(dvFile, plane, channel, totalChannels) ); 
end

planeSelect = 10;
selectedPlaneData = squeeze(megaCube(planeSelect, :,:))/stackMax;
imshow( histeq(selectedPlaneData ));

gaussianFilter = fspecial('gaussian', [20 20], 10);
gaussianFilteredPlane = imfilter(selectedPlaneData,gaussianFilter,'same');
[Vx,Vy,Vz] = gradient(megaCube);


indices = ( (abs(Vx)==0)) .* ( abs(Vy)==0); %.* ( abs(Vz)==0) ;
sum(sum(sum(indices)))
[z,y,x]=ind2sub(size(indices), find(indices));
scatter3(x,y,z, 'r+')
    




coordinates = []
for coordinate=centroidCell
    x = coordinate{1}(1);
    y = coordinate{1}(2);
    z = coordinate{1}(3);
    if abs(z-viewPlane)<=(viewRange)
             %plot(x,y,'Color',abs(z-viewPlane),'MarkerSize',3)
             coordinates = vertcat(coordinates, [x y viewRange-abs(z-viewPlane)] );
    end
end

imshow( imfuse( squeeze(Vx(planeSelect, :, :)), squeeze(Vy(planeSelect, :, :)) ))




%laplacianFilter = fspecial('log', [20 20], 0.1);
laplacianFilter = fspecial('laplacian', 0.1);




laplacianFilteredPlane = imfilter(gaussianFilteredPlane,laplacianFilter,'same');

imshow(histeq(laplacianFilteredPlane+min(min(laplacianFilteredPlane))));
imshow(imfuse(histeq(imgradient(gaussianFilteredPlane)), selectedPlaneData ));

