local splashlib = {
  _VERSION     = "v1.0.2",
  _DESCRIPTION = "a 0.10.1 splash",
  _URL         = "https://github.com/love2d-community/splashes",
  _LICENSE     = [[Copyright (c) 2016 love-community members (as per git commits in repository above)

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgement in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

The font used in this splash is "Handy Andy" by www.andrzejgdula.com]]
}

local current_folder = (...):gsub("%.[^%.]+$", "")

local timer = require(current_folder..".timer")

local colors = {
  bg =     { 141, 178, 210, 255 },
  white =  { 255, 255, 255, 255 },
  blue =   {  39, 170, 225, 255 },
  pink =   { 231,  74, 153, 255 },
  shadow = {   0,   0,   0, 255 / 3 }
}

function splashlib.new()
  local self = {}
  local width, height = love.graphics.getDimensions()

  -- radial mask shader
  self.shader = love.graphics.newShader[[
  extern number radius;
  extern number blur;
  extern number shadow;

  vec4 effect(vec4 global_color, Image canvas, vec2 tc, vec2 _)
  {
    // radial mask
    vec4 color = Texel(canvas, tc);
    number r = length((tc - vec2(.5)) * love_ScreenSize.xy);
    number s = smoothstep(radius+blur, radius-blur, r);
    color.a *= s * global_color.a;

    // add shadow on lower diagonal along the circle
    number sr = 7. * (1. - smoothstep(-.1,.04,(1.-tc.x)-tc.y));
    s = (1. - pow(exp(-pow(radius-r, 2.) / sr),3.) * shadow);

    return color - vec4(1, 1, 1, 0) * (1-s);
  }
  ]]

  -- this shader makes the text appear from left to right
  self.textshader = love.graphics.newShader[[
  extern number alpha;

  vec4 effect(vec4 color, Image logo, vec2 tc, vec2 sc)
  {
    //Probably would be better to just use the texture's dimensions instead; faster reaction.
    vec2 sd = sc / love_ScreenSize.xy;

    if (sd.x <= alpha) {
      return color * Texel(logo, tc);
    }
    return vec4(0);
  }
  ]]

  -- this shader applies a stroke effect on the logo using a gradient mask
  self.logoshader = love.graphics.newShader[[
  //Using the pen extern, only draw out pixels that have their color below a certain treshold.
  //Since pen will eventually equal 1.0, the full logo will be drawn out.

  extern number pen;
  extern Image mask;

  vec4 effect(vec4 color, Image logo, vec2 tc, vec2 sc)
  {
    number value = max(Texel(mask, tc).r, max(Texel(mask, tc).g, Texel(mask, tc).b));
    number alpha = Texel(mask, tc).a;

    //probably could be optimzied...
    if (alpha > 0.0) {
      if (pen >= value) {
        return color * Texel(logo, tc);
      }
    }
    return vec4(0);
  }
  ]]

  self.canvas = love.graphics.newCanvas()

  self.alpha = 1
  self.heart = {
    sprite = love.graphics.newImage(current_folder .. "/heart.png"),
    scale = 0,
    rot   = 0
  }

  self.stripes = {
    rot     = 0,
    height  = 100,
    offset  = -2 * width,
    radius  = math.max(width, height),
    shadow  = 0,
  }

  self.text = {
    obj   = love.graphics.newText(love.graphics.newFont(current_folder .. "/handy-andy.otf", 22), "made with"),
    alpha = 0
  }
  self.text.width, self.text.height = self.text.obj:getDimensions()

  self.logo = {
    sprite = love.graphics.newImage(current_folder .. "/logo.png"),
    mask   = love.graphics.newImage(current_folder .. "/logo-mask.png"),
    pen    = 0
  }
  self.logo.width, self.logo.height = self.logo.sprite:getDimensions()

  self.shader:send("radius",  width*height)
  self.shader:send("blur",    1)
  self.shader:send("shadow",  2)

  self.textshader:send("alpha", 0)

  self.logoshader:send("pen", 0)
  self.logoshader:send("mask", self.logo.mask)

  timer.clear()
  timer.script(function(wait)
    -- roll in stripes
    timer.tween(0.5, self.stripes, {offset = 0})
    wait(0.3)

    timer.tween(0.3, self.stripes, {rot = -5 * math.pi / 18, height=height})
    wait(0.2)

    -- hackety hack: execute timer to update shader every frame
    local haenker = timer.every(0, function()
      self.shader:send("radius", self.stripes.radius)
      self.shader:send("shadow", self.stripes.shadow)
      self.textshader:send("alpha", self.text.alpha)
      self.logoshader:send("pen",   self.logo.pen)
    end)

    -- focus the heart, desaturate the rest
    timer.tween(0.2, self.stripes, {radius = 170})
    wait(0.2)

    timer.tween(0.2, self.stripes, {radius = 70}, "out-back")
    timer.tween(0.7, self.stripes, {shadow = .3}, "back") -- @TODO 0.4?
    timer.tween(0.8, self.heart, {scale = 1}, "out-elastic", nil, 1, 0.3)

    -- write out the text
    timer.tween(.75, self.text, {alpha = 1}, "linear")

    -- draw out the logo, in parts
    local mult = 0.65
    local function tween_and_wait(dur, pen, easing)
      timer.tween(mult * dur, self.logo, {pen = pen/255}, "in-quad")
      wait(mult * dur)
    end
    tween_and_wait(0.175,  50, "in-quad")     -- L
    tween_and_wait(0.300, 100, "in-out-quad") -- O
    tween_and_wait(0.075, 115, "out-sine")    -- first dot on O
    tween_and_wait(0.075, 129, "out-sine")    -- second dot on O
    tween_and_wait(0.125, 153, "in-out-quad") -- \
    tween_and_wait(0.075, 179, "in-quad")     -- /
    tween_and_wait(0.250, 205, "in-quart")    -- e->break
    tween_and_wait(0.150, 230, "out-cubic")   -- e finish
    tween_and_wait(0.150, 244, "linear")      -- ()
    tween_and_wait(0.100, 255, "linear")      -- R

    wait(0.4)
    timer.tween(0.3, self, {alpha = 0})
    wait(0.4)

    timer.clear()

    if not self.done and self.onDone then self.onDone() end
    self.done = true
  end)

  self.done = false

  self.draw = splashlib.draw
  self.update = splashlib.update
  self.skip = splashlib.skip

  return self
