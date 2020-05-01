-- # GAME STATE & MUTATIONS

function init_business(tax_rate, inventory, base_production, base_consumption)
  local result = {
    tax_rate = tax_rate
  }
  for good in all(trade_good_keys) do
    result[good] = {
      base_price = 5, desired_stock= 64, base_production= base_production, base_consumption= base_consumption,
      net_production = base_production - base_consumption, buy_price = 0, avg_price = 0, sell_price= 0, inventory= inventory,
    }
  end
  return result
end

function make_planet(name,x,y,lanes,owner_code,type_code,size_code)
  local atmosphere_class = sub(type_code,1,1)
  local population_class = sub(type_code,2,2)
  local owner_class = sub(type_code,3,3)
  local result = {
    tax_rate = size_code_multipliers[size_code]*rndi(5)
  }
  for good in all(trade_good_keys) do
    local base_production = size_code_multipliers[size_code]
    local base_consumption = size_code_multipliers[size_code]
    base_production += (trade_good_mods[good][type_code] or 0) + (trade_good_mods[good][owner_code] or 0)
    result[good] = {
      base_price = trade_goods[good].base_price, desired_stock= 32+rndi(32), base_production= base_production, base_consumption= base_consumption,
      net_production = base_production - base_consumption, buy_price = 0, avg_price = 0, sell_price= 0, inventory= 64,
    }
  end
  planet_info[name]={
    name=name, map_x = x, map_y = y, map_r = 2,map_c=12,
    up=lanes.up,left=lanes.left,down=lanes.down,right=lanes.right,
    owner=owner_code,
    size=size_code,
    type=type_code,
    start_economy = result
  }
end

