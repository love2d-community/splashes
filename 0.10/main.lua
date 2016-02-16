local splashlib = require "splash"

function love.load()
  splash = splashlib.new()
end

function love.update(dt)
  if splash:isDone() then
    splash = splashlib.new()
  end
  splash:update(dt)
end

function love.draw()
  if splash:isCoveringScreen() then
    love.graphics.printf("Your logo here.",
      0,love.graphics.getHeight()/2,love.graphics..getWidth(),"center")
  end
  splash:draw()
end

function love.keypressed(key)
  splash.done = true
end
