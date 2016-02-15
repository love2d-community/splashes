--[[
  Copyright (c) 2016 love-community members

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
]]

local flux = require("flux")
local lg = love.graphics
local width, height = lg.getDimensions()

local colors = {
  bg =      {141, 178, 210},
  white =   {255, 255, 255},
  blue =    {39, 170, 225},
  pink =    {231,  74, 153},
  shadow =  {0, 0, 0, 255/3}
}

function init()
  heart = {
    sprite = lg.newImage("heart.png"),
    scale = 0,
    rot = 0
  }
  stripes = {
    rot = 0,
    height = 100,
    offset = -2 * width,
    radius = math.max(width, height)
  }

  flux.to(stripes, 0.5, {offset = 0})
  flux.to(stripes, 0.4, {height = height, rot = -5*math.pi/18}):delay(0.2)
  flux.to(heart, 0.4, {scale = 1}):ease("backout"):delay(0.4)
  flux.to(stripes, 0.3, {radius = 170}):ease("linear"):delay(0.6)
  :after(0.2, {radius = 70}):ease("backout")
end
init()

function stencil()
  return lg.circle("fill", width / 2, height / 2, stripes.radius, stripes.radius * 80)
end

function love.draw()
  lg.clear(colors.bg)
  lg.setStencilTest()
  if stripes.offset == 0 then
    lg.setColor(colors.shadow)
    lg.circle("fill", width/2 + 2, height/2 + 2, stripes.radius, stripes.radius * 80)
  end
  lg.stencil(stencil)
  lg.setStencilTest("greater", 0)
  lg.translate(width / 2, height / 2)
  lg.push()
  lg.rotate(stripes.rot)
  lg.setColor(colors.pink)
  lg.rectangle("fill", stripes.offset - width, -stripes.height, width * 2, stripes.height)
  lg.setColor(colors.blue)
  lg.rectangle("fill", -width - stripes.offset, 0, width * 2, stripes.height)
  lg.pop()
  lg.setColor(colors.white)
  return lg.draw(heart.sprite, 0, 5, heart.rot, heart.scale, heart.scale, 43, 39)
end

love.update = flux.update
love.keypressed = init
