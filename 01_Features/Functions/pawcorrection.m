function [PE,PD,pe,pd,pawchange] = pawcorrection (potaE,potaD,potae,potad,cul,nas,D)
pawchange = 0;

fe = sqrt((cul(1,:)-potaE(1,:)).^2+(cul(2,:)-potaE(2,:)).^2);
fd = sqrt((cul(1,:)-potaD(1,:)).^2+(cul(2,:)-potaD(2,:)).^2);
ie = sqrt((cul(1,:)-potae(1,:)).^2+(cul(2,:)-potae(2,:)).^2);
idr = sqrt((cul(1,:)-potad(1,:)).^2+(cul(2,:)-potad(2,:)).^2);

mice = [cul(1,:)-nas(1,:); cul(2,:)-nas(2,:); ones(1,D)];
fme = [potaE(1,:)-nas(1,:); potaE(2,:)-nas(2,:); ones(1,D)];
fmd = [potaD(1,:)-nas(1,:); potaD(2,:)-nas(2,:); ones(1,D)];
ime = [potae(1,:)-nas(1,:); potae(2,:)-nas(2,:); ones(1,D)];
imd = [potad(1,:)-nas(1,:); potad(2,:)-nas(2,:); ones(1,D)];
PE = nan(2,D); PD = nan(2,D); pe = nan(2,D); pd = nan(2,D);
for i = 1:D
    % Front/hind correction: for now right and left are not taken into
    % account, capital letters are used for front paws.
    [~,hind] = mink([fe(i), fd(i), ie(i), idr(i)],2);
    % P/p: paw coordinate
    % F/f: distance vector
    [P1,P2,p1,p2,F1,F2,f1,f2] = fronthind(potaE,potaD,potae,potad,hind,i,fmd,fme,imd,ime);
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
    % Hind paws: c positive --> right.
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
                pe(:,i) = p2; pd(:,i) = p1;
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
function [P1,P2,p1,p2,F1,F2,f1,f2] = fronthind(potaE,potaD,potae,potad,hind,i,fmd,fme,imd,ime)

if ismember(hind,[1,2])
    p1 = potaD(1:2,i); p2 = potaE(1:2,i);
    P1 = potad(1:2,i); P2 = potae(1:2,i);
    f1 = fmd(:,i);     f2 = fme(:,i);
    F1 = imd(:,i);     F2 = ime(:,i);
elseif ismember(hind,[1,3]) % Change hind left for front right
    p1 = potaE(1:2,i); p2 = potae(1:2,i);
    P1 = potaD(1:2,i); P2 = potad(1:2,i);
    f1 = fme(:,i);     f2 = ime(:,i);
    F1 = fmd(:,i);     F2 = imd(:,i);
elseif ismember(hind,[1,4]) % Change hind right for front right
    p1 = potaE(1:2,i); p2 = potad(1:2,i);
    P1 = potaD(1:2,i); P2 = potae(1:2,i);
    f1 = fme(:,i);     f2 = imd(:,i);
    F1 = fmd(:,i);     F2 = ime(:,i);
elseif ismember(hind,[2,3]) % Change hind left for front left
    p1 = potaD(1:2,i); p2 = potae(1:2,i);
    P1 = potaE(1:2,i); P2 = potad(1:2,i);
    f1 = fmd(:,i);     f2 = ime(:,i);
    F1 = fme(:,i);     F2 = imd(:,i);
elseif ismember(hind,[2,4]) % Change hind right for front left
    p1 = potaD(1:2,i); p2 = potad(1:2,i);
    P1 = potaE(1:2,i); P2 = potae(1:2,i);
    f1 = fmd(:,i);     f2 = imd(:,i);
    F1 = fme(:,i);     F2 = ime(:,i);
elseif ismember(hind,[3,4]) % Change both front for both hind
    p1 = potad(1:2,i); p2 = potae(1:2,i);
    P1 = potaD(1:2,i); P2 = potaE(1:2,i);
    f1 = imd(:,i);     f2 = ime(:,i);
    F1 = fmd(:,i);     F2 = fme(:,i);
end
end

% Intern function for paw correction 2
function [cos,c] = cosinus(u,v)
CosTheta = max(min(dot(u(1:2),v(1:2))/(norm(u(1:2))*norm(v(1:2))),1),-1);
cos = real(acosd(CosTheta));
cc = cross(u,v);
c = cc(3);
end