function create_game_state()
  make_planet("leminkainan",56,8,{left="ravenna",right="pentateuch"},"locals","icy","colony")
  make_planet("bannock",32,16,{down="stigmata",right="ravenna"},"locals","barren","post")
  make_planet("pentateuch",80,16,{left="leminkainan",down="delphi",right="terra"},"empire","ocean","colony")
  make_planet("artemis",112,16,{left="terra"},"locals","icy","post")
  make_planet("ravenna",48,24,{left="bannock",up="leminkainan",down="shaprut"},"locals","barren","colony")
  make_planet("terra",96,24,{left="pentateuch",right="artemis",down="sutek"},"church","ocean","megalopolis")
  make_planet("stigmata",24,32,{up="bannock",right="istakhr",down="aylon"},"empire","jungle","colony")
  make_planet("shaprut",45,36,{up="ravenna",right="delphi",down="istakhr"},"locals","airless","post")
  make_planet("delphi",64,32,{up="pentateuch",left="shaprut",right="tethys"},"hawkwood","icy","homeworld")
  make_planet("sutek",102,40,{up="terra",left="tethys",down="vera cruz"},"empire","jungle","colony")
  make_planet("istakhr",40,48,{up="shaprut",left="stigmata",down="criticorum"},"al malik","ocean","homeworld")
  make_planet("tethys",80,48,{left="delphi",right="sutek",down="byzantium"},"locals","ocean","colony")
  make_planet("aylon",16,56,{up="stigmata",right="criticorum",down="cadavus"},"empire","icy","post")
  make_planet("criticorum",40,64,{up="istakhr",left="aylon",right="byzantium",down="kish"},"locals","barren","colony")
  make_planet("byzantium",64,64,{left="criticorum",right="aragon",down="madoc",up="tethys"},"empire","urban","megalopolis")
  make_planet("vera cruz",112,64,{up="sutek",left="aragon"},"locals","ocean","colony")
  make_planet("cadavus",24,72,{up="aylon",down="severus",right="malignatius"},"empire","jungle","colony")
  make_planet("aragon",88,72,{left="byzantium",right="vera cruz",down="leagueheim"},"hazat","ocean","homeworld")
  make_planet("de moley",8,80,{right="severus"},"empire","jungle","post")
  make_planet("kish",48,80,{up="criticorum",left="malignatius",right="madoc",down="icon"},"li halan","barren","homeworld")
  make_planet("madoc",64,80,{left="kish",up="byzantium",right="leagueheim"},"locals","ocean","colony")
  make_planet("malignatius",32,88,{left="cadavus",right="kish",down="cadiz"},"empire","icy","post")
  make_planet("severus",16,96,{left="de moley",right="cadiz",up="cadavus"},"decados","jungle","homeworld")
  make_planet("leagueheim",80,96,{left="madoc",right="grail",up="aragon",down="rampart"},"league","urban","megalopolis")
  make_planet("grail",112,96,{left="leagueheim"},"locals","barren","post")
  make_planet("cadiz",32,104,{left="severus",right="icon",up="malignatius",down="vril ya"},"locals","ocean","post")
  make_planet("icon",48,104,{left="cadiz",right="midian",up="kish",down="manitou"},"empire","barren","post")
  make_planet("midian",64,104,{left="icon",right="rampart",down="apshai"},"locals","barren","post")
  make_planet("vril ya",16,112,{right="vau",up="cadiz"},"vril ya","ocean","megalopolis")
  make_planet("rampart",80,112,{left="midian",up="leagueheim",right="pandemonium",down="apshai"},"locals","airless","post")
  make_planet("vau",24,120,{left="vril ya",right="manitou"},"vril ya","ocean","megalopolis")
  make_planet("manitou",40,120,{left="vau",right="apshai",up="icon"},"empire","jungle","post")
  make_planet("apshai",56,120,{left="manitou",up="midian",right="rampart"},"locals","barren","colony")
  make_planet("pandemonium",112,120,{left="rampart"},"locals","airless","post")
  for k,v in pairs(planet_info) do
    add(planet_keys, k)
  end

  local result = {
    day_of_simulation = -19,
    current_planet_scene = "delphi",
    destination_planet_scene = "delphi",
    active_interfaces = {"root_interface","popup_dialog"},
    player = {
      storage_remaining = 100,
      storage_used = 0,
      cargo_hold_size = 100,
      wallet_balance = 0.123,
      business = init_business(0,0,0,0),
      events = {},
      picture = {}
    },
    warpspace = {
      ticker = 0,
      travel_time = 30, --ticks
      speed = 40,
      picture = {
        c_x= 64, c_y= 64,
        speed = 400,
        stars = times(function(i,with)
          local x = flr(rnd(127))
          local y = flr(rnd(127))
          local c = with.col[flr(rnd(6))+1]
          return {x= x, y= y, r=0, c= c}
        end, 200, {col= {7,7,6,5,1,2}})
      }
    },
    trade_interface = purchase_interface("delphi"),
    root_interface = root_interface("delphi"),
    map_interface = map_interface("delphi"),
    info_interface = info_interface("delphi"),
    ship_interface = ship_interface("delphi"),
    popup_dialog = popup_dialog("ok","fADING sUNS tRADER","nEW lEAGUER, tRAVEL THE GALAXY MAKING A PROFIT! rETIRE BY AMASSING $100000. gOOD lUCK!","root_interface",{}),
    news_ticker = {
      scroll_x = -127,
      news = "Welcome aboard, trader: the world is at your fingertips"
    }
  }
  for k in all(planet_keys) do
    if not result[k] then
      local planet_type = planet_types[planet_info[k].type]
      local s_x = 64+(rndi(64)-32)
      local s_y = rndi(32)+16
      local s_r = rndi(3)+2
      local p_r = 80
      local dx = 64-s_x
      local dy = 64-s_y
      local p_x = 64 + dx + (dx > 0 and p_r/2 or -p_r/2)
      local p_y = 64 + dy + (dy > 0 and p_r/2 or -p_r/2)
      local p_c1 = planet_type.p_c1
      local p_c2 = planet_type.p_c2
      local ps_x = p_x>64 and p_x+3 or p_x-3
      local ps_y = p_y>64 and p_y+3 or p_y-3
      local possible_blinks = {7,8,9,10}
      result[k] = {
        ticker = 0,
        wallet_balance = 1000,
        business = planet_info[k].start_economy,
        events = {},
        picture = {
          label = k,
          star_port = {spridx=14, x=-(s_x-64)+64, y=s_y, blink_light=(possible_blinks[rndi(3)+1]), offset=0},
          suns = {{x= s_x, y= s_y, r= s_r, c= 7, c1= 7, c2= 7}},
          planets = {
            {x= p_x, y= p_y, r= p_r, c = p_c1},
            {x= ps_x, y= ps_y, r= p_r-3, c = p_c2}
          },
          blink_sprite = function(sprite)
            if sprite.blink_light and mod(flr(g[g.current_planet_scene].ticker-sprite.offset), 40) < 20 then
              pal(8,sprite.blink_light)
            elseif sprite.blink_light then
              pal(8,1)
            end
          end,
          sprite_method = function() return planet_type.sprites(p_x,p_y,p_r) end
        }
      }
    end
  end
  return result
end

