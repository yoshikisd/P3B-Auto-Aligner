% Aligns stacks of images by...
%   - First, align all the images that are members of the same class (i.e., polarization, hv)
%   - Second, average those sets of aligned image for each class
%
% Assumes that EITHER polarization or hv changes, not both at the same time
function [p3b, avgSet] = alignClassMembers(p3b,opt)
arguments 
    % Only accept the p3b structure (define class later)
    p3b
    % Defines the type of registration operation to perform
    opt.Mode {mustBeMember(opt.Mode,['similarity','demon'])}

    % For options.Mode = similarity...
    %   define the type of registration transformation that will be performed
    opt.Transform {mustBeMember(opt.Transform,['translation','rigid','similarity','affine'])}
    %   defines the modality to use
    opt.Modality {mustBeMember(opt.Modality,['monomodal','multimodal'])}

    % For options.Mode = demon
    %   define the number of pyramid levels
    opt.pyLevel {mustBeInteger}
    %   define the smoothing level
    opt.smoothVal {mustBeNumeric}
    %   define the number of iterations
    opt.iterVal {mustBeInteger}
end
    
    % First, check what different energy values of polarizations exist in the p3b structure
    pol = unique(vertcat(p3b.polarization));
    hv = unique(round(vertcat(p3b.energy),1));
    
    % Set p = 1 (used for a waitbar and counter later)
    p = 1;

    % Open up the waitbar
    parDataQ = parallel.pool.DataQueue;
    f = waitbar(0,'Running alignment.');
    afterEach(parDataQ,@nUpdateWaitbar);
    % Create a structure which will store the unique class member values along
    % with their associated averaged image
    avgSet = struct('im',[],'imAligned',[],'tag',[],'idx',[],'opts',opt,'optsImAligned',[]);

    % Check whether pol or hv is varied. Sort the indices in p3b based on what class member they are
    if numel(pol) > 1    
        lookAt = pol;
        for i = 1:numel(pol)
            % Look for all indices which have the same polarization
            avgSet(i).idx = find(vertcat(p3b.polarization) == pol(i));
        end
    elseif numel(hv) > 1
        lookAt = hv;
        for i = 1:numel(pol)
            % Look for all indices which have the same polarization
            avgSet(i).idx = find(vertcat(p3b.energy) == hv(i));
        end
    end

    % Initialize matrice to store images from p3b
    % Type of array created depends on if a GPU is present or not
    if gpuDeviceCount("Available") > 0 && strcmp(opt.Mode,'demon')
        p3bImSet = zeros([size(p3b(1).im),length(p3b)],'single','gpuArray');
    else
        p3bImSet = zeros([size(p3b(1).im),length(p3b)],'single');
    end
    szp3bAlignTo = size(p3b(1).im);
    % Set the optimizer IF the option mode is similarity
    switch opt.Mode
        case 'similarity'
            [optimizer, metric] = imregconfig(opt.Modality);
            % Bump up the number of iterations to 500
            optimizer.MaximumIterations = 500;
            % Change the optimizer settings depending on the modality
            switch opt.Modality
                case 'monomodal'
                    optimizer.GradientMagnitudeTolerance = 1e-5;
                    optimizer.MinimumStepLength = 1e-5;
                    optimizer.MaximumStepLength = 1e-3;
                    optimizer.RelaxationFactor = 0.7;
                case 'multimodal'
                    optimizer.GrowthFactor = 1.1;
                    optimizer.Epsilon = 5e-7;
                    optimizer.InitialRadius = 5e-3;
            end
            % Define other zero matrices to store images for parfor
            p3bImRaw = p3bImSet;
    end

    % Temporarily store the images in a NxMxL matrix
    for i = 1:length(p3b)
        p3bImSet(:,:,i) = p3b(i).im;
        p3bImRaw(:,:,i) = p3b(i).imRaw;
    end

    % Then, process the images one class member at a time
    for i = 1:numel(lookAt)
        lookAtMe = lookAt(i);   % The current class member to look at
        avgSet(i).tag = lookAtMe;  % Stores the value of the class member
        lst = avgSet(i).idx;       % Gets the list of image indices in p3b to look at

        % Define p3bImSetAligned: a storage matrix for the aligned images
        if gpuDeviceCount("Available") > 0 && strcmp(opt.Mode,'demon')
            p3bImSetAligned = zeros([size(p3b(1).im),length(lst)],'single','gpuArray');
        else
            p3bImSetAligned = zeros([size(p3b(1).im),length(lst)],'single');
        end
        % Process each image that's a member of the observed class depending
        % on what the registration mode is
        switch opt.Mode
            case 'demon'
                for j = 1:length(lst)
                    % Get the index value of the image
                    idx = lst(j);    
                    % Get the image transform displacement field
                    [tform,~] = imregdemons(p3bImSet(:,:,idx),p3bImSet(:,:,1),opt.iterVal,...
                        "AccumulatedFieldSmoothing",opt.smoothVal,...
                        "PyramidLevels",opt.pyLevel,...
                        'DisplayWaitbar',false);
                    % Store the RAW IMAGE (not the flatfield/enhanced one) in a temporary variable
                    p3bImSetAligned(:,:,j) = imwarp(p3b(idx).imRaw,tform,'linear');
                    p3b(idx).imAligned = p3bImSetAligned(:,:,j);
                    % Update the waitbar
                    send(parDataQ,j);
                end

            case 'similarity'
                % Define the first image to align to
                p3bAlignTo = p3bImSet(:,:,lst(1));
                parfor j = 1:length(lst)
                    % Get the index value of the image
                    idx = lst(j);  
                    % Store temporary image slices
                    imTemp = p3bImSet(:,:,idx);
                    imRawTemp = p3bImRaw(:,:,idx);
                    % Get the image transform displacement field
                    tform = imregtform(imTemp,p3bAlignTo,opt.Transform,optimizer,metric);
                    p3bImSetAligned(:,:,j) = imwarp(imRawTemp,tform,'linear',OutputView=imref2d(szp3bAlignTo));
                    send(parDataQ,j);
                end
                % Take the parfor-processed values and put them in the p3b structure
                for j = 1:length(lst)
                    % Get the index value of the image
                    idx = lst(j); 
                    % Store the image
                    p3b(idx).imAligned = p3bImSetAligned(:,:,j);
                end
        end

        % Once the initial alignment has been performed, average the images within each class member
        avgSet(i).im = gather(mean(p3bImSetAligned,3));
    end
    close(f);

    % Function for the waitbar
    function nUpdateWaitbar(~)
        waitbar(p/length(p3b),f);
        p = p+1;
    end
end

