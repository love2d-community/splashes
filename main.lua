local splashes = {
  ["o-ten-one"]           = {module="o-ten-one"},
  ["o-ten-one: lighten"]  = {module="o-ten-one", {fill="lighten"}},
  ["o-ten-one: rain"]     = {module="o-ten-one", {fill="rain"}},
  ["o-ten-one: black"]    = {module="o-ten-one", {background={0, 0, 0}}},
}

local current, splash

local function next_splash()
  current = next(splashes, current) or next(splashes)
  splash = splashes[current]()
  splash.onDone = next_splash
end

function love.load()
  for name, entry in pairs(splashes) do
    entry.module = require(entry.module)
    splashes[name] = function ()
      return entry.module(unpack(entry))
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
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(current, 10, 10)

  love.graphics.setColor(0, 0, 0)
  love.graphics.print(current, 10, love.graphics.getHeight() - 20)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit")
  end

  splash:skip()
end
