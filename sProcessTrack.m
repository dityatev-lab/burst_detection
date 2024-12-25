close all
clear all
clc
Track = readtable('example.csv');
X = Track.Time;
Y = Track.Current;
%% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ops.durBlackT = 0.2; % secs, threshold to exclude too short non-burst periods
ops.durBurstT = 0.1; % secs threshold to exclude too short burst periods
ops.protectionT = [0.05,0.2]; % secs "protection zone" size
ops.minBurstDeltaI= 250; % pA, threshold to exclude bursts with small maximal amplitude
ops.minAvBurst=50; % pA, threshold to exclude bursts with small average amplitude
ops.movmadT = 20; % pA, thershold for moving median absolute deviation of the signal 
%% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Classification = fClassify(X,Y,ops);
%% Classification: 
% -1: protected; 
% 0-non-burst; 
% 1 - burst

figure('Position',[176.2         411.4         871.8         350.6])
hold all
plot(X,Y.*10^12,'-k','LineWidth',3)
Y1 = Y;
Y1(Classification~=-1) = nan;
plot(X,Y1.*10^12,'-b','LineWidth',3)
Y1 = Y;
Y1(Classification~=1) = nan;
plot(X,Y1.*10^12,'-r','LineWidth',3)
set(gca,'color','none','box','off')
xlabel('sec');
ylabel('pA')
legend({'non-burst','"protection zone"','bursts'})