function convertDataFile

inputFile = 'data/bdt-eccv10.mat';
outputFile = 'data/bdt-eccv10-nostats.mat';

% create copy
copyfile(inputFile, outputFile);

% this should be run on a computer *with* the statistics toolbox installed
classifier = load(inputFile, 'classifier'); classifier = classifier.classifier;

for i=1:length(classifier)
    for t=1:length(classifier{i}.wcs)
        classifier{i}.wcs(t).dt = convertToStruct(classifier{i}.wcs(t).dt);
    end
end

save(outputFile, 'classifier', '-append');


    function struct = convertToStruct(inputClass)

        fNames = fieldnames(inputClass);

        for f=1:length(fNames)
            struct.(fNames{f}) = inputClass.(fNames{f});
        end
    end
end