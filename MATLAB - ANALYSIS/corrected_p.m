clear all;
[A, title, ~] = xlsread ('/Users/hashem/Desktop/Subject_ID_dcount&personality_059&017/All_subjectID_all.xlsx');
%[A, title, ~] = xlsread ('/Users/hashem/Desktop/Subject_ID_dcount&personality_059&017/All_subjectID.xlsx'); %46 item
%[A, title, ~] = xlsread ('/Users/hashem/Desktop/Subject_ID_dcount&personality_059&017/All_subjectID_3.xlsx');%107item
%%
l = size(title)
l = l(1,2)
%%
title = title (1,6:l);
%% Date
for i=5:l-1
    [R,P] = corrcoef (A(:,2), A(:,i), 'rows', 'complete');
         c(i-4).title = (title(i-4));
         c(i-4).r = R(1,2);
         c(i-4).p = P(1,2);
end
%% sort
for i=1:l-5
    S(i,1) = i;
    S(i,2) = c(i).p;
end
S2 = sortrows(S, 2)
%%
[corrected_p, h]=bonf_holm(S2(:,2),0.05)
%%
for i=1:l-5
    if corrected_p(i,1) >= 0.05
        break
    end
    d = S2(i,1);
    Final_date(i).title = c(d).title;
    Final_date(i).r = c(d).r;
    Final_date(i).p_adjusted = corrected_p(i,1)
end
%% time
for i=5:l-1
    [R,P] = corrcoef (A(:,3), A(:,i), 'rows', 'complete');
         c(i-4).title = (title(i-4));
         c(i-4).r = R(1,2);
         c(i-4).p = P(1,2);
end
%% sort
for i=1:l-5
    S(i,1) = i;
    S(i,2) = c(i).p;
end
S2 = sortrows(S, 2)
%%
[corrected_p, h]=bonf_holm(S2(:,2),0.05)
%%
for i=1:l-5
    if corrected_p(i,1) >= 0.05
        break
    end
    d = S2(i,1);
    Final_time(i).title = c(d).title;
    Final_time(i).p_adjusted = corrected_p(i,1)
    Final_time(i).r = c(d).r;
end
    
