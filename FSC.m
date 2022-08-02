function [solution,rmse,cor1_new,cor2_new]=my_FSC(cor1,cor2,change_form,error_t)

[M,N]=size(cor1);
if(strcmp(change_form,'similarity'))
    n=2;
    max_iteration=M*(M-1)/2;
elseif(strcmp(change_form,'affine'))
    n=3;
    max_iteration=M*(M-1)*(M-2)/(2*3);
elseif(strcmp(change_form,'perspective'))
    n=4;
    max_iteration=M*(M-1)*(M-2)*(M-3)/(2*3*4);
end
if(max_iteration>50000)
    iterations=50000;
else
    iterations=max_iteration;%Algorithm iteration num
end

fsc_his = zeros(iterations,3);

most_consensus_number=0;
%most_consensus_loss=Inf;
cor1_new=zeros(M,N);
cor2_new=zeros(M,N);

%{
1. 找出RANSAC中采样集每次随机选点的代码；
2. 计算点集中μ和σ；
3. 计算点集中每一点的likelihood从而从大到小排序；
4. 初始选排序的集合中的前两个点，依次不断增加可选点数量直到p结束迭代。
%}

%rand('seed',0);
for i=1:iterations
    while(1)
        a=floor(1+(M-1)*rand(1,n));%随机选点
        cor11=cor1(a,1:2);
        cor22=cor2(a,1:2);
        
        if(n==2 && (a(1)~=a(2)) && sum(cor11(1,1:2)~=cor11(2,1:2),2) &&...
                sum(cor22(1,1:2)~=cor22(2,1:2)))
            break;
        end
        if(n==3 && (a(1)~=a(2) && a(1)~=a(3) && a(2)~=a(3)) && ...
        sum(cor11(1,1:2)~=cor11(2,1:2)) && sum(cor11(1,1:2)~=cor11(3,1:2)) && sum(cor11(2,1:2)~=cor11(3,1:2))...
        && sum(cor22(1,1:2)~=cor22(2,1:2)) && sum(cor22(1,1:2)~=cor22(3,1:2)) && sum(cor22(2,1:2)~=cor22(3,1:2)))
            break;
        end 
        if(n==4 && (a(1)~=a(2) && a(1)~=a(3) && a(1)~=a(4) && a(2)~=a(3) && a(2)~=a(4) && a(3)~=a(4)) && ...
        sum(cor11(1,1:2)~=cor11(2,1:2)) && sum(cor11(1,1:2)~=cor11(3,1:2)) && sum(cor11(1,1:2)~=cor11(4,1:2)) &&... 
        sum(cor11(2,1:2)~=cor11(3,1:2)) && sum(cor11(2,1:2)~=cor11(4,1:2)) && sum(cor11(3,1:2)~=cor11(4,1:2))...
        && sum(cor22(1,1:2)~=cor22(2,1:2)) && sum(cor22(1,1:2)~=cor22(3,1:2)) && sum(cor22(1,1:2)~=cor22(4,1:2))&&...
        sum(cor22(2,1:2)~=cor22(3,1:2)) && sum(cor22(2,1:2)~=cor22(4,1:2)) && sum(cor22(3,1:2)~=cor22(4,1:2)))
            break;
        end 
    end
      
    [parameters,~]=LSM(cor11,cor22,change_form);
    solution=[parameters(1),parameters(2),parameters(5);
        parameters(3),parameters(4),parameters(6);
        parameters(7),parameters(8),1];
    
    match1_xy=[cor1(:,1:2)';ones(1,M)];
    %for perspective
    if(strcmp(change_form,'perspective'))
        match1_test_trans=solution*match1_xy;
        match1_test_trans_12=match1_test_trans(1:2,:);
        match1_test_trans_3=match1_test_trans(3,:);
        match1_test_trans_3=repmat(match1_test_trans_3,2,1);
        match1_test_trans=match1_test_trans_12./match1_test_trans_3;
        match1_test_trans=match1_test_trans';
        match2_xy=cor2(:,1:2);
        match2_test=match2_xy;
        test=match1_test_trans-match2_test;
        diff_match2_xy=sqrt(sum(test.^2,2));
        index_in=find(diff_match2_xy<error_t);
%         consensus_num=size(index_in,1);
        % Edit by HGP begin
        consensus_num = length(index_in);
        % Edit by HGP end
    else%for similarity and affine
        t_match1_xy=solution*match1_xy;
        match2_xy=[cor2(:,1:2)';ones(1,M)];
        diff_match2_xy=t_match1_xy-match2_xy;
        diff_match2_xy=sqrt(sum(diff_match2_xy.^2));
        index_in=find(diff_match2_xy<error_t);
%         consensus_num=size(index_in,2);
        % Edit by HGP begin
        consensus_num = length(index_in);
        consensus_loss_mean = mean(diff_match2_xy(index_in));
        consensus_loss_std = std(diff_match2_xy(index_in));
        % Edit by HGP end
    end
    
    fsc_his(i,:) = [consensus_num,consensus_loss_mean,consensus_loss_std];
     
    % Edit by HGP
    % r represents the tolerance of matching points.
    r = 0;
    %更新匹配数最多的模型
    if(consensus_num>most_consensus_number+r) % || consensus_num>=most_consensus_number+r && consensus_loss_mean<most_consensus_loss)
        most_consensus_number=consensus_num;
        most_consensus_loss = consensus_loss_mean;
        cor1_new=cor1(index_in,:);
        cor2_new=cor2(index_in,:);
    end
end

%Delete duplicate point pair
uni1=cor1_new(:,[1 2]);
[~,i,~]=unique(uni1,'rows','first');
cor1_new=cor1_new(sort(i)',:);cor2_new=cor2_new(sort(i)',:);
uni1=cor2_new(:,[1 2]);
[~,i,~]=unique(uni1,'rows','first');
cor1_new=cor1_new(sort(i)',:);cor2_new=cor2_new(sort(i)',:);

[parameters,rmse]=LSM(cor1_new(:,1:2),cor2_new(:,1:2),change_form);
solution=[parameters(1),parameters(2),parameters(5);
    parameters(3),parameters(4),parameters(6);
    parameters(7),parameters(8),1];

end
