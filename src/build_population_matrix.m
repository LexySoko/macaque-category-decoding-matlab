function [X, y, meta] = build_population_matrix(tbl, tWindow, subset)
% BUILD_POPULATION_MATRIX  Feature matrix for decoding.
%
%   [X, Y, META] = BUILD_POPULATION_MATRIX(TBL, TWINDOW, SUBSET) builds a
%   trial × unit matrix of average firing rates within TWINDOW.
%
%   TWINDOW = [tMin tMax] (s).
%
%   SUBSET is an optional struct specifying filters, e.g.:
%       subset.go = 1;
%       subset.repetition = [1 2];
%
%   META is a table with columns: trial_id, category, repetition, go.

    if nargin < 3
        subset = struct();
    end

    % Apply subset filters
    mask = true(height(tbl), 1);
    if ~isempty(fieldnames(subset))
        fields = fieldnames(subset);
        for i = 1:numel(fields)
            fname = fields{i};
            val   = subset.(fname);
            if numel(val) > 1
                mask = mask & ismember(tbl.(fname), val);
            else
                mask = mask & tbl.(fname) == val;
            end
        end
    end
    tblSel = tbl(mask, :);

    % Restrict to time window
    tMin = tWindow(1);
    tMax = tWindow(2);
    maskTime = tblSel.t_start >= tMin & tblSel.t_end <= tMax;
    tblSel = tblSel(maskTime, :);

    % Average FR across bins within the window
    g = groupsummary(tblSel, {'trial_id', 'unit'}, 'mean', 'fr');
    % g: trial_id, unit, GroupCount, mean_fr

    wide = unstack(g, 'mean_fr', 'unit'); % trial_id + one column per unit

    % Meta-data (trial-level)
    metaUnique = unique(tblSel(:, {'trial_id', 'category', 'repetition', 'go'}));
    % Align ordering to wide.trial_id
    [~, loc] = ismember(wide.trial_id, metaUnique.trial_id);
    meta = metaUnique(loc, :);

    X = wide{:, 2:end};
    y = meta.category;
end