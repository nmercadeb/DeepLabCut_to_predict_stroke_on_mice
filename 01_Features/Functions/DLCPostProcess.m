function [B,ppcc] = DLCPostProcess(nomcsv,nomvideo)
%
% Input parameters:
%  - nomcsv: path to the CSV file extracted from DLC
%  - nomvideo: path to the video analyzed with DLC
% Output:
%  - B: matrix contaning label coordinates. Each column refears to a label,
%      likelihood not taken into account.
%
% ! If an error occures is due to the mouse tail. In some videos the
% location cannot be found because it cannot be distinguished from the cage
% edge.

video = VideoReader(nomvideo);
D  = video.NumFrames; Y = video.Height;

% GET FILTERED DATA FROM DEEPLABCUT ---------------------------------------
t = readtable(nomcsv);
t.Properties.VariableNames = {'scorer','nasX','nasY','Lnas','collX', ...
    'collY','Lcoll','culX','culY','Lcul','midcuaX','midcuaY','Lmidcua', ...
    'ficuaX','ficuaY','Lficua','potaEX','potaEY','LpotaE','potaDX', ...
    'potaDY','LpotaD','adhX','adhY','Ladh','potaeX','potaeY','Lpotae', ...
    'potadX','potadY','Lpotad'};

% Python starts at (0,0), matlab works starting in (1,1).
id = 2:3:size(t,2);  t{:,id} = t{:,id}+1;
id = 3:3:size(t,2);  t{:,id} = t{:,id}+1;


% Body parts (coordinates: lowerleft)
nas   = filter([t.nasX, t.nasY, t.Lnas],1);
coll  = filter([t.collX, t.collY, t.Lcoll],2);
cul   = filter([t.culX, t.culY, t.Lcul],3);
ficua = filter([t.ficuaX, t.ficuaY, t.Lficua],4);
adh   = filter([t.adhX, t.adhY, t.Ladh],5);
potaE = filter([t.potaEX, t.potaEY, t.LpotaE],6);
potaD = filter([t.potaDX, t.potaDY, t.LpotaD],7);
potae = filter([t.potaeX, t.potaeY, t.Lpotae],8);
potad = filter([t.potadX, t.potadY, t.Lpotad],9);

% MIDDLE TAIL POINT AND PAW CORRECTION ------------------------------------
midcua = middletail(cul,ficua);
midcua = midcua';
[PE,PD,pe,pd,ppcc] = pawcorrection (potaE,potaD,potae,potad,cul,nas);
potaEX = PE(1,:);  potaEY = PE(2,:);
potaDX = PD(1,:);  potaDY = PD(2,:);
potaeX = pe(1,:);  potaeY = pe(2,:);
potadX = pd(1,:);  potadY = pd(2,:);

% FINALLY ALL BODY PARTS --------------------------------------------------
% Origin: lower left 
B = [[1:D]' nas(1,:)' Y-nas(2,:)' coll(1,:)' Y-coll(2,:)' cul(1,:)' ...
    Y-cul(2,:)' midcua(1,:)' Y-midcua(2,:)' ficua(1,:)' Y-ficua(2,:)' potaEX' ...
    Y-potaEY' potaDX' Y-potaDY' adh(1,:)' Y-adh(2,:)' ... 
    potaeX' Y-potaeY' potadX' Y-potadY'];

%% FUNCTIONS
% Filter mouse parts -------------------------
    function dades = filter (inidades,t)
        th = .95;
        ind = find (inidades(:,3)<th); 
        if ismember(1,ind)
            ind(find(ind == 1))=[];
        end
        inidades(ind,1:2) = NaN;
        dadX = fillmissing(inidades(:,1),'linear','SamplePoints',1:D);
        dadY = fillmissing(inidades(:,2),'linear','SamplePoints',1:D);
        dades = [dadX'; dadY'; ones(1,length(dadX))];
    end

% Middle point -------------------------------
    function midcua = middletail(cul,ficua)
