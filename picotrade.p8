pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- GLOBALS & CONSTANTS

game_state = nil
trade_good_keys = {"sundries", "doodads", "boomerangs", "meat", "salad", "steel", "cola", "chips"}
trade_goods = {
  sundries = {sprite_id = 1},
  doodads = {sprite_id = 1},
  boomerangs = {sprite_id = 2},
  meat = {sprite_id = 3},
  salad = {sprite_id = 4},
  steel = {sprite_id = 5},
  cola = {sprite_id = 6},
  chips = {sprite_id = 7},
}
planet_keys = {"durruti", "sutek", "vera cruz", "byzantium II", "aragon"}
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
    map_x = 72, map_y = 50, map_r = 3, map_c = 12, left="byzantium II", down="sutek",
    name = "vera cruz", owner = "the hazat", overview = "a wet, pine world notable\nfor its tech industry",
  },
  ['byzantium II'] = {
    map_x = 64, map_y = 64, map_r = 3, map_c = 12, up= "vera cruz", right= "vera cruz", down="aragon",
    name = "byzantium secundus", owner = "neutral", overview = "the throne world of the \nimperium,it is the largest\n market in the galaxy",
  },
  aragon= {
    map_x = 64, map_y = 80, map_r = 3, map_c = 12, up="byzantium II", right="sutek", down="durruti",
    name = "aragon", owner = "the hazat", overview = "the home of house hazat, and\nis a rich agricultural planet",
  },
}

-- LIBRARY

function map(a,func)
  local result = {}
  for v in all(a) do
    add(result, func(v))
  end
  return result
end

function mapo(a,func)
  local result = {}
  for v in all(a) do
    key, value = func(v)
    result[v] = value
  end
  return result
end

function clamp(a,low,high)
  return low > a and low or (high < a and high or a)
end

function mod(a,b)
  local q = flr(a/b)
  return a - (q*b)
end

function rndi(z)
  return flr(rnd() * z)
end

function print_centered_text_on_point(text, c_x, c_y, col)
  local w = #text * 4
  print(text, c_x - w/2, c_y - 2, col)
end

function print_centered_text_in_rect(text, x1, y1, x2, y2, col)
  local w = #text * 4
  local c_x = (x2-x1)/2 + x1
  local c_y = (y2-y1)/2 + y1 - 2
  --rect(x1,y1,x2,y2,7) --Debug rect
  print(text, c_x - w/2, c_y, col)
end

-- # USER INTERFACE & GRAPHICS

function draw_durruti()
  --Black of Space
  rectfill(0,0,127,127,0)
  -- Stars
  for star in all(game_state.durruti.picture.stars) do
    circ(star.x, star.y, 0, star.c)
  end
  -- Durruti Prime
  circfill(80,14,3,10)
  circ(80,14,(mod(flr(time()),2) == 0 and 5 or 6), 7)
  circ(80,14,(mod(flr(time()),2) == 1 and 9 or 11), 15)
  -- Durruti I
  circfill(127, 90, 80, 15)
  for speck in all(game_state.durruti.picture.specks) do
    circ(speck.x, speck.y, 1, 4)
  end
  circfill(130, 95, 80, 4)
  for speck in all(game_state.durruti.picture.specks) do
    circ(speck.x+3, speck.y+5, 1, 0)
  end
  -- Name Label
  rectfill(1,1,40,8,0)
  print_centered_text_in_rect(game_state.durruti.picture.label, 0,0,40,8,13)
  -- Interface border
  rect(0,0,127,127,1)
end

function durruti_picture_init()
  local stars = {}
  local specks = {}
  srand(3)

  col = {7,7,6,5,8,12}
  for i=1,200 do
    local x = flr(rnd(127))
    local y = flr(rnd(127))
    local c = col[flr(rnd(6))+1]
    add(stars, {x= x, y=y, c=c})
  end

  for i= 1,200 do
    local t = rnd()
    local u = rnd() + rnd()
    local r = u
    if r > 1 then
      r = 2 - u
    end
    add(specks, {
      x=flr((80-2)*r*cos(t)+(127)), 
      y=flr((80-2)*r*sin(t)+(90)), 
      c=5
    })
  end

  return {label="durruti", stars= stars, specks= specks}
end

