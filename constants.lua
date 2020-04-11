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
planet_type_keys = {"jungle","ocean","airless","barren","urban"}
planet_types = {
  jungle = {
    p_c1= 11, p_c2= 3,
    sprites = function(p_x,p_y,p_r)
      return {}
    end
  },
  ocean = {
    p_c1= 12, p_c2= 13,
    sprites = function(p_x,p_y,p_r)
      return {}
    end
  },
  barren = {
    p_c1= 15, p_c2= 4,
    sprites = function(p_x,p_y,p_r)
      return times(function()
        local t = rnd()
        local u = rnd() + rnd()
        if u > 1 then u = 2 - u end
        return {spr= 0, x= flr((p_r-2)*u*cos(t)+(p_x)), y= flr((p_r-2)*u*sin(t)+(p_y)), c= 0, r= 1}
      end, 200)
    end
  },
  airless = {
    p_c1= 6, p_c2= 5,
    sprites = function(p_x,p_y,p_r)
      return {}
    end
  },
  urban = {
    p_c1= 6, p_c2= 5,
    sprites = function(p_x,p_y,p_r)
      return flatten(times(function()
        local t = rnd()/2
        local u = rnd() + rnd()
        local two_story = rnd() > 0.7
        if u > 1 then u = 2 - u end
        if two_story then
          return {
            {spr= 16, x= flr((p_r+4)*u*cos(t)+(p_x)), y= flr((p_r+4)*u*sin(t)+(p_y))-8, c= 0, r= 1, offset = rndi(20), blink_light = rndi(4)+8},
            {spr= 32, x= flr((p_r+4)*u*cos(t)+(p_x)), y= flr((p_r+4)*u*sin(t)+(p_y)), c= 0, r= 1, offset = rndi(20)},
          }
        else
          return {spr= 32, x= flr((p_r-2)*u*cos(t)+(p_x)), y= flr((p_r-2)*u*sin(t)+(p_y)), c= 0, r= 1, offset = rndi(20)}
        end
      end,300))
    end
  }
}
planet_keys = {}
planet_info = {}
