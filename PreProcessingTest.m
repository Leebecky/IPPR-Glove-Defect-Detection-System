img1 = imread("Dataset Images\Cloth Gloves\Cloth-Stain-3.jpg");
img2 = imread("Dataset Images\Medical Gloves\Unitrile-gloves.png");
img3 = imread("Dataset Images\Rubber Gloves\Rubber-Hole-1.jpg");

% Convert to Grayscale
img1_gray = rgb2gray(img1);
img2_gray = im2gray(img2);


% Resize Image to be standard 
img1_resize = imresize(img1_gray, [480, 480]);
img2_resize = imresize(img2_gray, [480, 480]);

% Sharpening
% sharp_d =  [-1 -1 -1; -1 9 -1; -1 -1 -1];
% img1_sharp = imfilter(img1_resize, sharp_d);
% img2_sharp = imfilter(img2_resize, sharp_d);

img2_blur = imgaussfilt(img2_resize, 3);

% Adaptive thresholding
% % img2_thres = histeq(img2_resize);
img2_thres = adaptthresh(img2_resize, 0.6, "NeighborhoodSize", 5, "Statistic","gaussian");

% Convert to Binary
% img1_bin = imbinarize(img1_sharp);
img2_bin = imbinarize(img2_blur);

img2_binOnly = imbinarize(img2_resize);


figure(1);
subplot(2,2,1), imshow(img2_blur), title("Img2 Blur");
subplot(2,2,2), imshow(img2_binOnly), title("Img2 Bin");
subplot(2,2,3), imshow(img2_thres), title("Img2 Thresh");
subplot(2,2,4), imshow(img2_bin), title("Img2 Bin Thresh");

% figure(2);
% subplot(2,1,1), imhist(img1_resize), title("Img1");
% subplot(2,1,2), imhist(img2_resize), title("Img2");

