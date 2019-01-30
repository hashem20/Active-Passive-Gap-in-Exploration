clear all;
active_all = load('/Users/hashem/Desktop/RT-AC_for_between_and_within/active_all_latertrials.mat')
passive_all = load('/Users/hashem/Desktop/RT-AC_for_between_and_within/passive_all_latertrials.mat')
active_019 = load('/Users/hashem/Desktop/RT-AC_for_between_and_within/active_019_latertrials.mat')
passive_019 = load('/Users/hashem/Desktop/RT-AC_for_between_and_within/passive_019_latertrials.mat')
RT_all_active = load('/Users/hashem/Desktop/RT-AC_for_between_and_within/RT_all_new.mat')
RT_all_passive = load('/Users/hashem/Desktop/RT-AC_for_between_and_within/RT_all_passive.mat')
%% ttest-Acuracy-between
[H,P,CI,STATS]=ttest2(active_all.ac1(:,5), passive_all.ac1(:,5))
[H,P,CI,STATS]=ttest2(active_all.ac6(:,5), passive_all.ac6(:,5)) %1st free trial
[H,P,CI,STATS]=ttest2(active_all.ac6(:,6), passive_all.ac6(:,6)) %2nd free trial
[H,P,CI,STATS]=ttest(passive_all.ac6(:,5), passive_all.ac6(:,6))
%% ttest-Acuracy-within
[H,P,CI,STATS]=ttest(active_019.ac1(:,5), passive_019.ac1(:,5))
[H,P,CI,STATS]=ttest(active_019.ac6(:,5), passive_019.ac6(:,5)) %1st free trial
[H,P,CI,STATS]=ttest(active_019.ac6(:,6), passive_019.ac6(:,6)) %2nd free trial
[H,P,CI,STATS]=ttest(passive_019.ac6(:,5), passive_019.ac6(:,6))
%% ttest-RT-between
[H,P,CI,STATS]=ttest2(RT_all_active.RT1(:,5), RT_all_passive.RT1(:,5))
[H,P,CI,STATS]=ttest2(RT_all_active.RT6(:,5), RT_all_passive.RT6(:,5)) %1st free trial
[H,P,CI,STATS]=ttest2(RT_all_active.RT6(:,6), RT_all_passive.RT6(:,6)) %2nd free trial
[H,P,CI,STATS]=ttest(RT_all_passive.RT6(:,5), RT_all_passive.RT6(:,6))
%% ttest-RT-within
[H,P,CI,STATS]=ttest(active_019.RT1(:,5), passive_019.RT1(:,5))
[H,P,CI,STATS]=ttest(active_019.RT6(:,5), passive_019.RT6(:,5)) %1st free trial
[H,P,CI,STATS]=ttest(active_019.RT6(:,6), passive_019.RT6(:,6)) %2nd free trial
[H,P,CI,STATS]=ttest(passive_019.RT6(:,5), passive_019.RT6(:,6))
%% Anova- Accuracy-between
y = [active_all.ac6(:,5)' active_all.ac6(:,6)' active_all.ac6(:,7)' active_all.ac6(:,8)' active_all.ac6(:,9)' active_all.ac6(:,10)' passive_all.ac6(:,5)' passive_all.ac6(:,6)' passive_all.ac6(:,7)' passive_all.ac6(:,8)' passive_all.ac6(:,9)' passive_all.ac6(:,10)'];
for i=1:1752
    AP (i) = 1;
end
for i=1753:3126
    AP (i) = 2;
end
for i=1:292
    trial(i) = 1;
    sub (i) = i;
end
for i=293:584
    trial(i) = 2;
    sub (i) = i-292;
end
for i=585:876
    trial(i) = 3;
    sub (i) = i-584;
end
for i=877:1168
    trial(i) = 4;
    sub (i) = i-876;
end
for i=1169:1460
    trial(i) = 5;
    sub (i) = i-1168;
end
for i=1461:1752
    trial(i) = 6;
    sub (i) = i-1460;
end
for i=1753:1981
    trial(i) = 1;
    sub (i) = i-1460;
end
for i=1982:2210
    trial(i) = 2;
    sub (i) = i-1689;
end
for i=2211:2439
    trial(i) = 3;
    sub (i) = i-1918;
end
for i=2440:2668
    trial(i) = 4;
    sub (i) = i-2147;
end
for i=2669:2897
    trial(i) = 5;
    sub (i) = i-2376;
end
for i=2898:3126
    trial(i) = 6;
    sub (i) = i-2605;
end

[p,tbl,stats,terms] = anovan(y,{sub, trial, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'trial','AP'},'random', 1, 'nested', [0 0 1; 0 0 0; 0 0 0])

%% Anova- Accuracy-within
y = [active_019.ac6(:,5)' active_019.ac6(:,6)' active_019.ac6(:,7)' active_019.ac6(:,8)' active_019.ac6(:,9)' active_019.ac6(:,10)' passive_019.ac6(:,5)' passive_019.ac6(:,6)' passive_019.ac6(:,7)' passive_019.ac6(:,8)' passive_019.ac6(:,9)' passive_019.ac6(:,10)'];
for i=1:408
    AP (i) = 1;
end
for i=409:816
    AP (i) = 2;
end
for i=1:68
    trial(i) = 1;
    sub (i) = i;
end
for i=69:136
    trial(i) = 2;
    sub (i) = i-68;
end
for i=137:204
    trial(i) = 3;
    sub (i) = i-136;
end
for i=205:272
    trial(i) = 4;
    sub (i) = i-204;
end
for i=273:340
    trial(i) = 5;
    sub (i) = i-272;
