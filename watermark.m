pkg load image;

% Retrieve command-line arguments
args = argv();
argsLength = length(args);
if argsLength < 2
    error("Usage: octave --silent watermark.m <input_image> <output_image> <watermark>?");
endif

input_image = args{1};
output_image = args{2};
watermarkPath = "watermark.png";
if argsLength == 3
    watermarkPath = args{3};
endif

% Read the input image and watermark
img = imread(input_image);
watermark = imread(watermarkPath);

% Convert the watermark to grayscale
watermark_gray = rgb2gray(watermark);

% Compute the optimal threshold using Otsu's method
threshold = graythresh(watermark_gray) * 255; % Scale to 0-255

% Convert the grayscale watermark to black and white using the computed threshold
watermark_bw = uint8(watermark_gray > threshold) * 255;

% Convert the binary image to 3 channels for RGB compatibility
watermark_bw = repmat(watermark_bw, [1, 1, 3]);

% Get the dimensions of the input image and the watermark
[r, c, ~] = size(img);
[wr, wc, ~] = size(watermark_bw);

% Calculate the scaling factor to make the watermark ~15% of the input image width
target_width = c * 0.15; % Target width is 15% of the image width
scale_factor = target_width / wc;

% Resize the watermark using the calculated scaling factor
watermark_bw = imresize(watermark_bw, scale_factor);

% Update watermark dimensions after resizing
[wr, wc, ~] = size(watermark_bw);

% Determine the bottom-right corner position
start_row = r - wr + 1;
start_col = c - wc + 1;

% Additive blend: Make black pixels transparent, brighten non-black areas
for ir = 1:wr
    for ic = 1:wc
        for ch = 1:3 % Iterate over RGB channels
            if watermark_bw(ir, ic, ch) > 0 % Non-black pixel
                img(start_row + ir - 1, start_col + ic - 1, ch) = ...
                    min(255, img(start_row + ir - 1, start_col + ic - 1, ch) + watermark_bw(ir, ic, ch));
            end
        end
    end
end

% Resize the final image to 320px width while keeping the aspect ratio
new_width = 320;
new_height = round((new_width / c) * r); % Maintain aspect ratio
img_resized = imresize(img, [new_height, new_width]);

% Save the resultant image
imwrite(img_resized, output_image);

fprintf("Watermarked image saved to: %s (Resized to %dx%d)\n", output_image, new_width, new_height);

%octave --silent watermark.m input_image.jpg output_image.jpg
%octave --silent watermark.m "E:\myDesktop\wallpaper\wallpaperflare.com_wallpaper (15).jpg" output_image.jpg

%octave --silent watermark.m input_image.jpg output_image.jpg
%octave --silent watermark.m "E:\myDesktop\wallpaper\wallpaperflare.com_wallpaper (15).jpg" output_image.jpg
