local o_ten_one = require "o-ten-one"

function love.load()
  splash = o_ten_one.new()
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
