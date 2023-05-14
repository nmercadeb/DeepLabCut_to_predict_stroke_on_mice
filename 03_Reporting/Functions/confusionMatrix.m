function confusionMatrix(numFig, subPlotAxes, subPlotNum, yObs, yPred)

TPind = yObs == 1 & (yPred >= .5) == 1;
TNind = yObs == 0 & (yPred >= .5) == 0;
FPind = yObs == 0 & (yPred >= .5) == 1;
FNind = yObs == 1 & (yPred >= .5) == 0;

% Confusion matrix
f = figure(numFig); 
f.CurrentAxes = subPlotAxes(subPlotNum);
f.Color = 'w';
f.Position = [505   523   600  400];

red   = {[0 0.5 0.5 0], [0 0 0.5 0.5]; [0.5 1 1 0.5], [0.5 0.5 1 1]};
green = {[0.5 1 1 0.5], [0 0 0.5 0.5]; [0 0.5 0.5 0], [0.5 0.5 1 1]};

fill(red{1,1}, red{1,2},'r','FaceAlpha',0.25,'EdgeColor','none')
hold on
fill(green{1,1},green{1,2},'g','FaceAlpha',0.25,'EdgeColor','none')
fill(green{2,1},green{2,2},'g','FaceAlpha',0.25,'EdgeColor','none')
fill(red{2,1}, red{2,2},'r','FaceAlpha',0.25,'EdgeColor','none')

if subPlotNum == 2
    text(0.5,1.25,'COMPUTACIONAL','Interpreter','latex','HorizontalAlignment','center','FontSize',17)
elseif subPlotNum == 4
    text(0.5,1.25,'EXPERIMENTAL','Interpreter','latex','HorizontalAlignment','center','FontSize',17)
end
if subPlotNum == 2 || subPlotNum == 4 || subPlotNum == 9
    text(0.25,1.04,'Stroke','Interpreter','latex','HorizontalAlignment','center','FontSize',15)
    text(0.75,1.04,'No stroke','Interpreter','latex','HorizontalAlignment','center','FontSize',15)
    text(0.5,1.13,'OBSERVATIONS','Interpreter','latex','HorizontalAlignment','center','FontSize',15)
end

axis([0 1 0 1])

red = [0.6350 0.0780 0.1840];
green = [0.4660 0.6740 0.1880];

plot(rand(1,sum(TNind))*0.49 + 0.505,yPred(TNind),'o','Color',green,'MarkerFaceColor',green)
plot(rand(1,sum(FPind))*0.49 + 0.505,yPred(FPind),'o','Color',red,'MarkerFaceColor',red)
plot(rand(1,sum(TPind))*0.49 + 0.005,yPred(TPind),'o','Color',green,'MarkerFaceColor',green)
plot(rand(1,sum(FNind))*0.49 + 0.005,yPred(FNind),'o','Color',red,'MarkerFaceColor',red)

text(0.25,0.75,num2str(sum(TPind)),'Interpreter','latex','HorizontalAlignment','center','FontSize',18)
text(0.75,0.75,num2str(sum(FPind)),'Interpreter','latex','HorizontalAlignment','center','FontSize',18)
text(0.25,0.25,num2str(sum(FNind)),'Interpreter','latex','HorizontalAlignment','center','FontSize',18)
text(0.75,0.25,num2str(sum(TNind)),'Interpreter','latex','HorizontalAlignment','center','FontSize',18)

ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 14;
ax.YTick = 0:.2:1;
ax.XAxis.Visible = 'off';
box off

if subPlotNum == 1 || subPlotNum == 2
    
    ax.YTick = [0:0.2:1];

    if subPlotNum == 2
        ylabel('Train prediction score','Interpreter','latex','FontSize',16)
    else
        ylabel('Test prediction score','Interpreter','latex','FontSize',16)
    end
elseif subPlotNum == 3 || subPlotNum == 4
    text(1.12,0.5,'PREDICTIONS','Interpreter','latex','HorizontalAlignment','center','FontSize',15,'Rotation',270)
    text(1.04,0.25,'No stroke','Interpreter','latex','HorizontalAlignment','center','FontSize',15,'Rotation',270)
    text(1.04,0.75,'Stroke','Interpreter','latex','HorizontalAlignment','center','FontSize',15,'Rotation',270)
    ax.YTickLabel = {};

else
end
end