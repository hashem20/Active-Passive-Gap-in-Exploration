clear all;
load('/Users/hashem/Desktop/RT-AC_for_between_and_within/ordereffect_plm.mat')

y = [a_active1(:,1)' p_active1(:,1)' a_passive1(:,1)' p_passive1(:,1)' a_active1(:,2)' p_active1(:,2)' a_passive1(:,2)' p_passive1(:,2)'];
for i=1:136
    h(i)= 1;
end
for i=137:272
    h(i)= 6;
end
for i=1:35
    AP (i) = 1;
    ord (i) = 1;
    sub (i) = i;
end
for i=36:70
    AP (i) = 2;
    ord (i) = 1;
    sub (i) = i-35;
end
for i=71:103
    AP (i) = 1;
    ord (i) = 2;
    sub (i) = i-35;
end
for i=104:136
    AP (i) = 2;
    ord (i) = 2;
    sub (i) = i-68;
end
for i=137:171
    AP (i) = 1;
    ord (i) = 1;
    sub (i) = i-136;
end
for i=172:206
    AP (i) = 2;
    ord (i) = 1;
    sub (i) = i-171;
end
for i=207:239
    AP (i) = 1;
    ord (i) = 2;
    sub (i) = i-171;
end
for i=240:272
    AP (i) = 2;
    ord (i) = 2;
    sub (i) = i-204;
end
[p,tbl,stats,terms] = anovan(y,{sub, h, AP, ord}, 'model', [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1; 0 1 1 1; 0 1 1 0; 0 1 0 1; 0 0 1 1], 'varnames',{'subject', 'horizon','AP', 'order'}, 'nested', [0 0 0 1; 0 0 0 0; 0 0 0 0; 0 0 0 0],'random', 1) %[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1; 0 1 1 0]
%%
[H,P,CI,STATS] = ttest2 (a_active1(:,1), a_passive1(:,1))
%%
[H,P,CI,STATS] = ttest2 (p_active1(:,1), p_passive1(:,1)) 
%%
[H,P,CI,STATS] = ttest2 (a_active1(:,2), a_passive1(:,2))
%%
[H,P,CI,STATS] = ttest2 (p_active1(:,2), p_passive1(:,2))
