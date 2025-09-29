function done = interpElx(x,z,inc,int,numelx,arrayStart,arrayFlip,addY)
% interpElx: takes topographic posistions in x-z space and interpolates to 
% make them at the desired sensor spacing. e.g., Extract elevations at
% electrode locations from sub-meter LIDAR coverage.
%
% Input must be in x-z space, NOT along-the-line-distance space.
% The inputs do NOT need to be evenly spaced in the x-direction.
% Appropriate for LiDAR extracted positions or sparse GPS measurements
%
% x = map-view distance along the line -OR- a two-column vector [x z]
% z = elevation (entry is ignored if a two column vector is input for 'x')
% inc = interpolation incrament, leave at 0.001 unless v. long or shrt line
% int = electrode spacing interval
% numelex = number of total electrodes
% arrayStart = if the input data includes locations before the start point,
%              input the distance in meters where the first sensor is.
%              Otherwise, 0.
% arrayFlip = if the input data is in the opposite direction of the array
%             numbering, set this to 1. Otherwise 0.
% addY = if a column of zero y-values is needed between the x and z columns
%        of the output, set to 1. Otherwise 0.
%
% A Parsekian 11/2019, update 12/2023
% ===================================================================

xCols = size (x); % find size of input 'x' matrix/vector
if xCols(2) ==2   % if 'x' has 2 colums...
    z = x(:,2);   % ...then seperate into two columns here 
    x(:,2) = [];
end % if x and z were already provided as sperate columns, skip this 

yn = exist('arrayStart'); %check to see if the variable is being used
if yn == 1 %indicates a value has been input by user
    x = x-arrayStart; %adjust all 'x' values by the arrayStart amount
    [~, index_closest] = min(abs(x));
    
    arrayLen = (int*numelx)-2;
    arrayMax = x -arrayLen;
    [~, index_furthest] = min(abs(arrayMax));

    x = x(index_closest:index_furthest);
    z = z(index_closest:index_furthest); 
end

cnt = 1;
outx = 0; outz = 0;
for i = 2:length(x) % first loop through to interpolate each point
    B = polyfit([x(i) x(i-1)],[z(i) z(i-1)],1);
    X = x(i-1):inc:x(i);
    Z = B(1).*X+B(2);
    outx = [outx X(1:end-1)]; %add to the end of the existing vctr
    outz = [outz Z(1:end-1)];
end

dist = outx(2:end); %just removes the zeroes added to initate the vectrs
elev = outz(2:end);

if arrayFlip ==1   % if user input requires direction flip...
    elev = fliplr(elev);   % ...then reverse the direction of 'dist' 
end % if no direction switch is needed, skip this 

% next, loop to follow along the line and incramentally find the next
% x-location that satisfies the known allong-the-line-distance "int"
stInd = 1;
for i = 1:numelx-1
    Dist = dist(stInd:end); %each loop incraments the starting indx to move along the line
    Elev = elev(stInd:end);
    for j = 1:length(Dist)-1 %calculate the allong-line-dist for each interpolated point
        a2 = (Dist(j)-Dist(1))^2;
        b2 = (Elev(j)-Elev(1))^2;
        c2(j) = sqrt(a2+b2); %hypot dist starting point to each point
    end
    loc = abs(c2-int);
    nwIndH = find(loc == min(loc)); %find the dist along line that matches the defined elx interval
    nwInd  = nwIndH(1); % just in case there are two minima
    done(i,:) = [Dist(nwInd) Elev(nwInd)]; %add correct value to output list
    stInd = stInd+nwInd; %advance the starting index
end

if arrayFlip == 0
done = [0 z(1); done]; % the zero point had been skipped, so add that back in
else
done = [0 z(end); done];
end


subplot(1,2,1)
plot(done(:,1),done(:,2),'-r'); hold on
plot(done(:,1),done(:,2),'or'); hold on
%plot(x,z,'.k')

for i = 1:length(done)-1  % just check the interpolation
    A2 = (done(i,1)-done(i+1,1))^2;
    B2 = (done(i,2)-done(i+1,2))^2;
    C2(i) = sqrt(A2+B2);
end
subplot(1,2,2)
hist(C2) %due to irregular sampling, there will be small variations in allong-line-dist, but these will be less than the width of an electrode.

if addY ==1
    done = [done(:,1) zeros(length(done),1) done(:,2)];
end
