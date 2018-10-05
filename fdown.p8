pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

cart_name="fdown"

--width of player sprite
p_w=6

--width of screen
screen_w=128

--how fast player moves right/left
move_spd=2
--how fast player falls
fall_spd=2

--how often to increase level
level_frames=512

function _init()

  mode="title"
  score=0
  frame_ct=0
  level=1

  --top left corner of player sprite
  p_x=screen_w/2
  p_y=screen_w/2-p_w-1

  --for keeping track of when to generate new platforms
  plat_frame_ctr=0

  --gap between platforms on a level
  gap_w=30

  platforms={}
  add_floor()
end

function plat_spd()
  return 0.5+((level-1)*0.125)
end

function plat_frame_max()
  return flr(screen_w/(level*0.75))
end

--returns platform's y coord if player has hit a platform else false
function collision()
  for platform in all(platforms) do
    --rightmost part of the platform
    plat_r=platform.x+platform.w
    --rightmost part of the player
    p_r=p_x+p_w
    if p_r>platform.x and p_x<platform.x+platform.w then
      if p_y+p_w>platform.y and p_y<platform.y then
        --the y value for the player to stay on the platform
        return platform.y-p_w
      end
    end
  end
  return false
end

function update_player()
  --handle left/right input
  if btn(0) and p_x>0 then
    p_x-=move_spd
  end
  if btn(1) and p_x<screen_w-p_w-move_spd then
    p_x+=move_spd
  end
  --if there's a collision, don't let player fall
  new_y = collision()
  if new_y then
    p_y = new_y
  else
    p_y+=fall_spd
    p_y=min(p_y,screen_w-p_w-1)
  end
end

function add_platform(x,plat_w)
  plat={x=x,y=screen_w,w=plat_w,h=6}
  add(platforms,plat)
end

function add_floor()
  plat_w=screen_w-gap_w
  gap_x=flr(rnd(screen_w-gap_w))
  add_platform(gap_x-plat_w,plat_w)
  add_platform(gap_x+gap_w,plat_w)
end

function update_platforms()
  plat_frame_ctr+=1
  if plat_frame_ctr%plat_frame_max()==0 then
    plat_frame_ctr=0
    add_floor()
  end
  floor_del=false
  for p in all(platforms) do
    if p.y+p.h<0 then
      del(platforms,p)
      floor_del=true
    end
    p.y-=0.5+plat_spd()
  end
  if floor_del then
    score += 1
  end
end

function check_level_up()
  if frame_ct%level_frames==0 then
    level+=1
  end
end

function check_gameover()
  if p_y<0-p_w+1 then
    mode="gameover"
  end
end

function _update60()
  if mode=="title" then
    for x=0,6 do
      if btn(x) then
          mode="play"
      end
    end
  end
  if mode=="play" then
    frame_ct+=1
    update_platforms()
    update_player()
    check_level_up()
    check_gameover()
  end
  if mode=="gameover" then
  end
end

function draw_player()
  rectfill(p_x,p_y,p_x+p_w,p_y+p_w,8)
end

function draw_platforms()
  for p in all(platforms) do
    rectfill(p.x,p.y,p.x+p.w,p.y+p.h,9)
  end
end

function draw_score()
  print(score,2,2,7)
end

function draw_title()
  cls()
  print("fdown", 54,60,7)
  print("press any button to start", 14,72,7)
end

function _draw()
  if (mode=="title") then
    draw_title()
  end
  if mode=="play" then
    cls()
    draw_platforms()
    draw_player()
    draw_score()
  end
  if (mode=="gameover") then
    print("game over",48,61,7)
  end
end
