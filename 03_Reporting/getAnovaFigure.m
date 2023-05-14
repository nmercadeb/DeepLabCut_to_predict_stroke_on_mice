% DATA ----
if windows
    load([path(1:id-1) projectFolder '\' analysesFolder '\Results\statisticalResults.mat'])
else
    load([path(1:id-1) projectFolder '/' analysesFolder '/Results/statisticalResults.mat'])
end

tapeSide = true;


% FIGURE DATA ----
% Labels:
ylabels = {'Distance travelled', 'Moving time', 'Mean nose velocity' ...
    'Mean bottom velocity', 'Mean tail velocity', ...
    'Mean FI paw velocity', 'Mean FC paw velocity' ...
    'Mean HI paw velocity', 'Mean HC paw velocity' ...
    'Mean velocity when moving', 'Distance between Fpaws', 'Distance between Hpaws' ...
    'Mouse length', 'Time tail I' ...
    'Time tail C', 'Time straight tail', 'Time body I' ...
    'Time body C', 'Time straight body', 'Tape removal', 'Tape removal I', 'Tape removal C'};

posXlabel = 25;

if ~tapeSide
    ylabels = ylabels(1:end-2);

    a2 = a2(1:end-2,:);
    a3 = a3(1:end-2,:);
    a4 = a4(1:end-2,:);

    posXlabel = posXlabel - 2;
end

xlabelsPRE    = {'24h','48h','72h'};
xlabelsGROUPS = {'Pre','24h','48h','72h'};

% ANOVA BETWEEN GROUPS
% No stroke - stroke
[ro21, co21] = ind2sub(size(an2),find(an2 <= 0.05 & an2 > 0.01));
[ro22, co22] = ind2sub(size(an2),find(an2 <= 0.01));

% No stroke - Mild stroke
[ro31, co31] = ind2sub(size(an3),find(an3 <= 0.05 & an3 > 0.01));
[ro32, co32] = ind2sub(size(an3),find(an3 <= 0.01));

% No stroke - Severe stroke
[ro41, co41] = ind2sub(size(an4),find(an4 <= 0.05 & an4 > 0.01));
[ro42, co42] = ind2sub(size(an4),find(an4 <= 0.01));


num = 1000; % for degradation
m   = 9;    % Marker size
d   = 0.2;  % Distance between markers
fontSize = 14;

% Color per comparison with pre surgery:
c1 = [109, 152, 134]./255;
c2 = [1 1 1];
c3 = [66, 129, 164]./255;

map = [[linspace(c1(1),c2(1),num)'; linspace(c2(1),c3(1),num)'], ...
       [linspace(c1(2),c2(2),num)'; linspace(c2(2),c3(2),num)'], ...
       [linspace(c1(3),c2(3),num)'; linspace(c2(3),c3(3),num)']];

% Figure and axes:
rx = .18; mx = .03; lx = .3;   
dy = .13;  my = 0;  uy = .05;

f = figure(1);
clf
f.Position(3:4) = [700 500];

AX = get_axes([1,3],lx,mx,rx,dy,my,uy);

% Colormap positions:
poscolormapGROUPS = rx + mx*2 + (1-lx-mx*2-rx)*1.33;
posY_Xlabel = -0.1; 

% Label sizes:
sizeXlabel           = 16;
sizeXlabelPRE        = 12;
colorbarFontSizeSub  = 12;
colormapFontSize     = 15;
colormapLabelPos1    = 6;
colormapPos3         = 0.01;
axisFontSize         = 15;
axisXFontSize        = 14;

% SUBPLOT 1: NO STROKE - STROKE
imagesc(AX(1), a2)
box(AX(1), 'off')
hold(AX(1), 'on')

plot(AX(1),co22+d,ro22,'*k','MarkerSize',m)
plot(AX(1),co22-d,ro22,'*k','MarkerSize',m)
plot(AX(1),co21,ro21,'*k','MarkerSize',m)
% text(AX(1),2.5, 24.1, 'Time test', 'Interpreter','latex','HorizontalAlignment','center','FontSize', sizeXlabel)
text(AX(1),6.94, 23/2, 'Ref: mice which did not develop stroke', 'Interpreter','latex','Rotation', 90, 'HorizontalAlignment','center','FontSize', colorbarFontSizeSub)

ax = AX(1);
ax.YTickLabel = ylabels;
ax.YTick = 1:22;
ax.XTickLabel = xlabelsGROUPS;
ax.XTick = 1:4;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = axisFontSize; 
ax.XAxis.FontSize = axisXFontSize;

colormap(AX(1), map)
clim([-1 1])

title(AX(1), 'NS - S', 'FontSize', fontSize, 'Interpreter','latex')



% SUBPLOT 2: NO STROKE - MILD STROKE
imagesc(AX(2), a3)
box(AX(2), 'off')
hold(AX(2), 'on')

ax = AX(2);
ax.YAxis.Visible = 'off';
ax.XTickLabel = xlabelsGROUPS;
ax.XTick = 1:4;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = axisFontSize; 
ax.XAxis.FontSize = axisXFontSize;
clear ax

plot(AX(2),co32+d,ro32,'*k','MarkerSize',m)
plot(AX(2),co32-d,ro32,'*k','MarkerSize',m)
plot(AX(2),co31,ro31,'*k','MarkerSize',m)
text(AX(2),2.5, posXlabel, 'Time test', 'Interpreter','latex','HorizontalAlignment','center','FontSize', sizeXlabel)
text(AX(2),6.94, 23/2, 'Ref: mice which did not develop stroke', 'Interpreter','latex','Rotation', 90, 'HorizontalAlignment','center','FontSize', colorbarFontSizeSub)

colormap(AX(2), map)
clim([-1 1])

title(AX(2), 'NS - MS', 'FontSize', fontSize, 'Interpreter','latex')

% SUBPLOT 2: NO STROKE - MILD STROKE
imagesc(AX(3), a4)
box off
hold(AX(3), 'on')

ax = AX(3);
ax.YAxis.Visible = 'off';
ax.XTickLabel = xlabelsGROUPS;
ax.XTick = 1:4;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = axisFontSize; 
ax.XAxis.FontSize = axisXFontSize;
clear ax

plot(AX(3),co42+d,ro42,'*k','MarkerSize',m)
plot(AX(3),co42-d,ro42,'*k','MarkerSize',m)
plot(AX(3),co41,ro41,'*k','MarkerSize',m)

title(AX(3), 'NS - SS', 'FontSize', fontSize, 'Interpreter','latex')

colormap(AX(3), map)
clim([-1 1])
colBarGroups = colorbar(AX(3));
colBarGroups.Label.String      = 'Normalized median error';
colBarGroups.Label.Interpreter = 'latex';
colBarGroups.Label.Rotation    = 90;
colBarGroups.Label.FontSize    = colormapFontSize;
colBarGroups.Position(1)       = poscolormapGROUPS;
colBarGroups.Position(3)       = colormapPos3;
colBarGroups.Label.Position(1) = colormapLabelPos1;
colBarGroups.TickLabelInterpreter = 'latex';

text(AX(3),colormapLabelPos1 + 2, 23/2, '(relative to NS)', 'Interpreter','latex','Rotation', 90, 'HorizontalAlignment','center','FontSize', colorbarFontSizeSub)


if windows
    print(f, [path(1:id-1) projectFolder '\' currentFolder '\' resultsFolder '\fig4_anova.png'], '-r600', '-dpng')
else
    print(f, [path(1:id-1) projectFolder '/' currentFolder '/' resultsFolder '/fig4_anova.png'], '-r600', '-dpng')
end