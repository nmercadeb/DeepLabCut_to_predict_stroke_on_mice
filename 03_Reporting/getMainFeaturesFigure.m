% DATA ----
if windows
    T = readtable([path(1:id-1) projectFolder '\' analysesFolder '\Results\dataForStrokeModel.xlsx']);
else
    T = readtable([path(1:id-1) projectFolder '/' analysesFolder '/Results/dataForStrokeModel.xlsx']);
end

featuresToPlot = T(:,8:end-1);
featuresToPlot = featuresToPlot.Properties.VariableNames;

ig = ~isnan(dades.vm_paw_ipsi) & ~isnan(dades.vm_paw_contra);  % Those with good computational removal time
T = dades(ig,["Test" "Infart" featuresToPlot]);

features = table2array(T(:,3:end));
indpre = ismember(T.Test,'TR - PRE');
ind24 = ismember(T.Test,'TR - POST - 24H');
ind48 = ismember(T.Test,'TR - POST - 48H');
ind72 = ismember(T.Test,'TR - POST - 72H');
indI = T.Infart > 0;

ylabs = {'Distance (cm)', 'Time fraction ($\%$)', 'Velocity (cm/s)', ...
    'Velocity (cm/s)', 'Velocity (cm/s)', 'Velocity (cm/s)', ...
    'Velocity (cm/s)', 'Velocity (cm/s)',...
    'Distance (cm)', 'Distance (cm)' ...
    'Time fraction ($\%$)', 'Time (s)'};

titles = {'Distance travelled', 'Moving time','Mean nose velocity' ...
     'Mean bottom velocity', 'Mean tail velocity', ...
    'Mean FI paw velocity', 'Mean FC paw velocity' ...
    'Mean HI paw velocity', 'Mean HC paw velocity','Distance between Fpaws', ...
    'Time tail C', 'Tape removal'};

legFontSize   = 12;
titleFontSize = 16;
axFontSizeY   = 14;
axFontSizeX   = 16;
labFontSize   = 15;

f = figure(1);
f.Position = [246   202   787   790];
clf

lx = 0.07; rx = 0.02; mx = 0.08;
dy = 0.1; my = 0.05; uy = 0.04;
[AX] = get_axes_sorted([4,3],lx,mx,rx,dy,my,uy); % subplot: [files, columnes] 


cmap = colormap(summer);
coli = cmap(floor(256/6),:);
coln = [0 0 0];


for k = 1:12 % nombre de variables a plotjear
        v1i = features(indpre & indI,k);        v1n = features(indpre & ~indI,k);
        v2i = features(ind24 & indI,k);         v2n = features(ind24 & ~indI,k);
        v3i = features(ind48 & indI,k);         v3n = features(ind48 & ~indI,k);
        v4i = features(ind72 & indI,k);         v4n = features(ind72 & ~indI,k);

    f.CurrentAxes = AX(k);
    hold on, box on
    
    if k == 9 % Per la llegenda
        plot(nan,nan,'-o','Color',coln,'MarkerEdgeColor',coln,'MarkerFaceColor',coln, 'MarkerSize',10)
        plot(nan,nan,'*','Color',coln,'MarkerSize',13)
        plot(nan,nan,'-s','Color',coli,'MarkerEdgeColor',coli,'MarkerFaceColor',coli, 'MarkerSize',10)       
        plot(nan,nan,'*','Color',coli,'MarkerSize',13)
        plot(nan,nan,'*','Color',[1, 1, 1])        
         plot(nan,nan,'*','Color',[170, 204, 0]./256,'MarkerSize',13)
    end
    
    errorbar([1 2 3 4],[mean(v1n) mean(v2n) mean(v3n) mean(v4n)],[(std(v1n)/sqrt(length(v1n)))*1.96 ...
        (std(v2n)/sqrt(length(v2n)))*1.96 (std(v3n)/sqrt(length(v3n)))*1.96 (std(v4n)/sqrt(length(v4n)))*1.96], ...
        '-o','Color',coln,'MarkerEdgeColor',coln,'MarkerFaceColor',coln, 'LineWidth', .9, 'MarkerSize', 7)

    errorbar([1 2 3 4],[mean(v1i) mean(v2i) mean(v3i) mean(v4i)],[(std(v1i)/sqrt(length(v1i)))*1.96 ...
        (std(v2i)/sqrt(length(v2i)))*1.96 (std(v3i)/sqrt(length(v3i)))*1.96 (std(v4i)/sqrt(length(v4i)))*1.96], ...
        '-s','Color',coli,'MarkerEdgeColor',coli,'MarkerFaceColor',coli, 'LineWidth', .9, 'MarkerSize', 7)

    axis padded
    box off
    ax = gca;
    ax.XTick = 1:4;
    ax.XTickLabel = {'Pre', '24h', '48h', '72h'};
    ax.YAxis.FontSize = axFontSizeY;   
    ax.XAxis.FontSize = axFontSizeX;
    ylabel(ylabs{k}, 'Interpreter','latex', 'FontSize', labFontSize)
    
    lims = ax.YAxis.Limits;
    perc = 10; numPunts = 4;
    z = perc*(lims(2)-lims(1))/100/numPunts;
    ax.YAxis.Limits(1) = lims(1) - 4*z;
    ax.YAxis.Limits(2) = lims(2) + 2*z;
    ax.TickLabelInterpreter = 'latex';
    lims = ax.YAxis.Limits;
    z = perc*(lims(2)-lims(1))/100/numPunts;
    fs = 23;
    strokeClass = {'n','i'};

    if k < 10
        ax.XAxis.TickLabels = {};
        ax.XAxis.TickLength(1) = 0.02;
    end

    for o = 1:4 % PRE - POST 24, 48, 72
        % No stroke vs. stroke
        var1 = eval(['v' num2str(o) 'n']);
        var2 = eval(['v' num2str(o) 'i']);
        an = anova1([var1;var2],[var1.*0+1;var2.*0+2],'off');
        xpos = o;
        ypos = z*2;

        if an < 0.05
            text(xpos,lims(2)-ypos*1.1,'*','Color',[170, 204, 0]./256,'HorizontalAlignment','center','FontSize',fs, 'FontWeight','bold')
        end
    end
    
    col = [[.1 .1 .1]; coli*0.9];
    for o = 1:3 % amb PRE
        for j = 1:2 % no stroke, stroke
            var1 = eval(['v1'  strokeClass{j}]);
            var2 = eval(['v' num2str(o+1) strokeClass{j}]);
            an = anova1([var1;var2],[var1.*0+1;var2.*0+2],'off');
            xpos = o + .95;
            ypos = z*0.7;

            if j == 2
                ypos = z*3;
                xpos = xpos + 0.1;
            end
            if an < 0.05 
                text(xpos,lims(1)+ypos,'*','Color',col(j,:),'HorizontalAlignment','center','FontSize',fs, 'FontWeight','bold')
            end
        end
    end

    plot([1.5 1.5],[-1000 1000],'--','Color',[0.7 .7 .7],'LineWidth',1)
    title(titles{k},'Interpreter','latex' ,'FontWeight','bold','FontSize',titleFontSize)
    ax.XAxis.Limits = [0.6 4.4];

    if k == 9
        leg = legend('No stroke (NS)','NS: pre - post', 'Stroke (S)','S: pre - post', ' ','NS - S');        
        leg.NumColumns = 5;
        leg.Position(1:2) = [0.5-leg.Position(3)/2 0.01];
        leg.FontSize = legFontSize;
        leg.Interpreter = 'latex';
    end

end

if windows
    print(f, [path(1:id-1) projectFolder '\' currentFolder '\' resultsFolder '\fig5_mainFeatures.png'], '-r600', '-dpng')
else
    print(f, [path(1:id-1) projectFolder '/' currentFolder '/' resultsFolder '\fig5_mainFeatures.png'], '-r600', '-dpng')
end