%         inici = 10;
%         midcua  = nan(D-inici+1,2);
        midcua  = nan(D,2);
        for i = 1:D
            % Llegim frame i la passem a blanc i negre
            I = read(video,i);
            Ig = rgb2gray(I);
            % Posició en píxels del cul i de la cua
            x_cul = [round(cul(1,i)) round(cul(2,i))];
            x_fic = [round(ficua(1,i)) round(ficua(2,i))];
            % Busquem edges en la imatge usant 3 metodes diferents -->
            % imatge binària
            [BW1] = edge(Ig,'prewitt');
            [BW2] = edge(Ig,'Sobel');
            [BW3] = edge(Ig,'Roberts');
            % Sumem el resultat dels 3 metodes (treballem en binari)
            BW = BW1 | BW2 | BW3;
            % Enllacem aquells píxels que no s'han ajuntat
            BW = bwmorph(BW,'bridge',50);
            th = 0:pi/50:2*pi; r = 15;
            BW(round(x_cul(2)+ r.*cos(th)),round(x_cul(1)+r.*sin(th))) = 1; % Marquem el cul
            BW(round(x_fic(2)+ r.*cos(th)),round(x_fic(1)+r.*sin(th))) = 1; % Marquem el final de la cua
            BW = imfill(BW,'holes'); % Omplim la cua
            bl = bwlabel(BW,8); % Etiquetem les diferents arees
            % Ens quedem amb la que conté la cua
            bl = bl==bl(x_cul(2),x_cul(1));
            s = bwskel(bl); % Dibuixem l'esquelet
            [row,col] = find(s);
            % Quin és el punt del esquelet més proper al cul --> nou cul
            dc = (row-x_cul(2)).^2 + (col-x_cul(1)).^2;
            [~,ic] = min(dc); % Index de la posició del cul en l'esquelet
            %xn_cul = [row(ic),col(ic)]; % Posició del cul
            % Igual amb el final de la cua
            df = (row-x_fic(2)).^2 + (col-x_fic(1)).^2;
            [~,ifc] = min(df);
            ij = [row, col];
            % Les distàncies entre tots els punts de l'esqulet:
            A = pdist2(ij,ij);
            % Ens quedem nomes amb els punts concatenats, és a dir, aquells
            % en que la distància entre ells és 1 o sqrt(2)=1,4...
            A(A>1.5)=0;
            G = graph(A);
            % Distancies dels punts del graph amb el cul
            dc = distances(G,ic);
            % Distancies dels punts del graph amb la ficua
            df = distances(G,ifc);
            [~,im] = min(abs(dc-df));
            midcua(i,:) = [col(im) row(im)];
        end
    end

% Paw correction -------------------------------
    function [PE,PD,pe,pd,pawchange] = pawcorrection (potaE,potaD,potae,potad,cul,nas)
        pawchange = 0;

        fe = sqrt((nas(1,:)-potaE(1,:)).^2+(nas(2,:)-potaE(2,:)).^2);
        fd = sqrt((nas(1,:)-potaD(1,:)).^2+(nas(2,:)-potaD(2,:)).^2);
        ie = sqrt((nas(1,:)-potae(1,:)).^2+(nas(2,:)-potae(2,:)).^2);
        idr = sqrt((nas(1,:)-potad(1,:)).^2+(nas(2,:)-potad(2,:)).^2);

        mice = [cul(1,:)-nas(1,:); cul(2,:)-nas(2,:); ones(1,D)];
        fme = [potaE(1,:)-nas(1,:); potaE(2,:)-nas(2,:); ones(1,D)];
        fmd = [potaD(1,:)-nas(1,:); potaD(2,:)-nas(2,:); ones(1,D)];
        ime = [potae(1,:)-nas(1,:); potae(2,:)-nas(2,:); ones(1,D)];
        imd = [potad(1,:)-nas(1,:); potad(2,:)-nas(2,:); ones(1,D)];
        PE = nan(2,D); PD = nan(2,D); pe = nan(2,D); pd = nan(2,D);
        for i = 1:D
            % Front/hind correction: for now right and left are not taken into
            % account, capital letters are used for front paws.
            [~,front] = mink([fe(i), fd(i), ie(i), idr(i)],2);
            % P/p: paw coordinate      
            % F/f: distance vector
            [P1,P2,p1,p2,F1,F2,f1,f2] = fronthind(potaE,potaD,potae,potad,front,i,fmd,fme,imd,ime);
            % Let's see wheter it is left or right.
            [COS1,C1] = cosinus(mice(:,i),F1); [COS2,C2] = cosinus(mice(:,i),F2);
            [cos1,c1] = cosinus(mice(:,i),f1); [cos2,c2] = cosinus(mice(:,i),f2);
            % Front paws: C positive --> right.
            if C1*C2>=0 % Both on same side of the mouse, we look at the angle
                if C1 >= 0 % Both on the right side
                    [~,dreta] = max([COS1,COS2]);
                    if dreta == 1
                        PD(:,i) = P1; PE(:,i) = P2;
                    else
                        PD(:,i) = P2; PE(:,i) = P1;
                    end
                elseif C1 <= 0 % Both on the left side
                    [~,esquerra] = max([COS1,COS2]);
                    if esquerra == 1
                        PD(:,i) = P2; PE(:,i) = P1;
                    else
                        PD(:,i) = P1; PE(:,i) = P2;
                    end
                end
            else
                if C1 >= 0
                    PD(:,i) = P1; PE(:,i) = P2;
                else
                    PD(:,i) = P2; PE(:,i) = P1;
                end
            end
            % Hind paws: c positive --> left.
            % For the hind paws we take the vector from the nose to the paw, and
            % the vector from the nose to the butt. It is done to avoid the case
            % in which hind paws are behind the but or in the same line.
            if c1*c2>=0 % Both on same side of the mouse, we look at the angle
                if c1 >= 0 % Both on the rigth side
                    [~,dreta] = max([cos1,cos2]);
                    if dreta == 1
                        pe(:,i) = p2; pd(:,i) = p1;
                    else
                        pe(:,i) = p1; pd(:,i) = p2;
                    end
                elseif c1 <= 0 % Both on the left side
                    [~,esquerra] = max([cos1,cos2]);
                    if esquerra == 1
                        pe(:,i) = p1; pd(:,i) = p2;
                    else
                        pd(:,i) = p2; pe(:,i) = p1;
                    end
                end
            else
                if c1 >= 0 
                    pe(:,i) = p2; pd(:,i) = p1;
                else
                    pe(:,i) = p1; pd(:,i) = p2;
                end
            end
             if any(PE(:,i) ~= potaE(1:2,i)) | any(PD(:,i) ~= potaD(1:2,i)) | ...
                     any(pd(:,i) ~= potad(1:2,i)) | any(pe(:,i) ~= potae(1:2,i))
                 pawchange = pawchange + 1;
             end
        end        
    end

