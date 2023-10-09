T   = dades(~isnan(dades.Distance), :); 

features = table2array(T(:,8:27));

indpre = ismember(T.Test, 'TR - PRE');
ind24 = ismember(T.Test, 'TR - POST - 24H');
ind48 = ismember(T.Test, 'TR - POST - 48H');
ind72 = ismember(T.Test, 'TR - POST - 72H');
inc = ismember(T.TapeSide, 'Contralateral');
ini = ~ismember(T.TapeSide, 'Contralateral');
indI = T.Infart > 0;

features = table2array(T(:,8:27));


% Generate matrix to save results
[~,l] = size(features);
a11  = nan(l+1,3);    a12  = a11;    a13  = a11;    a14  = a11; % relative difference with PRE
an11 = nan(l+1,3);    an12 = a11;    an13 = a11;    an14 = a11; % anova with PRE
a2   = nan(l+1,4);    a3   = a2;     a4   = a2;     a5   = a2;  % relative difference between groups: no-yes, no-mild, no-severe, mild-severe
an2  = nan(l+1,4);    an3  = a2;     an4  = a2;     an5  = a2;  % anova between groups: " " " "
li   = a2;            po   = a2;     bi   = a2;                 % lineal, exponential, and bionmial regressions

index = [indpre ind24 ind48 ind72];
for i = 1:l+2
     % 1. Amb els respectius PRE
    if i == l+2 
        fpre    = features(index(:,1) & ini,l);
        infpre  = T.Infart(index(:,1) & ini);
    elseif i == l+1
        pre     = features(index(:,1) & inc,l);
        infpre  = T.Infart(index(:,1) & inc);
    else
            fpre = features(index(:,1),i);
            infpre  = T.Infart(index(:,1));
    end
    infpre(isnan(fpre)) = [];        fpre(isnan(fpre))   = []; 

    preno   = fpre(find(~infpre));
    presi   = fpre(find(infpre));
    prelleu = fpre(find(infpre<28 & infpre>0));
    presev  = fpre(find(infpre>=28));
    
    % ANOVA WITH PRE
    for j = 1:3
        if i == l+2
            feature = features(index(:,j+1) & inc,l);
            Infart = T.Infart(index(:,j+1) & inc);
        elseif i == l+1
            feature = features(index(:,j+1) & ini,l);
            Infart = T.Infart(index(:,j+1) & ini);
        else
            feature = features(index(:,j+1),i);
            Infart = T.Infart(index(:,j+1));
        end        
        sev  = find(Infart >= 28);
        lleu = find(Infart > 0 & Infart < 28);
        fno   = feature(find(~Infart));  fno(isnan(fno))     = [];
        fsi   = feature(find(Infart));   fsi(isnan(fsi))     = [];
        flleu = feature(lleu);            flleu(isnan(flleu)) = [];
        fsev  = feature(sev);             fsev(isnan(fsev))   = [];
        %   1.1. NO
        a11(i,j) = (median(preno) - median(fno))/median(preno);
        %   1.2. SI
        a12(i,j) = (median(presi) - median(fsi))/median(presi);
        %   1.3. LLEU
        a13(i,j) = (median(prelleu) - median(flleu))/median(prelleu);
        %   1.4. SEVER
        a14(i,j) = (median(presev) - median(fsev))/median(presev);

        %   1.1. NO      
        an11(i,j) = anova1([preno;fno],[preno.*0+1;fno.*0+2],'off');
        %   1.2. SI
        an12(i,j) = anova1([presi;fsi],[presi.*0+1;fsi.*0+2],'off');
        %   1.3. LLEU
        an13(i,j) = anova1([prelleu;flleu],[prelleu.*0+1;flleu.*0+2],'off');
        %   1.4. SEVER
        an14(i,j) = anova1([presev;fsev],[presev.*0+1;fsev.*0+2],'off');
    end
    
    % ANOVA BETWEEN GROUPS
    for k = 1:4
        if i == l+2
            feature = features(index(:,k) & inc,l);
            Infart = T.Infart(index(:,k) & inc);
        elseif i == l+1
            feature = features(index(:,k) & ini,l);
            Infart = T.Infart(index(:,k) & ini);
        else
            feature = features(index(:,k),i);
            Infart = T.Infart(index(:,k));
        end       
        Infart(isnan(feature))  = [];
        feature(isnan(feature)) = [];
        sev  = find(Infart >= 28);
        lleu = find(Infart > 0 & Infart < 28);
        fno   = feature(find(~Infart));  fno(isnan(fno))     = [];
        fsi   = feature(find(Infart));   fsi(isnan(fsi))     = [];
        flleu = feature(lleu);           flleu(isnan(flleu)) = [];
        fsev  = feature(sev);            fsev(isnan(fsev))   = [];
        % 2. Entre NO - SI
        a2(i,k) = (median(fno) - median(fsi))/sqrt(median(fno)^2 + median(fsi)^2);
        an2(i,k) = anova1([fno;fsi],[fno.*0+1;fsi.*0+2],'off');
        % 3. Entre NO - LLEU
        a3(i,k) = (median(fno) - median(flleu))/sqrt(median(fno)^2 + median(flleu)^2);
        an3(i,k) = anova1([fno;flleu],[fno.*0+1;flleu.*0+2],'off');
        % 4. Entre NO - SEVER
        a4(i,k) = (median(fno) - median(fsev))/sqrt(median(fno)^2 + median(fsev)^2);
        an4(i,k) = anova1([fno;fsev],[fno.*0+1;fsev.*0+2],'off');
        % 5. Entre LLEU - SEVER
        a5(i,k) = (median(flleu) - median(fsev))/sqrt(median(flleu)^2 + median(fsev)^2);
        an5(i,k) = anova1([flleu;fsev],[flleu.*0+1;fsev.*0+2],'off');

        % LINEAR, EXPONENTIAL & LOGISTIC REGRESSIONS 
        [c,~]=corr(Infart,feature);
        mdl2 = fitlm(Infart,feature);
        if mdl2.Coefficients.pValue(2) <= 0.05
            li(i,k) = c;
        end

        mdl1 = fitglm(Infart,feature,'Distribution','poisson');        
        if mdl1.Coefficients.pValue(2) <= 0.05
            x = linspace(0,0.8,1e3)';
            [yhat,yci] = predict(mdl1,100*x);
            po(i,k) = yhat(end)-yhat(1);
        end

        ictus      = zeros(length(Infart),1);
        ind        = find(Infart>0);
        ictus(ind) = 1;
        mdl3 = fitglm(feature,ictus,'Distribution','binomial');       
        if mdl3.Coefficients.pValue(2) <= 0.05
            xb = linspace(min(feature),max(feature),1e3)';
            [yhatb,ycib] = predict(mdl3,xb);
            bi(i,k) = yhatb(end)-yhatb(1);
        end
    end
