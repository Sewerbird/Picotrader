pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--trader of the fading suns
--by sewerbird

#include lib.lua
#include constants.lua
#include gamestate.lua
#include gfx.lua

-- # PICO CALLBACKS

function _init()
  g = create_game_state()
  advance_simulation(20)
end

function _draw()
  if(not g) then return end
  --Background
	rectfill(0,0,127,127,0)
  --Scene
  if(g.current_planet_scene == 'warpspace') then
    draw_warp_scene()
  else
    draw_planet_scene(g.current_planet_scene)
  end
  --Border
	rect(0,0,127,127,1)
end

function _update()
  --Update the scene
  update_scene(g.current_planet_scene)
  -- Navigating with Cursor
  local dir
  if active_interface() and not game_over then
    local current_splat = g[active_interface()].current_splat
    local tgt = g[active_interface()].splats[current_splat]

    --Pressed D-Pad: Navigate to directed splat
    if (btnp(0)) then dir = 'left' end
    if (btnp(1)) then dir = 'right' end
    if (btnp(2)) then dir = 'up' end
    if (btnp(3)) then dir = 'down' end
    if(tgt and tgt[dir]) then 
      sfx(39)
      g[active_interface()].current_splat = tgt[dir] 
    end
    --Pressed B: Perform the current splat if it has something to do
    if btnp(4) and current_splat then g[active_interface()].splats[current_splat].execute() end
    --Pressed A: Pop the view stack
    if (btnp(5)) then 
      sfx(38)
      pop_interface() 
    end
  end
end

