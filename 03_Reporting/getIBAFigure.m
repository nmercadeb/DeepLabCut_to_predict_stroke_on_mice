% DATA ----
if windows
    filePath_C = [path(1:id-1) projectFolder '\' analysesFolder '\Results\evaluationInfart.csv' ];
    filePath_CT = [path(1:id-1) projectFolder '\' analysesFolder '\Results\evaluationInfartTrain.csv' ];
else
    filePath_C = [path(1:id-1) projectFolder '/' analysesFolder '/Results/evaluationInfart.csv' ];
    filePath_CT = [path(1:id-1) projectFolder '/' analysesFolder '/Results/evaluationInfartTrain.csv' ];
end

dades_infart = readtable(filePath_C);
dades_infart_train = readtable(filePath_CT);

f = figure(1);
f.Color = 'w';
f.Position(3:4) = [500 500];

hold on
grid on
box off
maxim_y = max(dades_infart.predicted);
minim_y = min(dades_infart.predicted);

% linea 0
plot([0 0], [minim_y maxim_y], '--', 'Color', [.1 .1 .1], 'LineWidth', 0.9)
% 28 v
plot([28 28], [minim_y maxim_y], '--', 'Color', [.1 .1 .1], 'LineWidth', 0.9)
% 28 v
plot([0 maxim_y], [28 28], '--', 'Color', [.1 .1 .1], 'LineWidth', 0.9)
%abline
plot([0 100], [0 100], '-', 'Color', '#3a5a40', 'LineWidth', 0.9)

plot(dades_infart.observed, dades_infart.predicted,'o','Color','#a3b18a','MarkerFaceColor','#a3b18a')
plot(dades_infart_train.observed, dades_infart_train.predicted,'o','Color','#537a5a','MarkerFaceColor','#537a5a', 'MarkerSize',7)


ax = gca;
ax.Position(3:4) = [0.8 0.8];
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 14;
ax.YTick = 0:10:100;
ax.XTick = 0:10:100;
ax.YAxis.LineWidth = 1;
ax.XAxis.LineWidth = 1;
axis equal
axis([minim_y maxim_y minim_y maxim_y])

ylabel('Predicted IBA (\%)','Interpreter','latex','FontSize',18)
xlabel('Observed IBA (\%)','Interpreter','latex','FontSize',18)

if windows
    print(f, [path(1:id-1) projectFolder '\' currentFolder '\' resultsFolder '\fig7_infartModel.png'], '-r600', '-dpng')
else
    print(f, [path(1:id-1) projectFolder '/' currentFolder '/' resultsFolder '\fig7_infartModel.png'], '-r600', '-dpng')
end
