local splashlib = require "o-ten-one"

function love.load()
  splash = splashlib.new()
  splash.onDone = love.load
end

function love.update(dt)
  splash:update(dt)
end

function love.draw()
  splash:draw()
end

function love.keypressed(key)
  splash:skip()
end
