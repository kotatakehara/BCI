clear all;
S = load('data_set_IVa_aa.mat');
cnt = S.cnt;
pos = S.mrk.pos.';
class = S.mrk.y.';
cnt= 0.1*double(cnt);
save('data_4a_aa.mat','cnt','-v7.3')
[s, HDR] = sload('data_4a_aa_after.gdf',0,'OVERFLOWDETECTION:OFF');