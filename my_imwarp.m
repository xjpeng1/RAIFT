function clip = my_imwarp(img,A,y1,y2,x1,x2)
%MY_IMWARP 
[X,Y] = meshgrid(x1:x2,y1:y2);
pt_r = [X(:),Y(:),ones(length(X(:)),1)]';
pt_l = A\pt_r;
pt_l = [pt_l(1,:)./pt_l(3,:);pt_l(2,:)./pt_l(3,:)];
% Bilinear interpolation begin
xa = pt_l(1,:) - floor(pt_l(1,:));xb = 1-xa;
ya = pt_l(2,:) - floor(pt_l(2,:));yb = 1-ya;
pt_l_ex = [floor(pt_l(1,:));floor(pt_l(1,:));...
    floor(pt_l(1,:))+1;floor(pt_l(1,:))+1;];
pt_l_ey = [floor(pt_l(2,:));floor(pt_l(2,:))+1;...
    floor(pt_l(2,:));floor(pt_l(2,:))+1];
prv = get_pix_round_val(img,pt_l_ex,pt_l_ey);
q11 = prv(1,:);q12 = prv(2,:);q21 = prv(3,:);q22 = prv(4,:);
pv = q11.*xb.*yb+q21.*xa.*yb+q12.*xb.*ya+q22.*xa.*ya;
clip = reshape(pv,y2-y1+1,x2-x1+1);
% Bilinear interpolation end
end

function prv = get_pix_round_val(img,pt_l_ex,pt_l_ey)
[h,w] = size(img);
mask = logical((pt_l_ex >= 1).*(pt_l_ey >= 1).*(pt_l_ex <= w).*(pt_l_ey <= h));
px = pt_l_ex(:);py = pt_l_ey(:);mk = mask(:);
idx = (px-1)*h+py;
idx(~mk) = 1;
prv = img(idx);
prv(~mk) = 0;
prv = reshape(prv,4,[]);
end