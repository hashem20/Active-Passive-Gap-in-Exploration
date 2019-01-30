%% set up path
clear, clc;
datadir = 'C:\Users\Siyu\Google Drive\EXPLOREEXPLOIT\Data\Temporal_Discounting_Experiments\017-Data_Fall2016\data';
savedir = 'C:\Users\Siyu\Google Drive\EXPLOREEXPLOIT\Data';
condnames = 'Exp017';
%% import dataset from 019
[data, basic] = group_EEHorizon(datadir,[100:300],'P017_horizontask*','_sub','_',[1 3]);
save(fullfile(savedir,'EEHorizon_017_raw_unprocessed.mat'), 'data','basic');
%% add gID
clearvars -except datadir savedir condnames, clc;
load(fullfile(savedir,'EEHorizon_017_raw_unprocessed.mat'));
dataobj = analysis_group(data);
dataobj.get_repeatedtrials;
data = dataobj.dataset;
basic.n_repeated = cellfun(@(x)sum(x.gID > 0)/2, data);
basic.n_single = cellfun(@(x)sum(x.gID < 0), data);
save(fullfile(savedir,'EEHorizon_017.mat'), 'data','basic');
%% performance
clearvars -except datadir savedir condnames, clc;
load(fullfile(savedir,'EEHorizon_017.mat'));
dataobj = analysis_group(data);
ac = dataobj.ac.ac10;
%% exclude using the same threshold and select participants that did well in both sections
thres = 0.6;
dataobj.select(thres);
ind = dataobj.ind;
data = data(ind);
basic.n_sub = sum(ind);
basic.sublist = basic.sublist(ind);
save(fullfile(savedir,sprintf('EEHorizon_017_filteredat%d.mat',round(thres*100))), 'data','basic');
%% horizon effect in exploration
clearvars -except savedir condnames, clc;
thres = 0.6;
load(fullfile(savedir,sprintf('EEHorizon_017_filteredat%d.mat',round(thres*100))));
path.figs = './Figs/017';
if ~exist(path.figs)
    mkdir(path.figs);
end
dataobj = analysis_group(data);
dataobj.set_path(path);
%% get modelfree measure
dataobj.compare_modelfree;
%% compare between conditions
de(:,1:2) = dataobj.modelfree.p_hi;
re(:,1:2) = dataobj.modelfree.p_lm;
da(:,1:2) = dataobj.modelfree.p_da;
%% load color
load('UA_colors.mat');
%% Main result
%% Direct Exploration
xlim = [0.5 2.5];
ylim = [0.3 0.7];
linw = 8;
rect = [0.4 0.1 0.5 0.9];
leg = condnames;
[ge,pp] = lineplot([de(:,1)],[de(:,2)],'horizon', 'p(high info)',...
 'Direct exploration', leg,[blue], linw, xlim, ylim, rect);
set(gca,'XTick',[1 2],'XTickLabel',{'1','6'});
ge{1}.CapSize = 20;
ge{2}.CapSize = 20;
set(gca,'FontSize',30,'FontWeight','Bold');
%% Random Exploration
xlim = [0.5 2.5];
ylim = [0.1 0.4];
linw = 8;
rect = [0.4 0.1 0.5 0.9];
leg = condnames;
[ge,pp] = lineplot([re(:,1)],[re(:,2)],'horizon', 'p(low mean)',...
 'Random exploration', leg,[blue], linw, xlim, ylim, rect);
set(gca,'XTick',[1 2],'XTickLabel',{'1','6'});
ge{1}.CapSize = 20;
ge{2}.CapSize = 20;
set(gca,'FontSize',30,'FontWeight','Bold');
%% Agreement
xlim = [0.5 2.5];
ylim = [0.1 0.4];
linw = 8;
rect = [0.4 0.1 0.5 0.9];
leg = condnames;
[ge,pp] = lineplot([da1(:,1),da2(:,1)],[da1(:,2),da2(:,2)],'horizon', 'p(disagree)',...
 'Choice Inconsistency', leg,[red;blue], linw, xlim, ylim, rect);
set(gca,'XTick',[1 2],'XTickLabel',{'1','6'});
ge{1}.CapSize = 20;
ge{2}.CapSize = 20;
set(gca,'FontSize',30,'FontWeight','Bold');
%% correlation
A = [de1 de2 re1 re2 da1 da2];
[hh pp] = corrcoef(A);
%% compute curves
dataobj1.compare_agreementindex;
dataobj2.compare_agreementindex;
%% plot curves
%% fixed parameter
xbins = dataobj1.curve.xbins;
rect = [0.4 0.1 0.48 0.83];
colors = {river,brick;blue,red};
legs = {[condnames{1},' ,h = 1'],[condnames{1},' ,h = 6'],[condnames{2},' ,h = 1'],[condnames{2},' ,h = 6']};
xtit = '\DeltaReward';
%%
ylines{1} = dataobj1.curve.raw.pr1_dm;
ylines{2} = dataobj1.curve.raw.pr6_dm;
ylines{3} = dataobj2.curve.raw.pr1_dm;
ylines{4} = dataobj2.curve.raw.pr6_dm;
ytit = 'p(right)';
tit = 'A. choice curve';
curveplot(xbins, ylines, colors, legs, xtit, ytit, tit, rect);

ylines{1} = dataobj1.curve.raw.phi1_dm;
ylines{2} = dataobj1.curve.raw.phi6_dm;
ylines{3} = dataobj2.curve.raw.phi1_dm;
ylines{4} = dataobj2.curve.raw.phi6_dm;
ytit = 'p(hi)';
tit = 'B. direct exploration';
curveplot(xbins, ylines, colors, legs, xtit, ytit, tit, rect);

ylines{1} = dataobj1.curve.raw.plm1_dm;
ylines{2} = dataobj1.curve.raw.plm6_dm;
ylines{3} = dataobj2.curve.raw.plm1_dm;
ylines{4} = dataobj2.curve.raw.plm6_dm;
ytit = 'p(lm)';
tit = 'C. random exploration';
curveplot(xbins, ylines, colors, legs, xtit, ytit, tit, rect);

ylines{1} = dataobj1.curve.raw.disagree1_dm;
ylines{2} = dataobj1.curve.raw.disagree6_dm;
ylines{3} = dataobj2.curve.raw.disagree1_dm;
ylines{4} = dataobj2.curve.raw.disagree6_dm;
ytit = 'p(disagree)';
tit = 'D. choice inconsistency';
curveplot(xbins, ylines, colors, legs, xtit, ytit, tit, rect);