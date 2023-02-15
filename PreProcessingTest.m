img1 = imread("Dataset Images\Cloth Gloves\Hole\Large+hole+in+glove+thumb.jpg");
img2 = imread("Dataset Images\Medical Gloves\Medical-Pinhole-1.png");

% Convert to Grayscale
img1_gray = rgb2gray(img1);
img2_gray = rgb2gray(img2);

% Resize Image to be standard 
img1_resize = imresize(img1_gray, [480, 480]);
img2_resize = imresize(img2_gray, [480, 480]);

% Sharpening
sharp_d =  [-1 -1 -1; -1 9 -1; -1 -1 -1];
img1_sharp = imfilter(img1_resize, sharp_d);
img2_sharp = imfilter(img2_resize, sharp_d);

% Convert to Binary
img1_bin = imbinarize(img1_sharp);
img2_bin = imbinarize(img2_sharp);

figure(1);
subplot(2,2,1), imshow(img1_bin), title("Img1");
subplot(2,2,2), imshow(img2_bin), title("Img2");
subplot(2,2,3), imshow(img1_sharp), title("Img1");
subplot(2,2,4), imshow(img2_sharp), title("Img2");

figure(2);
subplot(2,1,1), imhist(img1_resize), title("Img1");
subplot(2,1,2), imhist(img2_resize), title("Img2");