function draw_default_planet(name)
  --TODO make this rich enough that I can do most planets with this function, given a config
  --Black of Space
  rectfill(0,0,127,127,0)
  -- Stars
  for star in all(game_state[name].picture.stars) do
    circ(star.x, star.y, 0, star.c)
  end
  -- Sun
  sun_x = 80
  sun_y = 14
  circfill(sun_x,sun_y,3,9)
  circ(sun_x,sun_y,(mod(flr(time()),2) == 0 and 5 or 6), 7)
  circ(sun_x,sun_y,(mod(flr(time()),2) == 1 and 9 or 11), 15)
  -- Name Label
  rectfill(1,1,40,8,0)
  print_centered_text_in_rect(game_state[name].picture.label, 0,0,40,8,13)
  -- Interface border
  rect(0,0,127,127,1)
end

function default_planet_picture_init(name)
  --TODO make it so that all these planet pictures run off one method
  local stars = {}

  col = {7,7,6,5,8,12}
  for i=1,1000 do
    local x = flr(rnd(127))
    local y = flr(rnd(127))
    local c = col[flr(rnd(6))+1]
    add(stars, {x= x, y=y, c=c})
  end

  return {label=name, stars= stars}
end

function draw_balance()
  rectfill(127-30,0,127,8, 1)
  rect(127-30,0,127,8, 1)
  print_centered_text_in_rect("$"..flr(game_state.player.wallet_balance+0.5),127-30,0,127,8,11)
end

function draw_news_ticker()
  rectfill(0,115,127,125, 1)
  rectfill(0,116,127,124, 13)
  print(game_state.news_ticker.news, -game_state.news_ticker.scroll_x, 118, 6)
end

function draw_purchase_interface(interface)
  local t = interface.ui_settings
  --# CENTER COLUMN
  --## Header
  rectfill(0,t.t_y,128,t.t_y+t.h_h,1)
  print_centered_text_in_rect("sell", t.l_x, t.t_y, t.l_x + t.w/3, t.t_y+t.h_h, 6)
  print_centered_text_in_rect("buy", t.r_x - t.w/3, t.t_y, t.r_x, t.t_y+t.h_h, 6)
  print_centered_text_on_point("trade", t.l_x + t.w/2, t.t_y+t.h_h, 6)
  print_centered_text_in_rect("port", 0, t.t_y, t.l_x, t.t_y+t.h_h, 6)
  print_centered_text_in_rect("ship", t.r_x, t.t_y, 127, t.t_y+t.h_h, 6)
  --## Rows
  local i = 1
  for key in all(trade_good_keys) do
    local sprite_id = trade_goods[key].sprite_id
    local left = t.l_x
    local top = t.t_y+i*t.r_h-2
    local w = t.w
    local h = t.r_h
    local c_x = left+(w/2)
    rectfill(0,top,127, top+h, 5) --Background
    rect(0,top,127, top+h, 1) --Background border
    rectfill(left,top,left+w, top+h, 13) --Center column background
    rect(left,top,left+w,top+h, 1) -- Center column border
    spr(sprite_id, c_x-4, top+1) --Good Sprite
    local sell_price = game_state[interface.current_location].inventory[key].buy_price
    local buy_price = game_state[interface.current_location].inventory[key].sell_price
    local avg_price = game_state.player.inventory[key].avg_price
    print_centered_text_in_rect("+$"..flr(sell_price+0.5), left, top, c_x-4-8, top+h, avg_price > sell_price and 8 or 11) --Sell Amount
    print_centered_text_in_rect("-$"..flr(buy_price+0.5), c_x+4+8, top, left+w, top+h, avg_price < buy_price and 8 or 11) --Buy Amount
    trader_amount = game_state[interface.current_location].inventory[key].amount
    player_amount = game_state.player.inventory[key].amount
    print(trader_amount, 4, top+1+2, 11) --City Stock Amount
    print(player_amount, left+w+4, top+1+2, 11) --Ship Stock Amount
    i = i + 1
  end
  --## Active Splat
  local cursor = interface.splats[interface.current_splat]

  if(cursor) then
    rect(cursor.x, cursor.y, cursor.x + cursor.w, cursor.y + cursor.h, 14)
  end
end

