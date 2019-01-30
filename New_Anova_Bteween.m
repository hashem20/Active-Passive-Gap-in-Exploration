clear all; clc;
All = load('/Users/hashem/Desktop/data_allbetween_2.mat');
t = 0;
u = 0;
for i =1:length(All.d.subjectID)
    if All.d.isactive(i) == 1
        t = t+1;
        Between_Active(t, 1) = All.d.hi1(i); Between_Active(t, 2) = All.d.hi6(i); 
        Between_Active(t, 3) = All.d.lm1(i); Between_Active(t, 4) = All.d.lm6(i);
        Between_Active(t, 5) = All.d.ac1(i); Between_Active(t, 6) = All.d.ac6(i);
        Between_Active(t, 7) = All.d.RT1(i); Between_Active(t, 8) = All.d.RT6(i);
        active_ac6 (t,1:6) = All.d.ac6(i,1:6);
        active_RT6 (t,1:6) = All.d.RT6(i,1:6);
    elseif All.d.exp(i) ~= "Horizon___AU15F_060_infinite" & All.d.exp(i) ~= "Horizon___AU15F_042_testretest"
        u= u+1;
        Between_Passive(u, 1) = All.d.hi1(i); Between_Passive(u, 2) = All.d.hi6(i); 
        Between_Passive(u, 3) = All.d.lm1(i); Between_Passive(u, 4) = All.d.lm6(i); 
        Between_Passive(u, 5) = All.d.ac1(i); Between_Passive(u, 6) = All.d.ac6(i); 
        Between_Passive(u, 7) = All.d.RT1(i); Between_Passive(u, 8) = All.d.RT6(i);
        passive_ac6 (u,1:6) = All.d.ac6(i,1:6);
        passive_RT6 (u, 1:6) = All.d.RT6(i,1:6);
    end
end
% Ac = .5
for i=1:length(Between_Passive)
    AC_p(i,1) = .5;
end
for i=1:length(Between_Active)
    AC_a(i,1) = .5;
end
%% t-test against ac=.5 in between_passive_79: h1)
[H,P,CI,STATS]=ttest(Between_Passive(:,5), AC_p(:,1))
%% t-test against ac=.5 in between_passive_79: h6)
[H,P,CI,STATS]=ttest(Between_Passive(:,6), AC_p(:,1))
%% t-test against ac=.5 in between_active_292: h1)
[H,P,CI,STATS]=ttest(Between_Active(:,5), AC_a(:,1))
%% t-test against ac=.5 in between_active_292: h6)
[H,P,CI,STATS]=ttest(Between_Active(:,6), AC_a(:,1))
%% 2-sided t-test between active ac_h1 & passive ac_h1
[H,P,CI,STATS]=ttest2(Between_Active(:,5), Between_Passive(:,5))
%% 2-sided t-test between active ac_h6_trial 5 & passive ac_h6_trial 5
[H,P,CI,STATS]=ttest2(Between_Active(:,6), Between_Passive(:,6))
%% 2-sided t-test between active RT_h1 & passive RT_h1
[H,P,CI,STATS]=ttest2(Between_Active(:,7), Between_Passive(:,7))
%% 2-sided t-test between active phi_h1 & passive phi_h1
[H,P,CI,STATS]=ttest2(Between_Active(:,1), Between_Passive(:,1))
%% 2-sided t-test between active phi_h6 & passive phi_h6
[H,P,CI,STATS]=ttest2(Between_Active(:,2), Between_Passive(:,2))
%% paired t-test: horizon-based change in phi in active condition (292)
[H,P,CI,STATS]=ttest(Between_Active(:,1), Between_Active(:,2))
%% horizon-based change in phi in passive conditionn(79)
[H,P,CI,STATS]=ttest(Between_Passive(:,1), Between_Passive(:,2))
%% 2-sided t-test between active plm_h1 & passive plm_h1
[H,P,CI,STATS]=ttest2(Between_Active(:,3), Between_Passive(:,3))
%% 2-sided t-test between active plm_h6 & passive plm_h6
[H,P,CI,STATS]=ttest2(Between_Active(:,4), Between_Passive(:,4))
%% horizon-based change in plm in active condition (292)
[H,P,CI,STATS]=ttest(Between_Active(:,3), Between_Active(:,4))
%% horizon-based change in plm in passive conditionn(79)
[H,P,CI,STATS]=ttest(Between_Passive(:,3), Between_Passive(:,4))
%% anova phi - horizon and AP factors
y = [Between_Active(:,1)' Between_Passive(:,1)' Between_Active(:,2)' Between_Passive(:,2)'];
for i=1:371
    horizon (i) = 1;
    sub (i) = i;
