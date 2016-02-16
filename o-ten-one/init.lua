local splashlib = {
  _VERSION     = 'v1.0.2',
  _DESCRIPTION = 'a 0.10.1 splash',
  _URL         = 'https://github.com/love2d-community/splashes',
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
3. This notice may not be removed or altered from any source distribution.]]
}

local current_folder = (...):gsub('%.[^%.]+$', '')

local timer = require(current_folder..".timer")

local colors = {
  bg =     { 108, 190, 228, 255 },
  white =  { 255, 255, 255, 255 },
  blue =   {  39, 170, 225, 255 },
  pink =   { 231,  74, 153, 255 },
  shadow = {   0,   0,   0, 255 / 3 }
}

function splashlib.new()
  local self = {}
  local width, height = love.graphics.getDimensions()

  -- shader lightens everything except in a circular mask
  self.shader = love.graphics.newShader[[
  extern number radius;
  extern number blur;
  extern number lighten;
  extern number shadow;

  vec4 desat(vec4 color)
  {
    // roughly human luminance perception
    number g = dot(vec3(.299, .587, .114), color.rgb);
    return vec4(g,g,g,1.0) * lighten;
  }

  vec4 effect(vec4 color, Image canvas, vec2 tc, vec2 _)
  {
    // radial mask
    color = Texel(canvas, tc);
    //TODO: scale canvas, swap l_Sc.xy to internal res vec2
    number r = length((tc - vec2(.5)) * love_ScreenSize.xy);
    number s = smoothstep(radius-blur, radius+blur, r);
    color = desat(color) * s + color;

    // add shadow on lower diagonal along the circle
    number sr = 7. * (1. - smoothstep(-.1,.01,(1.-tc.x)-tc.y));
    s = (1. - pow(exp(-pow(radius-r, 2.) / sr),3.) * shadow);

    return color * s;
  }
  ]]

  -- this shader makes the text appear from left to right
  textshader = love.graphics.newShader[[
  extern number alpha;

  vec4 effect(vec4 color, Image logo, vec2 tc, vec2 sc)
  {
    //Probably would be better to just use the texture's dimensions instead; faster reaction.
    vec2 sd = sc / love_ScreenSize.xy;
    //vec2 sd = sc / vec2(800.,600.);

    if (sd.x <= alpha) {
      return color * Texel(logo, tc);
    }
    discard;
  }
  ]]

  -- this shader applies a stroke effect on the logo using a gradient mask
  logoshader = love.graphics.newShader[[
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
    discard;
  }
  ]]

  local ssend = self.shader.send
  getmetatable(self.shader).send = function(self, ...) pcall(ssend, self, ...) end
  self.shader:send("radius", math.max(width*height))
  self.shader:send("blur", 1)
  self.shader:send("shadow", 0.2)

  self.canvas = love.graphics.newCanvas()

  self.heart = {
    sprite = love.graphics.newImage(current_folder .. "/heart.png"),
    scale = 0,
    rot = 0
  }

  self.stripes = {
    rot = 0,
    height = 100,
    offset = -2 * width,
    radius = math.max(width, height),
    shadow = 0,
  }


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
    end)

    -- focus the heart, desaturate the rest
    timer.tween(0.2, self.stripes, {radius = 170})
    wait(0.2)

    timer.tween(0.2, self.stripes, {radius = 70}, "out-back")
    timer.tween(0.7, self.stripes, {shadow = .3}, "back")

    timer.tween(0.7, self.heart, {scale = 1}, "out-elastic")
    wait(0.9)

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

  love.graphics.setShader(self.shader)
  love.graphics.draw(self.canvas, 0,0)
  love.graphics.setShader()
end

function splashlib:update(dt)
  timer.update(dt)
end

function splashlib:skip()
  -- @TODO: overwrite timer with smooth skipping
  timer.clear()
  if not self.done and self.onDone then self.onDone() end
  self.done = true
end

return splashlib
