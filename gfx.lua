-- # USER INTERFACE & GRAPHICS

function popup_dialog(type, title, text, parent_interface, callbacks)
  local title = title
  local l_x = 32
  local t_y = 32
  local w = 64
  local c_x = l_x+w/2
  local h = 64
  local b_o = 3
  local b_h = 8
  local b_w = 25
  local title_w = #title * 4
  local settings = {
  }
  local result = {
    active = false,
    type = type,
    title = title,
    text = text,
    entry_splat = type == "yesno" and "yes" or "ok",
    current_splat = type == "yesno" and "yes" or "ok",
    settings = settings,
    draw = function(dialog)
      --Background
      rectfill(l_x,t_y,l_x+w,t_y+h,1)
      --Title
      print(title, l_x+w-title_w-1, t_y+2,12)
      --Textarea
      print_text_in_rect(text, l_x+2,t_y+10,l_x+w,t_y+6+h,7)
      --Border
      rect(l_x,t_y,l_x+w,t_y+h,2)
      --Buttons
      if dialog.type == "yesno" then
        -- # Either/Or Dialog
        rectfill(c_x-b_w-b_o, t_y+h-b_h,c_x-b_o,t_y+h,13)
        rect(c_x-b_w-b_o, t_y+h-b_h,c_x-b_o,t_y+h,9)
        print_centered_text_in_rect("Yes",c_x-b_w-b_o, t_y+h-b_h,c_x-b_o,t_y+h,7)
        rectfill(c_x+b_o, t_y+h-b_h,c_x+b_w+b_o,t_y+h,13)
        rect(c_x+b_o, t_y+h-b_h,c_x+b_w+b_o,t_y+h,9)
        print_centered_text_in_rect("No",c_x+b_o,t_y+h-b_h,c_x+b_w+b_o,t_y+h,7)
      else
        -- # Acknowledgement Dialog
        rectfill(c_x-b_w/2, t_y+h-b_h,c_x+b_w/2,t_y+h,13)
        rect(c_x-b_w/2, t_y+h-b_h,c_x+b_w/2,t_y+h,9)
        print_centered_text_in_rect("Okay",c_x-b_w/2, t_y+h-b_h,c_x+b_w/2,t_y+h,9)
      end
      --## Active Splat
      local cursor = dialog.splats[dialog.current_splat]
      if(cursor) then
        rect(cursor.x, cursor.y, cursor.x + cursor.w, cursor.y + cursor.h, 14)
      end
    end
  }
  result.splats_ok = {
    ["ok"] = {
      x = c_x-b_w/2, y= t_y+h-b_h, w = b_w, h= b_h,
      execute = function()
        printh("ACKNOWLEDGED")
        game_state.popup_dialog.active = false
        pop_interface()
        if callbacks["ok"] then callbacks["ok"]() end
      end
    }
  }
  result.splats_yesno = {
    ["yes"] = {
      x = c_x-b_w-b_o, y= t_y+h-b_h, w = b_w, h= b_h,
      right = "no",
      execute = function()
        printh("YES")
        game_state.popup_dialog.active = false
        pop_interface()
        if callbacks["yes"] then callbacks["yes"]() end
      end
    },
    ["no"] = {
      x = c_x+b_o, y= t_y+h-b_h, w = b_w, h= b_h,
      left = "yes",
      execute = function()
        printh("NO")
        game_state.popup_dialog.active = false
        pop_interface()
        if callbacks["no"] then callbacks["no"]() end
      end
    }
  }
  if type == "yesno" then
    result.splats = result.splats_yesno
  else
    result.splats = result.splats_ok
  end
  return result
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
    pal()
    if(picture.blink_sprite) then picture.blink_sprite(v) end
    spr(v.spr, l_x, v.y) 
    pal()
  end)
  --Star Port
  if picture.star_port then
    --Draws a 2x4 rect of sprites. 
    --Input specifies the top-left sprite to begin with and its x,y
    local x0= picture.star_port.x
    local y = picture.star_port.y
    local spridx = picture.star_port.spridx
    local l_x = lerp(clamp(ticker,0,60)/60,127,0)
    local x = x0 + l_x
    spr(spridx,x,y)
    spr(spridx+1,x+8,y)
    spr(spridx+16,x,y+8)
    spr(spridx+16+1,x+8,y+8)
    spr(spridx+32,x,y+16)
    spr(spridx+32+1,x+8,y+16)
    spr(spridx+48,x,y+24)
    spr(spridx+48+1,x+8,y+24)
  end
  -- Name Label
  rectfill(1,1,40,8,0)
  print_centered_text_in_rect(picture.label, 0,0,40,8,13)
  -- Draw the UI
  --Interfaces
  for interface in all(game_state.active_interfaces) do
    game_state[interface]:draw()
  end
  -- Interface border
  rect(0,0,127,127,1)
end

