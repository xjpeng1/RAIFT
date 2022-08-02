function [des] = descriptor_geometric_invariance(im, kps,eo,s,o,or,patch_size)
global L gii
KPS=kps'; %keypoints
[yim,xim,~] = size(im);
patch_size(4) = patch_size(3);
CSs = zeros(yim, xim, s); %convolution sequence
for i=1:s
    for j=1:o
        CSs(:,:,i)=CSs(:,:,i)+abs(eo{i,j});
    end
end
[~, MIMs] = max(CSs,[],3);
MMMs = mean(CSs,3);

ns=1;deep=L;
des = zeros(ns*ns*deep, size(KPS,2));%不考虑相反方向

kps_to_ignore = zeros(1,size(KPS,2));

for k = 1: size(KPS,2)
    x = round(KPS(1, k));
    y = round(KPS(2, k));
    %此处通过点(x,y)选择其对应最大的幅值作为尺度，MIMs存储着每一点对应的尺度索引
    idx_tmp = MIMs(y,x);
    r_tmp = patch_size(idx_tmp);%获取该尺度对应的窗口大小
    
    x1 = max(1,x-floor(r_tmp/2));
    y1 = max(1,y-floor(r_tmp/2));
    x2 = min(x+floor(r_tmp/2),size(im,2));
    y2 = min(y+floor(r_tmp/2),size(im,1));
    
    if y2-y1 ~= r_tmp || x2-x1 ~= r_tmp
        kps_to_ignore(k+0*size(KPS,2))=1;
        continue;
    end

    r = round(r_tmp/2);
    patch = or(y-r:y+r,x-r:x+r);
    
    dt = 5;range_t = 0:dt:180;
    hist_p = my_hist(patch,range_t);
    
    [~,idx] = max(hist_p);
    t = range_t(idx)+dt/2;
    t = t/180*pi;
    
    t1 = t;

    giinow = gii{idx_tmp};

    RIFT_des_1 = rot_and_desc(MMMs,t1,x,y,x1,x2,y1,y2,giinow);
    des(:,k+0*size(KPS,2))=RIFT_des_1;
    %反方向
    %RIFT_des_2 = rot_and_desc(MMMs,t2,x,y,x1,x2,y1,y2,giinow);
    %des(:,k+1*size(KPS,2))=RIFT_des_2;
    
end
KPS = repmat(KPS,1,2);
des = struct('kps', KPS(:,kps_to_ignore ==0)', 'des', des(:,kps_to_ignore==0)');
end

function desc = rot_and_desc(img,t,x,y,x1,x2,y1,y2,giinow)
    % my_imwarp以顺时针为正旋转方向，即t>0是顺时针转
    A = [1,0,x;0,1,y;0,0,1]*...
        [cos(t),-sin(t),0;sin(t),cos(t),0;0,0,1]*...
        [1,0,-x;0,1,-y;0,0,1];
    clip = my_imwarp(img,A,y1,y2,x1,x2);
    
    desc = my_BRIEF(clip,giinow);
end