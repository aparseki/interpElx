# interpElx
interpElx: takes electrode (or geophone, or any sensors spaced along a line) posistion in x-z space at smaller or larger 
% spacing and interpolates to make them at the desired electrode
% spacing.  input must be in x-z space, NOT along-the-line-distance space.
% The inputs do NOT need to be evenly spaced in the x-direction.
% Appropriate for LiDAR extracted positions or sparse GPS measurements
%
% x = map-view distance along the line
% z = elevation
% inc = interpolation incrament, leave at 0.001 unless v. long or shrt line
% int = electrode spacing interval
% numelex = number of total electrodes
