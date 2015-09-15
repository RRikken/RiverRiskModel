
Directory = 'Data\*.txt';
FileNames = dir(Directory);
NumberOfFileIds = length(FileNames);
Values = cell(1,NumberOfFileIds);

for K = 1:NumberOfFileIds
    load(FileNames(K).name);
end