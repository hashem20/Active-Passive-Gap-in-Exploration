Data used to produce figures in "Lessons from a “failed” replication: The importance of taking action in exploration"

Raw data for experiment 1(between design) is in: exp1_between.xls
Raw data for experiment 2(within design) is in: exp2_within.xls
 
Each row corresponds to a single game.  Each column corresponds to a separate variable

* expt_name - this is only meaningful for experiment 1, data we included here are from multiple experiments which involve the horizon task.  This show which experiment the data is from.
* subjectID - subject number
* order - this is only meaningful for experiment 2, this shows whether participant did passive condition first or active condition first
- 1 for data from the first condition, 2 for data from the second condition

* game_id - game number in experiment
* isactive - active or passive condition
* gameLength - number of trials in this game, including four forced trials
* uc - uncertainty condition, number of times option 1 is played in forced trials
* m1 - true mean of option 1
* m2 - true mean of option 2
* r1, r2, etc ... - reward outcome on each trial, = nan if no outcome (e.g. on trial 6 in horizon 1 games)
* c1, c2, etc ... - choice on trial t, 1 for left, 2 for right
* rt1, rt2, etc ... - reaction time on trial t in seconds