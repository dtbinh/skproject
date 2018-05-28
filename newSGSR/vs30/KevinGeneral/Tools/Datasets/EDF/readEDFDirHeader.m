function Header = readEDFDirHeader(fid)

%B. Van de Sande 29-07-2003

%Word Number (32-bit)    Contents
%--------------------    --------
%        1-3             Animal ID (12 characters)
%        4               No. of current entries
%        5               Size of directory (in blocks of 512 bytes)
%        6               Unused
%        7-8             Date last modified (DD-MMMYY)
%        9-16            Unused

frewind(fid);

AnimalID     = lower(deblank(char(freadVAXG(fid, 12, 'uchar')')));
NEntries     = freadVAXG(fid,  1, 'uint32');
DirSize      = freadVAXG(fid,  1, 'uint32');
Dummy        = freadVAXG(fid,  1, 'uint32');
LastModified = EDFDate2Vec(deblank(char(freadVAXG(fid,  8, 'uchar')')));

Header = CollectInStruct(AnimalID, NEntries, DirSize, LastModified);