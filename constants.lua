-- GLOBALS & CONSTANTS

game_state = nil
directions = {'left','right','up','down'}
trade_good_keys = {"sundries", "boomerangs", "meat", "salad", "steel", "cola", "chips", "doodads"}
trade_goods = {
  sundries = {sprite_id = 1},
  boomerangs = {sprite_id = 2},
  meat = {sprite_id = 3},
  salad = {sprite_id = 4},
  steel = {sprite_id = 5},
  cola = {sprite_id = 6},
  chips = {sprite_id = 7},
  doodads = {sprite_id = 8},
}
planet_keys = {"durruti", "sutek", "vera cruz", "byzantium", "aragon"}
planet_info = {
  durruti = {
    map_x = 64, map_y = 96, map_r = 3, map_c = 12, up="aragon",
    name = "durruti", owner = "the guild", overview = "a barren planet with rich\nreserves of ores and minerals\nnear the surface",
  },
  sutek = {
    map_x = 80, map_y = 75, map_r = 3, map_c = 12, up="vera cruz", left="aragon",
    name = "sutek", owner = "the hazat", overview = "a suburban planet recently\ncolonized by house hazat",
  },
  ['vera cruz'] = {
    map_x = 72, map_y = 50, map_r = 3, map_c = 12, left="byzantium", down="sutek",
    name = "vera cruz", owner = "the hazat", overview = "a wet, pine world notable\nfor its tech industry",
  },
  byzantium = {
    map_x = 64, map_y = 64, map_r = 3, map_c = 12, up= "vera cruz", right= "vera cruz", down="aragon",
    name = "byzantium secundus", owner = "neutral", overview = "the throne world of the \nimperium,it is the largest\n market in the galaxy",
  },
  aragon= {
    map_x = 64, map_y = 80, map_r = 3, map_c = 12, up="byzantium", right="sutek", down="durruti",
    name = "aragon", owner = "the hazat", overview = "the home of house hazat, and\nis a rich agricultural planet",
  },
}
