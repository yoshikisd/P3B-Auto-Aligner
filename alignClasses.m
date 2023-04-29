% Align the different classes of p3b images
% Should take the output of alignClassMembers as the input
function avgSet = alignClasses(avgSet,opt)
arguments 
    avgSet
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
    end

    for i = 1:length(avgSet)
        % Store the info about the transformation operation that was performed
        avgSet(i).optsImAligned = opt;

        % Since we're only iterating a few times, I'll just put the switch
        % statement in the for loop rather than doing it the other way around
        switch opt.Mode
            case 'demon'
                % Get the image transform displacement field
                [tform,~] = imregdemons(avgSet(i).im,avgSet(1).im,opt.iterVal,...
                    "AccumulatedFieldSmoothing",opt.smoothVal,...
                    "PyramidLevels",opt.pyLevel,...
                    'DisplayWaitbar',false);
                % Transform and store
                avgSet(i).imAligned = imwarp(avgSet(i).im,tform,'linear');
            case 'similarity'
                % Get the image transform displacement field
                tform = imregtform(avgSet(i).im,avgSet(1).im,opt.Transform,optimizer,metric);
                % Transform and store
                avgSet(i).imAligned = imwarp(avgSet(i).im,tform,'linear',OutputView=imref2d(size(avgSet(1).im)));
        end
    end
end

