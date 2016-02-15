local timer = require "timer"

local colors = {
  bg =     { 141, 178, 210, 255 },
  white =  { 255, 255, 255, 255 },
  blue =   {  39, 170, 225, 255 },
  pink =   { 231,  74, 153, 255 },
  shadow = {   0,   0,   0, 255 / 3 }
}
local heart, stripes, width, height, shader

function love.load()
  width, height = love.graphics.getDimensions()

  -- radial mask shader
  shader = love.graphics.newShader[[
  extern number radius;
  extern number blur;
  extern number shadow;

  vec4 effect(vec4 color, Image canvas, vec2 tc, vec2 _)
  {
    // radial mask
    color = Texel(canvas, tc);
    number r = length((tc - vec2(.5)) * love_ScreenSize.xy);
    number s = smoothstep(radius+blur, radius-blur, r);
    color.a *= s;

    // add shadow on lower diagonal along the circle
    number sr = 7. * (1. - smoothstep(-.1,.04,(1.-tc.x)-tc.y));
    s = (1. - pow(exp(-pow(radius-r, 2.) / sr),3.) * shadow);

    return color - vec4(1, 1, 1, 0) * (1-s);
  }
  ]]
  local ssend = shader.send
  getmetatable(shader).send = function(self, ...) pcall(ssend, self, ...) end
  shader:send("radius", math.max(width*height))
  shader:send("blur", 1)
  shader:send("shadow", 0.2)

  canvas = love.graphics.newCanvas()

  heart = {
    sprite = love.graphics.newImage("heart.png"),
    scale = 0,
    rot = 0
  }

  stripes = {
    rot = 0,
    height = 100,
    offset = -2 * width,
    radius = math.max(width, height),
    shadow = 0,
  }


  timer.clear()
  timer.script(function(wait)
    -- roll in stripes
    timer.tween(0.5, stripes, {offset = 0})
    wait(0.3)

    timer.tween(0.3, stripes, {rot = -5 * math.pi / 18, height=height})
    wait(0.2)

    -- hackety hack: execute timer to update shader every frame
    local haenker = timer.every(0, function()
      shader:send("radius", stripes.radius)
      shader:send("shadow",  stripes.shadow)
    end)

    -- focus the heart, desaturate the rest
    timer.tween(0.2, stripes, {radius = 170})
    wait(0.2)

    timer.tween(0.2, stripes, {radius = 70}, "out-back")
    timer.tween(0.7, stripes, {shadow = .3}, "back")

    timer.tween(0.7, heart, {scale = 1}, "out-elastic")
    wait(0.9)

    timer.clear()
  end)
end

function love.draw()
  love.graphics.clear(colors.bg)
  canvas:renderTo(function()
    love.graphics.push()
    love.graphics.translate(width / 2, height / 2)

    love.graphics.push()
    love.graphics.rotate(stripes.rot)
    love.graphics.setColor(colors.pink)
    love.graphics.rectangle("fill", stripes.offset - width, -stripes.height, width * 2, stripes.height)

    love.graphics.setColor(colors.blue)
    love.graphics.rectangle("line", -width - stripes.offset, 0, width * 2, stripes.height) -- draw line for anti aliasing
    love.graphics.rectangle("fill", -width - stripes.offset, 0, width * 2, stripes.height)
    love.graphics.pop()

    love.graphics.setColor(255, 255, 255, 255*heart.scale)
    love.graphics.draw(heart.sprite, 0, 5, heart.rot, heart.scale, heart.scale, 43, 39)
    love.graphics.pop()
  end)

  love.graphics.setShader(shader)
  love.graphics.draw(canvas, 0,0)
  love.graphics.setShader()
end

love.update = timer.update
love.keypressed = love.load
