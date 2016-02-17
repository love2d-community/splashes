local splashes = {
  o_ten_one = {module="o-ten-one"},
  o_ten_one_black = {module="o-ten-one", {background={0, 0, 0}}},
  o_ten_one_delay_before = {module="o-ten-one", {delay_before = 1}},
  o_ten_one_delay_after = {module="o-ten-one", {delay_after = 1}},
}

local current, splash

function next_splash()
  current = next(splashes, current) or next(splashes)
  splash = splashes[current]()
  splash.onDone = next_splash
end

function love.load()
  for name, splash in pairs(splashes) do
    splash.module = require(splash.module)
    splashes[name] = function ()
      return splash.module(unpack(splash))
    end
  end

  next_splash()
end

function love.update(dt)
  splash:update(dt)
end

function love.draw()
  splash:draw()

  -- draw with both colors so its definetely visible
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(current, 10, 10)

  love.graphics.setColor(0, 0, 0)
  love.graphics.print(current, 10, love.graphics.getHeight() - 20)
end

function love.keypressed(key)
  splash:skip()
end
