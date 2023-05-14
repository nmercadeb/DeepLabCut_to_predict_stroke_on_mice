function getDensityPlots(ObsPred, subPlotAxes, numFig, subPlotNum)
panel = {'A', 'B', 'C', 'D'};

f = figure(numFig); 
f.CurrentAxes = subPlotAxes(subPlotNum);
hold on, box on

x = 0:0.01:1;

pd = fitdist(ObsPred(ObsPred(:,1) == 1,2), 'Beta');
y = pdf(pd, x);
area(x,y, 'FaceColor','#569DAA', 'EdgeColor','none','FaceAlpha',0.5)

pd = fitdist(ObsPred(ObsPred(:,1) == 0,2), 'Beta');
y = pdf(pd, x);
area(x,y, 'FaceColor','#F7D060','EdgeColor','none','FaceAlpha',0.5)

xlabel('Predicted value', 'FontSize',14, 'Interpreter','latex')
ylabel('Density', 'Interpreter','latex')

ax = gca;
ax.FontSize = 14;
ax.TickLabelInterpreter = 'latex';
ax.XTick = 0:0.2:1;

if subPlotNum == 1
    xlabel(' ', 'FontSize',14, 'Interpreter','latex')
elseif subPlotNum == 2
    xlabel(' ', 'FontSize',14, 'Interpreter','latex')
ylabel(' ', 'Interpreter','latex')
elseif subPlotNum == 4
    ylabel(' ', 'Interpreter','latex')
    l = legend('Stroke', 'No stroke');
    l.Position(1:2) = [0.5-l.Position(3)/2, 0.001];
    l.NumColumns = 2;
    l.Interpreter = 'latex'
end

axis([0 1 0 9])

TP = sum(ObsPred(:,1) == (ObsPred(:,2) > .5) & ObsPred(:,1) == 1);
TN = sum(ObsPred(:,1) == (ObsPred(:,2) > .5) & ObsPred(:,1) == 0);
FP = sum(ObsPred(:,1) ~= (ObsPred(:,2) > .5) & ObsPred(:,1) == 0);
FN = sum(ObsPred(:,1) ~= (ObsPred(:,2) > .5) & ObsPred(:,1) == 1);


ACC = num2str(sum(ObsPred(:,1) == (ObsPred(:,2) > .5))/length(ObsPred(:,1)),'%.2f');
SE  = num2str(TP / (FN + TP),'%.2f');
SP  = num2str(TN / (FP + TN),'%.2f');
PPV = num2str(TP / (TP + FP),'%.2f');
NPV = num2str(TN / (TN + FN),'%.2f');

Tstring1 = '  \bfACC\rm        \bfSE\rm         \bfSP\rm        \bfPPV\rm       \bfNPV\rm ';
Tstring2 = '\bf\_\_\_\_\_\rm     \bf\_\_\_\_\_\rm     \bf\_\_\_\_\_\rm     \bf\_\_\_\_\_\rm     \bf\_\_\_\_\_\rm';
Tstring3 = ['' ACC '       ' SE '       ' SP '       ' PPV '       ' NPV];

text(0.5, 7.7, Tstring1, 'HorizontalAlignment','center', 'VerticalAlignment', 'baseline')
text(0.5, 7.6,Tstring2, 'HorizontalAlignment','center', 'VerticalAlignment', 'baseline')
text(0.5, 6.9,Tstring3, 'HorizontalAlignment','center', 'VerticalAlignment', 'baseline')
if subPlotNum == 1 || subPlotNum == 3
text(-0.2, 9.2, panel(subPlotNum), 'FontSize', 16, 'FontWeight', 'bold')
else
    text(-0.13, 9.2, panel(subPlotNum), 'FontSize', 16, 'FontWeight', 'bold')
end

end