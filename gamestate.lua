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

function create_game_state()
  return {
    day_of_simulation = 0,
    current_planet_scene = "warpspace",
    destination_planet_scene = "durruti",
    active_interface = "popup_dialog",
    active_interfaces = {},
    player = {
      storage_remaining = 100,
      wallet_balance = 100,
      business = init_business(0,50,0,0),
      events = {},
      picture = {}
    },
    durruti = {
      ticker = 0,
      wallet_balance = 1000,
      business = init_business(15, 50,0,0),
      events = {},
      picture = {
        label = "durruti",
        suns = {{x= 80, y= 14, r= 3, c= 10, c1= 7, c2= 15}},
        planets = {
          {x= 127, y= 90, r= 80, c = 15}, --sunlit horizon
          {x= 130, y= 95, r= 80, c = 4} --shadowed planet
        },
        sprites = times(function()
          local t = rnd()
          local u = rnd() + rnd()
          if u > 1 then u = 2 - u end
          return {spr= 0, x= flr((80-2)*u*cos(t)+(127)), y= flr((80-2)*u*sin(t)+(90)), c= 0, r= 1}
        end, 200)
      }
    },
    aragon = {
      ticker = 0,
      wallet_balance = 1000,
      business = init_business(10,50,0,0),
      events = {},
      picture = {
        label = "aragon",
        suns = {{x= 30, y= 30, r= 3, c= 10, c1= 8, c2= 9}},
      }
    },
    sutek = {
      ticker = 0,
      wallet_balance = 1000,
      business = init_business(25,50,0,0),
      events = {},
      picture = {
        label = "sutek",
        suns = {{x= 20, y= 76, r= 3, c= 7, c1= 8, c2= 12}},
      }
    },
    ["vera cruz"] = {
      ticker = 0,
      wallet_balance = 1000,
      business = init_business(10,50,0,0),
      events = {},
      picture = {
        label = "vera cruz",
      }
    },
    byzantium = {
      ticker = 0,
      wallet_balance = 1000,
      business = init_business(20,50,0,0),
      events = {},
      picture = {
        label = "byzantium",
        suns = {{x= 64, y= 64, r= 6, c= 7, c1= 7, c2= 7}},
        planets = {
          {x= 64, y= 145, r= 80, c = 6}, --sunlit horizon
          {x= 64, y= 160, r= 80, c = 5} --shadowed planet
        },
      }
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
    trade_interface = purchase_interface("durruti"),
    root_interface = root_interface("durruti"),
    map_interface = map_interface("durruti"),
    info_interface = info_interface("durruti"),
    ship_interface = ship_interface("durruti"),
    popup_dialog = popup_dialog("yesno","Inspection","you are being boarded by customs for inspection and tax collection.","root_interface"),
    news_ticker = {
      scroll_x = -127,
      news = "Welcome aboard, trader: the world is at your fingertips"
    }
  }
end

function update_scene(scene)
  game_state[scene].ticker += 1
  --Update the news ticker
  game_state.news_ticker.scroll_x += 1
  if(game_state.news_ticker.scroll_x > 4 * #game_state.news_ticker.news) then game_state.news_ticker.scroll_x = -127 end
  --Update warpspace if animating
  if scene == 'warpspace' then
    if game_state.warpspace.ticker > game_state.warpspace.travel_time then
      game_state.current_planet_scene = game_state.destination_planet_scene
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
  add(game_state.active_interfaces, interface)
end

function pop_interface()
  del(game_state.active_interfaces, game_state.active_interfaces[#game_state.active_interfaces])
end

function active_interface()
  return game_state.active_interfaces[#game_state.active_interfaces]
end
