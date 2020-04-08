-- # USER INTERFACE & GRAPHICS

function draw_interface(interface)
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
end

function draw_planet_scene(scene)
  --Note: Enforces 'arrival' animation
  local picture = game_state[scene].picture
  local ticker = game_state[scene].ticker
  --Black of Space
  rectfill(0,0,127,127,0)
  --Stars (are shared between everyone via the warpspace scene)
  each(game_state.warpspace.picture.stars,function(v) circ(v.x, v.y, v.r, v.c) end)
  --Suns
  each(picture.suns,function(v) 
    -- Suns wink into their position
    local s_r = lerp(clamp(ticker,0,20)/20,0,v.r)
    circfill(v.x, v.y, s_r, v.c) 
    -- Suns shine
    circ(v.x,v.y,(mod(flr(time()),2) == 0 and s_r*2 or s_r*2.5), v.c1)
    circ(v.x,v.y,(mod(flr(time()),2) == 1 and s_r*3 or s_r*3.5), v.c2)
  end)
  --Planets
  each(picture.planets,function(v) 
    -- Planet gets scrolled in from righthand of screen to its position
    local l_x = lerp(clamp(ticker,0,60)/60,v.x+127,v.x)
    circfill(l_x, v.y, v.r, v.c) 
  end)
  --Sprites
  each(picture.sprites,function(v) 
    --Sprites are asssumed to be relative to the planet, so scroll in with it
    local l_x = lerp(clamp(ticker,0,60)/60,v.x+127,v.x)
    spr(v.spr, l_x, v.y) 
  end)
  -- Name Label
  rectfill(1,1,40,8,0)
  print_centered_text_in_rect(picture.label, 0,0,40,8,13)
  -- Interface border
  rect(0,0,127,127,1)
end

function draw_warp_scene()
  -- Draws the travel animation
  local duration = game_state.warpspace.travel_time
  local c_x = game_state.warpspace.picture.c_x
  local c_y = game_state.warpspace.picture.c_y
  game_state.warpspace.picture.c_x = clamp(c_x + rnd(8)-4,32,96)
  game_state.warpspace.picture.c_y = clamp(c_y + rnd(8)-4,32,96)
  local speed = ease_in_out(game_state.warpspace.ticker/(duration), game_state.warpspace.speed, 0)
  for i=1,#game_state.warpspace.picture.stars do
    local star = game_state.warpspace.picture.stars[i]
    --check if off screen
    if star.x > 127 or star.x < 0 or star.y > 127 or star.y < 0 then
      game_state.warpspace.picture.stars[i].x = rnd()*127
      game_state.warpspace.picture.stars[i].y = rnd()*127
      circ(star.x,star.y,0,star.c)
    else
      local dx = (-c_x + star.x)/speed
      local dy = (-c_y + star.y)/speed
      game_state.warpspace.picture.stars[i].x += dx
      game_state.warpspace.picture.stars[i].y += dy
      line(star.x,star.y,star.x-dx,star.y-dy,star.c)
    end
  end
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
        game_state.current_planet_scene="warpspace"
        game_state.destination_planet_scene= key
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


