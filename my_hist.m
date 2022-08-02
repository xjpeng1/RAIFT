function answ = my_hist(clip,arr)
answ = zeros(length(arr)-1,1);
for i = 1:length(answ)
    tmp = (clip>=arr(i)) .* (clip<arr(i+1));
    answ(i) = sum(tmp(:));
end
end