% This is a samplest implementation of the proposed RIFT algorithm. In this implementation,...
% rotation invariance part and corner point detection are not included.

function [des_m1_h,des_m2_h] = feature_extract(im1,im2,s,o)
global ft1 ft2 D
% m1 and m2 are the maximum moment maps;
% eo1{s,o} = convolution result for scale s and orientation o.
% The real part is the result of convolving with the even symmetric filter,
% the imaginary part is the result from convolution with the odd symmetric filter.
%[M m or ft pc EO, T] = phasecong3(im, nscale, norient, minWaveLength, ...
%                           mult, sigmaOnf, k, cutOff, g, noiseMethod)
%default parameter
[M1,m1,or1,~,pc1,eo1,~] = phasecong3(im1,s,o,3,'mult',1.6,'sigmaOnf',0.65,'g', 3, 'k',10);
[M2,m2,or2,~,pc2,eo2,~] = phasecong3(im2,s,o,3,'mult',1.6,'sigmaOnf',0.65,'g', 3, 'k',10);

% FAST detector on the maximum moment maps to extract edge feature points.
m1_points = detectFASTFeatures(M1,'MinQuality',1e-6,'MinContrast',0.001);
m2_points = detectFASTFeatures(M2,'MinQuality',1e-6,'MinContrast',0.001);
sel = 5000;
m1_points=m1_points.selectStrongest(sel);
m2_points=m2_points.selectStrongest(sel);

basic_patch = 48;
patch_size1 = [];
for i = 0:s-1
    patch_size1(end+1) = floor(basic_patch * 1.6^i);
end
patch_size2 = [];
for i = 0:s-1
    patch_size2(end+1) = floor(basic_patch * 1.6^i);
end

% RIFT descriptor
[des_m1_h] = descriptor_geometric_invariance(im1, m1_points.Location,eo1,s,o,or1,patch_size1);
[des_m2_h] = descriptor_geometric_invariance(im2, m2_points.Location,eo2,s,o,or2,patch_size2);