end
for i=341:408
    trial(i) = 6;
    sub (i) = i-340;
end
for i=409:476
    trial(i) = 1;
    sub (i) = i-408;
end
for i=477:544
    trial(i) = 2;
    sub (i) = i-476;
end
for i=545:612
    trial(i) = 3;
    sub (i) = i-544;
end
for i=613:680
    trial(i) = 4;
    sub (i) = i-612;
end
for i=681:748
    trial(i) = 5;
    sub (i) = i-680;
end
for i=749:816
    trial(i) = 6;
    sub (i) = i-748;
end

[p,tbl,stats,terms] = anovan(y,{sub, trial, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'trial','AP'},'random', 1)
%% Anova- Accuracy-within Just laters
y = [active_019.ac6(:,6)' active_019.ac6(:,7)' active_019.ac6(:,8)' active_019.ac6(:,9)' active_019.ac6(:,10)' passive_019.ac6(:,6)' passive_019.ac6(:,7)' passive_019.ac6(:,8)' passive_019.ac6(:,9)' passive_019.ac6(:,10)'];
for i=1:340
    AP (i) = 1;
end
for i=341:680
    AP (i) = 2;
end
for i=1:68
    trial(i) = 2;
    sub (i) = i;
end
for i=69:136
    trial(i) = 3;
    sub (i) = i-68;
end
for i=137:204
    trial(i) = 4;
    sub (i) = i-136;
end
for i=205:272
    trial(i) = 5;
    sub (i) = i-204;
end
for i=273:340
    trial(i) = 6;
    sub (i) = i-272;
end
for i=341:408
    trial(i) = 2;
    sub (i) = i-340;
end
for i=409:476
    trial(i) = 3;
    sub (i) = i-408;
end
for i=477:544
    trial(i) = 4;
    sub (i) = i-476;
end
for i=545:612
    trial(i) = 5;
    sub (i) = i-544;
end
for i=613:680
    trial(i) = 6;
    sub (i) = i-612;
end

[p,tbl,stats,terms] = anovan(y,{sub, trial, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'trial','AP'},'random', 1)

%% Anova- RT-between
y = [RT_all_active.RT6(:,5)' RT_all_active.RT6(:,6)' RT_all_active.RT6(:,7)' RT_all_active.RT6(:,8)' RT_all_active.RT6(:,9)' RT_all_active.RT6(:,10)' RT_all_passive.RT6(:,5)' RT_all_passive.RT6(:,6)' RT_all_passive.RT6(:,7)' RT_all_passive.RT6(:,8)' RT_all_passive.RT6(:,9)' RT_all_passive.RT6(:,10)'];
for i=1:1752
    AP (i) = 1;
end
for i=1753:3126
    AP (i) = 2;
end
for i=1:292
    trial(i) = 1;
    sub (i) = i;
end
for i=293:584
    trial(i) = 2;
    sub (i) = i-292;
end
for i=585:876
    trial(i) = 3;
    sub (i) = i-584;
end
for i=877:1168
    trial(i) = 4;
    sub (i) = i-876;
end
for i=1169:1460
    trial(i) = 5;
    sub (i) = i-1168;
end
for i=1461:1752
    trial(i) = 6;
    sub (i) = i-1460;
end
for i=1753:1981
    trial(i) = 1;
    sub (i) = i-1460;
end
for i=1982:2210
    trial(i) = 2;
    sub (i) = i-1689;
end
for i=2211:2439
    trial(i) = 3;
    sub (i) = i-1918;
end
for i=2440:2668
    trial(i) = 4;
    sub (i) = i-2147;
end
for i=2669:2897
    trial(i) = 5;
    sub (i) = i-2376;
end
for i=2898:3126
    trial(i) = 6;
    sub (i) = i-2605;
end

[p,tbl,stats,terms] = anovan(y,{sub, trial, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'trial','AP'},'random', 1, 'nested', [0 0 1; 0 0 0; 0 0 0])

%% Anova- RT-within
y = [active_019.RT6(:,5)' active_019.RT6(:,6)' active_019.RT6(:,7)' active_019.RT6(:,8)' active_019.RT6(:,9)' active_019.RT6(:,10)' passive_019.RT6(:,5)' passive_019.RT6(:,6)' passive_019.RT6(:,7)' passive_019.RT6(:,8)' passive_019.RT6(:,9)' passive_019.RT6(:,10)'];
for i=1:408
    AP (i) = 1;
end
for i=409:816
    AP (i) = 2;
end
for i=1:68
    trial(i) = 1;
    sub (i) = i;
end
for i=69:136
    trial(i) = 2;
    sub (i) = i-68;
end
for i=137:204
    trial(i) = 3;
    sub (i) = i-136;
end
for i=205:272
    trial(i) = 4;
    sub (i) = i-204;
end
for i=273:340
    trial(i) = 5;
    sub (i) = i-272;
end
for i=341:408
    trial(i) = 6;
    sub (i) = i-340;
end
for i=409:476
    trial(i) = 1;
    sub (i) = i-408;
end
for i=477:544
    trial(i) = 2;
    sub (i) = i-476;
end
for i=545:612
    trial(i) = 3;
    sub (i) = i-544;
end
for i=613:680
    trial(i) = 4;
    sub (i) = i-612;
end
for i=681:748
    trial(i) = 5;
    sub (i) = i-680;
end
for i=749:816
    trial(i) = 6;
    sub (i) = i-748;
end

[p,tbl,stats,terms] = anovan(y,{sub, trial, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'trial','AP'},'random', 1)

    