clear all;
filename = 'A01T.gdf';
[s, HDR] = sload('A01T.gdf');
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

%行と列の入れ替え
for i=1:iv_c1-1
    temp=A01T_C1(i,:,:);
    temp=squeeze(temp);
    C1(i,:,:)=temp.';
end

for i=1:iv_c2-1
    temp=A01T_C2(i);
    temp=squeeze(temp);
    C2(i,:,:)=temp.';
end

%データを一回の試行ずつフィルタリングした場合
c1=1; c2=1;
for i=1:iv_c1-1
    temp_C1=squeeze(C1(i,:,:));
    temp_C2=squeeze(C2(i,:,:));
    [W,l,A] = csp(temp_C1,temp_C2);
    C1_CSP(c1,:,:) = W.'*temp_C1;
    C2_CSP(c2,:,:) = W.'*temp_C2;
    c1 = c1 + 1;
    c2 = c2 + 1;
end

%分散を計算して特徴ベクトルの導出