function create_purchase_interface(trader)
  local result = {
    active = false,
    entry_splat = "buy_sundries",
    current_splat = "buy_sundries",
    current_location = trader,
    ui_settings = {
      l_x = 64 - 80/2, --left side of center column
      c_x = 64, --center of center column
      r_x = 64 + 80/2, --right side of center column
      h_h = 10, --header height
      r_h = 10, --row height
      t_y = 24, --top of interface
      w = 80 --width of center column
    }
  }
  local splats = {}
  local row = 1
  interface = result.ui_settings
  for good in all(trade_good_keys) do
    print("Good: "..good,0,30,7)
    splats["buy_"..good] = {
      x = interface.c_x + interface.w/6, y = interface.t_y - 2 + interface.h_h + (row-1)*interface.r_h, w = interface.w/3, h = interface.r_h,
      up = (row > 1 and ("buy_"..trade_good_keys[row-1]) or nil),
      left = "sell_"..good, right = nil,
      down = (row < #trade_good_keys and ("buy_"..trade_good_keys[row+1]) or nil),
      execute = function()
        local success, error = buy_from_trader(trader,"player",good,1)
        if(not success) then printh("Error selling: '"..error.."'") end
      end
    }
    splats["sell_"..good] = {
      up = (row > 1 and ("sell_"..trade_good_keys[row-1]) or nil),
      x = interface.l_x, y = interface.t_y - 2 + interface.h_h + (row-1)*interface.r_h, w = interface.w/3, h = interface.r_h,
      left = nil, right = "buy_"..good,
      down = (row < #trade_good_keys and ("sell_"..trade_good_keys[row+1]) or nil),
      execute = function()
        local success, error = buy_from_trader("player",trader,good,1)
        if(not success) then printh("Error selling: '"..error.."'") end
      end
    }
    row = row + 1
  end
  result.splats = splats

  return result
end

function draw_root_interface(interface)
  if(interface == nil) then return end
  local t = interface.ui_settings

  local tab_keys = {"trade","map","info"}
  local i = 0
  for tab_key in all(tab_keys) do
    local w= t.tab_w
    local h= t.h 
    local x= t.l_x+i*w+i
    local y= t.t_y
    rectfill(x,y,x+w,y+h,1)
    line(x,y,x+w,y,5)
    line(x+w,y,x+w,y+h,5)
    print_centered_text_in_rect(tab_key,x,y,x+w,y+h,13)
    i+=1
  end
  --## Active Splat
  local cursor = interface.splats[interface.current_splat]

  if(cursor) then
    rect(cursor.x, cursor.y, cursor.x + cursor.w, cursor.y + cursor.h, 14)
  end
end

function create_root_interface(trader)
  local result = {
    active = false,
    entry_splat = "trade",
    current_splat = "trade",
    ui_settings = {
      l_x = 0,
      t_y = 105, --top of interface
      h = 10,
      tab_w = 30,
      w = 80 --width of center column
    }
  }
  local t = result.ui_settings
  result.splats = {
    trade = {
      x= t.l_x, y= t.t_y, w=t.tab_w, h = t.h, 
      up= nil, down= nil, left= nil, right= 'map',
      execute= function()
        game_state.active_interface = 'trade_interface'
      end
    },
    map = {
      x= (t.tab_w+1)*1 + t.l_x, y= t.t_y, w=t.tab_w, h = t.h, 
      up= nil, down= nil, left= 'trade', right= 'info',
      execute= function()
        game_state.active_interface = 'map_interface'
      end
    },
    info = {
      x= (t.tab_w+1)*2+ t.l_x, y= t.t_y, w=t.tab_w, h = t.h, 
      up= nil, down= nil, left= 'map', right= nil,
      execute= function()
        game_state.active_interface = 'info_interface'
      end
    },
  }
  return result
end

function draw_info_interface(interface)
  if(interface == nil) then return end
  local t = interface.ui_settings

  --## Header
  rectfill(0,0,127,127,5)
  local planet = planet_info[interface.current_location]
  rectfill(0,0,127,10,1)
  print_centered_text_in_rect(planet.name,0,0,127,10,7)
  --## Blurb
  print(planet.overview,5,12, 7)
  --## Economy Summary
  local w = 80
  local h = 80
  local l_x = 0
  local h_h = 8
  local t_y = 127-h
  local r = w * sqrt(1/6)
  local mid_x = l_x + w/2
  local mid_y = t_y + h/2
  rectfill(l_x,t_y,l_x+w+1,t_y+h, 0)
  rectfill(l_x-1,t_y-8,l_x+w+2,t_y-8+8, 1)
  rect(l_x-1,t_y-8,l_x+w+2,t_y-8+8+h, 1)
  print_centered_text_in_rect("economy",l_x-1,t_y-8,l_x-1+w+2,t_y-8+8, 7)
  local last_x = 0
  local last_y = 0
  local first_x = nil
  local first_y = nil
  for i=1,#trade_good_keys,1 do
    local a = (i-1)/#trade_good_keys
    -- # Good icon
    local x = mid_x + r * cos(a)
    local y = mid_y + r * sin(a)
    spr(trade_goods[trade_good_keys[i]].sprite_id, x-4, y-4)
    -- # Radial lines
    local scales = {11,10,9,8}
    for i=1,#scales do
      line(mid_x + r*(1-i*0.2)*cos(a),mid_y+r*(1-i*0.2)*sin(a),
           mid_x + r*(1-(i+1)*0.2)*cos(a),mid_y+r*(1-(i+1)*0.2)*sin(a), scales[i])
    end
    -- # Evaluation lines
    net_production = game_state[interface.current_location].production[trade_good_keys[i]] - game_state[interface.current_location].consumption[trade_good_keys[i]]
    score = 0.8 * (clamp(net_production, -10, 10) + 10)/20
    local me_x = mid_x+r*score*cos(a)
    local me_y = mid_y+r*score*sin(a)
    if last_y > 0 then
      line(last_x, last_y, me_x, me_y, 12)
    else
      first_x = me_x
      first_y = me_y
    end
    circ(me_x,me_y,0,7)
    last_x = me_x
    last_y = me_y
  end
  -- Last evaluation line. Cuz loops.
  line(last_x, last_y, first_x, first_y, 12)
  -- ## Owner
  t_y = t_y - h_h
  h_h = 8
  rectfill(l_x+w+2,t_y,127,t_y+h_h, 1)
  print_centered_text_in_rect("owner",l_x+w+2,t_y,127,t_y+h_h, 7)
  rectfill(l_x+w+2,t_y+h_h,127,t_y+2*h_h, 0)
  print_centered_text_in_rect(planet.owner,l_x+w+2,t_y+h_h,127,t_y+2*h_h,7)
  rect(l_x+w+2,t_y,127,t_y+2*h_h, 1)
  -- ## Tax Rate
  rectfill(l_x+w+2,t_y+2*h_h,127,t_y+3*h_h, 1)
  print_centered_text_in_rect("tax rate",l_x+w+2,t_y+2*h_h,127,t_y+3*h_h, 7)
  rectfill(l_x+w+2,t_y+3*h_h,127,t_y+4*h_h, 0)
  print_centered_text_in_rect(""..game_state[interface.current_location].tax_rate.."%",l_x+w+2,t_y+3*h_h,127,t_y+4*h_h,7)
  rect(l_x+w+2,t_y,127,t_y+4*h_h, 1)
  -- ## Coffers
  rectfill(l_x+w+2,t_y+4*h_h,127,t_y+5*h_h, 1)
  print_centered_text_in_rect("coffers",l_x+w+2,t_y+4*h_h,127,t_y+5*h_h, 7)
  rectfill(l_x+w+2,t_y+5*h_h,127,t_y+6*h_h, 0)
  print_centered_text_in_rect("$"..game_state[interface.current_location].wallet_balance,l_x+w+2,t_y+5*h_h,127,t_y+6*h_h,7)
  rect(l_x+w+2,t_y,127,t_y+6*h_h, 1)

  --## Active Splat
  local cursor = interface.splats[interface.current_splat]

  if(cursor) then
    rect(cursor.x, cursor.y, cursor.x + cursor.w, cursor.y + cursor.h, 14)
    print_centered_text_in_rect(interface.current_splat,cursor.x,cursor.y+cursor.h, cursor.x+cursor.w, cursor.y+cursor.h+cursor.h, 7)
  end
end

function create_info_interface(trader)
  local result = {
    active = false,
    entry_splat = trader,
    current_splat = nil,
    current_location = trader,
    ui_settings = {
      l_x = 64 - 80/2, --left side of center column
      c_x = 64, --center of center column
      r_x = 64 + 80/2, --right side of center column
      h_h = 10, --header height
      r_h = 10, --row height
      t_y = 32, --top of interface
      w = 80 --width of center column
    }
  }
  local splats = {
    [trader] = {}
  }
  result.splats = splats
  return result
end

function draw_map_interface(interface)
  if(interface == nil) then return end
  local t = interface.ui_settings

  -- # Black of Space
  rectfill(0,0,127,127,0)

  -- # Background stars
  for star in all(interface.background_stars) do
    circ(star.x, star.y, star.r, star.c)
  end

  -- # Hyperlanes
  for key in all(planet_keys) do
    local planet = planet_info[key]
    if planet.left then
      local other = planet_info[planet.left]
      line(planet.map_x, planet.map_y, other.map_x, other.map_y, 6)
    end
    if planet.right then
      local other = planet_info[planet.right]
      line(planet.map_x, planet.map_y, other.map_x, other.map_y, 6)
    end
    if planet.up then
      local other = planet_info[planet.up]
      line(planet.map_x, planet.map_y, other.map_x, other.map_y, 6)
    end
    if planet.down then
      local other = planet_info[planet.down]
      line(planet.map_x, planet.map_y, other.map_x, other.map_y, 6)
    end
  end
  -- # Planets
  for key in all(planet_keys) do
    local planet = planet_info[key]
    circfill(planet.map_x,planet.map_y,planet.map_r,planet.map_c)
    if key == interface.current_location then
      circ(planet.map_x,planet.map_y,(mod(flr(time()),2) == 1 and 4 or 6), 11)
    end
  end

  --## Active Splat
  local cursor = interface.splats[interface.current_splat]

  if(cursor) then
    rect(cursor.x, cursor.y, cursor.x + cursor.w, cursor.y + cursor.h, 14)
    print_centered_text_in_rect(interface.current_splat,cursor.x,cursor.y+cursor.h, cursor.x+cursor.w, cursor.y+cursor.h+cursor.h, 7)
  end
end

function create_map_interface(trader)
  local result = {
    active = false,
    entry_splat = trader,
    current_splat = trader,
    current_location = trader,
    ui_settings = {
      l_x = 64 - 80/2, --left side of center column
      c_x = 64, --center of center column
      r_x = 64 + 80/2, --right side of center column
      h_h = 10, --header height
      r_h = 10, --row height
      t_y = 32, --top of interface
      w = 80 --width of center column
    },
    background_stars = {}
  }
  colors = {5,6,7,15,13}
  for i=1,300 do
    add(result.background_stars, {x= rndi(127), y= rndi(127), r=rndi(1), c= colors[rndi(#colors)+1]})
  end
  local splats = {}
  for key in all(planet_keys) do
    local planet = planet_info[key]
    splats[key]= {
      x= planet.map_x-planet.map_r, y= planet.map_y-planet.map_r, w=2*planet.map_r, h=2*planet.map_r,
      left= planet.left, right= planet.right, up=planet.up, down=planet.down,
      execute=function()
        --TODO Show extra info about the planet before assuming we're travelling to it
        --TODO Do a travel animation
        --TODO Add travel events between planets
        --Do next turn, and arrive at destination
        advance_simulation()
        game_state.current_planet_scene = key
        game_state.trade_interface = create_purchase_interface(key)
        game_state.root_interface = create_root_interface(key)
        game_state.map_interface = create_map_interface(key)
        game_state.info_interface = create_info_interface(key)
        game_state.active_interface = "root_interface"
        game_state[game_state.active_interface].current_splat = "map"
      end
    }
  end
  result.splats = splats
  return result
end


-- # GAME STATE & MUTATIONS
function create_game_state()
  return {
    day_of_simulation = 0,
    current_planet_scene = "durruti",
    active_interface = "root_interface",
    player = {
      wallet_balance = 100,
      storage_remaining = 100,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = 0, avg_price = 0} end)
    },
    durruti = {
      wallet_balance = 1000,
      tax_rate = 15,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = 0, buy_price = 0, sell_price = 0} end),
      production = { sundries = 2, doodads = 2, boomerangs = 5, meat = 0, salad = 3, steel = 15, cola = 5, chips = 5 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
      picture = durruti_picture_init(), --data for rendering the background picture  
    },
    aragon = {
      wallet_balance = 1000,
      tax_rate = 10,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = rndi(100), buy_price = 0, sell_price = 0} end),
      production = { sundries = 5, doodads = 2, boomerangs = 0, meat = 8, salad = 15, steel = 2, cola = 5, chips = 3 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
      picture = default_planet_picture_init('aragon'), --data for rendering the background picture  
    },
    sutek = {
      wallet_balance = 1000,
      tax_rate = 25,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = rndi(100), buy_price = 0, sell_price = 0} end),
      production = { sundries = 3, doodads = 3, boomerangs = 15, meat = 10, salad = 5, steel = 4, cola = 3, chips = 2 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
      picture = default_planet_picture_init('sutek'), --data for rendering the background picture  
    },
    ["vera cruz"] = {
      wallet_balance = 1000,
      tax_rate = 10,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = rndi(100), buy_price = 0, sell_price = 0} end),
      production = { sundries = 7, doodads = 8, boomerangs = 2, meat = 3, salad = 2, steel = 4, cola = 3, chips = 15 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
      picture = default_planet_picture_init('vera cruz'), --data for rendering the background picture  
    },
    ["byzantium II"] = {
      wallet_balance = 1000,
      tax_rate = 20,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = rndi(100), buy_price = 0, sell_price = 0} end),
      production = { sundries = 10, doodads = 15, boomerangs = 2, meat = 3, salad = 2, steel = 4, cola = 8, chips = 7 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
      picture = default_planet_picture_init('byzantium II'), --data for rendering the background picture  
    },
    trade_interface = create_purchase_interface("durruti"),
    root_interface = create_root_interface("durruti"),
    map_interface = create_map_interface("durruti"),
    info_interface = create_info_interface("durruti"),
    news_ticker = {
      scroll_x = -127,
      news = "Welcome abord, trader: the world is at your fingertips"
    }
  }
