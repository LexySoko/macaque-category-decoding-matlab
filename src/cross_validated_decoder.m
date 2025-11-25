function results = cross_validated_decoder(X, y, nFolds)
% CROSS_VALIDATED_DECODER  Logistic-regression category decoder.
%
%   RESULTS = CROSS_VALIDATED_DECODER(X, Y, NFOLDS) trains a logistic
%   regression classifier with NFOLDS cross-validation and returns:
%
%       results.fold_auroc : AUROC per fold
%       results.mean_auroc : mean AUROC across folds
%       results.std_auroc  : std of AUROC across folds
%
%   Requires Statistics and Machine Learning Toolbox.

    if nargin < 3 || isempty(nFolds)
        nFolds = 5;
    end

    y = logical(y); % ensure binary logical labels

    cv = cvpartition(y, 'KFold', nFolds);
    foldAUC = zeros(nFolds, 1);

    for i = 1:nFolds
        trainIdx = training(cv, i);
        testIdx  = test(cv, i);

        Xtrain = X(trainIdx, :);
        ytrain = y(trainIdx);
        Xtest  = X(testIdx, :);
        ytest  = y(testIdx);

        % Logistic regression via generalized linear model
        mdl = fitglm(Xtrain, ytrain, ...
            'Distribution', 'binomial', 'Link', 'logit');

        yscore = predict(mdl, Xtest); % probability of class 1

        try
            [~, ~, ~, auc] = perfcurve(ytest, yscore, true);
        catch
            auc = NaN;
        end
        foldAUC(i) = auc;
    end

    results.fold_auroc = foldAUC;
    results.mean_auroc = mean(foldAUC, 'omitnan');
    results.std_auroc  = std(foldAUC, 'omitnan');
end