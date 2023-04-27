function p3bImShow(app,image)
    image = imNorm(image, Mode = app.modeRegister.Value,STDInterval = app.STDinterval.Value);
    %image = imNorm(image);
    cla(app.UIAxes);
    % Temporarily show the mean image intensity where ever
    % a NaN is present
    imshow(rot90(flip(image',2),2),'Parent',app.UIAxes);
    axis(app.UIAxes,'image');
end