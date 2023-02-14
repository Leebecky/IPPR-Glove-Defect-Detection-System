function ima_out = Inversion(ima)
% Check that ima is a gray level image

    if ndims(ima) > 2
    %     RGB Image?
        if ndims(ima) == 3
            ima = double(rgb2gray(uint8(ima)));
        else
            display("Unknown format. Cannot guarantee result");
        end
    end

%     Create new figure
    figure(1)

%     Display ima
    imagesc(ima);

%     Convert ima to double
    ima = double(ima);
    colormap(gray);
    axis image;

%     Rescales image between [0, 255]
    mini = min(min(ima));
    maxi = max(max(ima));
    ima_out = (ima-mini)/(maxi-mini)*255;
%     Invert ima_out
    ima_out = 255 - ima_out;

%     Display result
    figure(2)
    imagesc(ima_out);
    colormap(gray);
    axis image;
    axis off;
