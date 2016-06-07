clear all;
close all;

links = [ 1, 2;
          1, 3;
          1, 4;
          2, 3;
          2, 4;
          3, 4
          ];
      
edegesLength = [1;
                sqrt(2);
                1;
                1;
                sqrt(2);
                1
                ];
            
unreliablility = zeros(size(edegesLength));

startingPos = [];

lay = meshRelaxationLayout(edegesLength, links, unreliablility+1 ,startingPos);
plot(lay(:,2), lay(:,3),'o-')
axis([min(min(lay(:,2:3))) , max(max(lay(:,2:3))) , min(min(lay(:,2:3))) , max(max(lay(:,2:3))) ]);
grid on;
