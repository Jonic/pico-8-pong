pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- another pong clone
-- by jonic

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
-- ball

local ball = {}
ball.__index = ball

function ball.new()
  local self = setmetatable({}, ball)

  self.angle  = 0
  self.size   = 4
  self.v_init = 2
  self.v_max  = 8
  self.v_step = 1.0005

  self:reset()

  return self
end

function ball.reset(self)
  self.v = self.v_init
  self.x = 60
  self.y = 60

  self:init_angle()
end

function ball.init_angle(self)
  r = rnd(1)

  if r < .25 then
    a = .075 + rnd(.025)
  elseif r < .5 then
    a = .425 - rnd(.025)
  elseif r < .75 then
    a = .575 + rnd(.025)
  else
    a = .925 - rnd(.025)
  end

  self.angle = a
end

function ball.collide_with_paddle(self, player)
  collision = false

  if ((self.x > (player.x + player.w)) or
    (player.x > (self.x + self.size)) or
    (self.y > (player.y + player.h)) or
    (player.y > (self.y + self.size))
  ) then
    collision = true
  end

  if (collision) then
    self.angle = -self.angle
    self:increase_speed()
  end
end

function ball.increase_speed(self)
  self.v *= self.v_step
  if (self.v > self.v_max) self.v = self.v_max
end

function ball.collide_with_wall(self)
  if (self.y >= 0 and self.y <= (128 - self.size)) return
  self.angle = 0.5 - self.angle
end

function ball.isstillinplayingfield(self)
  return self.x >= -10 and self.x <= 138
end

function ball.check_scoring_player(self)
  if (self.x < -10) then
    player2:score()
  else
    player1:score()
  end

  self:reset()
end

-- ball lifecycle

function ball.update(self)
  self:collide_with_wall()
  self:collide_with_paddle(player1)
  self:collide_with_paddle(player2)

  self.x = self.x + sin(self.angle) * self.v
  self.y = self.y + cos(self.angle) * self.v

  if (not self:isstillinplayingfield()) then
    self:check_scoring_player()
  end
end

function ball.draw(self)
  rectfill(self.x, self.y, self.x + self.size, self.y + self.size, 7)
end

-->8
-- paddle

local paddle = {}
paddle.__index = paddle

function paddle.new(player)
  local self = setmetatable({}, paddle)

  self.x = 0
  self.y = 48
  self.w = 4
  self.h = 24
  self.v = 4
  self.player = player
  self.points = 0

  if (self.player == 1) then
    self.x = 128 - self.w
  end

  return self
end

function paddle.constrain_position(self)
  if (self.y < 0) self.y = 0
  if (self.y > 128 - self.h) self.y = 128 - self.h
end

function paddle.update(self)
  if (btn(2, self.player - 1)) self.y -= self.v
  if (btn(3, self.player - 1)) self.y += self.v
  self:constrain_position()
end

function paddle.draw(self)
  rectfill(self.x, self.y, self.x + self.w, self.y + self.h, 7)
  print(self.points, 16 * self.player, 4)
end

function paddle.score(self)
  self.points += 1
end

-->8
-- game loop

function _init()
  ball    = ball.new()
  player1 = paddle.new(1)
  player2 = paddle.new(2)
end

function _update()
  ball:update()
  player1:update()
  player2:update()
end

function _draw()
  rectfill(0, 0, 127, 127, 1)

  ball:draw()
  player1:draw()
  player2:draw()
end

__gfx__
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
