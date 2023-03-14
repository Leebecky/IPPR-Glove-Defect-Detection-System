img = imread("Medical-Tear-1.jpg");
img = im2gray(img);
% figure(1);
% imhist(img);

% Resize image
img = imresize(img, [480, 480]);
img = imgaussfilt(img, 3); 
binImg = imbinarize(img);

[counts,x] = imhist(img,10);
stem(x,counts);
T = otsuthresh(counts);
disp(T)
BW = imbinarize(img,T);

img_ii = img;
img_ii(img_ii>75) = 255;
img_ii(img_ii<75) = 0;

imshow(BW)
% 
% figure(2);
% subplot(1,3,1), imshow(img), title("Original");
% subplot(1,3,2), imshow(binImg), title("Bin");
% subplot(1,3,3), imshow(BW), title("Bin 2");
% 

