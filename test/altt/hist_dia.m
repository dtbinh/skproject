%contra
subplot(2,2,1)
dia_contra_all=[dia_89021_22contra;...
    dia_87039_10contra;...
    dia_87102_7contra;...
    dia_89007_39contra;...
    dia_87039_9contra;...
    dia_89141_27contra;...
    dia_88107_15contra;...
    dia_87091_27contra;...
    dia_89151_16contra];

hist(dia_contra_all,(0:0.1:5));
title('All contra segments from midline');xlabel('Diameter (micrometer)');ylabel('Number of segments');
xlim([0 4]);ylim([0 120]);

subplot(2,2,3)
dia_contraE_all=[dia_89021_22contraE;...
    dia_87039_10contraE;...
    dia_87102_7contraE;...
    dia_89007_39contraE;...
    dia_87039_9contraE;...
    dia_89141_27contraE;...
    dia_88107_15contraE;...
    dia_87091_27contraE;...
    dia_89151_16contraE];

hist(dia_contraE_all,(0:0.1:5));
title('All contra terminal segments');xlabel('Diameter (micrometer)');ylabel('Number of segments');
xlim([0 4]);ylim([0 120]);

%ipsi
subplot(2,2,2)
dia_ipsi_all=[dia_89021_22ipsi;...
    dia_89007_39ipsi;...
    dia_89007_43ipsi;...
    dia_90043_15ipsi;...
    dia_87056_24ipsi;...
    dia_88311_20ipsi;...
    dia_88011_3ipsi];

hist(dia_ipsi_all,(0:0.1:5));
title('All ipsi segments from FB');xlabel('Diameter (micrometer)');ylabel('Number of segments');
xlim([0 4]);ylim([0 120]);

subplot(2,2,4)
dia_ipsiE_all=[dia_89021_22ipsiE;...
    dia_89007_39ipsiE;...
    dia_89007_43ipsiE;...
    dia_90043_15ipsiE;...
    dia_87056_24ipsiE;...
    dia_88311_20ipsiE;...
    dia_88011_3ipsiE];

hist(dia_ipsiE_all,(0:0.1:5));
title('All ipsi terminal segments');xlabel('Diameter (micrometer)');ylabel('Number of segments');
xlim([0 4]);ylim([0 120]);

