# interpElx
This function takes irregual topographic data in x-z space and interpolates to 
calculate elevations at the actual sensor positions. e.g., Extract elevations at 
electrode locations from sub-meter LIDAR coverage.

The x and z inputs are a list of topography values along the desired transect. 

The actual sensor spacing is defined by the "along the line" regular sensor
spacing.
