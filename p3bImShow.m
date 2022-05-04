function p3bImShow(app,image)
    cla(app.UIAxes);
    meanImg = mean(image,'all','omitnan');
    stdImg = std(image,0,'all','omitnan');
    imshow(mat2gray(rot90(flip(image',2),2),meanImg + 3*stdImg*[-1 1]),'Parent',app.UIAxes);
    axis(app.UIAxes,'image');
end