-- # GAME STATE & MUTATIONS

function init_business(tax_rate, inventory, base_production, base_consumption)
  trade_good_keys = {"sundries", "boomerangs", "meat", "salad", "steel", "cola", "chips", "doodads"}
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

function make_planet(name,x,y,lanes,owner)
  planet_info[name]={
    name=name, map_x = x, map_y = y, map_r = 2,map_c=12,
    up=lanes.up,left=lanes.left,down=lanes.down,right=lanes.right,
    owner=owner,
    type= planet_type_keys[rndi(#planet_type_keys)+1]
  }
end

function create_game_state()
  make_planet("leminkainan",56,8,{left="ravenna",right="pentateuch"},"locals")
  make_planet("bannock",32,16,{down="stigmata",right="ravenna"},"local")
  make_planet("pentateuch",80,16,{left="leminkainan",down="delphi",right="terra"},"empire")
  make_planet("artemis",112,16,{left="terra"},"locals")
  make_planet("ravenna",48,24,{left="bannock",up="leminkainan",down="shaprut"},"locals")
  make_planet("terra",96,24,{left="pentateuch",right="artemis",down="sutek"},"the church")
  make_planet("stigmata",24,32,{up="bannock",right="istakhr",down="aylon"},"empire")
  make_planet("shaprut",45,36,{up="ravenna",right="delphi",down="istakhr"},"local")
  make_planet("delphi",64,32,{up="pentateuch",left="shaprut",right="tethys"},"hawkwood")
  make_planet("sutek",102,40,{up="terra",left="tethys",down="vera cruz"},"empire")
  make_planet("istakhr",40,48,{up="shaprut",left="stigmata",down="criticorum"},"al malik")
  make_planet("tethys",80,48,{left="delphi",right="sutek",down="byzantium"},"local")
  make_planet("aylon",16,56,{up="stigmata",right="criticorum",down="cadavus"},"empire")
  make_planet("criticorum",40,64,{up="istakhr",left="aylon",right="byzantium",down="kish"},"local")
  make_planet("byzantium",64,64,{left="criticorum",right="aragon",down="madoc"},"empire")
  make_planet("vera cruz",112,64,{up="sutek",left="aragon"},"local")
  make_planet("cadavus",24,72,{up="aylon",down="severus",right="malignatius"},"empire")
  make_planet("aragon",88,72,{left="byzantium",right="vera cruz",down="leagueheim"},"hazat")
  make_planet("de moley",8,80,{right="severus"},"empire")
  make_planet("kish",48,80,{up="criticorum",left="malignatius",right="madoc",down="icon"},"li halan")
  make_planet("madoc",64,80,{left="kish",up="byzantium",right="leagueheim"},"local")
  make_planet("malignatius",32,88,{left="cadavus",right="kish",down="cadiz"},"empire")
  make_planet("severus",16,96,{left="de moley",right="cadiz",up="cadavus"},"decados")
  make_planet("leagueheim",80,96,{left="madoc",right="grail",up="aragon",down="rampart"},"the league")
  make_planet("grail",112,96,{left="leagueheim"},"local")
  make_planet("cadiz",32,104,{left="severus",right="icon",up="malignatius",down="vril ya"},"local")
  make_planet("icon",48,104,{left="cadiz",right="midian",up="kish",down="manitou"},"empire")
  make_planet("midian",64,104,{left="icon",right="rampart",down="apshai"},"local")
  make_planet("vril ya",16,112,{right="vau",up="cadiz"},"vril ya")
  make_planet("rampart",80,112,{left="midian",up="leagueheim",right="pandemonium",down="apshai"},"local")
  make_planet("vau",24,120,{left="vril ya",right="manitou"},"vril_ya")
  make_planet("manitou",40,120,{left="vau",right="apshai",up="icon"},"empire")
  make_planet("apshai",56,120,{left="manitou",up="midian",right="rampart"},"local")
  make_planet("pandemonium",112,120,{left="rampart"},"local")
  for k,v in pairs(planet_info) do
    add(planet_keys, k)
  end

  local result = {
    day_of_simulation = 0,
    current_planet_scene = "delphi",
    destination_planet_scene = "delphi",
    active_interfaces = {"root_interface","popup_dialog"},
    player = {
      storage_remaining = 100,
      wallet_balance = 100,
      business = init_business(0,50,0,0),
      events = {},
      picture = {}
    },
    warpspace = {
      ticker = 0,
      travel_time = 300, --ticks
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
    popup_dialog = popup_dialog("ok","sPACE tRADER","tRAVEL THE GALAXY MAKING A PROFIT! rETIRE BY AMASSING $100000. gOOD lUCK!","root_interface",{}),
    news_ticker = {
      scroll_x = -127,
      news = "Welcome aboard, trader: the world is at your fingertips"
    }
  }
  for k in all(planet_keys) do
    if not result[k] then
      local planet_type = planet_types[planet_info[k].type]
      printh(k.." is "..planet_info[k].type)
      local s_x = 64+(rndi(16)+16)
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
      result[k] = {
        ticker = 0,
        wallet_balance = 1000,
        business = init_business(20,50,0,0),
        events = {},
        picture = {
          label = k,
          star_port = {spridx=14, x=-(s_x-64)+64, y=s_y},
          suns = {{x= s_x, y= s_y, r= s_r, c= 7, c1= 7, c2= 7}},
          planets = {
            {x= p_x, y= p_y, r= p_r, c = p_c1}, --sunlit horizon
            {x= ps_x, y= ps_y, r= p_r-3, c = p_c2} --shadowed planet
          },
          blink_sprite = function(sprite)
            if sprite.blink_light and mod(flr(game_state[game_state.current_planet_scene].ticker-sprite.offset), 40) < 20 then
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
  --Pause scene if popup dialog occuring
  if game_state.popup_dialog.active then
    return
  end
  game_state[scene].ticker += 1
  --Update the news ticker
  game_state.news_ticker.scroll_x += 1
  if(game_state.news_ticker.scroll_x > 4 * #game_state.news_ticker.news) then game_state.news_ticker.scroll_x = -127 end
  --Update warpspace if animating
  if scene == 'warpspace' then
    if game_state.warpspace.ticker > game_state.warpspace.travel_time then
      game_state.current_planet_scene = game_state.destination_planet_scene
      game_state[game_state.current_planet_scene].picture.sprites = game_state[game_state.current_planet_scene].picture.sprite_method()
      game_state[game_state.current_planet_scene].ticker = 0
      game_state.warpspace.ticker = 0
    end
  end
end

function buy_from_trader(trader, buyer, good, amount)
  local unit_price
  if(trader == 'player') then 
    unit_price = game_state[buyer].business[good].buy_price
  else 
    unit_price = game_state[trader].business[good].sell_price 
  end
  local price = unit_price * amount
  if(game_state[trader].business[good].inventory < amount) then
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
    game_state[buyer].business[good].avg_price = 
      (game_state[buyer].business[good].avg_price * game_state[trader].business[good].inventory + unit_price * amount) 
      / (game_state[buyer].business[good].inventory + amount)
  end
  if trader == 'player' then
    game_state[trader].storage_remaining += amount
  end
  game_state[trader].business[good].inventory -= amount
  game_state[trader].wallet_balance += price
  game_state[buyer].business[good].inventory += amount
  game_state[buyer].wallet_balance -= price
  -- # Planet specific bookkeeping
  if buyer == 'player' then reevaluate_price(trader, good) end
  if trader == 'player' then reevaluate_price(buyer, good) end
  return true, ""
end

function advance_simulation()
  game_state.day_of_simulation += 1
  generate_events()
  for planet in all(planet_keys) do
    apply_events(planet)
    generate_news(planet)
    produce_and_consume_goods(planet)
    reevaluate_prices(planet)
  end
end

function generate_events()
  --TODO move this out to a global?
  local possible_events = {
    {
      change= function(planet,good) planet.business[good].inventory = 127 end,
      text= function(planet,good) return "A surplus of "..good.." on "..planet.." causes exports to rise: investors worry about a glut lowering prices" end},
    {
      change= function(planet,good) planet.business[good].inventory = 0 end,
      text= function(planet,good) return "A shortage of "..good.." causes sticker shock on "..planet.." and anger for consumers" end},
    {
      change= function(planet,good) planet.business.tax_rate += 25 end,
      unchange= function(planet,good) planet.business.tax_rate -= 25 end, 
      text= function(planet,good) return "The Imperial embargo over "..planet.." continues to inflate the tax rate there for all goods" end},
    {
      change= function(planet,good) planet.business[good].base_production += 5 end,
      unchange= function(planet,good) planet.business[good].base_production -= 5 end, 
      text= function(planet,good) return "Economic forecasts for "..good.." on "..planet.." signal increased production" end},
    {
      change= function(planet,good) planet.business[good].base_production -= 5 end,
      unchange= function(planet,good) planet.business[good].base_production += 5 end, 
      text= function(planet,good) return "Layoffs at facilities producing "..good.." on "..planet.." presage decreased production" end},
  }
  local new_event = possible_events[rndi(#possible_events)+1]
  local new_planet = planet_keys[rndi(#planet_keys)+1]
  local new_good = trade_good_keys[rndi(#trade_good_keys)+1]
  local new_duration = rndi(8)
  add(game_state[new_planet].events, {
    applied = false,
    change= new_event.change,
    duration= new_duration,
    planet = new_planet,
    good = new_good,
    text= new_event.text(new_planet, new_good)
  })
end

function apply_events(planet)
  for event in all(game_state[planet].events) do
    if not event.applied then
      event.change(game_state[planet], event.good)
      event.applied = true
    end
    event.duration -= 1
    if event.duration <= 0 then
      if event.change_tax then
        game_state[planet].business.tax_rate -= event.change_tax
      end
      if event.unchange then
        event.unchange(game_state[planet])
      end
      del(game_state[planet].events,event)
    end
  end
end

function generate_news(planet)
  --TODO Make this range-specific or something, since this reports all news in the galaxy
  local news = ""
  for planet in all(planet_keys) do
    for event in all(game_state[planet].events) do
      news = news.." "..event.text
    end
  end
  game_state.news_ticker.news = news
end

function produce_and_consume_goods(planet)
  --TODO have each planet headquarter companies that produce/consume different mixes of material
  --TODO increase the planets' stock based on its on-planet production facilities and demographic consumption
  --TODO figure out if planets should have wallets
  if game_state[planet].wallet_balance < 1000 then game_state[planet].wallet_balance += 1000 end 
  for good in all(trade_good_keys) do
    local net_production = game_state[planet].business[good].base_production - game_state[planet].business[good].base_consumption
    game_state[planet].business[good].net_production = net_production
    for event in all(events) do
      if event.target == planet then
        net_production += event.production[good] and event.production[good] or 0
        net_production -= event.consumption[good] and event.consumption[good] or 0
      end
    end
    game_state[planet].business[good].inventory += net_production
    game_state[planet].business[good].inventory = clamp(game_state[planet].business[good].inventory, 0, 127)
  end
end

function reevaluate_prices(planet)
  for trade_good in all(trade_good_keys) do
    reevaluate_price(planet, trade_good)
  end
end

function reevaluate_price(planet, trade_good)
  local in_stock = game_state[planet].business[trade_good].inventory
  local tax_rate = game_state[planet].business.tax_rate --margin the planet wants sales to you
  local desired_stock = game_state[planet].business[trade_good].desired_stock --quantity desired
  local base_price = game_state[planet].business[trade_good].base_price --price when satisifed
  local f0 = 4 --base_price multiplier when none in stock. TODO Make this planet specific.... need a 'ln' function.
  --printh("Calculating bpm of "..trade_good.." on '"..planet.."' = "..base_price.."*e^(("..in_stock.."/"..desired_stock..")*ln(1/"..f0.."))")
  local neg_ln_4 = -1.3862943611 --ln(1/f0), but Pico doesn't have ln
  local base_price_multiplier = f0*2.71828^((in_stock/desired_stock)*neg_ln_4)
  local today_buy = base_price * base_price_multiplier
  local today_sell = base_price * base_price_multiplier * (1+tax_rate/100)
  game_state[planet].business[trade_good].buy_price = today_buy
  game_state[planet].business[trade_good].sell_price = today_sell
end

function push_interface(interface)
  game_state[active_interface()].active = false
  add(game_state.active_interfaces, interface)
  game_state[active_interface()].active = true
end

function pop_interface()
  if #game_state.active_interfaces == 1 then return end --Don't pop off root interface
  game_state[active_interface()].active = false
  del(game_state.active_interfaces, game_state.active_interfaces[#game_state.active_interfaces])
  game_state[active_interface()].active = true
end

function active_interface()
  return game_state.active_interfaces[#game_state.active_interfaces]
end