end
for i=372:742
    horizon (i) = 6;
    sub (i) = i-371;
end
for i=1:292
    AP (i) = 1;
end
for i=293:371
    AP (i) = 2;
end
for i=372:663
    AP (i) = 1;
end
for i=664:742
    AP (i) = 2;
end
[p,tbl,stats,terms] = anovan(y,{sub, horizon, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'horizon','AP'},'random', 1, 'nested', [0 0 1; 0 0 0; 0 0 0])
%% anova plm - horizon and AP factors
y = [Between_Active(:,3)' Between_Passive(:,3)' Between_Active(:,4)' Between_Passive(:,4)'];
for i=1:371
    horizon (i) = 1;
    sub (i) = i;
end
for i=372:742
    horizon (i) = 6;
    sub (i) = i-371;
end
for i=1:292
    AP (i) = 1;
end
for i=293:371
    AP (i) = 2;
end
for i=372:663
    AP (i) = 1;
end
for i=664:742
    AP (i) = 2;
end
[p,tbl,stats,terms] = anovan(y,{sub, horizon, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'horizon','AP'},'random', 1, 'nested', [0 0 1; 0 0 0; 0 0 0])

%% Anova-Accuracy-between_h6
y = [active_ac6(:,1)' active_ac6(:,2)' active_ac6(:,3)' active_ac6(:,4)' active_ac6(:,5)' active_ac6(:,6)' passive_ac6(:,1)' passive_ac6(:,2)' passive_ac6(:,3)' passive_ac6(:,4)' passive_ac6(:,5)' passive_ac6(:,6)'];
for i=1:1752
    AP (i) = 1;
end
for i=1753:2226
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
for i=1753:1831
    trial(i) = 1;
    sub (i) = i-1460;
end
for i=1832:1910
    trial(i) = 2;
    sub (i) = i-1539;
end
for i=1911:1989
    trial(i) = 3;
    sub (i) = i-1618;
end
for i=1990:2068
    trial(i) = 4;
    sub (i) = i-1697;
end
for i=2069:2147
    trial(i) = 5;
    sub (i) = i-1776;
end
for i=2148:2226
    trial(i) = 6;
    sub (i) = i-1855;
end

[p,tbl,stats,terms] = anovan(y,{sub, trial, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'trial','AP'},'random', 1, 'nested', [0 0 1; 0 0 0; 0 0 0])
%% Anova-RT-between_h6
y = [active_RT6(:,1)' active_RT6(:,2)' active_RT6(:,3)' active_RT6(:,4)' active_RT6(:,5)' active_RT6(:,6)' passive_RT6(:,1)' passive_RT6(:,2)' passive_RT6(:,3)' passive_RT6(:,4)' passive_RT6(:,5)' passive_RT6(:,6)'];
for i=1:1752
    AP (i) = 1;
end
for i=1753:2226
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
for i=1753:1831
    trial(i) = 1;
    sub (i) = i-1460;
end
for i=1832:1910
    trial(i) = 2;
    sub (i) = i-1539;
end
for i=1911:1989
    trial(i) = 3;
    sub (i) = i-1618;
end
for i=1990:2068
    trial(i) = 4;
    sub (i) = i-1697;
end
for i=2069:2147
    trial(i) = 5;
    sub (i) = i-1776;
end
for i=2148:2226
    trial(i) = 6;
    sub (i) = i-1855;
end

[p,tbl,stats,terms] = anovan(y,{sub, trial, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'trial','AP'},'random', 1, 'nested', [0 0 1; 0 0 0; 0 0 0])
