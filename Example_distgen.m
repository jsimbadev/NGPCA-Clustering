%%%
% NGPCA on DistGen-generated CSV samples
%%%

clear variables
close all

script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(script_dir, 'ngpca'), fullfile(script_dir, 'data'));

% Reproducibility
rng(0)

%% Load DistGen CSV data
% Default path points to GeomDiagnostics.jl/outputs/samples.csv
csv_path = fullfile(script_dir, '..', 'GeomDiagnostics.jl', 'outputs', 'banana_samples.csv');
if ~isfile(csv_path)
    error('CSV file not found at: %s', csv_path);
end

data = readmatrix(csv_path);
if size(data, 2) < 2
    error('NGPCA requires at least 2 columns. Found %d.', size(data, 2));
end

%% Create and train NGPCA model
ngpca = NGPCA('softhard', 1);
numUnits = 15;
ngpca = init_units(ngpca, data, numUnits, 'iterations', 20000, 'PCADimensionality', 2);
ngpca = fit_multiple(ngpca, data);

%% Visualization
figure;
scatter(data(:,1), data(:,2), 5, 'o', 'MarkerFaceAlpha', .2, 'MarkerEdgeAlpha', .2);
hold on;
axis equal;
ngpca.draw();
title('NGPCA on DistGen samples (with final model diagnostics)');

% Overlay useful final NGPCA diagnostics on the plot
u = ngpca.units{1};
data_mean = mean(data, 1);
data_cov = cov(data);

% Keep text compact and robust in case dimensionality changes
weight_str = mat2str(u.weight, 4);
center_str = mat2str(u.center', 4);
eig_str = mat2str(u.eigenvalue', 4);
cov_str = mat2str(data_cov, 4);
mean_str = mat2str(data_mean, 4);

diag_lines = {
    sprintf('numUnits=%d | PCA dim=%d | iterations=%d', ngpca.numberUnits, ngpca.PCADimensionality, ngpca.iterations)
    sprintf('potential=%s | softhard=%g | rho=%0.4f', string(ngpca.potentialFunction), ngpca.softhard, ngpca.rho)
    sprintf('lr0=%0.4f | rho_init=%0.4f | rho_final=%0.4f | mu=%0.4f | rmax=%g', ngpca.learningRate, ngpca.rho_init, ngpca.rho_final, ngpca.mu, ngpca.rmax)
    sprintf('unit.center=%s', center_str)
    sprintf('sample.mean=%s', mean_str)
    sprintf('unit.eigenvalue=%s', eig_str)
    sprintf('unit.sigma_sqr=%0.6f | activity=%0.6f | epsilon=%0.6f | alpha=%0.6f', u.sigma_sqr, u.activity, u.epsilon, u.alpha)
    sprintf('unit.weight=%s', weight_str)
    sprintf('sample.cov=%s', cov_str)
};

annotation('textbox', [0.02, 0.02, 0.96, 0.24], ...
    'String', diag_lines, ...
    'Interpreter', 'none', ...
    'FontName', 'Consolas', ...
    'FontSize', 9, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', [0.4 0.4 0.4], ...
    'FitBoxToText', 'off');
