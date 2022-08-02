function gi = gen_rot_gii(R,ang,num_sel)
%GEN_ROT_GII 
t = ang*pi/180;
[X,Y] = meshgrid(-R:R,-R:R);
pt = [X(:),Y(:),ones(length(X(:)),1)];
Rot = [cos(t),-sin(t),0;sin(t),cos(t),0;0,0,1];
pt_rot = pt*Rot';
gi = [pt(:,1),pt(:,2),pt_rot(:,1),pt_rot(:,2)];
mask = sum((gi>=-R).*(gi<=R),2) < 4;
gi = gi(~mask,:);
gi = gi(randperm(length(gi),num_sel),:);
end

