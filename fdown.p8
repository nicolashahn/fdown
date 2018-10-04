pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

cart_name="fdown"

--width of player sprite
p_width=6

--width of screen
s_width=128

--how fast player moves right/left
move_spd=2
--how fast player falls
fall_spd=2

function _init()

  --top left corner of player sprite
  p_x=s_width/2
  p_y=s_width/2-p_width-1

  --how fast platforms rise
  plat_spd=0.5
  --for keeping track of when to generate new platforms
  plat_frame_ctr=0
  plat_frame_max=120

  platforms={
    {x=30,y=s_width,w=70,h=6}
  }

end

--returns platform's y coord if player has hit a platform else false
function collision()
  for platform in all(platforms) do
    --rightmost part of the platform
    plat_r=platform.x+platform.w
    --rightmost part of the player
    p_r=p_x+p_width
    if p_r>platform.x and p_x<platform.x+platform.w then
      if p_y+p_width>platform.y and p_y<platform.y then
        --the y value for the player to stay on the platform
        return platform.y-p_width
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
  if btn(1) and p_x<s_width-p_width-move_spd then
    p_x+=move_spd
  end
  --if there's a collision, don't let player fall
  new_y = collision()
  if new_y then
    p_y = new_y
  else
    p_y+=fall_spd
    p_y=min(p_y,s_width-p_width-1)
  end
end

function add_platform()
  add(platforms,{x=30,y=s_width,w=70,h=6})
end

function update_platforms()
  plat_frame_ctr+=1
  if plat_frame_ctr==plat_frame_max then
    plat_frame_ctr=0
    add_platform()
  end
  for p in all(platforms) do
    if p.y+p.h<0 then
      del(platforms,p)
    end
    p.y-=plat_spd
  end
end

function _update60()
  update_platforms()
  update_player()
end

function draw_player()
  rectfill(p_x,p_y,p_x+p_width,p_y+p_width,8)
end

function draw_platforms()
  for p in all(platforms) do
    rectfill(p.x,p.y,p.x+p.w,p.y+p.h,9)
  end
end

function _draw()
  cls()
  draw_platforms()
  draw_player()
end