__gfx__
00000000060066000000090000000000000bb0000000666600076500000a00000000444000000050000006660000000000000000000000000008000000000000
00000000600600d0000090000000000000b3330000066665005bbb50033b3330000400a00000c5500777006000000000000000000000000000050c0000080000
005005000600d0d0000900000000444000000330006666550015551003b33ba000500000000c5500070700660000000000000000000000000005050000050000
0005500000d0d0d0009000b0ff004444b00b333b0666655500111a1003b3b33005c5000000c55000777770750000000000000000000000000005050000050000
000550001111d0d009900bbbfff444480bb3333b777755560011a11003bb3ba0005c560000456000778770750000000000000000000000005555555555555550
005005001dd1111d009900b0004444880333b3300775556000111a1033b33b3006666690044660aa788870750000000000000000000000000333535333353300
000000001dd11d1d0009900066666666444b3434077556000011a110833b3b306888889044000088778770700000000000000000000000000555555555555550
000000001111111d00009900000666600444b4407777600000011100000a000006666690040088a8777770700000000000000000000000005533535353535330
00800000000666600006060000b50bb000bb00000000030000030333000000000000000000000000000000000000000000000000000000000555555555555555
0010800006677770060000060bb5dd54004400b03033053005333333000000000000000000000000000000000000000000000000000000000055535333335350
0010100060070677777606005d00b5150bd0bb400333351335053535000000000000000000000000000000000000000000000000000000000005555555551115
001110000006777060777660d00b050b04bd4b00035553305531133300000000000000000000000000000000000000000000000000000000000055511551ccc1
001d10000777766066607760405d5d55d04db4b0033333535513330300000000000000000000000000000000000000000000000000000000000055511551ccc1
001110007706677777767760b35b05b400bb40403311353330355303000000000000000000000000000000000000000000000000000000000000505115066666
001d100006677700667676005b3b10500044044d3551553333303033000000000000000000000000000000000000000000000000000000000000005555500500
00111000000670007000660004411000000004000003333000333030000000000000000000000000000000000000000000000000000000000000005555055500
001d1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000
00111000000000000000667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000
001d1001000000760777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000
001110010000076000660700009fff00000666000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000
001d11110006760000067660095555f00fff65500000000000000000000000000000000000000000000000000000000000000000000000000000000155000000
10111dd1006070000777776099555ff9fffff5550000000000000000000000000000000000000000000000000000000000000000000000000000000105000000
101d111106700000000007000999ff900fff55550000000000000000000000000000000000000000000000000000000000000000000000000000000105000000
11111111070000000060000000090099000f55000000000000000000000000000000000000000000000000000000000000000000000000000000000105000000
155555555555555555555551dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
155555555555555555555551dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
155555555555555555555551dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
155555555555555555555551dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
155555555555555555555551dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000118000000
155555555555555555555551dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000008100000000
155555555555555555555551dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000
11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
10000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000020000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000007001
10000000000000000000000000000700000000000000000000000000000000000000000000070000000000000000000000000000000000001000000000000001
10000000500000000000000000000000000000000000000000000000000000000000000700000007000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000500000000000000000000000000000000000000000000000000000000000000000000007777777000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000001000000000000000000000000770000000770000000000000000000000000000070001
10000000000000000000000000000000000000000000000000000000000000000000000000000000077007777777007700000000000000000000000000000001
10070000000000000000000000000000000000000000000000000000000000000000000000000000700770000000770070000500000000000000000000000001
10006000000000000000000000000000000000000000000000060700000000000000000000000007007000000000007007000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000070070000000000000700710000000000000000000000000001
10000000000000000000000000000000000000000000006000000000000000000000000000000070700000000000000070700000060000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000707000000000000000007070000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000707000000077700000007070000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000007070000007777777000000707000000000070000000000000001
10000000000000000006000000000700000000000000000000000000000000000000000000007070000007777777000000707000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000007070000077777777700100707000000000000000000000000001
10000000000000000000000000000000000000000001000000000000000000000000000000007070000077777777700000707000007000000000000000000001
100000000000000000000000006000000000000000050c0000010000000000000000000000007070000077777777700000707000000000000000007000000001
10000000000000000010000000000000000000000005050000050000000000000000000000007070000007777777000000707000000000000006000000000001
10000000000000000000000000000000000000000005050000050000000000000000000000007770000007777777000000707000000000000000000000000001
10000000000000000000000000000000000000005555555555555550000000200000000000000707000000077700000007070000000000000000000000000001
10000000000000000000000000000000000000000333535333353300000000000000000000000707000000000001000207070000000000000000000000000001
10000000000000000000000000000000000000000555555555555550000000000000000000000070700000000000000070700000000000000000000000050001
10000000000000000000000000060000000000005533535353535330000006000000000000000070070000000000000700700000000000000000000000000001
10000000000000000000000000000000000000000555555555555555000000000000000000000007007000000000007007000000000000000000000000000001
10000700000000000000000000000000000000000055535333335350000000000000000000000000700770000000770070000000000000000000000000000001
10000000000000700000000000000000000002000005555555551115000000000000000000000000077007777777007700000000000000000000000000000001
1000000000000000000700000000000000000000000055511551ccc1000000000000000000000000000770000000770000000000000000000000000000000001
1000000000000000070000006000000000000000000055511551ccc1000000000000000000000000000007777777000000000000000000000000000000000001
10000000000000000000000000000000000000000000505115066666000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000005555500500000000000000000006001007000000000005000000000000000000000000000000000001
10000000000000000000000000000000000000000000005555055500000000000000000000000000000000000000000000000000000000000000000000000001
10000005000000000000000000200000000000000000000555000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000070000000000000000000000000007000555000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000555000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000100555000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000155000000000070000000000000000000000000000000000000000000000000000000000700000001
10070000000000000000000000000000000000000000000105500000000000000000000070000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000105000000005000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000105500000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000060000000000000000000001
10000000000000000000000000000600000000000000000100000000000000000020000000000000000000000000000600000000000000000000000000000001
10000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000200000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000111070000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000020000000001100000000000000000000000000000000000000000000000000000000000070000000000000000001
10000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000b00000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000100000000000000000000000000000000000000000000700000000000000000000000000200000000000000000000000000000000001
10000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000100000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000001
10000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
17777777700000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
17777777777777770000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000070000001
17777777777777777777000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000001
17777777777777777777777700000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
17777777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000001
17777777777777777777777737333700000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000001001
16666677777766667777775333333777000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000001
16666666666677777777335753535777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
16666666666676677337535311333777777700000000000600000000000000000000000000000000070000000000000000000000000000000000000000000001
16666666777767773333513133373777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
16666666767777663555333355373777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
16666666677766777333353363733777766667777700000000000000000000000000000000000000000000010000000000000000000000000000000000000001
16666677776677733113533533637736677777777770000000100000000000000000000000000000000000000000000000000000000000000000000000000001
16666776667767635515533363665363373677777777707000000000700000000000000000000000000000000000000000000000000000000000000000000001
16666666777666665533333365335653567777777777770000000000000000600000000000000000000500000000000000000000000000000000000000000001
16666666677666667635533335135317777667777777777700000000500000000000000000000000000000000000000000000000000000000000000000000001
16666666676666676336335553355177666777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000001
16666666766666766633333333536676677766777777777777000000000000000000000000000000000000000000000000000000000000000000000000000001
16666666766666766666331135333373667666666777777777760000000000000000000000000000000000000000000000000000000000000000000000000021
16666676666676666666355155336367776667777777777777677000000000000000000000000000000000000700000000000000000000000000000000000001
16666766777766666666666333367777666667667777777676737700000000000000000000000000000000000000000000000000000000000000000000000001
16666666766776666666666666677666777666777666773733753770000000000000000000000000000000000000020000000000000000000000000000000001
16666666677766666666666666666677766777766666667333351377000000000000000000600000000000000000000000000000000000000000000000000001
16666677776666676666666666666667667766677766677355533777700000000000000000000000000000000000000000000000000000000000000000000001
16666776637776766666666666666666666667776666666333335377770000000000000005000000000000000000000000000000000000000000000000000001
16663633753667666666666666666666666676766666663311353377777000000000070000000000000000000000000500000000000000000000000000000001
16666333351667666666666666667666666766666666663551553377777700000000000000000000000000000000000000000000000000000000000000000001
16666355536766666666666666676666666666666666666663333777777770000002000000000000000006000000000000000000000000000000000100000001
16666333337366666666666666766666666666666666666666667777777777000000000000000000000000000000000000000000000060000000000000000001
16663311353366666666666666766666666666666666666666666777777777700000000000000100000000000000000000000000000000000000000000000001
16663551553366636666666676666666666666666666666666666677777777700000000005000000000000000000000000000000000000000000000000100001
16666663333633653666666763336666666666666666666666666667777777770000000000000000000000000000000000700000000000000000000000000001
16666666666333351366653333336666666666666666666666666666777777777000000000000000000000000000000000000000000000000000000000000001
16666666666355533536356535356666666666666666666666666666677777777700000000000000000000070000600000000000000000000000020000000501
16666666666333335313553113336666666666666666666666666666677777777700000000000000000000000000000005000000000000000000000000000001
16666666663311353336551333633366666666666666666666666666667777777770000000000000000000000000000000000000000000000000000000000001
16666666633551553353363533333366666666666666666666666666666773733376000000000000000000000000000000000000006005000000000000000001
16666665333333333533333535353566666666666666666666666666666533333767000000000000000000000000000000000000000000000000000000000001
16663635653535515533665531133366666666666666666666666666663535333677700000000000000000000000000000000000000000000000000000000001
16666355311333633336665513336366666666666666666666666666665333333377770000000000000000000000000000200000005000000000000000000001
16666355133363666666663635536366667666666666666666666666635553535377770000000000000000000000000000000000000000000000000000000001
16666333355363666666663336363366676666666666666666666666655311333377777000006000000000000000000000000000000000000000000000000001
16353335353333666666666633363666766666666663666666666666655133373377777000000000000000000000000000000000000000000000000000000001
16333335133336666666666666666666766666363365366666666666636355363677777700000000000000000000000200000000000000000000000000700001
16535553333666666666666676666676666666633335136666666666633363633777777700000000000000000000000000000000000000000000002000000001
16533333533633366666766766666766666666635553366666666666666333736777777777000000000000000000000000000000000000000000000000000001
16331135333333366667667666666666666666633333536666666666666666766677777770002000000000000000000000000000000000000000000000000001
16355155335353566676667663633366666666331135336666666666666676666666677777000000000000000000000000000000000000000000000000000001
16663333331137666676766533333366666666355155336666666666666766666777777777000000000000000000000000000000000000000000000000000001
16666355513376367667663565353566666666666333366666666666666666666766777777700000000000000000050000000000000000000000000000000001
16666333336766376666665531133366666666666666666666666666666666666677777777700000000000000000000000000000000000000000000000000001
16663313363763366666665513336366666666666666666666666666666666677776677777770000000000000000000000000000000000000000000000000001
13365666673363666666663635536366666666666666666666666666666666776667777777770000000000000000000000000000000000000000000000000001
13366777733666666666663336363366666666666666666666666666666666666777677777770000000020000000000000000000000000000000000000010001
15653766776666666666666633363666666363633366666666666666666666666676677777777000000000000000000000000000000000000000000000000001
13333677766666666666676666666637636533333366666666677776666666666666667777777000000000000000000000000000000000000000000000000001
11177766666766666666766666666676333515353566666363336677666666666666667777777000000000000000000000000000000000000000000000000001
15777666667666666667666666666763555531133366653333337776666666666666667777777700000000000000000000000000000000000000000000000001
16676677776666666667666666666763335513336366356535357666666666666666666777777707606000000000007000000000000000000000000000000001
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__sfx__
002000000e0221003211042110421105213052150521504213042130321103211032100321003211052100520e0520e0521004210032110321104211042100421104211042130521305213052150521806218052
001000001a0621a0521a0521a0521a0421a0421a0321a052180521804218042180421504215052150521503215032150321503215022150221502215022150221501215012150121501215012150121501215012
0010000015022150321a0621a0621a0521a0621506215052150521505215052150321a0621a052180521805215052150421503215032180621805218052180421704217042150421504213042130521305213052
00100000150321503215032150321605216052150621506213052130521304213042110421104211042110321005210062100521005210052100521105211052100521005210052100520e0520e0521005210052
001000001105211052110521105213062130621306213062150721507215072150721506215062160621606215042150421305213052150621507215062150521505215052150521505215052150521505215052
0010000013052130421104211042100421004210042100520e0520e0420e0420e0320c0520c0420c0520c0521005210052100521005210052100520c0620c0620e0620e0620e0620e0620e0520e0620e0620e062
001000000e0520e0420e0420e0321005210052100521005210052100520c0620c0620e0420e0420e0520e0520e0520e0520e0520e0520e0420e0320e0320e0320e0320e0220e0220e0220e0220e0220e0220e012
011000000e0520e0520e0520e0520e0520e0520e0520e05200000000000000000000000000000000000000000e0520e0520e0520e0520e0520e0520e0520e0520000000000000000000000000000000000000000
011000000e0520e0520e0520e0520e0520e0520e0520e05209052090520905209052090520905209052090520a0520a0520a0520a0520a0520a0520a0520a0520905209052090520905209052090520905209052
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000201d6301c6301f640146401a65017650176601566018650116501a65015650146501b6501d6401a640156401a6401a6401564015640156501965015650146501c650156501665017640176402463017630
000400002d620356503c4703d4703e6703c6701f470356602d6502a6700c44020670196301667005420116700b6200e6500a65009640086400664006630056300563005630056100462003620026100161001600
001000002a6703b4702a660216602e4502265017630116300f6201541008610056100261001610006100061000000056000460002600026000260002600026001800000000026000160018000244000260002600
000400001b0501e050002001120011200112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c05017050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000b45000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001212000102001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000553000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002d4400f05025450150501f460190701b4701f06015460220601165025050126502804009440280401263024030136301e030156301803018620120301a6300e0401d6501e6501f650216502165023650
00040000000000000000000134500000000000000000e05000000000000000008050000000000000000000000000000000100500000000000000000000000000000001e0501f0500000021050000000000000000
000800000b000000000a0000a000000000a0100061000010000100061000620006200062001620016200630006300063000630006300053000430004300033000330000000000000000000000000000000000000
000400001722000000000000000009220000000000000000000000000000000000000000000000000000000000000002100000000000000000000000000000000000000000000000000000000000000000000000
010400001d0551d0551d0551d055000001905500000000001d0551d0551d0551d055000000000019055000001d0551d0551d0551d055000001905500000000002b0550000000000000002b055000000000000000
000400000061000620016100161001610016100061000620006100161003610036200462004630046200362002610026100161001610026100262002620026200162000620006100061001610036100461000010
__music__
00 08404344
00 08424344
00 08424344
00 08424344
00 00424344
00 01424344
00 02424344
00 03424344
00 04424344
00 05424344
04 06424344
00 40424344

