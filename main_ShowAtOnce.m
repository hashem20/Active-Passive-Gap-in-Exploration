%% initialize;
clear all, clc;
projectname = 'AU_019_PvsA_RP_M';
path.result = pwd;
for i = 1:2
    d{i} = importdata(['DATA_',projectname,'_',num2str(i),'.mat']);
end
temp = d{1}.basic.sublist' == d{2}.basic.sublist;
indcommon{1} = sum(temp,2)' == 1;
indcommon{2} = sum(temp,1) == 1;
for i = 1:2
    tind = indcommon{i};
    nind = 1:length(tind);
    ncommon = sum(indcommon{i});
    subcommon{i} = nind(tind);
end
Cond{1} = 'Active';
Cond{2} = 'Passive';
for i = 1:2
    disp(sprintf('%s: total participants = %d, who did both = %d', Cond{i}, d{i}.basic.n_sub, sum(indcommon{i})));
end
%% load
thres = 0.55;
for i = 1:2
    analyzer{i} = analysis_dataset(d{i}.data, path, [projectname '_' num2str(i)]);
    analyzer{i}.exclude(thres);
end
for i = 1:2
    te{i} = analyzer{i}.ind_sub(subcommon{i});
end
tecommon = te{1} & te{2};
for i = 1:2
    disp(sprintf('%s: after exclusion = %d, who did both = %d, pass at both = %d', Cond{i}, sum(analyzer{i}.ind_sub), sum(te{i}), sum(tecommon)));
end
for i = 1:2
    indcommon{i}(indcommon{i} == 1) = 0;
    indcommon{i}(subcommon{i}(tecommon)) = 1;
    analyzer{i}.ind_sub = analyzer{i}.ind_sub & indcommon{i};
    analyzer{i}.behavior.ind = analyzer{i}.ind_sub;
%     disp(sprintf('%s sanity check: pass at both = %d', Cond{i}, sum(analyzer{i}.ind_sub)));
end
%%
sw.behavior = 1;
sw.MLE = 0;
sw.bayesian = 0;
for i = 1:2
    analyzer{i}.process(sw);
end