end



if windows
    save('.\Results\statisticalResults.mat', ...
        'a11', 'a12', 'a13', 'a14', ...
        'an11', 'an12', 'an13', 'an14', ...
        'a2', 'a3', 'a4', 'a5', ...
        'an2', 'an3', 'an4', 'an5', ...
        'li', 'po', 'bi', '-mat')
else
    save('./Results/statisticalResults.mat', ...
        'a11', 'a12', 'a13', 'a14', ...
        'an11', 'an12', 'an13', 'an14', ...
        'a2', 'a3', 'a4', 'a5', ...
        'an2', 'an3', 'an4', 'an5', ...
        'li', 'po', 'bi', '-mat')
end

% Create table with statistical significant results:

inlcude = any(an2(1:end-2,2:end)' < 0.05) | any(an3(1:end-2,2:end)' < 0.05) | any(an4(1:end-2,2:end)' < 0.05);
exclude = (an2(1:end-2,1) < 0.05)' | (an3(1:end-2,1) < 0.05)' | (an4(1:end-2,1) < 0.05)';

startingFeatures_index = find(inlcude & ~exclude) + 7;
ind   = ~ismember(dades.Test,'TR - PRE') & ~isnan(dades.vm_paw_ipsi) & ~isnan(dades.vm_paw_contra);
T = dades(ind,[1:7, startingFeatures_index, 30]);
%%
if windows
    writetable(T, '.\Results\dataForStrokeModel.xlsx')
else
    writetable(T, './Results/dataForStrokeModel.xlsx')
end

