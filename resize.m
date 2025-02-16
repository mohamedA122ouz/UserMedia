pkg load image;

% Retrieve command-line arguments
args = argv();
argsLength = length(args);
if argsLength < 2
    error("Usage: octave --silent watermark.m <input_image> <output_image> <watermark>?");
endif

input_image = args{1};
output_image = args{2};
% Read the input image and watermark
img = imread(input_image);

function resized_img = resize_to_width(image, target_width)
    % Get the original dimensions
    [orig_height, orig_width, num_channels] = size(image);
    
    % Compute the scaling factor to maintain aspect ratio
    scale_factor = target_width / orig_width;
    
    % Compute new height while keeping aspect ratio
    new_height = round(orig_height * scale_factor);
    
    % Resize the image
    resized_img = imresize(image, [new_height, target_width]);
end

imwrite(resized_img(img,320), output_image);

fprintf("Watermarked image saved to: %s\n", output_image);