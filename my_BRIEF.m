function desc = my_BRIEF(clip,gii)
%MY_BRIEF 此处显示有关此函数的摘要
%   此处显示详细说明
% 还要修改上一层中的desc大小，以及匹配的时候用汉明距离
desc = zeros(length(gii),1);
m = floor(size(clip,1)/2)+1;
x1 = m + gii(:,1);y1 = m + gii(:,2);
x2 = m + gii(:,3);y2 = m + gii(:,4);
for i = 1:length(gii)
    if any([x1(i),y1(i),x2(i),y2(i)]<1) ||...
            any([x1(i),y1(i),x2(i),y2(i)]>size(clip,1)) ||...
            clip(y1(i),x1(i)) < clip(y2(i),x2(i))
        desc(i) = 1;
    else
        desc(i) = 0;
    end
end
end

