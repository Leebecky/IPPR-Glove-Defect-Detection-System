img = imread("Dataset Images/IPPR Dataset/Medical-Perforation-1.png");
mask = imread("Dataset Images/IPPR Dataset/Medical-NoDefects.jpg");

img = im2gray(img);
mask = im2gray(mask);

% Resize image
img = imresize(img, [480, 480]);
mask = imresize(mask, [480, 480]);

img = imgaussfilt(img, 3); 
mask = imgaussfilt(mask, 3); 

counts = imhist(img,10);
T = otsuthresh(counts);

bw = imbinarize(img,T);
mask = imbinarize(mask,T);

se = strel('line',10,45);

maskStats = regionprops(mask, "all");
bwStats = regionprops(bw, "all");
maskArea = maskStats.Area;
imgArea = bwStats.Area;
maskMajorAxis = maskStats.MajorAxisLength;
imgMajorAxis = bwStats.MajorAxisLength;

axisThreshold = maskMajorAxis - 5;

disp("Mask Area: " + maskArea);
disp("Img Area: " + imgArea);
disp("Mask Major Axis: " + maskMajorAxis);
disp("Img Major Axis: " + imgMajorAxis);
disp("AX:"+ (maskMajorAxis-5));

% Determine image segmentation method
if (imgArea > maskArea)
    % Deformed/Loose Threads
    x = imerode(bw, se);
    x(mask) = 0;
else
    % Missing Finger/Rip/Perforation/Scratch/Tear/Hole/Stain
%     x = mask - BW;
%     x = imerode(x, se);
    x = imerode(mask, se);
    x(bw) = 0;
end

% [ssimval,ssimmap] = ssim(uint8(BW),uint8(mask));
% disp("Img | Mask : "+ssimval);
% 
% [ssimval,ssimmap] = ssim(uint8(a),uint8(BW));
% disp("A | Mask : "+ssimval);
% [ssimval,ssimmap] = ssim(uint8(x),uint8(BW));
% disp("X | Mask : "+ssimval);

% Image | Mask | Difference
figure(1);
subplot(1,3,1), imshow(bw), title("Defect");
subplot(1,3,2), imshow(mask), title("Mask");
subplot(1,3,3), imshow(x), title("Difference");

% Identifying connceted components
imgLabel = bwconncomp(x, 4);
ccNum = imgLabel.NumObjects;
% imshow(imgLabel);
imgStats = regionprops(imgLabel, 'all');
imgBox = [imgStats.BoundingBox];
imgCentroid = [imgStats.Centroid];
imgBox = reshape(imgBox, [4 ccNum]);
% figure(10); imshow(~xcl);
% Display connected components
figure(2);
imshow(bw);
hold on;
for i= 1:ccNum
    plot(imgCentroid(:,1),imgCentroid(:,2),'b*')
    rectangle('position',imgBox(:,i), EdgeColor='r');
end
hold off;

% Outlining Mask Image
maskFill = imfill(mask,'holes');
maskBoundary = bwboundaries(maskFill);
maskStats = regionprops(maskFill, "all");

figure(3);
imshow(~bw); hold on;
for i = 1 : length(maskBoundary)
    boundary = maskBoundary{i};
    centroid = maskStats(i).Centroid;
    plot(boundary(:,2),boundary(:,1),'g','linewidth',2);
    text(centroid(1),centroid(2),num2str(i),'backgroundcolor','g');
end
hold off;

% figure(4); imshow(BW); hold on
% plot(stat.Centroid(:,1), stat.Centroid(:,2), 'g+', LineWidth=2);
% for i = 1:length(centroids)
%     plot(centroids(:,1), centroids(:,2), 'b*');
% end

% Identifying segments
maskPxList = maskStats.PixelList;
segment = zeros(length(imgStats));

figure(5); imshow(bw); hold on;
for i = 1 : length(imgStats)
    area = imgStats(i).Area;
    if (area < 50)
        continue;
    end

    imgPxList = imgStats(i).PixelList;
    xq = imgPxList(:,1);
    yq = imgPxList(:,2);

    % Determine if CC is within the Mask
    [in, on] = inpolygon(xq, yq, maskPxList(:,1), maskPxList(:,2));

    disp("N:"+i);
    disp("On Edge:"+numel(xq(on))); 
    disp("Out:"+numel(xq(~in)));
    disp("In:"+numel(xq(in)));
%            plot(xq(in&~on),yq(in&~on),'r+') % points strictly inside     
%             plot(xq(on),yq(on),'g*') % points on edge
%         plot(xq(~in),yq(~in),'bo') % points outside
    
    if (numel(xq(~in)) > 10 || numel(xq(on))> 75)
        segment(i) = i;     
%         plot(xq(on),yq(on),'g*') % points on edge
%         plot(xq(~in),yq(~in),'bo') % points outside
    
    elseif (numel(xq(in))> 10)
       segment(i) = i;   
%        plot(xq(in&~on),yq(in&~on),'r+') % points strictly inside        
    end
end
hold off;

% Shrink array
segment = nonzeros(segment);
disp(segment);

% Classify Defects
figure(6); imshow(bw); hold on;
for i = 1:length(segment)
%     if (segment(i,1) == 0)
%         continue;
%     end
    coords = imgStats(segment(i)).BoundingBox;
    area = imgStats(segment(i)).Area;
    centroid = imgStats(segment(i)).Centroid;
    extent = imgStats(segment(i)).Extent;
    circularity = imgStats(segment(i)).Circularity;
    convexHull = imgStats(segment(i)).ConvexHull;
    convexArea = imgStats(segment(i)).ConvexArea;
%     circularity = imgStats(segment(i)).Perimeter ^2 / (4 * pi * area);
    disp("N: "+segment(i));
    disp("Area: "+area);
    disp("Width: " + coords(3));
    disp("Height: " + coords(4));
    disp("Convex Area:" + convexArea);
     disp("Extent: "+extent);
    disp("Circularity:"+circularity);

       
    if (imgArea > maskArea)
        if (area >= 50 && area <= 250) % Loose Thread
            rectangle('position', coords, EdgeColor='r');
            text(coords(1),coords(2), "Loose Thread",'Color','g');
        elseif (area > 250) % Deformed
            rectangle('position', coords, EdgeColor='r');
            text(coords(1),coords(2), "Deformed",'Color','g');
        end
    else
        % Hole/Tear/Perforation/Rip/Stain/Scratch
        if (axisThreshold < imgMajorAxis)

                        
           plot(convexHull(:,1), convexHull(:,2),Color="r", LineWidth=1);
           if (circularity >= 1 && extent <= 0.8)
               text(coords(1),coords(2), "Stain",'Color','g');               
           elseif(extent <= 0.75 && (circularity > 0.6 && circularity < 0.9))
               text(coords(1),coords(2), "Hole",'Color','g');
           elseif(circularity <= 0.6)
               if (area <= 1000)
                   text(coords(1),coords(2), "Scratch",'Color','g');
               elseif (area > 1000 && area <= 3500)
                   text(coords(1),coords(2), "Tear",'Color','g');
               else
                   text(coords(1),coords(2), "Rip",'Color','g');
               end
           else
               text(coords(1),coords(2), "Defect",'Color','g');
           end

        else % Missing Finger
            if (area > 250) 
                rectangle('position', coords, EdgeColor='r');
                text(coords(1),coords(2), "Missing Finger",'Color','g');
           end
        end
    end


end
hold off;