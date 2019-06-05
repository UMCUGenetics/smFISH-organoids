% Read DV files to binary 3d image
addpath('C:/Users/momerzu/Documents/MATLAB');
addpath('C:/Users/momerzu/Documents/MATLAB/colocalization');
addpath('C:/Users/momerzu/Documents/MATLAB/bfmatlab');
addpath('D:/Data/');
dvFile = bfopen('L:\momerzu\IF pictures\Exp150_11052017\D3D_Matlab\CellRec_3andFar3_02_R3D_03_D3D.dv');

channelA = 2;
channelB = 3;
totalChannels = 3;

minimumDotArea = 5;

planesPerChannel = numel(dvFile{1})/totalChannels/2;
if planesPerChannel~=round(planesPerChannel)
    error('The amount of specified channels is incorrect')
end
if channelA>totalChannels || channelB>totalChannels 
    error('A channel was specified whch is higher than the total amount of channels')
end

% Get the XYZ coordinates of the dots
xyzChannelA = dvFileToDotCoordinates(dvFile, totalChannels, channelA, minimumDotArea);
xyzChannelB = dvFileToDotCoordinates(dvFile, totalChannels, channelB, minimumDotArea);


distanceThreshold = 4; % When you change this you can rerun the code below
% make distribution: amount of detected pairs as a function of the
% threshold

iWantToBreak = true;
ingoreIndicesA = [];
ingoreIndicesB = [];
colocalizing = 0;
colocalizingIndices = [];
colocalizingIndicesA = [];
colocalizingIndicesB = [];
colocalizingPairs = [];

maxCompletion = 0;
while iWantToBreak
    iWantToBreak = false;
    iterator = 0;
    for i=1:size(xyzChannelA,1)

        
        if ismember(i, ingoreIndicesA)
            continue
        end
        
        % Edge case: there are more dots close to this dot
        colocalisationsFoundForThisDot = 0;
        for j=1:size(xyzChannelB,1)
                iterator=iterator+1;
                  completion =  (iterator)/( size(xyzChannelA,1) * size(xyzChannelB,1));
                if completion>(maxCompletion+0.001)
                    disp( sprintf('Completion: %.2f percent', completion*100.0) );
                    maxCompletion = completion;
                end 
            
            if ismember(j, ingoreIndicesB)
                continue
             end
            
             
            if iWantToBreak
                disp('Assignment problem: two dots close by')
            end
            x1 = xyzChannelA(i,1);
            y1 = xyzChannelA(i,2);
            z1 = xyzChannelA(i,3);
            
            x2 = xyzChannelB(j,1);
            y2 = xyzChannelB(j,2);
            z2 = xyzChannelB(j,3);
            
            distance = sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2);
            %We have found a colocalized pair when the distance between two
            %points is smaller than the distance threshold
            if distance<=distanceThreshold
               colocalizing=1+colocalizing;
               ingoreIndicesA(end+1) = i;
               ingoreIndicesB(end+1) = j;
               colocalizingIndicesA(end+1) = i; 
               colocalizingIndicesB(end+1) = j;
               colocalizingPairs = vertcat(colocalizingPairs, [x1, x2, y1, y2, z1, z2]);
               iWantToBreak = true;
               break
            end;
        end;
        if iWantToBreak
           break
        end;
    end;
end;

% This obtains the distribution of centroids for the complete image
% plot( reshape( sum(sum(binarized3dmatrix(:,:,:),2),3), [1, size(binarized3dmatrix,1)] ))

% The amount of dots in channel A:
sprintf('Dots in channel A: %d , B: %d, overlap: %d', size(xyzChannelA,1), size(xyzChannelB,1), colocalizing)
dotSize = 10;
hold off
figure('Name', sprintf('3d overlap between channels, red=channelA(%d) green=channelB(%d)', channelA, channelB) ,'NumberTitle','off')
scatter3( xyzChannelA( colocalizingIndicesA, 1),xyzChannelA( colocalizingIndicesA, 2),xyzChannelA( colocalizingIndicesA, 3),'*', 'black')
hold on
scatter3( xyzChannelB( colocalizingIndicesB, 1),xyzChannelB( colocalizingIndicesB, 2),xyzChannelB( colocalizingIndicesB, 3),'*', 'black')

for i=1:size(colocalizingPairs,1)
    line(colocalizingPairs(i,[1 2]),colocalizingPairs(i,[3 4]), colocalizingPairs(i,[5 6]));
end
scatter3( xyzChannelA(:,1), xyzChannelA(:,2),xyzChannelA(:,3), dotSize, 'red', 'filled')
scatter3( xyzChannelB(:,1), xyzChannelB(:,2),xyzChannelB(:,3), dotSize, [0, 0.8, 0], 'filled')
hold off

