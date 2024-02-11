function d = bhattacharyyaDistance(x0,x1)
%d = prtUtilBhattacharyyaDistance(X1,X2)
%d = prtUtilBhattacharyyaDistance(DataSet1)
%d = prtUtilBhattacharyyaDistance(DataSet1,DataSet2)

% Copied and adapted by @dhasegan on 2021/12/16 from
% https://www.mathworks.com/matlabcentral/fileexchange/46392-pattern-recognition-toolbox?focused=b7ef20a7-ced3-4b8c-b4ff-2edd7cb187a7&tab=function


    function y = prtUtilNanMean(x)
    % prtUtilNanMean - Calculated the mean of data, X, ignoring nans
        dim = 1;
        nanBool = isnan(x);
        x(nanBool) = 0;
        nNonNans = sum(~nanBool,dim);
        nNonNans(nNonNans==0) = NaN;
        y = sum(x,1)./ nNonNans;
    end

    function y = prtUtilNanVar(x)
    % prtUtilNanVar - Calculated the variance of data, X, ignoring nans
        dim = 1;
        meanX = prtUtilNanMean(x,dim);
        y = prtUtilNanMean(bsxfun(@minus,x,meanX).^2,dim)*size(x,dim)./(size(x,dim)-1); % Variance is normalized by n-1 not n;
    end

    m0 = prtUtilNanMean(x0);
    m1 = prtUtilNanMean(x1);
    if size(x0,2) == 1
        c0 = prtUtilNanVar(x0);
        c1 = prtUtilNanVar(x1);
    else
        c0 = cov(x0);
        c1 = cov(x1);
    end
    %warning off
    logTerm = log( det((c1+c0)/2)./sqrt(det(c1)*det(c0)) );
    %warning on;
    if isnan(logTerm) || logTerm < eps;
        logTerm = eps;
    end
    d = 1/8*(m1-m0)*((c1+c0)/2)^-1*(m1-m0)' + 1/2 * logTerm;
end
