function exportPEEM(app)
    %Exports peem images
    % Save results
    [file,path] = uiputfile('*.tif','Save PEEM images');
    if ~ischar(file)
        return;
    end
    
    % Write raw XA- and XMCD-PEEM images
    A = app.imgRawXA';
    A(all(isnan(A),2),:) = [];
    A(1:10,:) = [];
    A(end-10:end,:) = [];
    A(:,all(isnan(A),1)) = [];
    A(:,1:10) = [];
    A(:,end-10:end) = [];
    t = Tiff(strcat(path,'AVG_',file),'w');
    tagstruct.ImageLength     = size(A,1);
    tagstruct.ImageWidth      = size(A,2);
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    %tagstruct.RowsPerStrip    = 16;
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(rot90(flip(single(A),2),2));
    t.close();
    
    A = app.imgRawXMCD';
    A(all(isnan(A),2),:) = [];
    A(1:10,:) = [];
    A(end-10:end,:) = [];
    A(:,all(isnan(A),1)) = [];
    A(:,1:10) = [];
    A(:,end-10:end) = [];
    t = Tiff(strcat(path,'Asymm_',file),'w');
    tagstruct.ImageLength     = size(A,1);
    tagstruct.ImageWidth      = size(A,2);
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    %tagstruct.RowsPerStrip    = 16;
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(rot90(flip(single(A),2),2));
    t.close();
    
    % Write flatfield XA- and XMCD-PEEM images
    A = app.imgXA';
    A(all(isnan(A),2),:) = [];
    A(1:10,:) = [];
    A(end-10:end,:) = [];
    A(:,all(isnan(A),1)) = [];
    A(:,1:10) = [];
    A(:,end-10:end) = [];
    t = Tiff(strcat(path,'Flat_AVG_',file),'w');
    tagstruct.ImageLength     = size(A,1);
    tagstruct.ImageWidth      = size(A,2);
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    %tagstruct.RowsPerStrip    = 16;
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(rot90(flip(single(A),2),2));
    t.close();
    
    A = app.imgXMCD';
    A(all(isnan(A),2),:) = [];
    A(1:10,:) = [];
    A(end-10:end,:) = [];
    A(:,all(isnan(A),1)) = [];
    A(:,1:10) = [];
    A(:,end-10:end) = [];
    t = Tiff(strcat(path,'Flat_Asymm_',file),'w');
    tagstruct.ImageLength     = size(A,1);
    tagstruct.ImageWidth      = size(A,2);
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    %tagstruct.RowsPerStrip    = 16;
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(rot90(flip(single(A),2),2));
    t.close();
end