end

function buy_from_trader(trader, buyer, good, amount)
  local unit_price
  if(trader == 'player') then 
    unit_price = game_state[buyer].inventory[good].buy_price
  else 
    unit_price = game_state[trader].inventory[good].sell_price 
  end
  local price = unit_price * amount
  if(game_state[trader].inventory[good].amount < amount) then
    return false, "Not enough stock"
  end
  if(game_state[buyer].storage_remaining and game_state[buyer].storage_remaining < amount) then
    return false, "Not enough space"
  end
  if(game_state[buyer].wallet_balance < price) then
    return false, "Not enough money"
  end
  -- # Player-specific bookeeping
  if buyer == 'player' then
    game_state[buyer].storage_remaining -= amount
    game_state[buyer].inventory[good].avg_price = 
      (game_state[buyer].inventory[good].avg_price * game_state[trader].inventory[good].amount + unit_price * amount) 
      / (game_state[buyer].inventory[good].amount + amount)
  end
  if trader == 'player' then
    game_state[trader].storage_remaining += amount
  end
  game_state[trader].inventory[good].amount -= amount
  game_state[trader].wallet_balance += price
  game_state[buyer].inventory[good].amount += amount
  game_state[buyer].wallet_balance -= price
  -- # Planet specific bookkeeping
  if buyer == 'player' then reevaluate_price(trader, good) end
  if trader == 'player' then reevaluate_price(buyer, good) end
  return true, ""
