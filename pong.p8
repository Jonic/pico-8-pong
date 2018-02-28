pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- another pong clone
-- by jonic
-- v0.1.0

--[[
  https://www.lexaloffle.com/bbs/?tid=30836

  this was the smallest thing
  i could make to get something
  finished.

  it's unoriginal, unfinished,
  and uninspiring.

  you might think the code is
  useful, i don't know! it's on
  github here:

  https://github.com/jonic/pico-8-pong
]]

-->8
-- helpers
function detect_collision(r0, r1)
  return r0.x < r1.x + r1.w and
         r0.x + r0.w > r1.x and
         r0.y < r1.y + r1.h and
         r0.h + r0.y > r1.y
end

function rndangle()
  diff = rnd(.025)
  r    = rnd(1)

  if     r < .25 then a = .075 + diff
  elseif r < .5  then a = .425 - diff
  elseif r < .75 then a = .575 + diff
  else                a = .925 - diff
  end

  return a
end

-->8
-- ball

function ball()
  return {
    -- props

    angle  = 0,
    h      = 4,
    size   = 4,
    v_init = 2,
    v_max  = 16,
    v_step = 1.05,
    w      = 4,

    -- methods

    check_scoring_player = function(b)
      player = (b.x < -10) and player2 or player1
      player:increment_score()
      b:_init()
    end,

    collide_with_paddle = function(b, player)
      if (detect_collision(b, player)) then
        sfx(0)
        b.angle = -b.angle
        b:increase_speed()
      end
    end,

    collide_with_wall = function(b)
      if (b.y >= 0 and b.y <= (128 - b.size)) return
      b.angle = 0.5 - b.angle
    end,

    increase_speed = function(b)
      b.v *= b.v_step
      if (b.v > b.v_max) b.v = b.v_max
    end,

    is_still_in_playing_field = function(b)
      return b.x >= -10 and b.x <= 138
    end,

    -- lifecycle

    _init = function(b)
      b.angle = rndangle()
      b.v     = b.v_init
      b.x     = 60
      b.y     = 60
    end,

    _update = function(b)
      b:collide_with_wall()
      b:collide_with_paddle(player1)
      b:collide_with_paddle(player2)

      b.x = b.x + sin(b.angle) * b.v
      b.y = b.y + cos(b.angle) * b.v

      if (not b:is_still_in_playing_field()) then
        b:check_scoring_player()
      end
    end,

    _draw = function(b)
      rectfill(b.x, b.y, b.x + b.size, b.y + b.size, 7)
    end
  }
end

-->8
-- paddle

function paddle(player)
  return {
    -- props

    h      = 24,
    player = player,
    points = 0,
    v      = 4,
    w      = 4,
    x      = player == 1 and 128 - 8 or 4,
    y      = 48,

    -- methods

    constrain_position = function(p)
      if (p.y < 0) p.y = 0
      if (p.y > 128 - p.h) p.y = 128 - p.h
    end,

    increment_score = function(p)
      sfx(1)
      p.points += 1
    end,

    -- lifecycle

    _update = function(p)
      if (btn(2, p.player - 1)) p.y -= p.v
      if (btn(3, p.player - 1)) p.y += p.v
      p:constrain_position()
    end,

    _draw = function(p)
      rectfill(p.x, p.y, p.x + p.w, p.y + p.h, 7)
      print(p.points, 16 * p.player, 4)
    end,
  }
end

-->8
-- game loop

function _init()
  ball    = ball()
  player1 = paddle(1)
  player2 = paddle(2)

  ball:_init()
end

function _update()
  ball:_update()
  player1:_update()
  player2:_update()
end

function _draw()
  rectfill(0, 0, 127, 127, 1)

  ball:_draw()
  player1:_draw()
  player2:_draw()
end

__sfx__
000100000f00039000350503400034000330003200031000310003100031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000000000b100101001410016100170501705000000170500000000000170501200012000000001805000000000001a05000000150001e050190002205000000000002605000000000002b0500000030050
