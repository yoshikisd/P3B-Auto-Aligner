function asymmetryCalc(app,sigma)
    % Calculates the XA and asymmetry images
    % Ask the user whether they want to use RCP-LCP or LCP-RCP convention
    convention = app.convention;
    
    % Define two matrices to save the averaged polarization-dependent images
    [width,height] = size(app.p3b(1).imageAligned);
    [~,numImages] = size(app.p3b);
    imgRCP = zeros(width,height);
    imgLCP = imgRCP;
    % Loop through all images, taking the average value for each polarization
    currentStatus = uiprogressdlg(app.UIFigure,'Message','Performing flatfield correction and calculating XA and asymmetry');
    for i = 1:numImages
        % Bullshit fix: since imflatfield doesn't like NaN, save a separate image that has the nan cropped out
        A = app.p3b(i).imageAligned;
        A(all(isnan(A),2),:) = [];
        A(:,all(isnan(A),1)) = [];
        A = imflatfield(A,sigma);
        B = app.p3b(i).imageAligned;
        B(~isnan(B)) = 1;
        B(B==1) = A;
        % Reinsert A into the matrix
        if app.p3b(i).polarization == 0.9
            imgRCP = imgRCP + B;
        elseif app.p3b(i).polarization == -0.9
            imgLCP = imgLCP + B;
        end
        currentStatus.Value = i/numImages;
    end

    app.imgXA = (imgRCP + imgLCP) / 2;

    switch convention
        case '(RCP-LCP)/Sum'
            app.imgXMCD = (imgRCP - imgLCP)./(imgRCP + imgLCP);
        case '(LCP-RCP)/Sum'
            app.imgXMCD = (imgLCP - imgRCP)./(imgRCP + imgLCP);
    end
    % Display aligned images
    % Alter the slider limit to reflect the amount of p3b images imported
    %app.view_imageSpinner.Value = 1;
    %app.view_imageSpinner.Enable = 1;
    % Alter the dropdown menu to show the raw p3b images
    app.view_imageType.Value = "Flatfield asymmetry";
    app.view_imageType.Enable = 1;
    app.view_imagePlaySeries.Enable = 1;
    app.flatSigma.Enable = 1;
    % Show the first image in the axes window
    p3bImShow(app,app.imgXMCD);
    close(currentStatus);
end

