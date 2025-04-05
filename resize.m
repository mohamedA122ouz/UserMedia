pkg load image;

% Retrieve command-line arguments
args = argv();
argsLength = length(args);
if argsLength < 3
    error("Usage: octave --silent watermark.m <input_image> <output_image> <watermark_image>");
endif

input_image = args{1};
output_image = args{2};
watermark_image = args{3};

% Read the input and watermark images
img = imread(input_image);
watermark = imread(watermark_image);

% Resize function
function out = resize_img(image, target_width)
    [orig_height, orig_width, ~] = size(image);
    scale_factor = target_width / orig_width;
    new_height = round(orig_height * scale_factor);
    out = imresize(image, [new_height, target_width]);
end

% Resize the input image
resized = resize_img(img, 320);

% Resize watermark (optional: e.g., make it 20% of resized image width)
wm_width = round(size(resized, 2) * 0.2);
scale = wm_width / size(watermark, 2);
wm_height = round(size(watermark, 1) * scale);
watermark_resized = imresize(watermark, [wm_height, wm_width]);

% Paste watermark at bottom-right corner
[res_h, res_w, res_c] = size(resized);
[wm_h, wm_w, wm_c] = size(watermark_resized);

% Position: bottom-right
y_start = res_h - wm_h + 1;
x_start = res_w - wm_w + 1;

% Simple blend (assumes both images are RGB)
alpha = 0.4;  % watermark transparency

for c = 1:res_c
    resized(y_start:end, x_start:end, c) = ...
        (1 - alpha) * resized(y_start:end, x_start:end, c) + ...
         alpha * watermark_resized(:, :, c);
end

% Save final image
imwrite(resized, output_image);
fprintf("Watermarked image saved to: %s\n", output_image);