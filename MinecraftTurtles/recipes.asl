recipe(nothing,[0,    0,    0,
                0,    0,    0,
                0,    0,    0]).

recipe(glassPane,[glass,  glass,  glass,
                  glass,  glass,  glass,
                  0,      0,      0    ]).

recipe(computer,[stone,  stone,     stone,
                 stone,  redstone,  stone,
                 stone,  glassPane, stone]).

recipe(chest,[wood,wood,wood,
              wood,0,   wood,
              wood,wood,wood]).

recipe(turtle,[iron,    iron,        iron,
               iron,    computer,    iron,
               iron,    chest,       iron]).
