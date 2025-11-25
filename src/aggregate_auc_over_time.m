function [tVals, meanAUC] = aggregate_auc_over_time(aucTbl)
% Average AUROC across units at each time point.

    % Drop NaNs before averaging
    % (but keep NaNs per time point if all units are NaN)
    tVals = unique(aucTbl.t_center);
    meanAUC = nan(size(tVals));

    for i = 1:numel(tVals)
        mask = aucTbl.t_center == tVals(i);
        vals = aucTbl.auc(mask);
        if all(isnan(vals))
            meanAUC(i) = NaN;
        else
            meanAUC(i) = mean(vals(~isnan(vals)));
        end
    end
end