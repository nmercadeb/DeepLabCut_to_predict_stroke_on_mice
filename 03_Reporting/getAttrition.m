% GET VIDEO COUNTS ----
% 1-
Reason    = "Number of videos recorded";
N         = length(v);
Npre      = sum(ismember(dades.Test, 'TR - PRE'));
Np24      = sum(ismember(dades.Test, 'TR - POST - 24H'));
Np48      = sum(ismember(dades.Test, 'TR - POST - 48H'));
Np72      = sum(ismember(dades.Test, 'TR - POST - 72H'));
excluded  = 0;
attrition = table(Reason,N,Npre,Np24,Np48,Np72,excluded);
% 2-
Reason    = "Middle tail point estimation";
N         = length(d);
ind       = dades.Test(~isnan(dades.Outilers1));
Npre      = sum(ismember(ind, 'TR - PRE'));
Np24      = sum(ismember(ind, 'TR - POST - 24H'));
Np48      = sum(ismember(ind, 'TR - POST - 48H'));
Np72      = sum(ismember(ind, 'TR - POST - 72H'));
excluded  = attrition.N(1) - N;
attrition = [attrition; table(Reason,N,Npre,Np24,Np48,Np72,excluded)];
% 3-
Reason    = "Outliers by distance";
excluded  = sum(any(table2array(dades(~isnan(dades.Outilers1), 33:38))./dades.TotalFrames(~isnan(dades.Outilers1)) > .1, 2));
N         = attrition.N(2) - excluded;
ind       = ind(all(table2array(dades(~isnan(dades.Outilers1), 33:38))./dades.TotalFrames(~isnan(dades.Outilers1)) <= .1, 2));
Npre      = sum(ismember(ind, 'TR - PRE'));
Np24      = sum(ismember(ind, 'TR - POST - 24H'));
Np48      = sum(ismember(ind, 'TR - POST - 48H'));
Np72      = sum(ismember(ind, 'TR - POST - 72H'));
attrition = [attrition; table(Reason,N,Npre,Np24,Np48,Np72,excluded)];

if windows
    outputPath = [path(1:id-1) projectFolder '\' currentFolder '\' resultsFolder '\attrition.xlsx'];
else
    outputPath = [path(1:id-1) projectFolder '/' currentFolder '/' resultsFolder '/attrition.xlsx'];
end
writetable(attrition, outputPath)
