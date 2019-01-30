    
    
% horizon task
% pasttime = etime(clock,starttaskclock)/60;
% timeleft = 50 - pasttime;
% if option == 1
%     timeleft = inf;
% end



savename = [savepath, projectname,'horizontask2_sub' num2str(subjectID),'_',time];
tsk = task_horizon2(window,savename,bgColour);
tsk.setup(sub.subjectID,eye,textColour);
eye.marker('taskstart');
% tsk.run(timeleft);
tsk.run(window);
eye.marker('taskend');
