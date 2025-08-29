function [ATTR, sensSet, domain] = preprocessData(combtype)
    % Preprocess data
    % T : data table
    % sensSet : \mathcal{X}_S
    % domain : \mathcal{X}
    %======================================================================
    % 2023 The Census Bureau’s American Community Survey (ACS) 
    % Public Use Microdata Sample (PUMS) 
    csvFile = 'psam_pusa.csv';

    % Select variable
    % AGEP : Age
    % SCHL : Educational attainment
    % MAR : Marital status
    % DIS : Disability recode
    % ESR : Employment status recode
    % POVPIP : Income-to-poverty ratio recode
    vars = {'AGEP', 'SCHL', 'MAR', 'DIS', 'ESR', 'POVPIP'};

    opts = detectImportOptions(csvFile,'FileType','text');
    opts.SelectedVariableNames = vars;
    opts = setvartype(opts, vars, 'double');
    T = readtable(csvFile, opts);

    % Convert all variables to 0-based indices
    % replace NaN rows with a new code
    % AGEP : [0–18], [19–35], [36–64], [65 and above]
    origAge = T.AGEP;
    edges = [0, 19, 36, 65, Inf];
    ageBucket = discretize(origAge, edges);
    T.AGEP = ageBucket;
    
    % SCHL : less than highschool : 1, college or above or NaN: 2
    origSchl = T.SCHL;
    schlBucket = nan(size(origSchl));
    schlBucket(ismember(origSchl, 1 : 17))  = 1; 
    schlBucket(isnan(origSchl) | ismember(origSchl, 18 : 24)) = 2;   
    T.SCHL = schlBucket;
    
    % MAR : married or separated : 1, widowed or divorced : 2,
    % never married or under 15 : 3
    origMar   = T.MAR;
    marBucket = nan(size(origMar));
    marBucket(ismember(origMar, [1 4])) = 1;
    marBucket(ismember(origMar, [2,3])) = 2;
    marBucket(origMar == 5) = 3;
    T.MAR = marBucket;

    % ESR : employed or in military service or NaN (<16 years old) : 1
    % unemployed or not in labor force : 2
    origEsr = T.ESR;
    esrBucket = nan(size(origEsr));
    esrBucket(isnan(origEsr) | ismember(origEsr, [1,2,4,5])) = 1;
    esrBucket(ismember(origEsr, [3,6])) = 2;
    T.ESR = esrBucket;  

    % POVPIP : 0 - 100 : 1, 101 - 500 : 2, 501 and above or NaN : 3
    origPov = T.POVPIP;
    povBucket = nan(size(origPov));
    povBucket(origPov >=   0 & origPov <= 100) = 1;
    povBucket(origPov >= 101 & origPov <= 500) = 2;
    povBucket(origPov >= 501 | isnan(origPov)) = 3;
    T.POVPIP = povBucket;

    k = numel(vars);
    idx = cell(1,k);                  
    card = zeros(1,k);               
    for j = 1:k
        v = T.(vars{j});            % Original code vector
        v = v - min(v);             % Convert to 0-based index
        idx{j} = v;                 
        card(j) = max(v) + 1;       % number of categories
    end
    
    % Compute radix multipliers
    mult = [1 cumprod(card(1 : end - 1))]; 
    
    % Create composite attribute (1, ..., prod(card))
    ATTR0 = zeros(height(T), 1, 'double');
    for j = 1 : k
        ATTR0 = ATTR0 + idx{j} .* mult(j);
    end
    T.ATTR = ATTR0 + 1;             % Convert to 1-based index
    uniqCodes = unique(T.ATTR);     % Observed unique codes
    [~, loc] = ismember(T.ATTR, uniqCodes);
    T.ATTR = loc;                   % Reassign to 1, ..., numel(uniqCodes)
    domain = unique(T.ATTR);

    % Identify sensitivity
    condEdu  = (ismember(T.AGEP, [2 3])) & (T.SCHL == 1);
    condMar  = (T.MAR == 2);
    condDis  = (T.DIS == 1);
    condWork = (T.ESR == 2);
    condPoor = (T.POVPIP <= 1);
    
    switch lower(combtype)
        case 'and'
            sensFlag = (condEdu | condMar | condDis) ...
                &  condWork  ...
                &  condPoor;
        case 'or'
            sensFlag = (condEdu | condMar | condDis) ...
                |  condWork  ...
                |  condPoor;
        case 'edu'
            sensFlag = conEdu & condWork & condPoor;
        case 'mar'
            sensFlag = condMar & condWork & condPoor;
        case 'dis'
            sensFlag = condDis & condWork & condPoor;
    end

    T_sens = T(sensFlag, :);
    sensSet = unique(T_sens.ATTR);  
    sensCodes = sensSet;
    nonsensCodes = setdiff(domain, sensCodes);
    newList = [sensCodes ; nonsensCodes];
    [~,loc2] = ismember(T.ATTR, newList);
    T.ATTR = loc2;
    [~, sensSet] = ismember(sensCodes, newList);

    ATTR = T.ATTR;
    
    filename = sprintf('Data_%s.mat' , lower(combtype));
    save(filename, 'ATTR', 'sensSet', 'domain');
end