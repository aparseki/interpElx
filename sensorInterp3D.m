function [coord_3d] = sensorInterp3D(se,d,plotFlag)
%sensorInterp3D -- Interpolates sensor positions
%   This function calculates the XY UTM locations of regularly spaced
%   sensors between GPS-measured end-points. It assumes that the
%   along-the-line distance between sensors is constant, and that the
%   conversion to map view distances has already been done during
%   assignment of elevations.
%
%   e.g., if you have LiDAR topography and a seismic line with a series of
%   sensors and only end point GPS locations measured. This function will
%   determine the UTMs for all points between the end points and produce a
%   list of 3D spatial values UTM,UTMy,elevation_MASL
%
%   Inputs:
%   se = 4-element vector of start and end coordinates, UTM: [start_EASTING
%   | start_NORTHING | end_EASTING | end_NORTHING]
%
%   d = 2 x n array of map-view distance-along-line and elevation value
%   pairs: [distance_meter | elevation_meter; ... | ...]
%
%   plotFlag = flag to supress the plot: 1 = plot, 0 = no plot

%% Initial setup
theta = (atan2(se(4)-se(2),se(3)-se(1))); %find the azimuth between the start coordinate of the line and end of line
coord_3d = [se(1:2) d(1,2)]; % start list of XYZ coordinates with the known start UTM location and LiDAR elevation
number = length(d);

%% Loop through the distance/elevation list to calculate and acure corrisponding x/y UTMs
for i = 2:number
    x_inc = d(i,1)*cos(theta); % using the line azimuth and the map-view distance between points, calculate the incremental x
    y_inc = d(i,1)*sin(theta); % using the line azimuth and the map-view distance between points, calculate the incremental y

    next_geoph = [se(1)+x_inc se(2)+y_inc]; % calculate the location of the next geophone
    coord_3d(i,:) = [next_geoph d(i,2)]; % add next geophone to list of coordinates
end

%% Plotting
if plotFlag == 1
    subplot(1,2,1)
    plot(se(1),se(2),'xr'); hold on %plot start marker
    plot(se(3),se(4),'xb') % plot end marker
    plot(coord_3d(:,1),coord_3d(:,2),'.k') %plot the map-view of calculated coordinates
    xlabel('UTM easting')
    ylabel('UTM northing')
    legend('GPS start','GPS end','calculated geophone locations')
    axis equal

    subplot(1,2,2)
    scatter3(coord_3d(:,1),coord_3d(:,2),coord_3d(:,3))
    xlabel('UTM easting')
    ylabel('UTM northing')
    zlabel('elevation, MASL')
end

end