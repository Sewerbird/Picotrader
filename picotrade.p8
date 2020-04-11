pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

#include constants.lua
#include lib.lua
#include gfx.lua
#include gamestate.lua

-- # PICO CALLBACKS

function _init()
  game_state = create_game_state()
  advance_simulation()
end

function _draw()
  if(not game_state) then return end
  --Background
	rectfill(0,0,127,127,0)
  --Scene
  if(game_state.current_planet_scene == 'warpspace') then
    draw_warp_scene()
  else
    draw_planet_scene(game_state.current_planet_scene)
  end
  --Border
	rect(0,0,127,127,1)
  if game_state.popup_dialog.active then game_state.popup_dialog:draw() end
end

function _update()
  --Update the scene
  update_scene(game_state.current_planet_scene)
  -- Navigating with Cursor
  local dir
  local current_splat = game_state[game_state.active_interface].current_splat
  local tgt = game_state[game_state.active_interface].splats[current_splat]

  --Pressed D-Pad: Navigate to directed splat
  if (btnp(0)) then dir = 'left' end
  if (btnp(1)) then dir = 'right' end
  if (btnp(2)) then dir = 'up' end
  if (btnp(3)) then dir = 'down' end
  if(tgt and tgt[dir]) then game_state[game_state.active_interface].current_splat = tgt[dir] end
  --Pressed B: Perform the current splat if it has something to do
  if btnp(4) and current_splat then game_state[game_state.active_interface].splats[current_splat].execute() end
  --Pressed A: Pop the view stack
  if (btnp(5)) then game_state.active_interface = 'root_interface' end
end

__gfx__
00000000000006c00000090000000000000bb0000000666600076500000a00000000444000000000000000000000000000000000000000000000000000000000
000000000006c060000090000000000000b333000006666500566650033b3330000400a000000000000000000000000000000000000000000000000000000000
0050050006c06060000900000000444000000330006666550015661003b33ba00050000000000000000000000000000000000000000000000000000000000000
0005500000606060009000b0ff004444b00b333b066665550011118003b3b33005c5000000000000000000000000000000000000000000000000000000000000
000550005555606009900bbbfff444480bb3333b777755560081188003bb3ba0005c560000000000000000000000000000000000000000000000000000000000
005005005aa55556009900b0004444880333b330077555600018881033b33b300666669000000000000000000000000000000000000000000000000000000000
000000005aa55a560009900066666666444b34340775560000111110833b3b306888889000000000000000000000000000000000000000000000000000000000
000000005555555600009900000666600444b4407777600000011100000a00000666669000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000020000300a6400f64011650106500f6300f6302302015630036200c1200f1200c3300c3300e3500f370191701d1701b060166701b050100401603027030047300b73013760157501775018750
__music__
00 40424344

