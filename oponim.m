% Performs math on image sets
function im = oponim(app,mode)
    arguments
        app
        mode {mustBeMember(mode,['asymm','avg','ratio'])}
    end

    % Perform an asymmetry calculation based on whatever image A and B have been selected
    % Find out the indices of app.avgSet which corresponds with whatever dropdown value was selected
    idxA = find(round(vertcat(app.avgSet.tag),1) == app.imADrop.Value);
    idxB = find(round(vertcat(app.avgSet.tag),1) == app.imBDrop.Value);
    imA = double(app.avgSet(idxA).imAligned);
    imB = double(app.avgSet(idxB).imAligned);

    % Performs the calculations
    switch mode
        case 'asymm'; im = (imA - imB) ./ (imA + imB);
        case 'avg';   im = (imA + imB) / 2;
        case 'ratio'; im = imA ./ imB;
    end
end

