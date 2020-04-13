-- GLOBALS & CONSTANTS

g = nil
beepboops = {41,42,43,44,45,46}
music_ticker = 3900
win_amount = 1000 --k$
lose_amount = 0
directions = {'left','right','up','down'}
trade_good_keys = {"medicine","fuel","food","steel","weapons","robotics","tools","artwork"}
trade_goods = {
  medicine = {sprite_id = 10, base_price = 10, bulk = 1},
  fuel = {sprite_id = 6, base_price = 5, bulk = 3},
  food = {sprite_id = 3, base_price = 4, bulk = 3},
  steel = {sprite_id = 5, base_price = 6, bulk = 2},
  weapons = {sprite_id = 9, base_price = 10, bulk = 2},
  robotics = {sprite_id = 7, base_price = 8, bulk = 2},
  tools = {sprite_id = 8, base_price = 10, bulk = 2},
  artwork = {sprite_id = 2, base_price = 20, bulk = 2},
}
neg_ln = {
[1]= 0,
[2]=-0.6931471806,
[3]=-1.0986122887,
[4]=-1.3862943611,
[5]=-1.6094379124,
[6]=-1.7917594692,
[7]=-1.9459101491,
[8]=-2.0794415417,
[9]=-2.1972245773,
[10]=-2.302585093,
[20]=-2.9957322736
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
    p_c1= 7, p_c2= 6,
    sprites = function(p_x,p_y,p_r)
      local scatter = {17,33,21,22}
      return scatter_over_planet(300,scatter,p_x,p_y,p_r)
    end
  },
  airless = {
    p_c1= 7, p_c2= 15,
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
possible_events = {
  {
    change= function(planet,good) planet.business[good].inventory = 127 end,
    text= function(planet,good) return "gLUT OF "..good.." ON "..planet end},
  {
    change= function(planet,good) planet.business[good].inventory = 0 end,
    text= function(planet,good) return "sHORTAGE OF "..good.." ON "..planet end},
  {
    change= function(planet,good) planet.business.tax_rate += 25 end,
    unchange= function(planet,good) planet.business.tax_rate -= 25 end, 
    text= function(planet,good) return "iMPERIAL EMBARGO OVER "..planet end},
  {
    change= function(planet,good) planet.business[good].base_production += 5 end,
    unchange= function(planet,good) planet.business[good].base_production -= 5 end, 
    text= function(planet,good) return "nEW JOBS FOR MAKING "..good.." ON "..planet end},
  {
    change= function(planet,good) planet.business[good].base_production -= 5 end,
    unchange= function(planet,good) planet.business[good].base_production += 5 end, 
    text= function(planet,good) return "lAYOFFS FOR PRODUCERS OF "..good.." ON "..planet end},
}
planet_keys = {}
planet_info = {}
