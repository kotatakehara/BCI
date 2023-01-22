clear all;
S = load('data_set_4a_aw_1000Hz.mat');
cnt = S.cnt;
pos = S.mrk.pos.';
class = S.mrk.y.';
cnt= 0.1*double(cnt);
cnt = bandpass(cnt,[8 15],1000);

iv_c1=1; iv_c2=1;
for i=1:size(class,1)
    if class(i,1)==1
        subdata=cnt(pos(i,1):pos(i,1)+(3.5*1000)-1,:);
        AA_C1_K1(iv_c1,:,:)=subdata;
        iv_c1=iv_c1+1;
    elseif class(i,1)==2
        subdata=cnt(pos(i,1):pos(i,1)+(3.5*1000)-1,:);
        AA_C2_K1(iv_c2,:,:)=subdata;
        iv_c2=iv_c2+1;
    end
end

%トレーニングデータをランダムに指定数を抜き出す(train_nel個ずつ)
train_nel = 30;
%配列の事前割り当て
Train_right = zeros(train_nel,size(AA_C1_K1,2),size(AA_C1_K1,3));
Train_foot = zeros(train_nel,size(AA_C2_K1,2),size(AA_C2_K1,3));
%ランダムにデータを抜き出す際の指定するインデックス配列を作成
random_index_right = randperm(iv_c1-1,train_nel);
random_index_foot = randperm(iv_c2-1,train_nel);
for i=1:train_nel
    Train_right(i,:,:) = AA_C1_K1(random_index_right(i),:,:);
    Train_foot(i,:,:) = AA_C2_K1(random_index_foot(i),:,:);
end

%配列の事前割り当て
Right = zeros(train_nel,size(AA_C1_K1,3),size(AA_C1_K1,2));
Foot = zeros(train_nel,size(AA_C2_K1,3),size(AA_C2_K1,2));

%行と列の入れ替え
for i=1:train_nel
    temp=Train_right(i,:,:);
    temp=squeeze(temp);
    Right(i,:,:)=temp.';
end

for i=1:train_nel
    temp=Train_foot(i,:,:);
    temp=squeeze(temp);
    Foot(i,:,:)=temp.';
end

%データの次元数を減らして横並びに結合したもの
for i=1:train_nel
    if i==1
        matrix_right=squeeze(Right(i,:,:));
    else
        matrix_right=horzcat(matrix_right,squeeze(Right(i,:,:)));
    end
end

for i=1:train_nel
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
for i=1:train_nel
    temp_C1=squeeze(Right(i,:,:));
    temp_C2=squeeze(Foot(i,:,:));
    Right_CSP_K1(c1,:,:) = W*temp_C1;
    Foot_CSP_K1(c2,:,:) = W*temp_C2;
    c1 = c1 + 1;
    c2 = c2 + 1;
end

%分散を計算して特徴ベクトルの導出
for i=1:train_nel
   temp_C1=squeeze(Right_CSP_K1(i,:,:));
   Var1=var(temp_C1,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_right_K1(i,:,:)=log(Var1/sum(Var1));
end
for i=1:train_nel
   temp_C2=squeeze(Foot_CSP_K1(i,:,:));
   Var2=var(temp_C2,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_foot_K1(i,:,:)=log(Var2/sum(Var2));
end

writematrix(feat_right_K1,'feat_4a_1000Hz_30_3/feat_right_aw_30.txt')
writematrix(feat_foot_K1,'feat_4a_1000Hz_30_3/feat_foot_aw_30.txt')