end

function advance_simulation()
  game_state.day_of_simulation += 1
  printh("Day "..game_state.day_of_simulation)
  for planet in all(planet_keys) do
    printh("Updating "..planet)
    generate_news(planet)
    produce_and_consume_goods(planet)
    reevaluate_prices(planet)
  end
end

function generate_news(planet)
  --TODO generate events dynamically here to impact the planets, and then report on them here
  game_state.news_ticker.news = "Sutek chip production embargoed by Byzantine fleet over conflicts with House Hazat. Vera Cruz hostilities continue to affect cola supplies. Aragon undergoing a fad diet, increasing demand for meat and salads."
end

function produce_and_consume_goods(planet)
  --TODO have each planet headquarter companies that produce/consume different mixes of material
  --TODO increase the planets' stock based on its on-planet production facilities and demographic consumption
  --TODO figure out if planets should have wallets
  if game_state[planet].wallet_balance < 1000 then game_state[planet].wallet_balance += 1000 end 
  for good in all(trade_good_keys) do
    game_state[planet].inventory[good].amount += game_state[planet].production[good]
    game_state[planet].inventory[good].amount -= game_state[planet].consumption[good]
    game_state[planet].inventory[good].amount = clamp(game_state[planet].inventory[good].amount, 0, 127)
  end
