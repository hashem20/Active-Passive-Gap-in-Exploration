classdef bwToCol_horInfo < handle
    
    properties
        
        bwDir
        colDir
        bgColour
        
    end
    
    methods
        
        function obj = bwToCol_horInfo(bwDir, colDir, bgColour)
            if exist('bwDir') == 1
                obj.bwDir = bwDir;
            end
            if exist('colDir') == 1
                obj.colDir = colDir;
            end
            if exist('bgColour') == 1
                obj.bgColour = bgColour;
            end
        end
        
        function pic8 = convertBwToCol_dollarBill(obj, colour, fname)
            
            Ncol = length(colour);
            
            im = imread([obj.bwDir fname]);
            
            bw_im = mean(im,3);
            
            bw_imCol = bw_im(:);
            
            max_bw = max(bw_im(:));
            min_bw = min(bw_im(:));
            
            h = hist(bw_im(:), [0:255]);
            
            csh = cumsum(h);
            csh = csh / csh(end);
            
            deltaBin = 1 / Ncol;
            
            csBin = [0:deltaBin:1];
            
            for i = 1:length(csBin)-1
                
                bound(i) = min(find(csh>csBin(i)));
                
            end
            
            %[hs, inds] = sort(h, 'descend');
            %
            %shadeBoundaries = inds(1:Ncol)-1;
            %
            %sBsort = sort(shadeBoundaries);
            %
            %for i = 1:Ncol-1
            %    bound(i) = (sBsort(i+1)+sBsort(i))/2;
            %end
            
            bound(1) = -1;
            bound = [bound 256];
            
            for i = 1:Ncol
                
                ind{i} = (bw_im > bound(i)) & (bw_im <= bound(i+1));
                
            end
            
            
            pic = zeros(size(im));
            
            for i = 1:Ncol
                
                
                for j = 1:3
                    pic(:,:,j) = pic(:,:,j) + ind{i}*colour{i}(j);
                end
                
            end
            
            pic8 = uint8(pic);
            
        end
        
        function pic8 = convertBwToCol(obj, colour, fname)
            
            Ncol = length(colour);
            
            im = imread([obj.bwDir fname]);
            
            bw_im = mean(im,3);
            
            bw_imCol = bw_im(:);
            
            max_bw = max(bw_im(:));
            min_bw = min(bw_im(:));
            
            h = hist(bw_im(:), [0:255]);
            
            [hs, inds] = sort(h, 'descend');
            
            shadeBoundaries = inds(1:Ncol)-1;
            
            sBsort = sort(shadeBoundaries);
            
            for i = 1:Ncol-1
                bound(i) = (sBsort(i+1)+sBsort(i))/2;
            end
            
            bound = [-1 bound 256];
            
            for i = 1:Ncol
                
                ind{i} = (bw_im > bound(i)) & (bw_im <= bound(i+1));
                
            end
            
            
            pic = zeros(size(im));
            
            for i = 1:Ncol
                
                
                for j = 1:3
                    pic(:,:,j) = pic(:,:,j) + ind{i}*colour{i}(j);
                end
                
            end
            
            pic8 = uint8(pic);
            
        end
        
        function savePic(obj, pic, savename)
            
            imwrite(pic, [obj.colDir savename '.png'], 'png');
            
            
        end
        
        function convertNumbers(obj, col, nMin, nMax)
            
            for i = nMin:nMax
                pic = obj.convertBwToCol({col obj.bgColour}, ...
                    [num2str(i) '.png']);
                obj.savePic(pic, [num2str(i)])
            end
            
            
        end
        
        function convertBandits(obj, col)
            
            for i = 1:length(col)
                loadname = 'bandit';
                pic = obj.convertBwToCol({col{i} obj.bgColour}, ...
                    [loadname '.png']);
                obj.savePic(pic, [loadname num2str(i)]);
                
                loadname = 'playedBandit';
                pic = obj.convertBwToCol({col{i} obj.bgColour}, ...
                    [loadname '.png']);
                obj.savePic(pic, [loadname num2str(i)]);
            end
        end
        
        function convertMisc(obj, col, loadname, ext)
            
            if exist('ext') ~= 1
                ext = '';
            end
            
            pic = obj.convertBwToCol({col obj.bgColour}, ...
                [loadname '.png']);
            obj.savePic(pic, [loadname ext]);
            
        end
        
        function convertMiscMultipleColours(obj, col, loadname)
            
            pic = obj.convertBwToCol_dollarBill({col{:} obj.bgColour}, ...
                [loadname '.png']);
            obj.savePic(pic, [loadname]);
            
        end
        
        function convertAll(obj, col, dbFlag)
            
            if exist('dbFlag') ~= 1
                dbFlag = 0;
            end
            
            obj.convertNumbers(col{1}, 1, 100)
            
            
            obj.convertBandits({col{2:end}});
            
            obj.convertMisc( obj.bgColour, 'blankNumber')
            obj.convertMisc( col{1}, 'Fix')
            obj.convertMisc( col{1}, 'XX')
            try
                obj.convertMisc( col{1}, 'QQ')
            end
            obj.convertMisc( col{1}, 'changed')
            obj.convertMisc( col{1}, 'progress')
            obj.convertMisc( col{1}, 'Slow')
            obj.convertMisc( col{1}, 'gameChange')
            try
                obj.convertMisc( col{1}, 'info')
                obj.convertMisc( col{1}, 'infoAndValue')
                obj.convertMisc( col{1}, 'value')
                obj.convertMisc( col{1}, 'valueOnly')
            end
            obj.convertMisc( col{1}, 'valueOnlyWithFix')
            obj.convertMisc( col{1}, 'infoAndValueWithFix')
                
            if dbFlag
                obj.convertMiscMultipleColours( col, 'dollarBill')
            end
            
            
            for i = 2:length(col)
                obj.convertMisc( col{i}, 'rewHistBackground', num2str(i-1));
            end
            
        end
        
    end
    
end
