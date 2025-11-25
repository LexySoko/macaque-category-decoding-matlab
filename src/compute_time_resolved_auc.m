function aucTbl = compute_time_resolved_auc(tbl, minTrialsPerClass)
% COMPUTE_TIME_RESOLVED_AUC  Per-unit AUROC over time for category.
%
%   AUCTBL = COMPUTE_TIME_RESOLVED_AUC(TBL) computes AUROC for predicting
%   category (0 vs 1) from firing rate at each time bin for each unit.
%
%   AUCTBL has columns: unit, t_center, auc.
%
%   Requires Statistics and Machine Learning Toolbox (PERFCURVE).

    if nargin < 2 || isempty(minTrialsPerClass)
        minTrialsPerClass = 5;
    end

    % Unique time bins
    bins = unique(tbl(:, {'t_start', 't_end'}));
    [~, order] = sort(bins.t_start);
    bins = bins(order, :);
    tCenters = (bins.t_start + bins.t_end) / 2;

    units = unique(tbl.unit);
    nUnits = numel(units);
    nBins  = numel(tCenters);

    unitCol   = zeros(nUnits * nBins, 1);
    tCenterCol = zeros(nUnits * nBins, 1);
    aucCol    = nan(nUnits * nBins, 1);

    idx = 1;

    for ui = 1:nUnits
        u = units(ui);
        tblU = tbl(tbl.unit == u, :);

        for bi = 1:nBins
            t0 = bins.t_start(bi);
            t1 = bins.t_end(bi);

            mask = tblU.t_start == t0 & tblU.t_end == t1;
            binData = tblU(mask, :);

            unitCol(idx)    = u;
            tCenterCol(idx) = tCenters(bi);

            if isempty(binData)
                auc = NaN;
            else
                y = binData.category;
                x = binData.fr;

                n0 = sum(y == 0);
                n1 = sum(y == 1);

                if n0 < minTrialsPerClass || n1 < minTrialsPerClass
                    auc = NaN;
                else
                    try
                        [~, ~, ~, auc] = perfcurve(y, x, 1);
                    catch
                        auc = NaN;
                    end
                end
            end

            aucCol(idx) = auc;
            idx = idx + 1;
        end
    end

    aucTbl = table(unitCol, tCenterCol, aucCol, ...
        'VariableNames', {'unit', 't_center', 'auc'});
end
