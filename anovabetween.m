clear
xxx = load('/Users/hashem/Desktop/paper-results-task/data_lm.mat')
yyy = load('/Users/hashem/Desktop/paper-results-task/data_hi.mat')
y = [data{1}(:,1)' data{2}(:,1)' data{1}(:,2)' data{2}(:,2)'];
for i=1:521
    horizon (i) = 1;
    sub (i) = i;
end
for i=522:1042
    horizon (i) = 6;
    sub (i) = i-521;
end
for i=1:292
    AP (i) = 1
end
for i=293:521
    AP (i) = 2
end
for i=522:813
    AP (i) = 1
end
for i=814:1042
    AP (i) = 2
end
[p,tbl,stats,terms] = anovan(y,{sub, horizon, AP}, 'model', [1 0 0; 0 1 0; 0 0 1; 0 1 1], 'varnames',{'subject', 'horizon','AP'},'random', 1, 'nested', [0 0 1; 0 0 0; 0 0 0])
