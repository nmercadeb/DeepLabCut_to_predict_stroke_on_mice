% DATA ----
if windows
    filePath_C = [path(1:id-1) projectFolder '\' analysesFolder '\Results\evaluationStroke.csv' ];
else
    filePath_C = [path(1:id-1) projectFolder '/' analysesFolder '/Results/evaluationStroke.csv' ];
end

dades_stroke = readtable(filePath_C);
TPind = dades_stroke.observed == 1 & (dades_stroke.predicted >= .5) == 1;
TNind = dades_stroke.observed == 0 & (dades_stroke.predicted >= .5) == 0;
FPind = dades_stroke.observed == 0 & (dades_stroke.predicted >= .5) == 1;
FNind = dades_stroke.observed == 1 & (dades_stroke.predicted >= .5) == 0;

f = figure(1);
f.Color = 'w';
f.Position(3:4) = [400 350];


red   = {[0 0.5 0.5 0], [0 0 0.5 0.5]; [0.5 1 1 0.5], [0.5 0.5 1 1]};
green = {[0.5 1 1 0.5], [0 0 0.5 0.5]; [0 0.5 0.5 0], [0.5 0.5 1 1]};

fill(red{1,1}, red{1,2},'r','FaceAlpha',0.25,'EdgeColor','none')
hold on
fill(green{1,1},green{1,2},'g','FaceAlpha',0.25,'EdgeColor','none')
fill(green{2,1},green{2,2},'g','FaceAlpha',0.25,'EdgeColor','none')
fill(red{2,1}, red{2,2},'r','FaceAlpha',0.25,'EdgeColor','none')

size_lab = 17;
% text(0.25,1.03,'Stroke','Interpreter','latex','HorizontalAlignment','center','FontSize',size_lab)
% text(0.75,1.03,'No stroke','Interpreter','latex','HorizontalAlignment','center','FontSize',size_lab)
% text(0.5,1.1,'OBSERVATIONS','Interpreter','latex','HorizontalAlignment','center','FontSize',size_lab-1)

axis([0 1 0 1])

red = [0.6350 0.0780 0.1840];
green = [0.4660 0.6740 0.1880];

plot(rand(1,sum(TNind))*0.49 + 0.505,dades_stroke.predicted(TNind),'o','Color',green,'MarkerFaceColor',green)
plot(rand(1,sum(FPind))*0.49 + 0.505,dades_stroke.predicted(FPind),'o','Color',red,'MarkerFaceColor',red)
plot(rand(1,sum(TPind))*0.49 + 0.005,dades_stroke.predicted(TPind),'o','Color',green,'MarkerFaceColor',green)
plot(rand(1,sum(FNind))*0.49 + 0.005,dades_stroke.predicted(FNind),'o','Color',red,'MarkerFaceColor',red)

text(0.25,0.75,[num2str(sum(TPind)/length(dades_stroke.predicted)*100, "%.2f") '\%'],'Interpreter','latex','HorizontalAlignment','center','FontSize',18)
text(0.75,0.75,[num2str(sum(FPind)/length(dades_stroke.predicted)*100, "%.0f") '\%'],'Interpreter','latex','HorizontalAlignment','center','FontSize',18)
text(0.25,0.25,[num2str(sum(FNind)/length(dades_stroke.predicted)*100, "%.2f") '\%'],'Interpreter','latex','HorizontalAlignment','center','FontSize',18)
text(0.75,0.25,[num2str(sum(TNind)/length(dades_stroke.predicted)*100, "%.2f") '\%'],'Interpreter','latex','HorizontalAlignment','center','FontSize',18)

% text(1.1,0.5,'PREDICTIONS','Interpreter','latex','HorizontalAlignment','center','FontSize',size_lab-1,'Rotation',270)
% text(1.025,0.25,'No stroke','Interpreter','latex','HorizontalAlignment','center','FontSize',size_lab,'Rotation',270)
% text(1.025,0.75,'Stroke','Interpreter','latex','HorizontalAlignment','center','FontSize',size_lab,'Rotation',270)

ylabel('Logistic regression prediction score','Interpreter','latex','FontSize',size_lab+6)

ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 14;
ax.YTick = 0:.1:1;
ax.YAxis.LineWidth = 1;
ax.XAxis.Visible = 'off';
box off

if windows
    print(f, [path(1:id-1) projectFolder '\' currentFolder '\' resultsFolder '\fig6_strokeModel.png'], '-r600', '-dpng')
else
    print(f, [path(1:id-1) projectFolder '/' currentFolder '/' resultsFolder '\fig6_strokeModel.png'], '-r600', '-dpng')
end