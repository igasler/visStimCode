function [Xpos,Ypos, sizeX, sizeY]=calculate_deg2patches(n_patches,mousepos,mouseDistancecm,scr_cm,scr_pix)
viewy=[atan(-mousepos(2)/mouseDistancecm),atan((scr_cm(2)-mousepos(2))/mouseDistancecm)];
viewx=[atan(-mousepos(1)/mouseDistancecm),atan((scr_cm(1)-mousepos(1))/mouseDistancecm)];
field_of_view=[viewx(2)-viewx(1), viewy(2)-viewy(1)];

cmppix=scr_cm(1)/scr_pix(1);
incX_deg=field_of_view(1)/n_patches(1)
incY_deg=field_of_view(2)/n_patches(2)


Xdeg(1)=viewx(1);
Xdeg(n_patches(1)+1)=viewx(2);
Ydeg(1)=viewy(1);
Ydeg(n_patches(2)+1)=viewy(2);

Xpos(1)=1;
Xpos(n_patches(1)+1)=scr_pix(1);
Ypos(1)=1;
Ypos(n_patches(2)+1)=scr_pix(2);


for aa=2:n_patches(1)
    Xdeg(aa)=Xdeg(aa-1)+incX_deg;
    Xpos(aa)=ceil((tan(Xdeg(aa))*mouseDistancecm+mousepos(1))/cmppix); %in pix
    
end

for aa=2:n_patches(2)
    Ydeg(aa)=Ydeg(aa-1)+incY_deg;
    Ypos(aa)=ceil((tan(Ydeg(aa))*mouseDistancecm+mousepos(2))/cmppix);   
end
Xdeg
Ydeg
for i=1:n_patches(1)
    sizeX(i)=Xpos(i+1)-Xpos(i);    
    
end

for i=1:n_patches(2)
    sizeY(i)=Ypos(i+1)-Ypos(i);    
end

end
