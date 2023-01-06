clear all;
S = load('data_set_4a_aa.mat');
cnt = S.cnt;
pos = S.mrk.pos.';
class = S.mrk.y.';
cnt= 0.1*double(cnt);
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

%トレーニングデータを抜き出す(40個ずつ)
train_nel = 40;
Train_C1 = AA_C1_K1(1:train_nel,:,:);
Train_C2 = AA_C2_K1(1:train_nel,:,:);


%行と列の入れ替え
for i=1:train_nel
    temp=Train_C1(i,:,:);
    temp=squeeze(temp);
    C1(i,:,:)=temp.';
end

for i=1:train_nel
    temp=Train_C2(i,:,:);
    temp=squeeze(temp);
    C2(i,:,:)=temp.';
end

%データの次元数を減らして横並びに結合したもの
for i=1:train_nel
    if i==1
        matrix_C1=squeeze(C1(i,:,:));
    else
        matrix_C1=horzcat(matrix_C1,squeeze(C1(i,:,:)));
    end
end

for i=1:train_nel
    if i==1
        matrix_C2=squeeze(C2(i,:,:));
    else
        matrix_C2=horzcat(matrix_C2,squeeze(C2(i,:,:)));
    end
end

%データを一回の試行ずつフィルタリングした場合
c1=1; c2=1;
[W,l,A] = csp(matrix_C1,matrix_C2);
W(3:116,:)=[];
for i=1:train_nel
    temp_C1=squeeze(C1(i,:,:));
    temp_C2=squeeze(C2(i,:,:));
    C1_CSP_K1(c1,:,:) = W*temp_C1;
    C2_CSP_K1(c2,:,:) = W*temp_C2;
    c1 = c1 + 1;
    c2 = c2 + 1;
end

%分散を計算して特徴ベクトルの導出
for i=1:train_nel
   temp_C1=squeeze(C1_CSP_K1(i,:,:));
   Var1=var(temp_C1,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_C1_K1(i,:,:)=log(Var1/sum(Var1));
end
for i=1:train_nel
   temp_C2=squeeze(C2_CSP_K1(i,:,:));
   Var2=var(temp_C2,1,2);
   %第三要素が行か列のどちら方向に計算するか参照している
   feat_C2_K1(i,:,:)=log(Var2/sum(Var2));
end

writematrix(feat_C1_K1,"feat_r.txt");
writematrix(feat_C2_K1,"feat_foot.txt");