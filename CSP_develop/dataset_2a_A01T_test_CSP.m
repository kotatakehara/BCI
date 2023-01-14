%データの次元数を一つ減らしてまとめてフィルタリングした場合
clear all;
filename = 'A01T.gdf';
[s, HDR] = sload('A01T.gdf',0,'OVERFLOWDETECTION:OFF');
type=HDR.EVENT.TYP;
pos=HDR.EVENT.POS;
dur=HDR.EVENT.DUR;
iv_c1=1; iv_c2=1; 
s = bandpass(s,[8 15],250);
i = 1;
while i <= size(type,1)
    %アーティファクト認定されたデータは省く
    if type(i,1) == 1023
        i = i + 1;
    elseif type(i,1)==769
        subdata=s(pos(i,1):pos(i,1)+dur(i,1),:);
        A01T_left(iv_c1,:,:)=subdata;
        iv_c1=iv_c1+1;
    elseif type(i,1)==770
        subdata=s(pos(i,1):pos(i,1)+dur(i,1),:);
        A01T_right(iv_c2,:,:)=subdata;
        iv_c2=iv_c2+1;
    end
    i = i + 1;
end
%EOGを入れているので削除する
A01T_left(:,:,23:25)=[];
A01T_right(:,:,23:25)=[];
%トレーニングデータをランダムに指定数を抜き出す(train_nel個ずつ)
train_nel = 20;
%配列の事前割り当て
Train_left = zeros(train_nel,size(A01T_left,2),size(A01T_left,3));
Train_right = zeros(train_nel,size(A01T_right,2),size(A01T_right,3));
test_nel = 40;
Test_left = zeros(test_nel,size(A01T_left,2),size(A01T_left,3));
Test_right = zeros(test_nel,size(A01T_right,2),size(A01T_right,3));

for i=1:train_nel
    Train_left(i,:,:) = A01T_left(i,:,:);
    Train_right(i,:,:) = A01T_right(i,:,:);
end
for i=1:test_nel
    Test_left(i,:,:) = A01T_left(i+train_nel,:,:);
    Test_right(i,:,:) = A01T_right(i+train_nel,:,:);
end

%行と列の入れ替え
for i=1:train_nel
    temp=Train_left(i,:,:);
    temp=squeeze(temp);
    left(i,:,:)=temp.';
    temp=Train_right(i,:,:);
    temp=squeeze(temp);
    right(i,:,:)=temp.';
end

for i=1:test_nel
    temp=Test_left(i,:,:);
    temp=squeeze(temp);
    test_left(i,:,:)=temp.';
    temp=Test_right(i,:,:);
    temp=squeeze(temp);
    test_right(i,:,:)=temp.';
end

%データの次元数を減らして横並びに結合したもの
for i=1:train_nel
    if i==1
        matrix_left=squeeze(left(i,:,:));
    else
        matrix_left=horzcat(matrix_left,squeeze(left(i,:,:)));
    end
end

for i=1:train_nel
    if i==1
        matrix_right=squeeze(right(i,:,:));
    else
        matrix_right=horzcat(matrix_right,squeeze(right(i,:,:)));
    end
end


%データを一回の試行ずつフィルタリングした場合
c1=1; c2=1;
for i=1:train_nel
    temp_C1=squeeze(left(i,:,:));
    temp_C2=squeeze(right(i,:,:));
    [W,l,A] = csp(matrix_left,matrix_right);
    W(3:20,:)=[];
    C1_CSP(c1,:,:) = W*temp_C1;
    C2_CSP(c2,:,:) = W*temp_C2;
    c1 = c1 + 1;
    c2 = c2 + 1;
end
writematrix(W,'W_A01T.txt')
%分散を計算して特徴ベクトルの導出
for i=1:train_nel
   temp_C1=squeeze(C1_CSP(i,:,:));
   Var1=var(temp_C1,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_left(i,:,:)=log(Var1/sum(Var1));
end
for i=1:train_nel
   temp_C2=squeeze(C2_CSP(i,:,:));
   Var2=var(temp_C2,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_right(i,:,:)=log(Var2/sum(Var2));
end
for i=1:test_nel
    temp_C1=squeeze(test_left(i,:,:));
    temp_C2=squeeze(test_right(i,:,:));
    temp_C1 = W*temp_C1;
    temp_C2 = W*temp_C2;
    Var1=var(temp_C1,1,2);
    Var2=var(temp_C2,1,2);
    feat_test_left(i,:,:)=log(Var1/sum(Var1));
    feat_test_right(i,:,:)=log(Var2/sum(Var2));

end
writematrix(feat_left,'feat_left_A01T.txt')
writematrix(feat_right,'feat_right_A01T.txt')
writematrix(feat_test_left,'feat_test_left_A01T.txt')
writematrix(feat_test_right,'feat_test_right_A01T.txt')
