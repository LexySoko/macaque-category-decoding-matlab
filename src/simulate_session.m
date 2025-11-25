function session = simulate_session(nUnits, nTrials, timeWindow, binSize)
% SIMULATE_SESSION  Simulate spiking data for a categorical decision task.
%
%   SESSION = SIMULATE_SESSION() uses default parameters.
%
%   SESSION = SIMULATE_SESSION(nUnits, nTrials, timeWindow, binSize)
%   simulates Poisson spike trains for a Go/No-Go visual categorization
%   task with repetition effects.
%
%   Output struct fields:
%       spike_times : cell(nUnits, nTrials) of spike time vectors (s)
%       trials      : table of trial metadata
%       time_window : [tStart tEnd] (s)
%       bin_size    : scalar (s)

    if nargin < 1 || isempty(nUnits),     nUnits = 40;          end
    if nargin < 2 || isempty(nTrials),    nTrials = 240;        end
    if nargin < 3 || isempty(timeWindow), timeWindow = [-0.2 0.8]; end
    if nargin < 4 || isempty(binSize),    binSize = 0.02;       end

    rng(42); % reproducible

    tStart = timeWindow(1);
    tEnd   = timeWindow(2);

    % Trial-level labels
    trial_id   = (1:nTrials).';
    category   = randi([0 1], nTrials, 1);        % 0 or 1
    repetition = randi([1 4], nTrials, 1);        % 1–4
    go         = randi([0 1], nTrials, 1);        % 0 (No-Go), 1 (Go)

    % Reaction times for Go trials only
    baseRT = 0.4;
    jitter = 0.08 * randn(nTrials, 1);
    reaction_time = nan(nTrials, 1);
    reaction_time(go == 1) = baseRT + jitter(go == 1);

    trials = table(trial_id, category, repetition, go, reaction_time);

    % Unit-level tuning parameters
    baseline  = 5 + 10 * rand(nUnits, 1);         % spikes/s
    cat_pref  = 4 * randn(nUnits, 1);             % category preference
    rep_slope = -0.5 + 1.0 * randn(nUnits, 1);    % repetition modulation
    go_mod    = 2.0 + 1.0 * randn(nUnits, 1);     % Go vs No-Go effect

    % Time bins for generation
    nBins    = round((tEnd - tStart) / binSize);
    binEdges = linspace(tStart, tEnd, nBins + 1);
    tCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;

    spike_times = cell(nUnits, nTrials);

    for u = 1:nUnits
        for k = 1:nTrials
            cat = category(k);
            rep = repetition(k);
            g   = go(k);

            % Gaussian bump: category-dependent timing
            if cat == 1
                bumpCenter = 0.0;
            else
                bumpCenter = 0.2;
            end
            bump = 10 * exp(-0.5 * ((tCenters - bumpCenter) / 0.07).^2);

            rate = baseline(u) + bump;

            % Category preference (positive = prefers cat=1)
            rate = rate + cat_pref(u) * (cat - 0.5);

            % Repetition effect (adaptation)
            rate = rate + rep_slope(u) * (rep - 1);

            % Go vs No-Go modulation in late window
            goMask = tCenters > 0.2;
            rate = rate + go_mod(u) * g .* goMask;

            % Ensure non-negative
            rate = max(rate, 0.1);

            % Poisson spiking
            lambda = rate * binSize;
            counts = poissrnd(lambda);

            % Convert counts to spike times
            st = [];
            for b = 1:nBins
                c = counts(b);
                if c > 0
                    t0 = binEdges(b);
                    t1 = binEdges(b+1);
                    st = [st, t0 + (t1 - t0) * rand(1, c)]; %#ok<AGROW>
                end
            end
            st = sort(st(:));
            spike_times{u, k} = st;
        end
    end

    session.spike_times = spike_times;
    session.trials      = trials;
    session.time_window = timeWindow;
    session.bin_size    = binSize;
end