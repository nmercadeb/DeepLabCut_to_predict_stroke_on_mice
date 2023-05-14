firstOutliers  = [];

for o = 1:length(d)
    disp(['Video ' num2str(o) ' de ' num2str(length(d))])
    if windows
        nomcsv   = [d(o).folder '\' d(o).name];
        nomvideo = [v(o).folder '\' v(o).name];
        csvcapsa = [c(o).folder '\' c(o).name];
    else
        nomcsv   = [d(o).folder '/' d(o).name];
        nomvideo = [v(o).folder '/' v(o).name];
        csvcapsa = [c(o).folder '/' c(o).name];
    end
    m = strfind(v(o).name,'.mp4');
    nomcarpeta = v(o).name(1:m-1);
    video = VideoReader(nomvideo);
    D = video.NumFrames; Y = video.Height;
    % This function gives the coordinates with origin lower-left
    try
        [B] = DLCPostProcess(nomcsv,nomvideo);
        if windows
            copyfile('.\template.xlsx', [nomcsv(1:end-3) 'xlsx'])
        else
            copyfile('./template.xlsx', [nomcsv(1:end-3) 'xlsx'])
        end
        writematrix(B,[nomcsv(1:end-3) 'xlsx'],'Sheet', 'Sheet1', 'Range','A4')
    catch ERR
           % Outliers: middle tail point couldn't be allocated
    end
end



