function [r, lligadura] = tapeRemovalTime_2(B, nomvideo, nomv)
% B = data;
%
% This function gives as an output how much time does it take for the mouse
% to take the tape off (in seconds). It distinguish if the tape is in the
% ipsilateral or contralateral paw.
%
% Inputs:
%  - B: data from bodyparts in centimeters, in the standard order
%  - nomvideo: path to the video
%  - nomv: name of the video file (without '.mp4')
%
% Outputs:
%  - r: time in seconds to remove the tape
%  - lligadura: paw with the tape (ipsilateral/contralateral)
%

% Video
video = VideoReader(nomvideo);
fps   = video.NumFrames/video.Duration;

B = B'; % Each row a bodypart coordinate
% Body parts
potaEX  = B(11,:);   potaEY  = B(12,:);
potaDX  = B(13,:);   potaDY  = B(14,:);
adhX    = B(15,:);   adhY    = B(16,:);

% Classifiquem els ratolins segons a quin costat els han fet la lligadura
% Si la lligadura és a l'esquerra, dreta = contralateral, esquerra =
% ipsilateral.
left  = [629, 631, 633, 634, 636, 637, 645, 654];
right = [638, 639, 640, 641, 642, 643, 644, 646, 647, 648, 649, 650, 651, 652, 653, 655, 656, 657];
ini=strfind(nomv,'(6');

% Busquem els parametres que necessitarem:
distanciaadhD=sqrt((potaDX-adhX).^2+(potaDY-adhY).^2);
distanciaadhE=sqrt((potaEX-adhX).^2+(potaEY-adhY).^2);
velocitatA=sqrt(((adhX(2:end)-adhX(1:end-1))).^2+((adhY(2:end)-adhY(1:end-1))).^2)*fps;
velocitatE=sqrt(((potaEX(2:end)-potaEX(1:end-1))).^2+((potaEY(2:end)-potaEY(1:end-1))).^2)*fps;
velocitatD=sqrt(((potaDX(2:end)-potaDX(1:end-1))).^2+((potaDY(2:end)-potaDY(1:end-1))).^2)*fps;

l  = 48; % frames to check in adavance to see if the tape is far from the paw
ft = 20;
st = 25;

if video.NumFrames/fps > 30
    start = round(video.NumFrames*0.9);
else
    start = round(video.NumFrames*0.55);
end

% En primer lloc mirem en quina pota porta l'adhesiu
if mean(distanciaadhE(1:round(length(distanciaadhE)/2)))<mean(distanciaadhD(1:round(length(distanciaadhE)/2))) % Enganxina a l'esquerra
    if ismember(eval(nomv(ini+1:ini+3)),left)
        lligadura = "Ipsilateral";
    elseif ismember(eval(nomv(ini+1:ini+3)),right)
        lligadura = "Contralateral";
    end

    T     = [];
    done  = false;
    vA    = ft;

    while isempty(T) && ~done

        for i = start:video.NumFrames-st-1
            if sum(abs(distanciaadhE(i:end)) > 1)/length(distanciaadhE(i:end)) > 0.95 && sum(abs(velocitatA(i+vA:end)) < 4)/length(velocitatA(i+vA:end)) > 0.95
                T    = i;
                done = true;
                break
            end
        end

        for i = start:video.NumFrames-st-1

            if i + l > video.NumFrames - 1
                l = video.NumFrames - 1 - i;
                vA = vA - 1;
            end

            if all(abs(distanciaadhE(i:i+l))>1) && sum(abs(velocitatA(i+vA:end)) < 3)/length(velocitatA(i+vA:end)) > 0.95
                T = i;
                break

            elseif all(abs(velocitatA(i:i+l))<2) % Velocity in ft frames is < 2cm/s
                for k = 1:l-st-1
                    % Check if meanwhile this happens, during st frames
                    % velocity of some paw is > 2, or distance tape-paw is > 1
                    if all(abs(velocitatE(i+k-1:i+k-1+st))>2) || all(abs(distanciaadhE(i+k-1:i+k-1+st))>1)
                        T = i;
                        break
                    end
                end

                if ~isempty(T)
                    break
                end
            end

        end
        done = true;
    end
    if isempty(T)
        r = video.Duration;
        T = video.NumFrames;
    else
        r = T/fps;
    end

elseif mean(distanciaadhD(1:round(length(distanciaadhE)/2)))<mean(distanciaadhE(1:round(length(distanciaadhE)/2)))
    disp("dreta")
    if ismember(eval(nomv(ini+1:ini+3)),left)
        lligadura = "Contralateral";
    elseif ismember(eval(nomv(ini+1:ini+3)),right)
        lligadura = "Ipsilateral";
    end

    T     = [];
    done  = false;
    vA    = ft;

    while isempty(T) && ~done

        for i = start:video.NumFrames-st-1
            if sum(abs(distanciaadhD(i:end)) > 1)/length(distanciaadhD(i:end)) > 0.95 && sum(abs(velocitatA(i+vA:end)) < 4)/length(velocitatA(i+vA:end)) > 0.95
                T    = i;
                done = true;
                break
            end
        end
        
        for i = start:video.NumFrames-st-1

            if i + l > video.NumFrames - 1
                l  = video.NumFrames - 1 - i;
                vA = vA - 1;
            end
            
            if all(abs(distanciaadhD(i:i+l))>1) && sum(abs(velocitatA(i+vA:end)) < 3)/length(velocitatA(i+vA:end)) > 0.95
                T = i;
                break

            elseif all(abs(velocitatA(i:i+l))<2) % Velocity in ft frames is < 2cm/s
                for k = 1:l-st-1
                    % Check if meanwhile this happens, during st frames
                    % velocity of some paw is > 2, or distance tape-paw is > 1
                    if all(abs(velocitatD(i+k-1:i+k-1+st))>2) || all(abs(distanciaadhD(i+k-1:i+k-1+st))>1)
                        T = i;
                        break
                    end
                end

                if ~isempty(T)
                    break
                end
            end

        end
        done = true;
    end

    if isempty(T)
        r = video.Duration;
        T = video.NumFrames;
    else
        r = T/fps;
    end
else
    disp('There''s no tape stick to its paw')
end

end