function run_example()
% RUN_EXAMPLE  Demo pipeline for macaque category decoding in MATLAB.
%
%   RUN_EXAMPLE simulates a categorical decision task, bins spike times,
%   builds an analysis-ready table, computes time-resolved AUROC, and
%   trains a cross-validated decoder. Example figures are saved in the
%   ./figures directory.

    % Add src folder to path
    thisDir = fileparts(mfilename('fullpath'));
    addpath(fullfile(thisDir, 'src'));

    % Output directory for figures
    figDir = fullfile(thisDir, 'figures');
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end

    %% 1) Simulate a session
    session = simulate_session( ...
        40, ...             % nUnits
        240, ...            % nTrials
        [-0.2, 0.8], ...    % time window around event (s)
        0.02 ...            % bin size (s)
    );

    %% 2) Bin spikes and build tidy table
    [counts, binEdges] = bin_spikes(session);
    tbl = build_tidy_table(counts, binEdges, session.trials);

    %% 3) Time-resolved category AUROC per unit
    aucTbl = compute_time_resolved_auc(tbl);

    % Population mean AUROC over time
    [tVals, meanAUC] = aggregate_auc_over_time(aucTbl);

    f1 = figure('Color', 'w');
    plot(tVals, meanAUC, 'LineWidth', 1.5);
    hold on;
    yline(0.5, '--', 'Color', [0.5 0.5 0.5]);
    xlabel('Time (s)');
    ylabel('Mean AUROC (Cat1 vs Cat2)');
    title('Time-resolved category discriminability (population mean)');
    box off;
    saveas(f1, fullfile(figDir, 'time_resolved_mean_auc.png'));

    %% 4) Build a population matrix and decode category
    tWindow = [0.1, 0.4]; % late-ish decision window
    subset.go = 1;        % Go trials only

    [X, y, meta] = build_population_matrix(tbl, tWindow, subset); %#ok<ASGLU>
    results = cross_validated_decoder(X, y, 5);

    fprintf('\n=== Category decoder (Go trials, %.2f–%.2f s) ===\n', ...
        tWindow(1), tWindow(2));
    fprintf('Mean AUROC: %.3f +/- %.3f (nFolds = %d)\n', ...
        results.mean_auroc, results.std_auroc, numel(results.fold_auroc));

    % Histogram of fold-wise performance
    f2 = figure('Color', 'w');
    histogram(results.fold_auroc, 'BinWidth', 0.05);
    xlabel('Fold AUROC');
    ylabel('Count');
    title('Cross-validated category decoder performance');
    box off;
    saveas(f2, fullfile(figDir, 'decoder_fold_auc.png'));

    fprintf('Figures saved in: %s\n\n', figDir);
end