classdef analysis_behavior < handle
    properties
        projectname
        dataset
        ac
        ind
        name
        modelfree
        RTcurve
        curve
        savedir
    end
    methods
        function obj = analysis_behavior(dataset)
            obj.dataset = dataset;
            obj.ind = 1:length(dataset);
            obj.get_ac;
        end
        function main_analysis(obj, savedir, projectname)
            obj.savedir = savedir;
            obj.projectname = projectname;
            obj.analysis_individual;
            result.projectname = obj.projectname;
            result.ac = obj.ac;
            result.ind = obj.ind;
            result.name = obj.name;
            result.modelfree = obj.modelfree;
            result.RTcurve = obj.RTcurve;
            result.curve = obj.curve;
            save(fullfile(obj.savedir, ['Behavior_' obj.projectname]),'result');
        end
        function get_ac(obj)
            dataset = obj.dataset;
            dataobj = analysis_behavior_individual;
            for si = 1:length(dataset)
                dataobj.load(dataset{si});
                dataobj.get_ac;
                ac(si) = dataobj.ac;
            end
            obj.ac.ac5 = [ac.ac5];
            obj.ac.ac10 = [ac.ac10];
            obj.ac.av = [ac.av];
        end
        function analysis_individual(obj)
            dataset = obj.dataset;
            dataobj = analysis_behavior_individual;
            for si = 1:length(dataset)
                dataobj.load(dataset{si});
                dataobj.process;
                field_nms = fieldnames(dataobj.modelfree);
                for fi = 1:length(field_nms)
                    fname = field_nms{fi};
                    te = dataobj.modelfree.(fname);
                    if size(te,1) > 1
                        for ssi = 1:size(te,1)
                            modelfree.(fname){ssi}(si,:) = te(ssi,:);
                            name.modelfree.(fname)(ssi) = dataobj.name.modelfree.(fname)(ssi);
                        end
                    else
                        modelfree.(fname)(si,:) = te(:);
                        name.modelfree.(fname) = dataobj.name.modelfree.(fname);
                    end
                end
                names_h = fieldnames(dataobj.name.curve.h);
                field_nms = names_h;
                for fi = 1:length(field_nms)
                    fname = field_nms{fi};
                    curve.(fname)(si,:) = dataobj.curve.(fname);
                    name.curve.h.(fname) = dataobj.name.curve.h.(fname);
                end
                names_n = fieldnames(dataobj.name.curve.n);
                field_nms = names_n;
                for fi = 1:length(field_nms)
                    fname = field_nms{fi};
                    curve.(fname)(si,:) = dataobj.curve.(fname);
                    name.curve.n.(fname) = dataobj.name.curve.n.(fname);
                end
                x = dataobj.curve.x;
            end
            obj.name = name;
            obj.modelfree = modelfree;
            field_nms = names_h;
            for fi = 1:length(field_nms)
                fname = field_nms{fi};
                for hi = 1:2
                    te = curve.(fname)(:,hi);
                    temp{hi} = cell2mat(te);
                end
                curve.(fname) = temp;
            end
%             field_nms = names_n;
%             for fi = 1:length(field_nms)
%                 fname = field_nms{fi};
%                 te = curve.(fname);
%                 curve.(fname) = cell2mat(te);
%                
%             end
            curve.x = x;
            obj.curve = curve;
%             fields_RT = fieldnames(RT);
%             for fi = 1:length(fields_RT)
%                 fname = fields_RT{fi};
%                 temp = arrayfun(@(x)x.(fname)(:,1)', RT, 'UniformOutput', false);
%                 obj.RT.(fname).p = vertcat(temp{:});
%                 temp = arrayfun(@(x)x.(fname)(:,2)', RT, 'UniformOutput', false);
%                 obj.RT.(fname).n = vertcat(temp{:});
%             end
        end
        function get_RTcurves(obj)
%             dataobj = analysis_individual;
%             ind = obj.ind;
%             dataset = obj.dataset;
%             for si = 1:length(dataset)
%                 dataobj.load(dataset{si});
%                 [RTcurve(si)] = dataobj.get_RTcurve;
%             end
%             RTcurve_av.xbins_dM = RTcurve.xbins;
%             RTcurve_av.xbins_n = RTcurve.xbins_n;
%             fields_RT = fieldnames(RTcurve);
%             for fi = 1:length(fields_RT)
%                 fname = fields_RT{fi};
%                 if sum(strcmp(fname, {'av','xbins'}))
%                     continue;
%                 end
%                 if fname(end-1) == '_'
%                     RTcurve_av.(fname) = RTcurve.(fname);
%                 else
%                     for ci = 1:2
%                         for cj = 1:2
%                             temp = arrayfun(@(x)x.(fname){ci,cj},RTcurve, 'UniformOutput', false);
%                             temp = vertcat(temp{:});
%                             tcurve(ci*2 + cj - 2,:) = nanmean(temp(ind,:));
%                         end
%                     end
%                     RTcurve_av.(fname) = tcurve;
%                 end
%             end
%             RTcurve_av.av = RTcurve.av;
%             obj.RTcurve = RTcurve_av;
        end
        function select(obj, thres, ind)
            if nargin < 3
                obj.ind = obj.ac.ac10 >= thres;
            else
                obj.ind = ind;
            end
        end
    end
    
end