% Intern function for paw correction 1
    function [P1,P2,p1,p2,F1,F2,f1,f2] = fronthind(potaE,potaD,potae,potad,front,i,fmd,fme,imd,ime)

        if ismember(front,[1,2])
            P1 = potaD(1:2,i); P2 = potaE(1:2,i);
            p1 = potad(1:2,i); p2 = potae(1:2,i);
            F1 = fmd(:,i);     F2 = fme(:,i);
            f1 = imd(:,i);     f2 = ime(:,i);
        elseif ismember(front,[1,3]) % Change hind left for front right
            P1 = potaE(1:2,i); P2 = potae(1:2,i);
            p1 = potaD(1:2,i); p2 = potad(1:2,i);
            F1 = fme(:,i);     F2 = ime(:,i);
            f1 = fmd(:,i);     f2 = imd(:,i);
        elseif ismember(front,[1,4]) % Change hind right for front right
            P1 = potaE(1:2,i); P2 = potad(1:2,i);
            p1 = potaD(1:2,i); p2 = potae(1:2,i);
            F1 = fme(:,i);     F2 = imd(:,i);
            f1 = fmd(:,i);     f2 = ime(:,i);
        elseif ismember(front,[2,3]) % Change hind left for front left
            P1 = potaD(1:2,i); P2 = potae(1:2,i);
            p1 = potaE(1:2,i); p2 = potad(1:2,i);
            F1 = fmd(:,i);     F2 = ime(:,i);
            f1 = fme(:,i);     f2 = imd(:,i);
        elseif ismember(front,[2,4]) % Change hind right for front left
            P1 = potaD(1:2,i); P2 = potad(1:2,i);
            p1 = potaE(1:2,i); p2 = potae(1:2,i);
            F1 = fmd(:,i);     F2 = imd(:,i);
            f1 = fme(:,i);     f2 = ime(:,i);
        elseif ismember(front,[3,4]) % Change both front for both hind
            P1 = potad(1:2,i); P2 = potae(1:2,i);
            p1 = potaD(1:2,i); p2 = potaE(1:2,i);
            F1 = imd(:,i);     F2 = ime(:,i);
            f1 = fmd(:,i);     f2 = fme(:,i);
        end
    end

% Intern function for paw correction 2
    function [cos,c] = cosinus(u,v)
        CosTheta = max(min(dot(u(1:2),v(1:2))/(norm(u(1:2))*norm(v(1:2))),1),-1);
        cos = real(acosd(CosTheta));
        cc = cross(u,v);
        c = cc(3);
    end
end
