recipe(nothing,[0,    0,    0,
                0,    0,    0,
                0,    0,    0]).

recipe(glass_pane,[glass,  glass,  glass,
                  glass,  glass,  glass,
                  0,      0,      0    ]).

recipe(computer,[gold,  gold,      gold,
                 gold,  redstone,  gold,
                 gold,  glass_pane, gold]).

recipe(wood,[log,  0,  0,
              0,    0,  0,
              0,    0,  0]).

recipe(chest,[wood,wood,wood,
              wood,0,   wood,
              wood,wood,wood]).

recipe(turtle,[gold,    gold,        gold,
               gold,    computer,    gold,
               gold,    chest,       gold]).
               
               
smelt_recipe(glass, sand).
smelt_recipe(gold,  gold_ore).
smelt_recipe(fuel,  log).

