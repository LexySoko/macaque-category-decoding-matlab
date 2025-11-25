function [counts, binEdges] = bin_spikes(session, timeWindow, binSize)
% BIN_SPIKES  Bin spike times into counts (unit × trial × time bin).
%
%   [COUNTS, BINEDGES] = BIN_SPIKES(SESSION) uses SESSION.time_window and
%   SESSION.bin_size.
%
%   [COUNTS, BINEDGES] = BIN_SPIKES(SESSION, TIMEWINDOW, BINSIZE) allows
%   overriding the window/bin size.

    if nargin < 2 || isempty(timeWindow)
        timeWindow = session.time_window;
    end
    if nargin < 3 || isempty(binSize)
        binSize = session.bin_size;
    end

    tStart = timeWindow(1);
    tEnd   = timeWindow(2);

    [nUnits, nTrials] = size(session.spike_times);
    nBins = round((tEnd - tStart) / binSize);
    binEdges = linspace(tStart, tEnd, nBins + 1);

    counts = zeros(nUnits, nTrials, nBins);

    for u = 1:nUnits
        for k = 1:nTrials
            st = session.spike_times{u, k};
            if isempty(st)
                continue;
            end
            counts(u, k, :) = histcounts(st, binEdges);
        end
    end
end
