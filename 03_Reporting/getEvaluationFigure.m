% DLC DATA ----
visualResults = readtable('./visualCorrectionDLC.xlsx','Range','A2:E5631');

left  = [629, 631, 633, 634, 636, 637, 645, 654];
right = [638, 639, 640, 641, 642, 643, 644, 646, 647, 648, 649, 650, 651, 652, 653, 655, 656, 657];

ini = strfind(visualResults.Var1,'(6'); ini = cell2mat(ini); ini = ini(1:10:end);
videonames = visualResults.Var1(1:10:end);

L = visualResults.Var4; E = visualResults.Var5;

percCorrect = sum(E)/length(E);
percWrong   = sum(E == 0)/length(E);
TP = sum(E == 1 & L >  0.95)/length(E);
TN = sum(E == 0 & L <= 0.95)/length(E);
FP = sum(E == 1 & L <= 0.95)/length(L <= 0.95);
FN = sum(E == 0 & L >  0.95)/length(E);
bodyPart    = {"All", "Nose","Neck","Bottom","End tail","FL paw","FR paw","Tape","HL paw","HF paw"};

col = lines(2);

BPs =  {"NAS","COLL","CUL","FICUA","POTAE","POTAD","ADHESIU","POTAe","POTAd"};
BPchar = {"Nose","Neck","Bottom","End tail","FL paw","FR paw","Tape","HL paw","HR paw"};
BP = visualResults.Var3;

% TR DATA ----
T = dades(~isnan(dades.TapeRemovalExperimental) & all(table2array(dades(:, 33:38))./dades.TotalFrames <= .1, 2), :);
exp  = T.TapeRemovalExperimental;
comp = T.TapeRemoval;

numVid = length(exp);
cau_ind   = exp == 0;
good_ind  = abs(exp-comp) <= 2 & ~cau_ind;
wrong_ind =  ~good_ind & ~cau_ind;

% FIGURE 1 ----
f = figure(1);
clf
f.Position = [100 100 900 800];

lx = 0.1;   mx = 0.1; rx = 0.05;
dy = 0.075; my = 0.125; uy = 0.03;
DX = (1-lx-(2-1)*mx-rx)/2;
DY = (1-dy-(2-1)*my-uy)/2;

AX = axes('Units','normalized','Position',[lx dy+(DY+my)  DX*2+mx DY-uy/2], 'Parent',f); 
AX = [AX; axes('Units','normalized','Position',[lx dy DX DY], 'Parent',f)];
AX = [AX; axes('Units','normalized','Position',[lx+(DX+mx) dy DX DY], 'Parent',f)];

fontSize = 15;

% SUBPLOT 1 ----
f.CurrentAxes = AX(1);
hold on

tcolor = [129, 178, 154]./256;
fcolor = [199, 81, 70]./256;
pos = 0.5:1.5:length(BPs)*1.5;

boxchart(NaN,NaN, ...
    'JitterOutliers','on','MarkerStyle','.','BoxWidth',0.05, 'BoxFaceColor', tcolor, ...
    'BoxFaceAlpha', 0.4, 'MarkerColor', tcolor)
boxchart(NaN,NaN, ...
    'JitterOutliers','on','MarkerStyle','.','BoxWidth',0.05, 'BoxFaceColor', fcolor, ...
    'BoxFaceAlpha', 0.4, 'MarkerColor', fcolor)

mx = [pos(1:2:end)'-0.5 pos(1:2:end)'+1 pos(1:2:end)'+1 pos(1:2:end)'-.5];
my = [zeros(6,1) zeros(6,1) ones(6,1) ones(6,1)];

for jj = 1:size(mx,1)
    fill(mx(jj,:), my(jj,:), [.95 .95 .95], 'EdgeColor', [.95 .95 .95])
end

for j = 1:length(BPs)
    boxchart(find(E==1 & BP == BPs{j}).*0 + pos(j),L(E == 1 & BP == BPs{j}), ...
        'JitterOutliers','on','MarkerStyle','.','BoxWidth',0.25, 'BoxFaceColor', tcolor, ...
        'BoxFaceAlpha', 0.4, 'MarkerColor', tcolor)
    boxchart(find(E~=1 & BP == BPs{j}).*0+0.5 + pos(j),L(E ~= 1 & BP == BPs{j}), ...
        'JitterOutliers','on','MarkerStyle','.','BoxWidth',0.25, 'BoxFaceColor', fcolor, ...
        'BoxFaceAlpha', 0.4, 'MarkerColor', fcolor)
    ax = gca;
    ax.XAxis.Visible = 'off';
    ax.YTick = 0:.1:1;
    ax.FontSize = fontSize;
    ax.TickLabelInterpreter = 'latex';
    ylabel('DLC likelihood','FontSize',fontSize, 'interpreter', 'latex')

    percCorrect = [percCorrect sum(E(BP == BPs{j}))/sum(BP == BPs{j})];
    percWrong   = [percWrong sum(E(BP == BPs{j}) == 0)/sum(BP == BPs{j})];
    TP = [TP sum(E == 1 & L >  0.95 & BP == BPs{j})/length(BP == BPs{j})];
    TN = [TN sum(E == 0 & L <= 0.95 & BP == BPs{j})/length(BP == BPs{j} & E == 0)];
    FP = [FP sum(E == 1 & L <= 0.95 & BP == BPs{j})/length(BP == BPs{j})];
    FN = [FN sum(E == 0 & L >  0.95 & BP == BPs{j})/length(BP == BPs{j})];

    text(pos(j), 1.03, [num2str(percCorrect(end)*100, '%.1f') '$\%$'], 'HorizontalAlignment','center', 'FontSize', 12, 'Interpreter', 'latex', 'Color', [.4, .4, .4])
    text(pos(j) + 0.5, -0.04, [num2str(percWrong(end)*100, '%.1f') '$\%$'], 'HorizontalAlignment','center', 'FontSize', 12, 'Interpreter', 'latex', 'Color', [.4, .4, .4])
