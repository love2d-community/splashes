local timer = require "timer"

local colors = {
  bg =     { 141, 178, 210, 255 },
  white =  { 255, 255, 255, 255 },
  blue =   {  39, 170, 225, 255 },
  pink =   { 231,  74, 153, 255 },
  shadow = {   0,   0,   0, 255 / 3 }
}
local heart, stripes, width, height, shader

heart_png =
  "iVBORw0KGgoAAAANSUhEUgAAAFYAAABPCAYAAABxjzKkAAAACXBIWXMAAAsTAAALEwEAmpwYAAAA\
  GXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAADo1JREFUeNrsnXtwVNUdx88597nv\
  zSbhoVDru0CHUAqKD7Ct1bGtCuhYZ3QqYmtLO04f8oczHZCnMtrKH+IDfGJpOzpFoFBFVKgWUGTK\
  o850UERHXgaSEDa7m+zj3ntOf79z70JSsiEku5tA9jiHDUt2772f+zvf3+93zvldqRCCVFrxG62A\
  LU1j5T7g0MGDaLmOVV0VpX6fj55TFhuLRimnlNjZLGGqRjOZNNFNgzQcOTpm8NChu3OZDNF0k3DH\
  EqqiknS6jVi23eOTCUUilMG1ZLI5qusqcWyHOGA3x481jqkdVLubO5xQOI6qMOFYFjFMkzQ3N4uz\
  AmwMLMSBr7OyWfrZvn3RQYMGTVEU5TpK6Rjoo///9+HYB6C/5zjO++FIZDlcNMlmcyKXy3XrpKpj\
  VbQ1nSGKqlIOIJubj03VdX0yYwyP+bWujtfQ0LDmoksuPa6rjCSTqeIDRrC97VGwlkgoTP3+IDva\
  0HCxbdt/gvfj4sxa3LKs+Z988km14fczwzBooeOFwyEaBaj+YJDt2LmzBj/Xg+MJPE8AfLHp87Fo\
  LEaLwSLfe/XhSCRMg8EgNQHEjh07ajygvW3xtra223XDVKKRMIuEwx0uuAoABAIBphmGEo/Hv885\
  39/bA+J5o0H4TZMFQiHap2DRanxwIniBCAIusEUUsYEcLNFNU8WbBhZFUbMBqLyJmmlo6XR6oShu\
  i2cymZmG6WN4HHR6ZQcbCnWw0rWiRA2/e/OWLbU63DwTbiKAVuBG6gB9RamOCQbyPsqRD+UhGqFl\
  AwvOgaImNTY2jgMn8LEoccNjIEzNNDV4NbLZ7J9LfUyUF5CZbxtwnUOGDKYlBWv6/DQcjTITtK/+\
  yJHxxR76XTUY9n9RDSPQ2tr6TLmOidfX2NQ0DnwIRIs6LQlYGPY0FIowDQLEQ4cOXVFOqPkGUNeX\
  +5gSLoxMpqqMMkaLDjZSFWVgMSpoz2V9AbUvWx4u6DuLRKto0cCC46AGDP9169YNLoem9lO4+zdv\
  3lILkQJIodEtuF1mXn6QAEcIyBSFmojHXwLPfNdAnVSBCOUfvmDgNk3VHOpKk+jRJEwEsinbge/g\
  nB08cGDqQIaKTVXVm5uONkwHwEzXNdrjlBZDKnRWf1u5cghIwAFRaVJv14IkgpEpgdMkEJ2+6QMJ\
  wKAcHJaRSCQWVZB2iE4eAS6az+dnYUiUCoE9RQow2yAUQgtK2PNLl1VDHPeryrT1yQYZ2QOrV66M\
  2dxh6XSm+xorKCUcPgTQlZt+cNMUSmm4grPdPCvwmDhx4r3IjjGFhoIB2q35WNP0MYcIFX7U25LJ\
  bZqmjarg7NhAaw8aPv/lChEW6K0Tb2kRXVosaiveEvgttmrlyosqUAsMc8aG/3v7R2M5pcziDj2t\
  FMAHCLg+EAOi1NXVXVdBWLgNGz58Engpxm2HBjqRgw5gOcStBJwWAX0NBgKjK/i6cGKmOQn8kQJS\
  ShFaQbBSBkAHOEYKlKjg/b5ZwddlwoBragoHsDjKC4I1dJ043MG4AN9TQF+HV/AVbrqujyRuuMps\
  zgtbbDqdllECWi2+D3fk/Aq+0/sx4fKiuP5XwGI1is2FW/6NHGcrWKAlQ1bORecWm7NsIv/NdV4V\
  sN3KFiQnaYwKpZ2DVTTdNerKVq4zQ4taIDhpdaW0k3CLSaumkiz8AJr7aYVbl9lX0k1xZYSAW5c6\
  Rg3tcmCXv3BN2rbtRAVf4QaGt4d4Axzif2IX0lji2K4Au1xFU1PT9gq+wi2RTO5xJ1uI3HynKUrn\
  YLltEUZF/iaIAwcP7qngK9yaGhv/C6TQFDH1EsFIuHOwTNUwOxPE/Y8vWfLUtgq+wu2tDRs+RHuU\
  TgnCrZbj8Y5eLT9tGAmHaDqbUwC/Dr8agLfC9YcPv1BTU/2dCsZT9PXTcLTqRpDNJLBKKwrLmbom\
  4vGT04esvfEqjAnq6TF8yNn72d5NFYynti+//HIVeiUc2aACHNW1PdQOYFsSLTIiw1/2PmQ//vgf\
  NjiOk6qg7NjmzJu3EgMnyQnIUs85dR4VYJKAno261grdeuPNN4/v3bv3rxWUJ9uRo0fXrl6z5pgE\
  S6m0Wt0wSZdgVZACXGKkeCfcO5J7efkrqyo4T7ann37mSXixwPCQD1eoW9NwSkrWfs0rGApS7nDm\
  cK7Buwb8UxDeDu3euWPmqFGjfjbQoX5VX7/ugq9f+Fv4MQkhVhoMMAt+yWlra+NdWmwqmZIxmaDS\
  YrHnsP/uwZkrIBNrHchQ0dc8+eSSp/LWinkBbiHw+cxOZ1dOmcXSNUMwDHwFaghBG8/+8733Gv+1\
  efPigQwWfc0Tixd/AUyyCBfclaOqKvf7/Z3PznS2Kc40DMbleg7R4a8++LIwiHT4aP1XL8disTED\
  DWoqlfqsqrpmKmayMnYlJAMyYIdNv9MUb+6exRJ3UkG4MZobHaDVYn947tw5A1ESXnjxxdmSgWut\
  NlijozGF29wu/KGCBRzBINMNQ1N1ww+9VjWMC+F19NvvvLNwIO3V2r59+2K47hHQhwGDKuimYWKp\
  VNebkAuuFDBVFYxSztywAu8UblRK//BHN7++/8CB9QPBUg8dPvzG1ddOfAmvW1qrIDkFYlfMTrGs\
  tKvW5cZj3IhgOxyXeDWUXjmHQCEEg9fmpsZXQ6HQJecq1GQyue+OO++cvnHTpnqUWZwTgGvPQKxv\
  G7ou4vF4zzYeY9NUlUAAjFprwxdjmCGtFq33lsmTf5lOp4+ei1DRj/x+1qwHN27c1CCBCqmvFsRK\
  3FC000I9LVicWGAKk5JAXSeWg4NIuFu3ftAI4cdD55ozw+v54xNPzFi6dNnnJyQAwisAZYOhcUXt\
  5jprdwoVsHYVyy81EG4Q7wgI+VDol0IfO3/Bgnsty0qdC44Kr+PRRYt+gk4a+oVwrbWabgSxgE83\
  DQXrhotb52WaFHcwq7qO1YE+RTeicODzoV9+LsF9d+PGBR7Ui6EPhmsN4a52aIr/DKCeUWVidXWM\
  QpaBlqvBwXzQY9CH5eHOnTd/+tkMtwNUwxgCr2EcoSa4f/iTlbSW1u8zJVwN41vDCECvgT4cTuIb\
  8Dpuzrx5951tcPF8FyxcOA2uoc6DijIXxZEJXQ0EgiwWq6Ki1EXKvkCAqoYuq7DhJIISrm58DfpI\
  +Hn82QS3HdQx0mcYxnmYBICu+nFkBnw+FuthBXiPSsZRxP1uibuhog5hZqYbF0AfBX3ctZMm3dTS\
  0rKvP0PF81v4yCP3wPkj1Ms8n1EFfsSPvgQMiEWi0R6X1ff4mTChaJRlMxmcZIQUhGqCEh+EYn45\
  aUOIf8KEK2tXr1r1WE11dV1/C6kSicTnt06ZMgNCxgb4axuEVGn5KnByRdgONFnXhXMmPWy9ethO\
  OFTFMlYadybhzmZc3TVlhkYkYAn54927Zo4YMeL2/gJ1//79b11y2eVzPKAIsw1i9Aycv5xgAZgO\
  d7n2ahdbr3YVJpLHuekPCJ0SzJ9zcj6ByqAaC00xcWgbPeZbT7y5fv1j/SGR2PD224sA6sN4frID\
  VDxnONccpdRmjBUFaq/BSrjNx7ii6RwfhgHDyIULaSClEqyEO3nK1NULH33016BrX/QFUEy9wUlN\
  v/mWW1d5Q75VdirPMwtyZvl0HcY9KwrUXktBh5UH3aCaqrAc53izNK+7uuvqrw90t/q1V1+dfd7Q\
  odeUcZ1q61133z0X9LTJm+dIe6kqTlZb3qIpj4aCoqGxqWibWIv6QLMaSCJS6Qx+J+PCLcLzZsVM\
  byVCAv77mtWTb7zhhgdUVQ2UEuqWLVuf+u7116+Q8iROQM14kmXB8HcCpinaWttENpct6s7gou7c\
  bjrWLDRNFZQLd0bM1d20dBLUG34gD5OnTl39ixkz7kPvXCqvj0MfoL4i5UiQlJz6I66jQkvVAKqm\
  qsI09KJDLbrF5hvkDhSlIW1Z+CAVBaIGtF4DLtDIh2Peq/7Rhx/cP3bs2GnFOvauXbuWXzHhqudO\
  WCaRDkrOUkH4YhHBLU1ROMRUPJvNlmz/eklqDfD5hLqmCVNVOXham1FqUXf4uZZLTlrQlVddvWz2\
  w3Pu761jQyt9dunS3wDUZzscw/057a6CCEtXVYfBeZUSaskstn2LRatozs7RnMMV6hacadJy6Qnt\
  NaX2gkVv27r1/rq6utvPVHt37tz5Ctyg506Ee8LTUirnj7M4l4xzyipYKoZTbel0ySstSl4d0xw/\
  LrDu2dR03AACQ1FkvUwn5S0lJ+DicTtk64Srr3kWtbexsenj7mn6sf+glgLUp3E1RX6Xu0SdciWA\
  YjiV05hi47NcUqkULwfUslhsvg2qraGW7ZBsLsdA35jA+gchQzLdy9ak1UpLhtflL738vTt/fMdD\
  nVkvJhvvvPvuklsnT1nbTksz3g3DDCrHpPOkjgKhFNM1kUokyloPVPZHSQdDIepYNm7Tk6WlHmDd\
  kwbjBGRKjCvGj489v2zZT0eOHHlb/vN79ux5/eczZrywbdtHzfl41AObzUP1NvU5oO9Cg55Mpcpe\
  ZNUnz+iura6mOcsC3XXwSUkI2LVeSnSS333jAkbQ+rRp9wybPWvWfStWrHht3vwFe9pBzC9uYlhn\
  yXU5QRwI+TgFoOW20j4Hm2+RaITa2Ry1ZGk6ODa3PErz4J4Ai9XoWKgm9+4Kb2eOu86flQ7KXexz\
  KGVcUZj0kolkqk9LAfv8qfL4+OnWTA7rTLGKmgE9RVCSz9p0T4dRMlj7fbvE3fVneWkpVxiFrohU\
  KtUvaiv7zeP6a2pqaGtrq3x0isN5XntVgKfggymI+7QFdxu/u8/BBjN3FAijIITjWB3Y2k+g9iuw\
  2PCRf0xhxAbnJtDzuICZ3LFLZG26LLSm6OkpbjUV3DAMkehDLT0rwOZbNBpFq0UHhydIZQEaY7iO\
  RFQY7lhMYfp8ArIoUl9f3y/Lqvv1/7kDLVihjDiCE6ZpBPJQopsm6c4WnwrYc7RVwFbAnl3tfwIM\
  AIfmF+R5AXv5AAAAAElFTkSuQmCC"

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
    sprite = love.graphics.newImage(love.filesystem.newFileData(heart_png, "heart", "base64")),
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
