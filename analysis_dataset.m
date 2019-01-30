classdef analysis_dataset < handy_funcs
    properties
        projectname
        data
        path
        thres
        ind_sub
        behavior
        MLE
        bayes
    end
    methods
        function obj = analysis_dataset(data, path, projectname)
            obj.data = data;
            obj.path = path;
            obj.projectname = projectname;
            obj.behavior = analysis_behavior(data);
        end
        function process(obj, sw)
            if nargin < 2 | isempty(sw)
                sw.behavior = 1;
                sw.MLE = 1;
            end
            path = obj.path;
            if sw.behavior
                obj.behavior.main_analysis(path.result, [obj.projectname '_' num2str(round(obj.thres*100))]);
            end
            if sw.MLE
                obj.MLE = analysis_MLE(obj.data, path.result, [obj.projectname '_' num2str(round(obj.thres*100))]);
                obj.MLE.main_analysis;
            end
            if sw.bayesian
                obj.bayes = analysis_bayesian(obj.data(obj.ind_sub), [obj.projectname '_' num2str(round(obj.thres*100))], path.bayesdata, path.bayesmodel, path.bayesresult);
                obj.bayes.main_analysis(2);
            end
        end
        function exclude(obj, thres, ind)
            if nargin == 3
                obj.ind_sub = ind;
                obj.thres = nan;
            else
                obj.behavior.select(thres);
                obj.ind_sub = obj.behavior.ind;
                obj.thres = thres;
            end
        end
    end
end