end

function reevaluate_prices(planet)
  for trade_good in all(trade_good_keys) do
    reevaluate_price(planet, trade_good)
  end
end

function reevaluate_price(planet, trade_good)
  local in_stock = game_state[planet].inventory[trade_good].amount
  local tax_rate = game_state[planet].tax_rate --margin the planet wants sales to you
  local desired_stock = 64 --quantity desired TODO make this planet specific
  local base_price = 5 --price when satisifed TODO make this good-specific (planet specific too?)
  local f0 = 4 --base_price multiplier when none in stock.
  printh("Calculating bpm of "..trade_good.." on '"..planet.."' = "..base_price.."*e^(("..in_stock.."/"..desired_stock..")*ln(1/"..f0.."))")
  local neg_ln_4 = -1.3862943611 --ln(1/f0), but Pico doesn't have ln
  local base_price_multiplier = f0*2.71828^((in_stock/desired_stock)*neg_ln_4)
  local today_buy = base_price * base_price_multiplier
  local today_sell = base_price * base_price_multiplier * (1+tax_rate/100)
  game_state[planet].inventory[trade_good].buy_price = today_buy
  game_state[planet].inventory[trade_good].sell_price = today_sell
end

-- # PICO CALLBACKS

function _draw()
  if(not game_state) then return end
  --Background and border
	rectfill(0,0,127,127,0)
  --Scene
  if(game_state.current_planet_scene == 'durruti') then
    draw_durruti()
  end
  if(game_state.current_planet_scene == 'aragon') then
    draw_default_planet('aragon')
  end
  if(game_state.current_planet_scene == 'byzantium II') then
    draw_default_planet('byzantium II')
  end
  if(game_state.current_planet_scene == 'vera cruz') then
    draw_default_planet('vera cruz')
  end
  if(game_state.current_planet_scene == 'sutek') then
    draw_default_planet('sutek')
  end
  --Interfaces
  if(game_state.active_interface == 'root_interface') then
    draw_root_interface(game_state.root_interface)
    draw_balance()
    draw_news_ticker()
  end
  if(game_state.active_interface == 'trade_interface') then
    draw_purchase_interface(game_state.trade_interface)
    draw_balance()
    draw_news_ticker()
  end
  if(game_state.active_interface == 'map_interface') then
    draw_map_interface(game_state.map_interface)
    draw_news_ticker()
  end
  if(game_state.active_interface == 'info_interface') then
    draw_info_interface(game_state.info_interface)
  end
  --Border
	rect(0,0,127,127,1)
