classdef analysis_datasets < handle
    properties
        nExp
        path
        datadir
        basic
        datasets
        analyzer
    end
    methods
        function obj = analysis_datasets(path)
            obj.path = path;
            obj.datadir = path.data;
            obj.load;
        end
        function analyze(obj, sw)
            analyzer = obj.analyzer;
            for ei = 1:obj.nExp
                disp(['Analyzing experiment: ', obj.basic.projectname{ei}]);
                analyzer{ei}.process(sw);
            end
            obj.analyzer = analyzer;
            disp(['Analysis completed! ']);
        end
        function load(obj, ind_exp)
            f_datasets = dir(fullfile(obj.datadir,'DATA*.mat'));
            list_dataset = {f_datasets.name};
            n_Exp = length(list_dataset);
            if nargin < 2
                ind_exp = true(n_Exp, 1);
            end
            datasets = [];
            analyzer = {};
            for fi = 1:n_Exp
                filename = list_dataset{fi};
                load(fullfile(obj.datadir, filename));
                ind1 = min(strfind(filename, '_'))+1;
                ind2 = max(strfind(filename, '.'))-1;
                projectname{fi} = filename(ind1:ind2);
                datasets(fi).data = data;
                datasets(fi).basic = basic;
                analyzer{fi} = analysis_dataset(data, obj.path, projectname{fi});
            end
            obj.nExp = sum(ind_exp);
            obj.basic.list_dataset = list_dataset(ind_exp);
            obj.basic.projectname = projectname(ind_exp);
            obj.datasets = datasets(ind_exp);
            obj.analyzer = analyzer(ind_exp);
            if nargin == 2
                disp('Projects loaded: ');
                for pi = 1:length(obj.basic.projectname)
                    disp([obj.basic.projectname{pi}]);
                end
            end
        end
        function exclude(obj, thres)
             for ei = 1:obj.nExp
                obj.analyzer{ei}.exclude(thres);
            end
        end
    end
end
