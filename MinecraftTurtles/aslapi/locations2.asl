
// Storage
poi(gold_ore,       263, 76, -245, east).
poi(log,            263, 75, -245, east).
poi(sand,           263, 74, -245, east).

poi(gold,           263, 76, -243, east).
poi(wood,           263, 75, -243, east).
poi(glass,          263, 74, -243, east).

poi(redstone,       263, 76, -241, east).
poi(chest,          263, 75, -241, east).
poi(glass_pane,     263, 74, -241, east).

poi(fuel,           263, 76, -239, east).
poi(turtle,         263, 75, -239, east).
poi(computer,       263, 74, -239, east).


// Name, minimum_count, craft_count 
resource_setup(gold_ore,  128, 16).
resource_setup(sand,      128, 16).
resource_setup(redstone,  128, 16).
// resource_setup(log,       128, 16).

resource_setup(gold,      128, 8).
resource_setup(glass,     128, 8).
resource_setup(fuel,      128, 8).

resource_setup(wood,      128, 8).
resource_setup(chest,     128, 4).
resource_setup(glass_pane,128, 2).
resource_setup(turtle,    128, 1).
resource_setup(computer,  128, 1).


// Crafting stations
poi(crafter,  257, 74, -245, south).
poi(crafter1, 257, 74, -245, south).
poi(crafter2, 255, 74, -245, south).
poi(crafter3, 253, 74, -245, south).
poi(crafter4, 251, 74, -245, south).
poi(crafter5, 249, 74, -245, south).

poi(smelter,  257, 75, -247, north).
poi(smelter1, 257, 75, -247, north).
poi(smelter2, 255, 75, -247, north).
poi(smelter3, 253, 75, -247, north).
poi(smelter4, 251, 75, -247, north).
poi(smelter5, 249, 75, -247, north).

poi(idle,           256, 77, -238, east).

mine_loc(gold_ore, 249, 60, -275, south).
mine_loc(gold_ore, 248, 60, -275, south).
mine_loc(gold_ore, 248, 61, -275, west).
mine_loc(gold_ore, 249, 59, -276, west).
mine_loc(gold_ore, 247, 60, -276, west).
mine_loc(gold_ore, 247, 61, -276, west).
mine_loc(gold_ore, 247, 60, -278, west).

mine_loc(redstone, 247, 60, -283, west).
mine_loc(redstone, 247, 61, -284, west).
mine_loc(redstone, 247, 60, -283, north).
mine_loc(redstone, 248, 59, -282, north).
mine_loc(redstone, 249, 60, -284, north).

mine_loc(sand, 257, 64, -276, east).
mine_loc(sand, 257, 65, -276, east).
mine_loc(sand, 257, 66, -276, east).
mine_loc(sand, 257, 66, -277, east).
mine_loc(sand, 257, 66, -275, east).

// Y, Spacing, XMin, ZMin, XMax, ZMax
tree_farm_setting(75, 3, 260, -228, 272, -216).
// tree_farm_setting(75, 3, 260, -228, 263, -225).
