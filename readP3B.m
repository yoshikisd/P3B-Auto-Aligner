function s=readP3B(filename)
% function s=readP3B(filename)
% Courtesy of R. Ogliore

fid=fopen(filename);

s=struct;

ntags=fread(fid,1,'long');

for ii=1:ntags
    tagnamelength=fread(fid,1,'long');
    tagname=fread(fid,tagnamelength,'*char')';
    datatype=fread(fid,1,'long');
    switch datatype
    case 1
        matlabdatatype='uint8';
    case 2
        matlabdatatype='int16';
    case 3
        matlabdatatype='int32';
    case 4
        matlabdatatype='single';
    case 5
        matlabdatatype='double';
    case 7
        matlabdatatype='*char';
    case 12
        matlabdatatype='uint16';
    case 13
        matlabdatatype='uint32';
    case 14
        matlabdatatype='int64';
    case 15
        matlabdatatype='uint64';
    otherwise
        matlabdatatype='uint'; % No COMPLEX, DCOMPLEX
    end
    
    
    datalength=fread(fid,1,'long');
    data=fread(fid,datalength,matlabdatatype);    

    eval(['[s(:).' tagname ']=data;']);

    
end

fclose(fid);


