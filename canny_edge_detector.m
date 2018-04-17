function [gradient_magnitude, gradient_angle, suppressed, output] = canny_edge_detector(input, sigma, threshold_high)
    %   Generate Canny edge detected image output along with intermediate
    %   Results
    
    % Threshold low = 40% of high for similarity with internal function
    threshold_low = 0.4 * threshold_high;

    % Step 1: Smoothing the input image with a Gaussian filter.
    filter_size = sigma * 3;

    x = -filter_size:filter_size;
    gaussian_1D = (1/(sqrt(2*pi)*sigma)) * exp(-(x.^2)/(2*sigma^2));

    % Filter both directions
    smoothed_image = imfilter(input, gaussian_1D, 'conv', 'replicate');
    smoothed_image = imfilter(smoothed_image, gaussian_1D', 'conv', 'replicate');

    % Step 2: Computer the gradient magnitude and angle images
    derivative_gaussian_1D = -x.*gaussian_1D./(sigma^2);
    
    % Filter both directions
    gradient_x = imfilter(smoothed_image, derivative_gaussian_1D, 'conv', 'replicate');
    gradient_y = imfilter(smoothed_image, derivative_gaussian_1D', 'conv', 'replicate');

    % Find magnitude and angle images
    gradient_magnitude = sqrt(gradient_x.^2 + gradient_y.^2);
    gradient_magnitude = gradient_magnitude / max(gradient_magnitude(:)); % Normalization

    gradient_angle = atand(gradient_y./gradient_x);

    % Step 3: Apply nonmaxima suppression to the gradient magnitude image.
    [m, n] = size(gradient_angle);
    suppressed = gradient_magnitude;

    % Adjust for direction of gradient to closest 45 seperated axes
    % if value is less than two of its neighbors along the adjusted direction, suppress
    for i = 2:m-1
        for j = 2:n-1
            a = gradient_angle(i,j);
            m = gradient_magnitude(i,j);

            % Skip if magnitude is 0
            if m == 0
                continue;
            end

            if ((a >= -22.5 && a < 22.5) || (a >= 157.5 && a <= 180) || (a >= -180 && a < -157.5))
                % Horizontal
                if (m < gradient_magnitude(i,j+1) || m < gradient_magnitude(i,j-1))
                    suppressed(i,j) = 0;
                end
            elseif ((a >= -67.5 && a < -22.5) || (a >= 112.5 && a < 157.5))
                % 45/-135 degrees lines

                if (m < gradient_magnitude(i-1,j-1) || m < gradient_magnitude(i+1,j+1))
                    suppressed(i,j) = 0;
                end
            elseif ((a >= 67.5 && a < 112.5) || (a < -67.5 && a >= -112.5))
                % Vertical
                if (m < gradient_magnitude(i-1,j) || m < gradient_magnitude(i+1,j))
                    suppressed(i,j) = 0;
                end
            elseif ((a >= 22.5 && a < 67.5) || (a < -112.5 && a >= -157.5))
                % -45/135 degrees lines
                if (m < gradient_magnitude(i+1,j-1) || m < gradient_magnitude(i-1,j+1))
                    suppressed(i,j) = 0;
                end
            end
        end
    end    


    % Step 4: Use double thresholding and connectivity analysis to
    % detect and link edges.
    % Thresholding into weak and strong edges
    gradient_low = suppressed >= threshold_low; 
    gradient_high = suppressed >= threshold_high;

    gradient_low = padarray(gradient_low, [1,1], 'both');
    gradient_high = padarray(gradient_high, [1,1], 'both');
    
    gradient_low = gradient_low - gradient_high;

    % Find all indices to strong edge pixels
    [r, c] = find(gradient_high > 0);
    
    % Iterate over strong edges to find 8-connected weak edges to link
    for i = 1:1:size(r)
        if (gradient_low(r(i)-1, c(i)-1) > 0)
            gradient_high(r(i)-1, c(i)-1) = 1;
        end
        if (gradient_low(r(i)+1, c(i)+1) > 0)
            gradient_high(r(i)+1, c(i)+1) = 1;
        end
        if (gradient_low(r(i)-1, c(i)) > 0)
            gradient_high(r(i)-1, c(i)) = 1;
        end
        if (gradient_low(r(i), c(i)-1) > 0)
            gradient_high(r(i), c(i)-1) = 1;
        end
        if (gradient_low(r(i)+1, c(i)-1) > 0)
            gradient_high(r(i)+1, c(i)-1) = 1;
        end
        if (gradient_low(r(i)-1, c(i)+1) > 0)
            gradient_high(r(i)-1, c(i)+1) = 1;
        end
        if (gradient_low(r(i), c(i)+1) > 0)
            gradient_high(r(i), c(i)+1) = 1;
        end
        if (gradient_low(r(i)+1, c(i)) > 0)
            gradient_high(r(i)+1, c(i)) = 1;
        end
    end

    % Crop out 1-padding to resize to normal
    output = gradient_high(2:end-1,2:end-1);
end

% Debug stuff
% fig1 = figure('Name', 'Canny Edge Detection', 'color', [1 1 1]);
% subplot(3, 3, 1);
% imshow(image);
% title("Input Image");
% 
% subplot(3, 3, 2);
% imshow(gradient_magnitude);
% title("Gradient Magnitude");
% 
% subplot(3, 3, 3);
% imshow(gradient_angle);
% title("Gradient Angle");
% 
% subplot(3, 3, 4);
% imshow(suppressed);
% title("Non-Maxima Suppression Result");
% 
% subplot(3, 3, 5);
% imshow(gradient_high);
% title("Threshold and Linked");
% 
% subplot(3, 3, 6);
% imshow(edge(input, 'Canny', threshold_high, sigma));
% title("MATLAB's Canny Edge Detector");
