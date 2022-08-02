% This is a samplest implementation of the proposed algorithm. In this implementation,...
% Parameter optimization and feature point detection details are not included.
clear;
global gii dist_des L
clc;close all; 
warning('off')

str1='test_data/pair3-1.png';   % image pair      
str2='test_data/pair3-2.png';
str1='test_data/VisionDN_2_a.png';   % image pair      
str2='test_data/VisionDN_2_b.png';

im1 = im2uint8(imread(str1));
im2_0 = im2uint8(imread(str2));
ang = 0;  %rotation angle
t = ang/180*pi;
m1 = floor((size(im2_0)+1)/2);
im2 = imrotate(im2_0,ang);
m2 = floor((size(im2)+1)/2);

if size(im1,3)==1
    temp=im1;
    im1(:,:,1)=temp;
    im1(:,:,2)=temp;
    im1(:,:,3)=temp;
end

if size(im2,3)==1
    temp=im2;
    im2(:,:,1)=temp;
    im2(:,:,2)=temp;
    im2(:,:,3)=temp;
end

disp('Feature detection and description')
%feature detection and description
D = [48,76,122,196];L = 1024;
gii = cell(length(D),1);
gii{1} = gen_rot_gii(48,60,L);
for k = 2:length(D)
    gii{k} = round(gii{1}*D(k)/D(1));
end
gii{1} = round(gii{1});
tic
[des_m1_h,des_m2_h] = feature_extract(im1,im2,4,6);

disp('nearest matching')
% nearest matching
des_m1_h.des = binaryFeatures(uint8(des_m1_h.des));
des_m2_h.des = binaryFeatures(uint8(des_m2_h.des));
[indexPairs_h,matchmetric_h] = matchFeatures(des_m1_h.des,des_m2_h.des,'MaxRatio',1,'Unique',1);
matchedPoints1_h = des_m1_h.kps(indexPairs_h(:, 1), :);
matchedPoints2_h = des_m2_h.kps(indexPairs_h(:, 2), :);
toc

disp('outlier removal')
%outlier removal
error_t = 10;
H_h=my_FSC(matchedPoints1_h,matchedPoints2_h,'affine',error_t);
Y_h=H_h*[matchedPoints1_h';ones(1,size(matchedPoints1_h,1))];
Y_h(1,:)=Y_h(1,:)./Y_h(3,:);
Y_h(2,:)=Y_h(2,:)./Y_h(3,:);
E_h=sqrt(sum((Y_h(1:2,:)-matchedPoints2_h').^2));
inliersIndex_h=E_h<error_t;
cleanedPoints1_h = matchedPoints1_h(inliersIndex_h, :);
cleanedPoints2_h = matchedPoints2_h(inliersIndex_h, :);

% Show results
disp('Show matches')
figure; showMatchedFeatures(im1, im2, cleanedPoints1_h, cleanedPoints2_h, 'montage');

disp('registration result')
% registration
image_fusion(im2,im1,double(H_h));
