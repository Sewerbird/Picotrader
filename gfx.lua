-- # USER INTERFACE & GRAPHICS

function draw_planet_scene(scene)
  --Note: Enforces 'arrival' animation
  local picture = g[scene].picture
  local ticker = g[scene].ticker
  --Black of Space
  rectfill(0,0,127,127,0)
  --Stars (are shared between everyone via the warpspace scene)
  each(g.warpspace.picture.stars,function(v) circ(v.x, v.y, v.r, v.c) end)
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
    local y = picture.star_port.y
    local spridx = picture.star_port.spridx
    local l_x = lerp(clamp(ticker,0,60)/60,127,0)
    local x = picture.star_port.x + l_x
    for i=0,3 do
      pal()
      if(picture.blink_sprite) then picture.blink_sprite(picture.star_port) end
      spr(spridx+16*i,x,y+i*8)
      spr(spridx+16*i+1,x+8,y+i*8)
      pal()
    end
  end
  --Name Label
  rectfill(2,2,60,8,0)
  print_text_in_rect(picture.label,2,2,60,8,13)
  --Interfaces
  for interface in all(g.active_interfaces) do
    g[interface]:draw()
  end
  --Interface border
  rect(0,0,127,127,1)
end

function draw_warp_scene()
  -- Draws the travel animation
  local duration = g.warpspace.travel_time
  local c_x = g.warpspace.picture.c_x
  local c_y = g.warpspace.picture.c_y
  local speed = ease_in_out(g.warpspace.ticker/(duration), g.warpspace.speed, 1, 0.6)
  for i=1,#g.warpspace.picture.stars do
    local star = g.warpspace.picture.stars[i]
    --check if off screen
    if star.x > 127 or star.x < 0 or star.y > 127 or star.y < 0 then
      g.warpspace.picture.stars[i].x = rnd()*127
      g.warpspace.picture.stars[i].y = rnd()*127
      circ(star.x,star.y,0,star.c)
    else
      local dx = (-c_x + star.x)/speed
      local dy = (-c_y + star.y)/speed
      g.warpspace.picture.stars[i].x += dx
      g.warpspace.picture.stars[i].y += dy
      line(star.x,star.y,star.x-dx,star.y-dy,star.c)
    end
  end
  print(""..g.destination_planet_scene.."\nETA: "..flr((g.warpspace.travel_time-g.warpspace.ticker)/30),c_x-16,c_y+4,8)
  spr(0,c_x-4,c_y-4)
end

function draw_balance()
  rectfill(127-34,0,127,8, 0)
  rect(127-34,0,127,8, 1)
  local kilodollars = flr(g.player.wallet_balance)
  local dollars = flr(1000*(g.player.wallet_balance - flr(g.player.wallet_balance)))
  if kilodollars > 0 and dollars < 100 then dollars = "0"..dollars
  elseif kilodollars > 0 and dollars < 10 then dollars = "00"..dollars end
  print_centered_text_in_rect("$"..(kilodollars>0 and (kilodollars..",") or "")..dollars,127-34,0,127,8,11)
  rectfill(127-30,8,127,16, 0)
  rect(127-34,8,127,16, 1)
  print_centered_text_in_rect(""..flr(g.player.storage_used+0.5).."/"..flr(g.player.cargo_hold_size+0.5).."t",127-34,8,127,16,g.player.storage_remaining > 1 and 11 or 8)
end

function draw_news_ticker()
  rectfill(0,115,127,125, 1)
  rectfill(0,116,127,124, 13)
  print(g.news_ticker.news, -g.news_ticker.scroll_x, 118, 6)
end

function root_interface(trader)
  local l_x = 0
  local t_y = 105
  local h = 10
  local tab_w = 22
  local w = 80
  local result = {
    active = false,
    entry_splat = "trade",
    current_splat = "trade",
    settings = {
    },
    draw = function(interface)
      local tab_keys = {"trade","map","info"}
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
      right= 'map',
      execute= function()
        push_interface('trade_interface')
      end
    },
    map = {
      x= (tab_w+1)*1 + l_x, y= t_y, w=tab_w, h = h, 
      left= 'trade', right= 'info',
      execute= function()
        push_interface('map_interface')
      end
    },
    info = {
      x= (tab_w+1)*2+ l_x, y= t_y, w=tab_w, h = h, 
      left= 'map',
      execute= function()
        push_interface('info_interface')
      end
    }
  }
  return result
