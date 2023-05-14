function [AX] = get_axes(N,lx,mx,rx,dy,my,uy)
 
Nx = N(2);
Ny = N(1);
 
DX = (1-lx-(Nx-1)*mx-rx)/Nx;
DY = (1-dy-(Ny-1)*my-uy)/Ny;
 
for j = 1:Ny
    for i = 1:Nx
        if i==1 && j==1
            AX = axes('Units','normalized','Position',[lx+(i-1)*(DX+mx) dy+((Ny+1-j)-1)*(DY+my) DX DY]);
        else
            AX = [ AX; axes('Units','normalized','Position',[lx+(i-1)*(DX+mx) dy+((Ny+1-j)-1)*(DY+my) DX DY])];
        end
    end
end
 
end