end

function splashlib:draw()
  local width, height = love.graphics.getDimensions()

  love.graphics.clear(colors.bg)
  self.canvas:renderTo(function()
    love.graphics.push()
    love.graphics.translate(width / 2, height / 2)

    love.graphics.push()
    love.graphics.rotate(self.stripes.rot)
    love.graphics.setColor(colors.pink)
    love.graphics.rectangle("fill",
      self.stripes.offset - width,
      -self.stripes.height,
      width * 2,
      self.stripes.height)

    love.graphics.setColor(colors.blue)
    love.graphics.rectangle("line",
      -width - self.stripes.offset,
      0,
      width * 2,
      self.stripes.height) -- draw line for anti aliasing
    love.graphics.rectangle("fill",
      -width - self.stripes.offset,
      0,
      width * 2,
      self.stripes.height)

    love.graphics.pop()

    love.graphics.setColor(255, 255, 255, 255*self.heart.scale)
    love.graphics.draw(self.heart.sprite, 0, 5, self.heart.rot, self.heart.scale, self.heart.scale, 43, 39)
    love.graphics.pop()
  end)

  love.graphics.setColor(255, 255, 255, 255*self.alpha)
  love.graphics.setShader(self.shader)
  love.graphics.draw(self.canvas, 0,0)
  love.graphics.setShader()

  love.graphics.push()
  love.graphics.setShader(self.textshader)
  love.graphics.draw(self.text.obj,
    (width  / 2) - (self.text.width   / 2),
    (height / 2) - (self.text.height  / 2) + (height / 10) + 62
  )
  love.graphics.pop()

  love.graphics.push()
  love.graphics.setShader(self.logoshader)
  love.graphics.draw(self.logo.sprite,
    (width  / 2) - (self.logo.width   / 4),
    (height / 2) + (self.logo.height  / 4) + (height / 10),
    0, 0.5, 0.5
  )
  love.graphics.setShader()
  love.graphics.pop()
end

function splashlib:update(dt)
  -- dt / 1.85
  timer.update(dt)
end

function splashlib:skip()
  -- @TODO: overwrite timer with smooth skipping
  timer.clear()
  if not self.done and self.onDone then self.onDone() end
  self.done = true
end

return splashlib