end

function _update()
  --Update the news ticker
  game_state.news_ticker.scroll_x += 1
  if(game_state.news_ticker.scroll_x > 4 * #game_state.news_ticker.news) then game_state.news_ticker.scroll_x = -127 end
  -- Navigating with Cursor
  local dir = nil
  if (btnp(0)) then dir = 'left' end
  if (btnp(1)) then dir = 'right' end
  if (btnp(2)) then dir = 'up' end
  if (btnp(3)) then dir = 'down' end
  local current_splat = game_state[game_state.active_interface].current_splat
  local tgt = game_state[game_state.active_interface].splats[current_splat]
  if(tgt and tgt[dir]) then game_state[game_state.active_interface].current_splat = tgt[dir] end
  --Pressed A
  if (btnp(5)) then game_state.active_interface = 'root_interface' end
  --Pressed B
  if btnp(4) and current_splat then game_state[game_state.active_interface].splats[current_splat].execute() end
end

function _init()
  game_state = create_game_state()
  advance_simulation()
end

__gfx__
00000000000660000000090000000000000bb0000000666600076500000a00000000000000000000000000000000000000000000000000000000000000000000
0000000006666660000090000000000000b333000006666500566650033b33300000000000000000000000000000000000000000000000000000000000000000
007007000c66669b000900000000444000000330006666550015661003b33ba00000000000000000000000000000000000000000000000000000000000000000
000770000cc669b0009000b0ff004444b00b333b066665550011118003b3b3300000000000000000000000000000000000000000000000000000000000000000
000770000ccc9b9009900bbbfff444480bb3333b777755560081188003bb3ba00000000000000000000000000000000000000000000000000000000000000000
007007000ccbb990009900b0004444880333b330077555600018881033b33b300000000000000000000000000000000000000000000000000000000000000000
0000000000cc99000009900066666666444b34340775560000111110833b3b300000000000000000000000000000000000000000000000000000000000000000
00000000000c900000009900000666600444b4407777600000011100000a00000000000000000000000000000000000000000000000000000000000000000000
