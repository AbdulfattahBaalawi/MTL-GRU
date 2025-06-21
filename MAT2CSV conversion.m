% Define the folders using absolute paths directly
healthyFolder = 'C:\Users\User\Downloads\archive (37)\Healthy';
faultyFolder  = 'C:\Users\User\Downloads\archive (37)\Faulty';
outputFolder  = 'C:\Users\User\Documents\MATLAB\ExportedData';

% Create output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Process both folders
processFolder(healthyFolder, 'H', outputFolder);
processFolder(faultyFolder, 'F', outputFolder);

disp('Conversion completed.');

% --------- Function to process each folder ----------
function processFolder(folderPath, prefix, outputFolder)
    matFiles = dir(fullfile(folderPath, '*.mat'));
    
    for i = 1:length(matFiles)
        fileName = matFiles(i).name;
        filePath = fullfile(folderPath, fileName);
        
        % Load the .mat file
        dataStruct = load(filePath);

        % If the MAT file has only one variable, extract it
        varNames = fieldnames(dataStruct);
        if length(varNames) == 1
            data = dataStruct.(varNames{1});
        else
            data = dataStruct; % Keep full structure if multiple variables
        end
        
        % Convert to table
        if isnumeric(data)
            dataTable = array2table(data);
        elseif isstruct(data)
            try
                dataTable = struct2table(data);
            catch
                warning('File %s has complex structure, skipping.', fileName);
                continue;
            end
        else
            warning('Unsupported data type in %s. Skipping.', fileName);
            continue;
        end
        
        % Export to CSV
        [~, baseFileName, ~] = fileparts(fileName);
        csvFileName = fullfile(outputFolder, [baseFileName '.csv']);
        writetable(dataTable, csvFileName);
    end
end