end


function popup_dialog(type, title, text, parent_interface, callbacks)
  local title = title
  local l_x = 18
  local t_y = 32
  local w = 92
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
        rectfill(c_x-b_w-b_o, t_y+h-b_h,c_x-b_o,t_y+h,13)
        rect(c_x-b_w-b_o, t_y+h-b_h,c_x-b_o,t_y+h,5)
        print_centered_text_in_rect("yES",c_x-b_w-b_o, t_y+h-b_h,c_x-b_o,t_y+h,7)
        rectfill(c_x+b_o, t_y+h-b_h,c_x+b_w+b_o,t_y+h,13)
        rect(c_x+b_o, t_y+h-b_h,c_x+b_w+b_o,t_y+h,5)
        print_centered_text_in_rect("nO",c_x+b_o,t_y+h-b_h,c_x+b_w+b_o,t_y+h,7)
      else
        rectfill(c_x-b_w/2, t_y+h-b_h,c_x+b_w/2,t_y+h,13)
        rect(c_x-b_w/2, t_y+h-b_h,c_x+b_w/2,t_y+h,5)
        print_centered_text_in_rect("oKAY",c_x-b_w/2, t_y+h-b_h,c_x+b_w/2,t_y+h,7)
      end
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
        g.popup_dialog.active = false
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
        g.popup_dialog.active = false
        pop_interface()
        if callbacks["yes"] then callbacks["yes"]() end
      end
    },
    ["no"] = {
      x = c_x+b_o, y= t_y+h-b_h, w = b_w, h= b_h,
      left = "yes",
      execute = function()
        g.popup_dialog.active = false
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

function purchase_interface(location)
  local l_x = 64 - 80/2
  local c_x = 64
  local r_x = 64 + 80/2
  local h_h = 10
  local r_h = 10
  local t_y = 24
  local w = 80
  local result = {
    active = false,
    entry_splat = "buy_medicine",
    current_splat = "buy_medicine",
    current_location = location,
    draw = function(interface)
      rectfill(0,t_y,128,t_y+h_h,1)
      print_centered_text_in_rect("sell", l_x, t_y, l_x + w/3, t_y+h_h, 6)
      print_centered_text_in_rect("buy", r_x - w/3, t_y, r_x, t_y+h_h, 6)
      print_centered_text_on_point("trade", l_x + w/2, t_y+h_h, 6)
      print_centered_text_in_rect("port", 0, t_y, l_x, t_y+h_h, 6)
      print_centered_text_in_rect("ship", r_x, t_y, 127, t_y+h_h, 6)
      local i = 1
      for key in all(trade_good_keys) do
        local sprite_id = trade_goods[key].sprite_id
        local left = l_x
        local top = t_y+i*r_h-2
        local w = w
        local h = r_h
        local c_x = left+(w/2)
        local sell_price = g[interface.current_location].business[key].buy_price
        local buy_price = g[interface.current_location].business[key].sell_price
        local avg_price = g.player.business[key].avg_price
        rectfill(0,top,127, top+h, 5) --Background
        rect(0,top,127, top+h, 1) --Background border
        rectfill(left,top,left+w, top+h, 13) --Center column background
        rect(left,top,left+w,top+h, 1) -- Center column border
        spr(sprite_id, c_x-4, top+1) --Good Sprite
        print_centered_text_in_rect("+$"..flr(sell_price+0.5), left, top, c_x-4-8, top+h, avg_price > sell_price and 8 or 11) --Sell Amount
        print_centered_text_in_rect("-$"..flr(buy_price+0.5), c_x+4+8, top, left+w, top+h, avg_price < buy_price and 8 or 11) --Buy Amount
        trader_amount = g[interface.current_location].business[key].inventory
        player_amount = g.player.business[key].inventory
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
        local amount = btn(1) and 5 or 1
        local success, error = buy_from_trader(location,"player",good,amount)
        if(not success) then printh("Error selling: '"..error.."'") end
      end
    }
    splats["sell_"..good] = {
      x = l_x, y = t_y - 2 + h_h + (row-1)*r_h, w = w/3, h = r_h,
      up = (row > 1 and ("sell_"..trade_good_keys[row-1]) or nil),
      left = nil, right = "buy_"..good,
      down = (row < #trade_good_keys and ("sell_"..trade_good_keys[row+1]) or nil),
      execute = function()
        local amount = btn(0) and 5 or 1
        local success, error = buy_from_trader("player",location,good,amount)
        if(not success) then printh("Error selling: '"..error.."'") end
      end
    }
    row = row + 1
  end
  result.splats = splats
  return result
end

function info_interface(location)
  local l_x = 64 - 80/2
  local c_x = 64
  local r_x = 64 + 80/2
  local h_h = 10
  local r_h = 10
  local t_y = 32
  local w = 80
  local result = {
    active = false,
    entry_splat = location,
    current_splat = nil,
    current_location = location,
    draw = function(interface)
      local planet = planet_info[interface.current_location]
      local w = 75
      local h = 60
      local l_x = 0
      local h_h = 8
      local t_y = 127-h-47+10+10
      local r = w * sqrt(1/6)
      -- Background
      rectfill(0,t_y,127,103+11,0)
      -- Sidebar
      local info = {
        owner = planet.owner,
        ["tax rate"] = ""..g[interface.current_location].business.tax_rate.."%",
        coffers = "$"..g[interface.current_location].wallet_balance,
        type = planet_info[interface.current_location].type,
        size = planet_info[interface.current_location].size
      }
      local h_h = 8.4
      t_y -= 8
      for key, value in pairs(info) do
        rectfill(l_x+w,t_y,127,t_y+h_h,1)
        rect(l_x+w,t_y,127,t_y+h_h*2,1)
        print_centered_text_in_rect(key,l_x+w,t_y,127,t_y+h_h,7)
        print_centered_text_in_rect(value,l_x+w,t_y+h_h,127,t_y+h_h*2,7)
        t_y = t_y + h_h + h_h
      end
      --Economy
      t_y = 127-h-47+10+10
      local mid_x = l_x + w/2
      local mid_y = t_y + w/2
      rectfill(l_x-1,t_y-8,l_x+w+2,t_y-8+8, 1)
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
        net_production = g[interface.current_location].business[trade_good_keys[i]].net_production
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
      l_x = 64 - 80/2,
      t_y = 32,
      w = 80
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
      l_x = 64 - 80/2,
      c_x = 64,
      r_x = 64 + 80/2,
      h_h = 10,
      r_h = 10,
      t_y = 32,
      w = 80
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
            line(planet.map_x, planet.map_y, other.map_x, other.map_y, 5)
          end
        end
      end
      -- # Planets
      for key in all(planet_keys) do
        local planet = planet_info[key]
        if planet.size == 'megalopolis' then
          circfill(planet.map_x,planet.map_y,planet.map_r+2,6)
          circfill(planet.map_x,planet.map_y,planet.map_r+1,10)
        elseif planet.size == 'homeworld' then
          circfill(planet.map_x,planet.map_y,planet.map_r+1,6)
        end
        circfill(planet.map_x,planet.map_y,planet.map_r,planet_types[planet.type].p_c1)
        circ(planet.map_x,planet.map_y,planet.map_r,planet_types[planet.type].p_c2)
        if key == interface.current_location then
          circ(planet.map_x,planet.map_y,(mod(flr(time()),2) == 1 and 4 or 6), 11)
        end
      end
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
        local here = g.map_interface.current_location
        --TODO Add travel events between planets
        g.popup_dialog = popup_dialog("yesno","Travel?","tRAVELLING TO "..key.." WILL COST $"..flr(travel_cost(here,key)).." AND TAKE "..flr(travel_time(here,key)).." DAYS", "map_interface",
        {
          ["yes"]= function()
            if can_travel(here,key) then
              travel(here,key)
              pop_interface() --Exit map scene and focus map tab
              g[active_interface()].current_splat = "map"
            else
              pop_interface()
              g.popup_dialog = popup_dialog("ok","sTUCK?","yOU CAN'T AFFORD THE TRIP TO "..key..": SELL SOME WARES TO BUY PASSAGE", "map_interface",{})
              push_interface("popup_dialog")
            end
          end
        })
        push_interface("popup_dialog")
      end
    }
  end
  result.splats = splats
  return result
end

