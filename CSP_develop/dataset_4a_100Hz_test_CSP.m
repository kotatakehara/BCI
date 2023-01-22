clear all;
S = load('data_set_4a_av_100Hz.mat');
cnt = S.cnt;
pos = S.mrk.pos.';
class = S.mrk.y.';
cnt= 0.1*double(cnt);
cnt = bandpass(cnt,[8 15],100);
s = load("true_labels_av.mat");

iv_c1=1; iv_c2=1;
j = 1;
for i=1:size(class,1)
    if class(i,1)==1

    elseif class(i,1)==2
       
    else
        if s.true_y(j) == 1
            subdata=cnt(pos(i,1):pos(i,1)+(3.5*100)-1,:);
            AA_C1_K1(iv_c1,:,:)=subdata;
            iv_c1=iv_c1+1;
            j = j + 1;
        elseif s.true_y(j) == 2
            subdata=cnt(pos(i,1):pos(i,1)+(3.5*100)-1,:);
            AA_C2_K1(iv_c2,:,:)=subdata;
            iv_c2=iv_c2+1;
            j = j + 1;
        end
    end
end

%トレーニングデータをランダムに指定数を抜き出す(train_nel個ずつ)
test_nel = 50;
Test_right = zeros(test_nel,size(AA_C1_K1,2),size(AA_C1_K1,3));
Test_foot = zeros(test_nel,size(AA_C2_K1,2),size(AA_C2_K1,3));

for i=1:test_nel
    Test_right(i,:,:) = AA_C1_K1(i,:,:);
    Test_foot(i,:,:) = AA_C2_K1(i,:,:);
end

%配列の事前割り当て
Right = zeros(test_nel,size(AA_C1_K1,3),size(AA_C1_K1,2));
Foot = zeros(test_nel,size(AA_C2_K1,3),size(AA_C2_K1,2));

%行と列の入れ替え
for i=1:test_nel
    temp=Test_right(i,:,:);
    temp=squeeze(temp);
    Right(i,:,:)=temp.';
end

for i=1:test_nel
    temp=Test_foot(i,:,:);
    temp=squeeze(temp);
    Foot(i,:,:)=temp.';
end


%データの次元数を減らして横並びに結合したもの
for i=1:test_nel
    if i==1
        matrix_right=squeeze(Right(i,:,:));
    else
        matrix_right=horzcat(matrix_right,squeeze(Right(i,:,:)));
    end
end

for i=1:test_nel
    if i==1
        matrix_foot=squeeze(Foot(i,:,:));
    else
        matrix_foot=horzcat(matrix_foot,squeeze(Foot(i,:,:)));
    end
end

%データを一回の試行ずつフィルタリングした場合
c1=1; c2=1;
[W,l,A] = csp(matrix_right,matrix_foot);
W(3:116,:)=[];
for i=1:test_nel
    temp_C1=squeeze(Right(i,:,:));
    temp_C2=squeeze(Foot(i,:,:));
    Right_CSP_K1(c1,:,:) = W*temp_C1;
    Foot_CSP_K1(c2,:,:) = W*temp_C2;
    c1 = c1 + 1;
    c2 = c2 + 1;
end

%分散を計算して特徴ベクトルの導出
for i=1:test_nel
   temp_C1=squeeze(Right_CSP_K1(i,:,:));
   Var1=var(temp_C1,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_test_right(i,:,:)=log(Var1/sum(Var1));
end
for i=1:test_nel
   temp_C2=squeeze(Foot_CSP_K1(i,:,:));
   Var2=var(temp_C2,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_test_foot(i,:,:)=log(Var2/sum(Var2));
end


writematrix(feat_test_right,'feat_4a_100Hz_Test/feat_test_right_av.txt')
writematrix(feat_test_foot,'feat_4a_100Hz_Test/feat_test_foot_av.txt')