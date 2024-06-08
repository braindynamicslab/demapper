data_path = [datafolder, 'data_treefoil.1D'];
data = read_1d(data_path);

% Size of data will be 120x3. A 3D dataset with 120 points and 3 coordinates
size(data) 

% Explore the data
figure;
plot3(data(:,1), data(:,2), data(:,3), 'x');

% Load the "nodeCData" data, coloring each node as one of 3 colors
coloring_data = [datafolder, 'data_treefoil_task_nodeCData.1D'];
nodeCData = read_1d(coloring_data);

% Explore the treefoil knot data with the colors
figure;
scatter3(data(:,1), data(:,2), data(:,3), 100, nodeCData(:, 1:3), 'filled');
