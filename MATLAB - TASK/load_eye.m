function [eye_data, mess] = load_eye(datadir, fname)

% load eye data
fid = fopen([datadir fname]);
X = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);

T = textscan(X{1}{1}, '%s', 'delimiter', '\t');
Y = strvcat(X{1}{:});
ind_mess = Y(:,1) == 'M';
M = {X{1}{ind_mess}};
Z = {X{1}{~ind_mess}};
Z = {Z{2:end}};
A = strvcat(Z{:});

if isempty(A)
    eye_data = [];
    mess = [];
    return;
end
B = textscan(A','%s%s%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f');

E = strvcat(B{2});
sc = str2num(E(:,end-5:end));
mn = str2num(E(:,end-8:end-7))*60;
hr = str2num(E(:,end-11:end-10))*60*60;
L = min([length(B{15}) length(B{24}) length(hr) length(mn) length(sc)]);
tm = hr(1:L)+mn(1:L)+sc(1:L);

eye_data.tm = tm;

eye_data.pd_raw = [B{15}(1:L) B{22}(1:L)];
eye_data.leftPupil = [B{16}(1:L) B{17}(1:L)];
eye_data.rightPupil = [B{23}(1:L) B{24}(1:L)];
% eye_data.leftGaze = [B{13}(1:L) B{15}(1:L)];
% eye_data.rightGaze = [B{20}(1:L) B{21}(1:L)];
eye_data.gaze = [B{6}(1:L) B{7}(1:L)];
eye_data.var_names = {T{1}{4:end}};


% messages
C = strvcat(M{:});
C = C(2:end,:);
CC = C(:,4:end);
D = textscan(CC','%s%s%s%s');
E = strvcat(D{2});
sc = str2num(E(:,end-5:end));
mn = str2num(E(:,end-8:end-7))*60;
hr = str2num(E(:,end-11:end-10))*60*60;
tm = hr+mn+sc;

str = D{4};
mess.tm = tm;
mess.str = str;

