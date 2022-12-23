%データの次元数を一つ減らしてまとめてフィルタリングした場合
clear all;
filename = 'A01T.gdf';
[s, HDR] = sload('A01T.gdf',0,'OVERFLOWDETECTION:OFF');
type=HDR.EVENT.TYP;
pos=HDR.EVENT.POS;
dur=HDR.EVENT.DUR;
iv_c1=1; iv_c2=1; iv_c3=1; iv_c4=1;
for i=1:size(type,1)
    if type(i,1)==769
        subdata=s(pos(i,1):pos(i,1)+dur(i,1),:);
        A01T_C1(iv_c1,:,:)=subdata;
        iv_c1=iv_c1+1;
    elseif type(i,1)==770
        subdata=s(pos(i,1):pos(i,1)+dur(i,1),:);
        A01T_C2(iv_c2,:,:)=subdata;
        iv_c2=iv_c2+1;
    elseif type(i,1)==771
        subdata=s(pos(i,1):pos(i,1)+dur(i,1),:);
        A01T_C3(iv_c3,:,:)=subdata;
        iv_c3=iv_c3+1;
     elseif type(i,1)==772
        subdata=s(pos(i,1):pos(i,1)+dur(i,1),:);
        A01T_C4(iv_c4,:,:)=subdata;
        iv_c4=iv_c4+1;
    end
end
%EOGを入れているので削除する

A01T_C1(:,:,23:25)=[];
A01T_C2(:,:,23:25)=[];

%行と列の入れ替え
for i=1:iv_c1-1
    temp=A01T_C1(i,:,:);
    temp=squeeze(temp);
    C1(i,:,:)=temp.';
end

for i=1:iv_c2-1
    temp=A01T_C2(i,:,:);
    temp=squeeze(temp);
    C2(i,:,:)=temp.';
end

%トレーニングデータとテストデータに分ける
train_nel = 60;
Train_C1 = C1(1:train_nel+1,:,:);
Test_C1 = C1(train_nel+1:iv_c1-1,:,:);
Train_C2 = C2(1:train_nel+1,:,:);
Test_C2 = C2(train_nel+1:iv_c2-1,:,:);


%データの次元数を減らして横並びに結合したもの
for i=1:train_nel
    if i==1
        matrix_C1=squeeze(Train_C1(i,:,:));
    else
        matrix_C1=horzcat(matrix_C1,squeeze(Train_C1(i,:,:)));
    end
end

for i=1:train_nel
    if i==1
        matrix_C2=squeeze(Train_C2(i,:,:));
    else
        matrix_C2=horzcat(matrix_C2,squeeze(Train_C2(i,:,:)));
    end
end

%データを一回の試行ずつフィルタリングした場合
c1=1; c2=1;
for i=1:train_nel
    temp_C1=squeeze(Train_C1(i,:,:));
    temp_C2=squeeze(Train_C2(i,:,:));
    [W,l,A] = csp(matrix_C1,matrix_C2);
    W(3:20,:)=[];
    C1_CSP(c1,:,:) = W*temp_C1;
    C2_CSP(c2,:,:) = W*temp_C2;
    c1 = c1 + 1;
    c2 = c2 + 1;
end

for i=1:iv_c1-train_nel-1
    temp_C1=squeeze(Test_C1(i,:,:));
    temp_C2=squeeze(Test_C2(i,:,:));
    C1_Test_CSP(i,:,:) = W*temp_C1;
    C2_Test_CSP(i,:,:) = W*temp_C2;
end

%分散を計算して特徴ベクトルの導出
for i=1:train_nel
   temp_C1=squeeze(C1_CSP(i,:,:));
   Var1=var(temp_C1,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_C1(i,:,:)=log(Var1/sum(Var1));
end
for i=1:train_nel
   temp_C2=squeeze(C2_CSP(i,:,:));
   Var2=var(temp_C2,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_C2(i,:,:)=log(Var2/sum(Var2));
end

for i=1:iv_c1-train_nel-1
   temp_C1=squeeze(C1_Test_CSP(i,:,:));
   Var1=var(temp_C1,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_Test_C1(i,:,:)=log(Var1/sum(Var1));
end
for i=1:iv_c2-train_nel-1
   temp_C2=squeeze(C2_Test_CSP(i,:,:));
   Var2=var(temp_C2,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_Test_C2(i,:,:)=log(Var2/sum(Var2));
end

%特徴ベクトルを横並びに結合したもの
feat=cat(1,feat_C1,feat_C2);
Trainlabels = zeros(120,1);
Trainlabels(1:61,1) = 1;
Trainlabels(61:120,1) = 2;
[predictions,src_scores]=src(feat,Trainlabels,feat_Test_C2,0.3);