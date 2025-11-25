function tbl = build_tidy_table(counts, binEdges, trials)
% BUILD_TIDY_TABLE  Long-form table of firing rate and labels.
%
%   TBL = BUILD_TIDY_TABLE(COUNTS, BINEDGES, TRIALS) converts a
%   (nUnits × nTrials × nBins) array into a table with variables:
%       unit, trial_id, t_start, t_end, fr, category, repetition, go.

    [nUnits, nTrials, nBins] = size(counts);

    t_start = binEdges(1:end-1);
    t_end   = binEdges(2:end);
    binDur  = t_end - t_start;

    nRows = nUnits * nTrials * nBins;

    unitCol       = zeros(nRows, 1);
    trialCol      = zeros(nRows, 1);
    tStartCol     = zeros(nRows, 1);
    tEndCol       = zeros(nRows, 1);
    frCol         = zeros(nRows, 1);
    catCol        = zeros(nRows, 1);
    repCol        = zeros(nRows, 1);
    goCol         = zeros(nRows, 1);

    idx = 1;

    for u = 1:nUnits
        for k = 1:nTrials
            trial_id   = trials.trial_id(k);
            category   = trials.category(k);
            repetition = trials.repetition(k);
            go         = trials.go(k);

            for b = 1:nBins
                unitCol(idx)   = u;
                trialCol(idx)  = trial_id;
                tStartCol(idx) = t_start(b);
                tEndCol(idx)   = t_end(b);

                frCol(idx)   = counts(u, k, b) / binDur(b);
                catCol(idx)  = category;
                repCol(idx)  = repetition;
                goCol(idx)   = go;

                idx = idx + 1;
            end
        end
    end

    tbl = table( ...
        unitCol, trialCol, tStartCol, tEndCol, frCol, ...
        catCol, repCol, goCol, ...
        'VariableNames', {'unit', 'trial_id', 't_start', 't_end', ...
                          'fr', 'category', 'repetition', 'go'});
end