end

axis([-0.1  14.7 0 1])
text(pos+0.25, 0.*pos-0.115, BPchar, 'HorizontalAlignment', 'center', 'FontSize', fontSize, 'Interpreter', 'latex')
l = legend('True','False','Interpreter', 'latex', 'Location','bestoutside');
% l.NumColumns = 2;
l.Position(1:2) = [0.88 .75];
l.Box = 'off';
l.FontSize = 12;

if windows
    writetable(table(bodyPart', percCorrect', percWrong', TP', TN', FP', FN',  'VariableNames',{'Label name', 'True', 'False', 'TP', 'TN', 'FP', 'FN'}), ...
        [path(1:id-1) projectFolder '\' currentFolder '\' resultsFolder '\evaluationDLC.xlsx'])
else
    writetable(table(bodyPart', percCorrect', percWrong', TP', TN', FP', FN', 'VariableNames',{'Label name', 'True', 'False', 'TP', 'TN', 'FP', 'FN'}), ...
        [path(1:id-1) projectFolder '/' currentFolder '/' resultsFolder '\evaluationDLC.xlsx'])
end

text(-1, 1.05, 'A', 'FontSize', 18, 'FontWeight', 'bold')
text(-1,  -.3, 'B', 'FontSize', 18, 'FontWeight', 'bold')
text(7.1, -.3, 'C', 'FontSize', 18, 'FontWeight', 'bold')


% SUBPLOT 2 ----
f.CurrentAxes = AX(2);
hold on

colors = [
    0, 0.4470, 0.7410;  % Blue
    0.8500, 0.3250, 0.0980;  % Orange
    0.9290, 0.6940, 0.1250;  % Yellow
    0.4940, 0.1840, 0.5560;  % Purple
    0.4660, 0.6740, 0.1880;  % Green
    0.3010, 0.7450, 0.9330;  % Light blue
    0.6350, 0.0780, 0.1840;  % Red
    0.5170, 0.5170, 0.5170;  % Gray
    0.9290, 0.6940, 0.8390   % Pink
];

% Set the ColorOrder property to the colors
set(AX(2), 'ColorOrder', colors);

for j = 1:length(BPs)
plot(nan,nan, '-o', 'LineWidth',1.8, 'Color', colors(j,:), 'MarkerEdgeColor', colors(j,:), 'MarkerFaceColor', colors(j,:))
end
for j = 1:length(BPs)
rocComp = rocmetrics(E(BP == BPs{j}), L(BP == BPs{j}), 1);
plot(rocComp, 'LineWidth',1.8, 'ShowConfidenceIntervals', 1, ...
    'ShowDiagonalLine', false, 'Color', colors(j,:))
end

ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = fontSize;
ax.XTick = 0:.2:1;
ax.YTick = 0:.2:1;
axis([0 1 0 1])
ylabel('True Positive Rate','Interpreter','latex','FontSize',fontSize)
xlabel('False Positive Rate','Interpreter','latex','FontSize',fontSize)
box on

legend(BPchar, 'Location', 'southeast', 'interpreter', 'latex')


% SUBPLOT 3 ----
f.CurrentAxes = AX(3);
hold on
box on

scatter(exp(good_ind),comp(good_ind),'o','MarkerFaceColor','#0072BD','MarkerEdgeColor','#0072BD')
scatter(exp(~good_ind & ~cau_ind),comp(~good_ind & ~cau_ind),'o','MarkerFaceColor','#4DBEEE','MarkerEdgeColor','#4DBEEE','MarkerFaceAlpha',0.6,'MarkerEdgeAlpha',0.8)
scatter(exp(cau_ind),comp(cau_ind),'o','MarkerFaceColor',[105, 161, 151]./256,'MarkerEdgeColor',[105, 161, 151]./256,'MarkerFaceAlpha',0.6,'MarkerEdgeAlpha',0.8)

scatter(exp(good_ind),comp(good_ind),'o','MarkerFaceColor','#0072BD','MarkerEdgeColor','#0072BD')
plot([0 200],[0 200],'Color','#0072BD','LineWidth',1)
scatter(exp(cau_ind),comp(cau_ind),'o','MarkerFaceColor',[105, 161, 151]./256,'MarkerEdgeColor',[105, 161, 151]./256,'MarkerFaceAlpha',0.6,'MarkerEdgeAlpha',0.8)


ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = fontSize;
ax.XTick = ax.YTick;
xlabel('Experimental time (s)', 'interpreter', 'latex', 'FontSize', fontSize)
ylabel('Computational time (s)', 'interpreter', 'latex', 'FontSize', fontSize)
l = legend(['$\|$t$_{exp}$ - t$_{comp}\| \leq$ 2 (' num2str(sum(good_ind)/length(good_ind(~cau_ind))*100, '%.2f') '$\%$)'], ...
    ['$\|$t$_{exp}$ - t$_{comp}\| >$ 2 (' num2str(sum(~good_ind & ~cau_ind)/length(good_ind(~cau_ind))*100, '%.2f') '$\%$)'], ...
    'Tape falls', 'interpreter', 'latex', 'FontSize', fontSize-1, 'Location','northwest');

if windows
    print(f, [path(1:id-1) projectFolder '\' currentFolder '\' resultsFolder '\fig3_evaluation.png'], '-r600', '-dpng')
else
    print(f, [path(1:id-1) projectFolder '/' currentFolder '/' resultsFolder '\fig3_evaluation.png'], '-r600', '-dpng')
end




