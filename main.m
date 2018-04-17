clear;
close all;
clc;

image = imread('lena_gray.bmp');
input = im2double(image);

[mag1, ang1, nonmax1, output1] = canny_edge_detector(input, 2, 0.175);
[mag2, ang2, nonmax2, output2] = canny_edge_detector(input, 8, 0.175);
[mag3, ang3, nonmax3, output3] = canny_edge_detector(input, 16, 0.175);


fig1 = figure('Name', 'Canny Edge Detections', 'color', [1 1 1]);
subplot(3, 3, 1);
imshow(mag1);
title("\sigma = 2");
subplot(3, 3, 2);
imshow(mag2);
title({"Gradient Magnitude";"\sigma = 8"});
subplot(3, 3, 3);
imshow(mag3);
title("\sigma = 16");

subplot(3, 3, 4);
imshow(ang1);
subplot(3, 3, 5);
imshow(ang2);
title("Gradient Angle");
subplot(3, 3, 6);
imshow(ang3);

subplot(3, 3, 7);
imshow(nonmax1);
subplot(3, 3, 8);
imshow(nonmax2);
title("Non-Maxima Suppression Result");
subplot(3, 3, 9);
imshow(nonmax3);

fig2 = figure('Name', 'Canny Edge Detections 2','color', [1 1 1]);
subplot(3, 2, 1);
imshow(output1);
title({"Final Result";"\sigma = 2"});
subplot(3, 2, 3);
imshow(output2);
title("\sigma = 8");
subplot(3, 2, 5);
imshow(output3);
title("\sigma = 16");

subplot(3, 2, 2);
imshow(edge(input, 'Canny', 0.175, 2));
title({"MATLAB's Canny Edge Detector";""});
subplot(3, 2, 4);
imshow(edge(input, 'Canny', 0.175, 8));
subplot(3, 2, 6);
imshow(edge(input, 'Canny', 0.175, 16));