function draw_warp_scene()
  -- Draws the travel animation
  local duration = game_state.warpspace.travel_time
  local c_x = game_state.warpspace.picture.c_x
  local c_y = game_state.warpspace.picture.c_y
  local speed = ease_in_out(game_state.warpspace.ticker/(duration), game_state.warpspace.speed, 1, 0.6)
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
  print(""..game_state.destination_planet_scene.."\nETA: "..(flr((game_state.warpspace.travel_time-game_state.warpspace.ticker)/3)/10),c_x-16,c_y+4,8)
  spr(0,c_x-4,c_y-4)
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


function purchase_interface(location)
  local l_x = 64 - 80/2 --left side of center column
  local c_x = 64 --center of center column
  local r_x = 64 + 80/2 --right side of center column
  local h_h = 10 --header height
  local r_h = 10 --row height
  local t_y = 24 --top of interface
  local w = 80 --width of center column
  local result = {
    active = false,
    entry_splat = "buy_sundries",
    current_splat = "buy_sundries",
    current_location = location,
    draw = function(interface)
      --# CENTER COLUMN
      --## Header
      rectfill(0,t_y,128,t_y+h_h,1)
      print_centered_text_in_rect("sell", l_x, t_y, l_x + w/3, t_y+h_h, 6)
      print_centered_text_in_rect("buy", r_x - w/3, t_y, r_x, t_y+h_h, 6)
      print_centered_text_on_point("trade", l_x + w/2, t_y+h_h, 6)
      print_centered_text_in_rect("port", 0, t_y, l_x, t_y+h_h, 6)
      print_centered_text_in_rect("ship", r_x, t_y, 127, t_y+h_h, 6)
      --## Rows
      local i = 1
      for key in all(trade_good_keys) do
        local sprite_id = trade_goods[key].sprite_id
        local left = l_x
        local top = t_y+i*r_h-2
        local w = w
        local h = r_h
        local c_x = left+(w/2)
        local sell_price = game_state[interface.current_location].business[key].buy_price
        local buy_price = game_state[interface.current_location].business[key].sell_price
        local avg_price = game_state.player.business[key].avg_price
        rectfill(0,top,127, top+h, 5) --Background
        rect(0,top,127, top+h, 1) --Background border
        rectfill(left,top,left+w, top+h, 13) --Center column background
        rect(left,top,left+w,top+h, 1) -- Center column border
        spr(sprite_id, c_x-4, top+1) --Good Sprite
        print_centered_text_in_rect("+$"..flr(sell_price+0.5), left, top, c_x-4-8, top+h, avg_price > sell_price and 8 or 11) --Sell Amount
        print_centered_text_in_rect("-$"..flr(buy_price+0.5), c_x+4+8, top, left+w, top+h, avg_price < buy_price and 8 or 11) --Buy Amount
        trader_amount = game_state[interface.current_location].business[key].inventory
        player_amount = game_state.player.business[key].inventory
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
  }
  local splats = {}
  local row = 1
  for good in all(trade_good_keys) do
    splats["buy_"..good] = {
      x = c_x + w/6, y = t_y - 2 + h_h + (row-1)*r_h, w = w/3, h = r_h,
      up = (row > 1 and ("buy_"..trade_good_keys[row-1]) or nil),
      left = "sell_"..good, right = nil,
      down = (row < #trade_good_keys and ("buy_"..trade_good_keys[row+1]) or nil),
      execute = function()
        local success, error = buy_from_trader(location,"player",good,1)
        if(not success) then printh("Error selling: '"..error.."'") end
      end
    }
    splats["sell_"..good] = {
      x = l_x, y = t_y - 2 + h_h + (row-1)*r_h, w = w/3, h = r_h,
      up = (row > 1 and ("sell_"..trade_good_keys[row-1]) or nil),
      left = nil, right = "buy_"..good,
      down = (row < #trade_good_keys and ("sell_"..trade_good_keys[row+1]) or nil),
      execute = function()
        local success, error = buy_from_trader("player",location,good,1)
        if(not success) then printh("Error selling: '"..error.."'") end
      end
    }
    row = row + 1
  end
  result.splats = splats
  return result
end

function root_interface(trader)
  local   l_x = 0
  local   t_y = 105 --top of interface
  local   h = 10
  local   tab_w = 22
  local   w = 80 --width of center column
  local result = {
    active = false,
    entry_splat = "trade",
    current_splat = "trade",
    settings = {
    },
    draw = function(interface)
      local tab_keys = {"trade","map","info","ship","bar"}
      local i = 0
      for tab_key in all(tab_keys) do
        local w= tab_w
        local h= h 
        local x= l_x+i*w+i
        local y= t_y
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
      draw_balance()
      draw_news_ticker()
    end
  }
  result.splats = {
    trade = {
      x= l_x, y= t_y, w=tab_w, h = h, 
      up= nil, down= nil, left= nil, right= 'map',
      execute= function()
        push_interface('trade_interface')
      end
    },
    map = {
      x= (tab_w+1)*1 + l_x, y= t_y, w=tab_w, h = h, 
      up= nil, down= nil, left= 'trade', right= 'info',
      execute= function()
        push_interface('map_interface')
      end
    },
    info = {
      x= (tab_w+1)*2+ l_x, y= t_y, w=tab_w, h = h, 
      up= nil, down= nil, left= 'map', right= 'ship',
      execute= function()
        push_interface('info_interface')
      end
    },
    ship = {
      x= (tab_w+1)*3+ l_x, y= t_y, w=tab_w, h = h, 
      up= nil, down= nil, left= 'info', right= 'bar',
      execute= function()
        push_interface('ship_interface')
      end
    },
    bar = {
      x= (tab_w+1)*4+ l_x, y= t_y, w=tab_w, h = h, 
      up= nil, down= nil, left= 'ship', right= nil,
      execute= function()
        push_interface('ship_interface')
      end
    },
  }
  return result
end

function info_interface(location)
  local l_x = 64 - 80/2 --left side of center column
  local c_x = 64 --center of center column
  local r_x = 64 + 80/2 --right side of center column
  local h_h = 10 --header height
  local r_h = 10 --row height
  local t_y = 32 --top of interface
  local w = 80 --width of center column
  local result = {
    active = false,
    entry_splat = location,
    current_splat = nil,
    current_location = location,
    draw = function(interface)
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
        net_production = game_state[interface.current_location].business[trade_good_keys[i]].net_production
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
      print_centered_text_in_rect(""..game_state[interface.current_location].business.tax_rate.."%",l_x+w+2,t_y+3*h_h,127,t_y+4*h_h,7)
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
  }
  result.splats = { [location] = {}}
  return result
end

function ship_interface(trader)
  local result = {
    active = false,
    entry_splat = trader,
    current_splat = trader,
    current_location = trader,
    settings = {
      l_x = 64 - 80/2, --left side of center column
      t_y = 32, --top of interface
      w = 80 --width of center column
    },
    draw = function(interface)
      local t = interface.settings
    end
  }
  local splats = {}
  result.splats = splats
  return result
end

function bar_interface(trader)
  local result = {
    active = false,
    entry_splat = trader,
    current_splat = trader,
    current_location = trader,
    settings = {
      l_x = 64 - 80/2, --left side of center column
      t_y = 32, --top of interface
      w = 80 --width of center column
    },
    draw = function(interface)
      local t = interface.settings
    end
  }
  local splats = {}
  result.splats = splats
  return result
end

function map_interface(trader)
  local result = {
    active = false,
    entry_splat = trader,
    current_splat = trader,
    current_location = trader,
    settings = {
      l_x = 64 - 80/2, --left side of center column
      c_x = 64, --center of center column
      r_x = 64 + 80/2, --right side of center column
      h_h = 10, --header height
      r_h = 10, --row height
      t_y = 32, --top of interface
      w = 80 --width of center column
    },
    draw = function(interface)
      local t = interface.settings
      -- # Black of Space
      rectfill(0,0,127,127,0)
      -- # Background stars
      for star in all(interface.background_stars) do
        circ(star.x, star.y, star.r, star.c)
      end
      -- # Hyperlanes
      for key in all(planet_keys) do
        local planet = planet_info[key]
        for k in all(directions) do
          if planet[k] then
            local other = planet_info[planet[k]]
            line(planet.map_x, planet.map_y, other.map_x, other.map_y, 6)
          end
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
    end,
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
        --TODO Add travel events between planets
        --Do next turn, and arrive at destination
        local here = planet_info[game_state.current_planet_scene]
        printh("Here is "..game_state.current_planet_scene)
        printh("There is "..key)
        local warp_distance = dist(planet_info[key].map_x, planet_info[key].map_y, here.map_x, here.map_y)
        game_state.popup_dialog = popup_dialog("yesno","Travel?","Travel to "..key.." will take "..flr(warp_distance), "map_interface",
        {
          ["yes"]= function()
            printh("Warp distance is "..warp_distance)
            game_state.warpspace.travel_time = warp_distance/10
            advance_simulation()
            game_state[game_state.current_planet_scene].picture.sprites = nil
            game_state.current_planet_scene="warpspace"
            game_state.destination_planet_scene= key
            game_state.trade_interface = purchase_interface(key)
            game_state.root_interface = root_interface(key)
            game_state.map_interface = map_interface(key)
            game_state.info_interface = info_interface(key)
            pop_interface() -- Pop out of map view
            game_state[active_interface()].current_splat = "map" -- ...but leave it selected in the root view
          end
        })
        push_interface("popup_dialog")
      end
    }
  end
  result.splats = splats
  return result
end

