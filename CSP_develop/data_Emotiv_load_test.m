clear all;
data = readmatrix('BCI_data_me/Psychopy_kota_test_2023-01-19T155010.129380_EPOCFLEX_135254_2023.01.19T15.50.09+09.00.csv');
event = readmatrix('BCI_data_me/Psychopy_kota_test_2023-01-19T155010.129380_EPOCFLEX_135254_2023.01.19T15.50.09+09.00_intervalMarker.csv');
type = readtable('BCI_data_me/event_type.csv');
type = table2array(type);
event_timestamp = event(:,6);
iv_c1 = 1;
iv_c2 = 1;
eeg_data = bandpass(data(:,5:9),[8 15],128);
for i=1:size(event_timestamp,1)
    %下の式でtimestampと同意なindexを格納
    index = find(data(:,1) == event_timestamp(i,1));
    if type(i,1) == "left"
        subdata=eeg_data(index:index+(2*128)-1,:);
        AA_C1_K1(iv_c1,:,:)=subdata;
        iv_c1 = iv_c1+1;
    elseif type(i,1) == "right"
        subdata=eeg_data(index:index+(2*128)-1,:);
        AA_C2_K1(iv_c2,:,:)=subdata;
        iv_c2 = iv_c2+1;
    end
end
%トレーニングデータをランダムに指定数を抜き出す(train_nel個ずつ)
train_nel = 20;
%配列の事前割り当て
Train_left = zeros(train_nel,size(AA_C1_K1,2),size(AA_C1_K1,3));
Train_right = zeros(train_nel,size(AA_C2_K1,2),size(AA_C2_K1,3));
test_nel = 40;
Test_left = zeros(test_nel,size(AA_C1_K1,2),size(AA_C1_K1,3));
Test_right = zeros(test_nel,size(AA_C2_K1,2),size(AA_C2_K1,3));
for i=1:train_nel
    Train_left(i,:,:) = AA_C1_K1(i,:,:);
    Train_right(i,:,:) = AA_C2_K1(i,:,:);
end
for i=1:test_nel
    Test_left(i,:,:) = AA_C1_K1(i+train_nel,:,:);
    Test_right(i,:,:) = AA_C2_K1(i+train_nel,:,:);
end

%配列の事前割り当て
Left = zeros(train_nel,size(AA_C1_K1,3),size(AA_C1_K1,2));
Right = zeros(train_nel,size(AA_C2_K1,3),size(AA_C2_K1,2));

%行と列の入れ替え
for i=1:train_nel
    temp=Train_left(i,:,:);
    temp=squeeze(temp);
    Left(i,:,:)=temp.';
end

for i=1:train_nel
    temp=Train_right(i,:,:);
    temp=squeeze(temp);
    Right(i,:,:)=temp.';
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
        matrix_left=squeeze(Left(i,:,:));
    else
        matrix_left=horzcat(matrix_left,squeeze(Left(i,:,:)));
    end
end

for i=1:train_nel
    if i==1
        matrix_right=squeeze(Right(i,:,:));
    else
        matrix_right=horzcat(matrix_right,squeeze(Right(i,:,:)));
    end
end

%データを一回の試行ずつフィルタリングした場合
c1=1; c2=1;
[W,l,A] = csp(matrix_left,matrix_right);
W(3:3,:)=[];
for i=1:train_nel
    temp_C1=squeeze(Left(i,:,:));
    temp_C2=squeeze(Right(i,:,:));
    Left_CSP_K1(c1,:,:) = W*temp_C1;
    Right_CSP_K1(c2,:,:) = W*temp_C2;
    c1 = c1 + 1;
    c2 = c2 + 1;
end

%分散を計算して特徴ベクトルの導出
for i=1:train_nel
   temp_C1=squeeze(Left_CSP_K1(i,:,:));
   Var1=var(temp_C1,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_left_K1(i,:,:)=log(Var1/sum(Var1));
end
for i=1:train_nel
   temp_C2=squeeze(Right_CSP_K1(i,:,:));
   Var2=var(temp_C2,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_right_K1(i,:,:)=log(Var2/sum(Var2));
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

writematrix(feat_left_K1,'feat_left_emotiv_K0.txt')
writematrix(feat_right_K1,'feat_right_emotiv_K0.txt')
writematrix(feat_test_left,'feat_test_left_emotiv.txt')
writematrix(feat_test_right,'feat_test_right_emotiv.txt')