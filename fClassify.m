function Classification =fClassify(X,Y,ops)
%% prepare data
X = X(:);
Y=Y(:);
Y = -Y*10^12; % convert to -pA
idx = Y==max(Y);
%% Step 1 calculate draft bursts
isBurst = double(movmad(Y,10^3)>ops.movmadT);
isBurst = medfilt1(isBurst,10^3,'truncate');
isBurst(idx)=1;
%% Exclude too short black periods
[intervalStart, intervalStop] = idx2intervals(isBurst', 0);
intervalStartX = X(intervalStart);
intervalStopX = X(intervalStop);
idx = (intervalStopX-intervalStartX)<ops.durBlackT;
intervalStart(idx)=[];
intervalStop(idx)=[];
isBlack = X.*0;
for ii = 1:numel(intervalStart)
   isBlack(intervalStart(ii):intervalStop(ii))=1; 
end
isBurst = 1-isBlack;
%% Exclude too short Bursts
[intervalStart, intervalStop] = idx2intervals(isBurst', 1);
intervalStartX = X(intervalStart);
intervalStopX = X(intervalStop);
idx = (intervalStopX-intervalStartX)<ops.durBurstT;
intervalStart(idx)=[];
intervalStop(idx)=[];
isBurst = X.*0;
for ii = 1:numel(intervalStart)
   isBurst(intervalStart(ii):intervalStop(ii))=1; 
end
%% Exclude bursts with too small amplidude
[intervalStart, intervalStop] = idx2intervals(isBurst', 1);
A=[];
Av=[];
for ii = 1:numel(intervalStart)
   idx=(intervalStart(ii):intervalStop(ii));
   A(ii) = max(Y(idx))-min(Y(idx));
   Av(ii) = mean(Y(idx)-min(Y(idx)));
   
end
idx = or(A<ops.minBurstDeltaI,Av<ops.minAvBurst);
intervalStart(idx)=[];
intervalStop(idx)=[];
isBurst = X.*0;
for ii = 1:numel(intervalStart)
   isBurst(intervalStart(ii):intervalStop(ii))=1; 
end
%% Create protection Zone
[intervalStart, intervalStop] = idx2intervals(isBurst', 1);
intervalStartX = X(intervalStart);
intervalStopX = X(intervalStop);
intervalStartX=intervalStartX-ops.protectionT(1);
intervalStopX=intervalStopX+ops.protectionT(2);
intervalStartX(intervalStartX<min(X))=min(X);
intervalStopX(intervalStopX>max(X))=max(X);
isProtected = X.*0;
for ii = 1:numel(intervalStartX)
    idx = and(X>=intervalStartX(ii),X<=intervalStopX(ii));
    isProtected(idx)=1; 
end
isProtected = isProtected-isBurst;
%% Classify % -1: protected; 0-black; 1 - burst
Classification = isBurst.*0;
Classification(isBurst==1)=1;
Classification(isProtected==1)=-1;
end
%% Helpers
function [intervalStart, intervalStop] = idx2intervals(x, val)
    %idx2intervals converts indices of define value to borders
    % IN:
    %   x   : 1D array 
    %   val : one number, repeated intervals of which we need to detect
    % OUT:
    %   intervalStart 1D array containing indexes of intervals starts
    %   intervalStop 1D array containing indexes of intervals stops
    % COMMENTS:
    %   is reverse to interval2idx function
    % Example:
    % x = [1 2 3 4 4 4 4 5 6 7];
    % [intervalStart, intervalStop] = findChunkBorders(x, 4);
    idx = (x==val);
    intervalStart = find([idx(1), diff(idx)==1]);
    intervalStop = find([diff(idx)==-1, idx(end)]);

end

function v = intervals2idx(intervalStart,intervalStop)
    %intervals2idx converts borders to indices
    % IN:
    %   intervalStart 1D array containing indexes of intervals starts
    %   intervalStop 1D array containing indexes of intervals stops
    % OUT:
    %   v array,which contains subscripts between pairs
    %   intervalStart(n):intervalStop(n)
    % COMMENTS:
    %   is reverse to idx2interval function
    % Example:
%     startIDX = [1,6,11];
%     stopIDX = [3 9 15];
%     subs = intervals2idx(intervalStart,intervalStop);
    v = zeros(1, max(intervalStop)+1);  % An array of zeroes
    v(intervalStart) = 1;              % Place 1 at the starts of the intervals
    v(intervalStop+1) = v(intervalStop+1)-1;  % Add -1 one index after the ends of the intervals
    v = find(cumsum(v));          % Perform a cumulative sum and find the nonzero entries
end