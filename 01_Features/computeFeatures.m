nomsX = {};
nomsV = {};
nomsC = {};

for k = 1:length(d)
    nomsX{k} = d(k).name(1:end-46);
end

for k = 1:length(v)
    nomsV{k} = v(k).name(1:end-4);
end

for k = 1:length(c)
    nomsC{k} = c(k).name(1:end-44);
end

for k = 1:length(d)
    disp(['Video ' num2str(k) ' de ' num2str(length(d))])

    nomv = d(k).name(1:end-46);
    [~,loc_C] = ismember(nomv,nomsC);
    [~,loc_V] = ismember(nomv,nomsV);

    disp(T.TapeRemovalExperimental(loc_V))

    if windows
        nomcsv   = [d(k).folder     '\' d(k).name];
        nomvideo = [v(loc_V).folder '\' v(loc_V).name];
        csvcapsa = [c(loc_C).folder '\' c(loc_C).name];
    else
        nomcsv   = [d(k).folder     '/' d(k).name];
        nomvideo = [v(loc_V).folder '/' v(loc_V).name];
        csvcapsa = [c(loc_C).folder '/' c(loc_C).name];
    end


    data = scaleData(nomvideo, nomcsv, csvcapsa);

    [out, tabOut] = outlierByDistance(data);

    if windows
        writematrix(tabOut,'.\dades.xlsx','Range',eval('[ ''AG'' num2str(loc_V+1)]'),'AutoFitWidth',false);
    else
        writematrix(tabOut,'./dades.xlsx','Range',eval('[ ''AG'' num2str(loc_V+1)]'),'AutoFitWidth',false);
    end

    if ~ out
        table  = mouseGaite(data,nomvideo,nomv);
        [r, lligadura] = tapeRemovalTime(data, nomvideo, nomv);

        if windows
            writematrix(table(1:end-1),'.\dades.xlsx','Range',eval('[ ''H'' num2str(loc_V+1)]'),'AutoFitWidth',false);
            writematrix(r,'.\dades.xlsx','Range',eval('[ ''AA'' num2str(loc_V+1)]'),'AutoFitWidth',false);
            writematrix(lligadura,'.\dades.xlsx','Range',eval('[ ''AB'' num2str(loc_V+1)]'),'AutoFitWidth',false);
        else
            writematrix(table(1:end-1),'./dades.xlsx','Range',eval('[ ''H'' num2str(loc_V+1)]'),'AutoFitWidth',false);
            writematrix(r,'./dades.xlsx','Range',eval('[ ''AA'' num2str(loc_V+1)]'),'AutoFitWidth',false);
            writematrix(lligadura,'./dades.xlsx','Range',eval('[ ''AB'' num2str(loc_V+1)]'),'AutoFitWidth',false);
        end
    end
end