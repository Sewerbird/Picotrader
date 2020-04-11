-- GLOBALS & CONSTANTS

game_state = nil
directions = {'left','right','up','down'}
trade_good_keys = {"medicine","fuel","food","steel","weapons","robotics","tools","artwork"}
trade_goods = {
  medicine = {sprite_id = 1},
  fuel = {sprite_id = 6},
  food = {sprite_id = 3},
  steel = {sprite_id = 5},
  weapons = {sprite_id = 9},
  robotics = {sprite_id = 7},
  tools = {sprite_id = 8},
  artwork = {sprite_id = 2},
}
trade_good_mods = {
  medicine= { urban=5, locals=-5, ["decados"]=5},
  fuel= {airless=5, ocean=-5, empire=-5 },
  food= {barren=-5, jungle=5},
  steel= {barren=5, urban=-5},
  weapons= {colony=-5, empire=5, ["the hazat"]=5, icy=-5},
  robotics= {airless=-5, ["hawkwood"]=5, icy=5},
  tools= {jungle=-5, ocean=5, league=5, church=-10, ["al malik"]=5},
  artwork= {locals=5, league=-5, church=10, ["li halan"]=5}
}
size_code_multipliers = {
  post = 3,
  colony = 5,
  homeworld = 7,
  megalopolis = 10
}

function scatter_over_planet(amount, scatter, p_x, p_y, p_r)
  return times(function()
    local t = rnd()
    local u = rnd() + rnd()
    if u > 1 then u = 2 - u end
    return {spr= scatter[rndi(#scatter)+1], x= flr((p_r-2)*u*cos(t)+(p_x)), y= flr((p_r-2)*u*sin(t)+(p_y)), c= 0, r= 1}
  end, amount)
end

planet_type_keys = {"jungle","ocean","icy","airless","barren","urban"}
planet_types = {
  jungle = {
    p_c1= 11, p_c2= 3,
    sprites = function(p_x,p_y,p_r)
      return scatter_over_planet(600,{19,20,17,18,33,34,17,18,33,34},p_x,p_y,p_r)
    end
  },
  ocean = {
    p_c1= 12, p_c2= 13,
    sprites = function(p_x,p_y,p_r)
      local scatter = {17,18,33,34}
      return scatter_over_planet(300,scatter,p_x,p_y,p_r)
    end
  },
  barren = {
    p_c1= 15, p_c2= 4,
    sprites = function(p_x,p_y,p_r)
      local scatter = {0,33,36}
      return scatter_over_planet(300,scatter,p_x,p_y,p_r)
    end
  },
  icy = {
    p_c1= 6, p_c2= 5,
    sprites = function(p_x,p_y,p_r)
      local scatter = {17,33,21,22}
      return scatter_over_planet(300,scatter,p_x,p_y,p_r)
    end
  },
  airless = {
    p_c1= 6, p_c2= 5,
    sprites = function(p_x,p_y,p_r)
      local scatter = {0}
      return scatter_over_planet(300,scatter,p_x,p_y,p_r)
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
