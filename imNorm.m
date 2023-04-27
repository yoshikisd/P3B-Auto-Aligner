% Renormalizes image intensity. Basically a non-double version of mat2gray
function img = imNorm(img,options)
arguments
    img (:,:) {mustBeNumeric}
    
    % options.Mode
    % Either uses the mean +- std or the current minimum/maximum image intensity
    % to determine the bounds for normalization
    options.Mode {mustBeMember(options.Mode,['mean','minmax'])} = 'minmax'

    % options.STDInterval
    % When using options.Mode = 'mean', STDInterval defines the upper and lower
    % limit cut-offs based on mean +- std*STDInterval
    options.STDInterval {mustBeNumeric} = 1;
end
    
    % Define the pixel intensity max and min bounds
    switch options.Mode
    case 'minmax'
        bound = [min(img,[],'all','omitnan'),max(img,[],'all','omitnan')];
    case 'mean'
        % Get the mean and standard deviation of the image
        imMean = mean(img,'all','omitnan');
        imSTD = std(img,0,'all','omitnan');
        % Start off by defining the cut-off intensity range, below which is 0 and above which is 1
        bound = imMean + imSTD*options.STDInterval*[-1,1];
    end

    % Bin the img intensity such that all values above the upper bound is bound(2) and
    % all values below the lower bound is bound(1)
    img(img > bound(2)) = bound(2);
    img(img < bound(1)) = bound(1);
    % Renormalize the image intensity from 0 to 1
    img = (img - (bound(1)))./((bound(2))-(bound(1)));
end