function update_scene(scene)
  if g.popup_dialog.active then
    return
  end
  music_ticker += 1
  if music_ticker > 4000 then
    music(0)
    music_ticker = 0
  elseif mod(music_ticker,300)==0 then
    sfx(beepboops[rndi(#beepboops)+1])
  end
  g[scene].ticker += 1
  g.news_ticker.scroll_x += 1
  if(g.news_ticker.scroll_x > 4 * #g.news_ticker.news) then g.news_ticker.scroll_x = -127 end
  if scene == 'warpspace' then
    if g.warpspace.ticker > g.warpspace.travel_time then
      sfx(-1,3)
      sfx(34)
      g.current_planet_scene = g.destination_planet_scene
      g[g.current_planet_scene].picture.sprites = g[g.current_planet_scene].picture.sprite_method()
      g[g.current_planet_scene].ticker = 0
      g.warpspace.ticker = 0
      inspect(g[g.current_planet_scene].events)
    elseif g.warpspace.ticker == 4 then
      sfx(32,3)
    end
  else
    if g[g.current_planet_scene].picture.sprites == nil then 
      g[g.current_planet_scene].picture.sprites = g[g.current_planet_scene].picture.sprite_method()
    end
    if g.player.wallet_balance > win_amount then
      game_over = true
      g.popup_dialog = popup_dialog("ok","yOU wIN!!!","aFTER A LOT OF HARD WORK, YOU CAN RETIRE! \nCONGRATULATIONS STAR TRADER...","root_interface",
      {
        ["ok"] = function()
          extcmd('reset')
        end
      }, true)
      push_interface("popup_dialog")
    elseif g.player.wallet_balance <= lose_amount and total_goods() == 0 then
      game_over = true
      g.popup_dialog = popup_dialog("ok","bankrupt","fINDING YOURSELF PAUPERED, YOU ARE STRANDED ON THIS PLANET. \nGAMEOVER","root_interface",
      {
        ["ok"] = function()
          extcmd('reset')
        end
      }, true)
      push_interface("popup_dialog")
    end
  end
end

function buy_from_trader(trader, buyer, good, amount)
  local unit_price
  if(trader == 'player') then 
    unit_price = g[buyer].business[good].buy_price
  else 
    unit_price = g[trader].business[good].sell_price 
  end
  local price = unit_price * amount
  if(g[trader].business[good].inventory < amount) then
    sfx(37)
    return false, "Not enough stock"
  end
  if(g[buyer].storage_remaining != nil and g[buyer].storage_remaining < amount*trade_goods[good].bulk) then
    sfx(37)
    return false, "Not enough space"
  end
  if(g[buyer].wallet_balance < price/1000) then --k$
    sfx(37)
    return false, "Not enough money"
  end
  if buyer == 'player' then
    sfx(36)
    g[buyer].storage_remaining -= amount * trade_goods[good].bulk
    g[buyer].storage_used += amount * trade_goods[good].bulk
    g[buyer].business[good].avg_price = 
      (g[buyer].business[good].avg_price * g[trader].business[good].inventory + unit_price * amount) 
      / (g[buyer].business[good].inventory + amount)
  end
  if trader == 'player' then
    sfx(35)
    g[trader].storage_remaining += amount * trade_goods[good].bulk
    g[trader].storage_used -= amount * trade_goods[good].bulk
  end
  g[trader].business[good].inventory -= amount
  g[trader].wallet_balance += price/1000 --k$
  g[buyer].business[good].inventory += amount
  g[buyer].wallet_balance -= price/1000 --k$
  if buyer == 'player' then reevaluate_price(trader, good) end
  if trader == 'player' then reevaluate_price(buyer, good) end
  return true, ""
end

function advance_simulation(days)
  g.day_of_simulation += days
  for i=0,days do
    generate_events()
    for planet in all(planet_keys) do
      apply_events(planet)
      generate_news(planet)
      produce_and_consume_goods(planet)
      reevaluate_prices(planet)
    end
  end
end

function travel_cost(here, there)
  local cost = flr(travel_time(here, there))
  return cost
end

function can_travel(here, there)
  return travel_cost(here, there)/1000 < g.player.wallet_balance --k$
end

function travel_time(here, there)
  local travel_speed = 5
  return dist(planet_info[there].map_x, planet_info[there].map_y, planet_info[here].map_x, planet_info[here].map_y)/travel_speed
end

function travel(here, there)
  local cost = travel_cost(here, there)
  if cost/1000 < g.player.wallet_balance then --k$
    sfx(40)
    g.player.wallet_balance -= cost/1000
    g.warpspace.travel_time = travel_time(here, there) * 30
    advance_simulation(flr(travel_time(here,there)))
    g[g.current_planet_scene].picture.sprites = nil
    g.current_planet_scene="warpspace"
    g.destination_planet_scene= there
    g.trade_interface = purchase_interface(there)
    g.root_interface = root_interface(there)
    g.map_interface = map_interface(there)
    g.info_interface = info_interface(there)
  end
end

function generate_events()
  local new_event = possible_events[rndi(#possible_events)+1]
  local new_planet = planet_keys[rndi(#planet_keys)+1]
  local new_good = trade_good_keys[rndi(#trade_good_keys)+1]
  local new_duration = new_event.duration or rndi(20)
  add(g[new_planet].events, {
    applied = false,
    change= new_event.change,
    unchange= new_event.unchange,
    duration= new_duration,
    planet = new_planet,
    good = new_good,
    text= new_event.text(new_planet, new_good)
  })
end

function apply_events(planet)
  for event in all(g[planet].events) do
    if not event.applied then
      event.change(g[planet], event.good)
      event.applied = true
    end
    event.duration -= 1
    if event.duration <= 0 then
      if event.change_tax then
        g[planet].business.tax_rate -= event.change_tax
      end
      if event.unchange then
        event.unchange(g[planet],event.good)
      end
      del(g[planet].events,event)
    end
  end
end

function generate_news(planet)
  --TODO Make this range-specific or something, since this reports all news in the galaxy
  local slogans = {
    "just the facts ma'am",
    "for every space trader",
    "the inside scoop",
    "are we there yet?",
    "don't sue us if ur late",
    "best rag this side terra"
  }
  local news = "".."(dAY "..g.day_of_simulation..")"
  for planet in all(planet_keys) do
    for event in all(g[planet].events) do
      news = news.." "..event.text.."."
    end
  end
  news = news..".. lEAGUE iNSIDER-\""..slogans[rndi(#slogans)+1].."\""
  g.news_ticker.scroll_x = -127
  g.news_ticker.news = news
end

function produce_and_consume_goods(planet)
  --TODO have each planet headquarter companies that produce/consume different mixes of material
  --TODO increase the planets' stock based on its on-planet production facilities and demographic consumption
  --TODO figure out if planets should have wallets
  if g[planet].wallet_balance < 1000 then g[planet].wallet_balance += 1000 end 
  for good in all(trade_good_keys) do
    local net_production = g[planet].business[good].base_production - g[planet].business[good].base_consumption
    net_production += rndi(10)-5 --randomness in supply
    g[planet].business[good].net_production = net_production
    for event in all(events) do
      if event.target == planet then
        net_production += event.production[good] and event.production[good] or 0
        net_production -= event.consumption[good] and event.consumption[good] or 0
      end
    end
    g[planet].business[good].inventory += net_production
    g[planet].business[good].inventory = clamp(g[planet].business[good].inventory, 0, 127)
  end
end

function reevaluate_prices(planet)
  for trade_good in all(trade_good_keys) do
    reevaluate_price(planet, trade_good)
  end
end

function reevaluate_price(planet, trade_good)
  local in_stock = g[planet].business[trade_good].inventory
  local tax_rate = g[planet].business.tax_rate --margin the planet wants sales to you
  local desired_stock = g[planet].business[trade_good].desired_stock --quantity desired
  local base_price = g[planet].business[trade_good].base_price --price when satisifed
  local f0 = 4 --base_price multiplier when none in stock. TODO Make this planet specific.... need a 'ln' function.
  local base_price_multiplier = f0*2.71828^((in_stock/desired_stock)*neg_ln[f0])
  local today_buy = base_price * base_price_multiplier * (1-tax_rate/100)
  local today_sell = base_price * base_price_multiplier * (1+tax_rate/100)
  g[planet].business[trade_good].buy_price = today_buy
  g[planet].business[trade_good].sell_price = today_sell
end

function push_interface(interface)
  g[active_interface()].active = false
  add(g.active_interfaces, interface)
  g[active_interface()].active = true
end

function pop_interface()
  if #g.active_interfaces == 1 then return end --Don't pop off root interface
  g[active_interface()].active = false
  del(g.active_interfaces, g.active_interfaces[#g.active_interfaces])
  g[active_interface()].active = true
end

function active_interface()
  return g.active_interfaces[#g.active_interfaces]
end

function total_goods()
  local total = 0
  for good in all(trade_good_keys) do
    total += g.player.business[good].inventory
  end
  return total
end
