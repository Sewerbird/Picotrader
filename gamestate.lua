-- # GAME STATE & MUTATIONS

function create_game_state()
  return {
    day_of_simulation = 0,
    current_planet_scene = "warpspace",
    destination_planet_scene = "durruti",
    active_interface = "root_interface",
    player = {
      wallet_balance = 100,
      storage_remaining = 100,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = 0, avg_price = 0} end)
    },
    durruti = {
      ticker = 0,
      wallet_balance = 1000,
      tax_rate = 15,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = 0, buy_price = 0, sell_price = 0} end),
      production = { sundries = 2, doodads = 2, boomerangs = 5, meat = 0, salad = 3, steel = 15, cola = 5, chips = 5 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
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
          local r = u
          if r > 1 then
            r = 2 - u
          end
          return {spr= 0, x= flr((80-2)*r*cos(t)+(127)), y= flr((80-2)*r*sin(t)+(90)), c= 0, r= 1}
        end, 200)
      }
    },
    aragon = {
      ticker = 0,
      wallet_balance = 1000,
      tax_rate = 10,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = rndi(100), buy_price = 0, sell_price = 0} end),
      production = { sundries = 5, doodads = 2, boomerangs = 0, meat = 8, salad = 15, steel = 2, cola = 5, chips = 3 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
      picture = {
        label = "aragon",
        suns = {{x= 30, y= 30, r= 3, c= 10, c1= 8, c2= 9}},
      }
    },
    sutek = {
      ticker = 0,
      wallet_balance = 1000,
      tax_rate = 25,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = rndi(100), buy_price = 0, sell_price = 0} end),
      production = { sundries = 3, doodads = 3, boomerangs = 15, meat = 10, salad = 5, steel = 4, cola = 3, chips = 2 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
      picture = {
        label = "sutek",
        suns = {{x= 20, y= 76, r= 3, c= 7, c1= 8, c2= 12}},
      }
    },
    ["vera cruz"] = {
      ticker = 0,
      wallet_balance = 1000,
      tax_rate = 10,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = rndi(100), buy_price = 0, sell_price = 0} end),
      production = { sundries = 7, doodads = 8, boomerangs = 2, meat = 3, salad = 2, steel = 4, cola = 3, chips = 15 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
      picture = {
        label = "vera cruz",
      }
    },
    byzantium = {
      ticker = 0,
      wallet_balance = 1000,
      tax_rate = 20,
      inventory = mapo(trade_good_keys, function(key) return v, {amount = rndi(100), buy_price = 0, sell_price = 0} end),
      production = { sundries = 10, doodads = 15, boomerangs = 2, meat = 3, salad = 2, steel = 4, cola = 8, chips = 7 },
      consumption = { sundries = 5, doodads = 5, boomerangs = 5, meat = 5, salad = 5, steel = 5, cola = 5, chips = 5 },
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
      travel_time = 120, --ticks
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

function update_scene(scene)
  game_state[scene].ticker += 1
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
  for planet in all(planet_keys) do
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
  --printh("Calculating bpm of "..trade_good.." on '"..planet.."' = "..base_price.."*e^(("..in_stock.."/"..desired_stock..")*ln(1/"..f0.."))")
  local neg_ln_4 = -1.3862943611 --ln(1/f0), but Pico doesn't have ln
  local base_price_multiplier = f0*2.71828^((in_stock/desired_stock)*neg_ln_4)
  local today_buy = base_price * base_price_multiplier
  local today_sell = base_price * base_price_multiplier * (1+tax_rate/100)
  game_state[planet].inventory[trade_good].buy_price = today_buy
  game_state[planet].inventory[trade_good].sell_price = today_sell
end

