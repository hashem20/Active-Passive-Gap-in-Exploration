classdef makeStimuli < handle
    
    properties
        saveDir
        bWidth
        bHeight
        
    end
    
    methods
        
        function obj = makeStimuli(saveDir)
            if exist('saveDir') == 1
                obj.saveDir = saveDir;
            end
            
            obj.bWidth = 400;
            obj.bHeight = 300;
            
        end
        
        function saveStimulus(obj, fignum, savename, bWidth, bHeight)
            
            % this is convoluted and ridiculous but it should work
            set(gcf, 'visible', 'off')
            saveas(gcf, 'tmp', 'jpeg');
            
            % read jpg file and edit
            xx = imread('tmp.jpg');
            sx = size(xx);
            d = sx(2)-sx(1);
            xx2 = xx(:, d/2:sx(2)-d/2-1,:);
            %yy = imresize(xx2, bndtWidth/size(xx2,1));
            if exist('bWidth') == 1
                yy = imresize(xx2, [bWidth bHeight]);
            else
                yy = imresize(xx2, [200 200]);
            end
            
            % write out image
            imwrite(yy, [obj.saveDir savename '.png'], 'png')
            
            % remove temp file stupid.jpg
            % delete(sprintf('tmp.jpg',i));
            
        end
        
        function drawMeABandit(obj, colour, bgColour, fignum)
            
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            w = 0.5;
            x = 0.1;
            h = 0.9;
            y = (1-h)/2;
            
            pad = 0.1;
            rw=0.6*w;
            pad = w/2 - rw/2;
            rx = x + pad;
            
            tr_h = pad;
            tr_y = y + h-pad-tr_h;
            
            br_y = y + pad;
            br_h = 0.4*h;
            bob_r_h = h-2*pad;
            bob_r_y = y + h-pad-bob_r_h;%y + h - 2*pad;
            
            cw = 0.3 * rw;
            ch = cw+0.04;
            cx = 1 - x*1.35 - cw;
            cy = tr_y + tr_h / 2 - ch / 2;
            
            padd = 0.01;
            lx = [x + w - padd; cx + padd];
            ly = [br_y + br_h; cy + ch/2 - padd];
            
            rect.y=br_y;
            rect.h=br_h;
            rect.w=rw;
            rect.x=pad/(cx+cw);
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            set(gca, 'xtick', [], 'ytick', []);
            
            bg = annotation('rectangle',[0 0 1 1]);
            set(bg, 'color', bgColour, 'facecolor',bgColour);
            
            bndt = annotation('rectangle', [x y w h]);
            set(bndt, 'color', bgColour, 'facecolor', colour);
            
            %top_rec = annotation('rectangle', [rx tr_y rw tr_h]);
            %set(top_rec, 'color', bgColour, 'facecolor', bgColour);
            
            bot_rec = annotation('rectangle', [rx bob_r_y rw bob_r_h]);
            set(bot_rec, 'color', bgColour, 'facecolor', bgColour);
            
            circ = annotation('ellipse', [cx cy cw ch]);
            set(circ, 'color', colour, 'facecolor', colour);
            
            lin = annotation('line', lx, ly);
            set(lin, 'color', colour, 'LineWidth', 15);
            
            
        end
        
        function drawMeAPlayedBandit(obj, colour, bgColour, fignum)
            
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            w = 0.5;
            x = 0.1;
            h = 0.9;
            y = (1-h)/2;
            
            pad = 0.1;
            rw=0.6*w;
            pad = w/2 - rw/2;
            rx = x + pad;
            
            tr_h = pad;
            tr_y = y + h-pad-tr_h;
            
            br_y = y + pad;
            br_h = 0.4*h;
            bob_r_h = h-2*pad;
            bob_r_y = y + h-pad-bob_r_h;%y + h - 2*pad;
            
            cw = 0.3 * rw;
            ch = cw+0.04;
            cx = 1 - x*1.35 - cw;
            %cy = tr_y + tr_h / 2 - ch / 2;
            cy = br_y;
            padd = 0.01;
            lx = [x + w - padd; cx + padd];
            ly = [br_y + br_h; br_y+pad];
            
            rect.y=br_y;
            rect.h=br_h;
            rect.w=rw;
            rect.x=pad/(cx+cw);
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            set(gca, 'xtick', [], 'ytick', []);
            
            bg = annotation('rectangle',[0 0 1 1]);
            set(bg, 'color', bgColour, 'facecolor',bgColour);
            
            bndt = annotation('rectangle', [x y w h]);
            set(bndt, 'color', bgColour, 'facecolor', colour);
            
            %top_rec = annotation('rectangle', [rx tr_y rw tr_h]);
            %set(top_rec, 'color', bgColour, 'facecolor', bgColour);
            
            bot_rec = annotation('rectangle', [rx bob_r_y rw bob_r_h]);
            set(bot_rec, 'color', bgColour, 'facecolor', bgColour);
            
            circ = annotation('ellipse', [cx cy cw ch]);
            set(circ, 'color', colour, 'facecolor', colour);
            
            lin = annotation('line', lx, ly);
            set(lin, 'color', colour, 'LineWidth', 15);
            
            
        end
        
        function drawNumber(obj, n, colour, bgColour, fignum)
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            set(gca, 'xtick', [], 'ytick', []);
            
            rec = annotation('rectangle', [0 0 1 1]);
            set(rec, 'color', bgColour, 'facecolor', bgColour);
            
            points = int2str(n);
            
            tb = annotation('textbox', [0 0 1 1]);
            set(tb(1), 'string', points, 'fontsize', ...
                260, 'verticalAlignment', 'middle')
            
            set(tb, 'color', colour, ...
                'edgecolor', bgColour, 'fontweight', 'bold', ...
                'horizontalAlignment', 'center', 'linewidth', 0);
            
            
            
        end
        
        function drawStr(obj, str, colour, bgColour, fignum, fontsize)
            if exist('fignum') ~= 1
                fignum = 1;
            end
            if exist('fontsize') ~= 1
                fontsize = 260;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            set(gca, 'xtick', [], 'ytick', []);
            
            rec = annotation('rectangle', [0 0 1 1]);
            set(rec, 'color', bgColour, 'facecolor', bgColour);
            
            points = str;
            
            tb = annotation('textbox', [0 0 1 1]);
            set(tb(1), 'string', points, 'fontsize', ...
                fontsize, 'verticalAlignment', 'middle')
            
            set(tb, 'color', colour, ...
                'edgecolor', bgColour, 'fontweight', 'bold', ...
                'horizontalAlignment', 'center', 'linewidth', 0);
            
            
            
        end
        
        function makeHasChanged(obj, fignum, colour, bgColour)
            
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            set(gca, 'xtick', [], 'ytick', []);
            
            bg = annotation('rectangle',[0 0 1 1]);
            set(bg, 'color', colour, 'facecolor',colour);
            
        end
        
        function makeFixationCross(obj,fignum, colour, bgColour)
            
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            width = 100;
            
            figure(fignum); clf;
            set(gcf, 'position', [0 0 100 100]);
            axes('position', [0 0 1 1]);
            
            
            sideLength = 15;
            w = 2;
            part1 = zeros(sideLength);
            part1(end-w:end,:) = 1;
            part1(:,end-w:end) = 1;
            
            part2 = [part1; flipud(part1)];
            
            part3 = [part2, fliplr(part2)];
            pic = part3;
            
            padSize = (width - sideLength)/2;
            
            imagesc(-pic);
            colormap('gray');
            set(gca, 'xtick', [], 'ytick', []);
            
            
            
        end
        
        function drawTooSlow(obj, colour, bgColour, fignum)
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            rec = annotation('rectangle', [0 0 1 1]);
            set(rec, 'color', bgColour, 'facecolor', bgColour);
            
            clear tb
            tb(1) = annotation('textbox', [0 0.15 1 0.7]);
            set(tb(1), 'string', 'TOO', 'fontsize', 120, 'verticalAlignment', 'top')
            
            tb(2) = annotation('textbox', [0 0.15 1 0.7]);
            set(tb(2), 'string', 'SLOW', 'fontsize', 120, 'verticalAlignment', 'bottom')
            
            
            for i = 1:length(tb)
                set(tb(i), 'color', [1 1 1] .* colour, ...
                    'edgecolor', bgColour, 'fontweight', 'bold', ...
                    'horizontalAlignment', 'center', 'linewidth', 0);
            end
            
            
            
        end
        
        function drawGameChange(obj, colour, bgColour, fignum)
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            rec = annotation('rectangle', [0 0 1 1]);
            set(rec, 'color', bgColour, 'facecolor', bgColour);
            
            clear tb
            tb(1) = annotation('textbox', [0 0.15 1 0.7]);
            set(tb(1), 'string', 'GAME', 'fontsize', 100, 'verticalAlignment', 'top')
            
            tb(2) = annotation('textbox', [0 0.15 1 0.7]);
            set(tb(2), 'string', 'CHANGE', 'fontsize', 100, 'verticalAlignment', 'bottom')
            
            
            for i = 1:length(tb)
                set(tb(i), 'color', [1 1 1] .* colour, ...
                    'edgecolor', bgColour, 'fontweight', 'bold', ...
                    'horizontalAlignment', 'center', 'linewidth', 0);
            end
            
            
            
        end
        
        function drawInfo(obj, colour, bgColour, fignum)
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            rec = annotation('rectangle', [0 0 1 1]);
            set(rec, 'color', bgColour, 'facecolor', bgColour);
            
            clear tb
            tb(1) = annotation('textbox', [0 0 1 1]);
            set(tb(1), 'string', 'INFO', 'fontsize', 100, ...
                'verticalAlignment', 'middle')
            
            for i = 1:length(tb)
                set(tb(i), 'color', [1 1 1] .* colour, ...
                    'edgecolor', bgColour, 'fontweight', 'bold', ...
                    'horizontalAlignment', 'center', 'linewidth', 0);
            end
            
            
            
        end
        
        function drawValue(obj, colour, bgColour, fignum)
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            rec = annotation('rectangle', [0 0 1 1]);
            set(rec, 'color', bgColour, 'facecolor', bgColour);
            
            clear tb
            tb(1) = annotation('textbox', [0 0 1 1]);
            set(tb(1), 'string', 'VALUE', 'fontsize', 100, ...
                'verticalAlignment', 'middle')
            
            for i = 1:length(tb)
                set(tb(i), 'color', [1 1 1] .* colour, ...
                    'edgecolor', bgColour, 'fontweight', 'bold', ...
                    'horizontalAlignment', 'center', 'linewidth', 0);
            end
            
            
            
        end
        
        function drawInfoAndValue(obj, colour, bgColour, fignum)
            if exist('fignum') ~= 1
                fignum = 1;
            end
            
            if exist('colour') ~= 1
                colour = [0.906 0.463 0.247]*256;
            end
            if exist('bgColour') ~= 1
                bgColour = [75 75 75];
            end
            bgColour = bgColour / 255;
            colour = colour / 255;
            
            
            figure(fignum); clf;
            axes('position', [0 0 1 1]);
            rec = annotation('rectangle', [0 0 1 1]);
            set(rec, 'color', bgColour, 'facecolor', bgColour);
            
            clear tb
            tb(1) = annotation('textbox', [0 0.15 1 0.7]);
            set(tb(1), 'string', 'INFO', 'fontsize', 100, ...
                'verticalAlignment', 'top')
            
            tb(2) = annotation('textbox', [0 0 1 1]);
            set(tb(2), 'string', '+', 'fontsize', 100, ...
                'verticalAlignment', 'middle')
            
            tb(3) = annotation('textbox', [0 0.15 1 0.7]);
            set(tb(3), 'string', 'VALUE', 'fontsize', 100, ...
                'verticalAlignment', 'bottom')
            
            
            for i = 1:length(tb)
                set(tb(i), 'color', [1 1 1] .* colour, ...
                    'edgecolor', bgColour, 'fontweight', 'bold', ...
                    'horizontalAlignment', 'center', 'linewidth', 0);
            end
            
            
            
        end
        
    end
    
end