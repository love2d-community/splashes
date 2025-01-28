local splashlib = {
	_VERSION     = "v1.0",
	_DESCRIPTION = "a 11.3 splash",
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

Font used in the image is honchokomono (OFL): https://fontesk.com/honchokomono-typeface/]]
}

local current_module = (...):gsub("%.init$", "")
local current_folder = current_module:gsub("%.", "/")


local pink_r = 231 / 255;
local pink_g = 74 / 255;
local pink_b = 153 / 255;

local blue_r = 39 / 255;
local blue_g = 170 / 255;
local blue_b = 224 / 255;

local black_r = 0.1
local black_g = 0.1
local black_b = 0.15


local fillShader
local shrinkShader

local startTime
local t
local gWidth, gHeight = love.graphics.getDimensions()
local minLength

local circleImage
local circleImageW, circleImageH

local loveImage
local loveImageW, loveImageH
local loveHDiameter

local heart
local heartWidth, heartHeight
local heartDiameter
local circleDiameter

local SPLASH_DURATION = 7.5
local HEART_AT = 2.7 -- when the screen starts shrinking into a circle
local HEART_BOUNCE_TIME = 0.8 -- how long the heart animates for
local HEART_BOUNCE_DELAY = 0.5 -- delay on when the heart appears after the circle has started shrinking
local HEART_START_ANGLE = math.pi / 4 -- start angle at which the heart bounces
local SHIFT_DELAY = 1.5 -- time it takes for the logo to move left after the circle started appearing on screen
local SHIFT_DURATION = 0.7


local function interpolateBounce(x)
	return 1 - 2^(-8 * x^0.7) * math.cos(6.5 * math.pi * x)
end

local function interpolateMovement(x)
	return 0.5 * math.sin(math.pi * ((x - 1)^2 + 0.5)) + 0.5
end


function splashlib.new(init)

	startTime = love.timer.getTime()
	t = startTime

	fillShader = love.graphics.newShader(current_folder .. "/fill.c")
	fillShader:send("t", 0)
	shrinkShader = love.graphics.newShader(current_folder .. "/shrink.c")
	shrinkShader:send("t", 0)

	heart = love.graphics.newImage(current_folder .. "/heart.png")
	heartWidth, heartHeight = heart:getDimensions()

	circleImage = love.graphics.newImage(current_folder ..  "/circle.png")
	circleImageW, circleImageH = circleImage:getDimensions()
	loveImage = love.graphics.newImage(current_folder ..  "/love.png")
	loveImageW, loveImageH = loveImage:getDimensions()

	gWidth, gHeight = love.graphics.getDimensions()
	minLength = math.min(gWidth, gHeight)
	loveHDiameter = minLength * 0.29
	heartDiameter = minLength * 0.17
	circleDiameter = minLength * 0.3

	local self = {}
	self.draw = splashlib.draw
	self.update = splashlib.update
	self.skip = splashlib.skip

	return self
end


function splashlib:draw(dt)
	if t < HEART_AT then -- animate the background filling up
		love.graphics.setShader(fillShader)
		fillShader:send("t", t^0.9)
		love.graphics.rectangle("fill", 0, 0, gWidth, gHeight)
		love.graphics.setShader()

	elseif t < HEART_AT + SHIFT_DELAY then
		-- draw background
		love.graphics.setShader(shrinkShader)
		shrinkShader:send("t", t - HEART_AT)
		love.graphics.rectangle("fill", 0, 0, gWidth, gHeight)
		love.graphics.setShader()

		-- draw heart on top
		local x = (t - HEART_AT - HEART_BOUNCE_DELAY) / HEART_BOUNCE_TIME
		if x >= 0 then
			x = math.min(1, x)
			local bounce = interpolateBounce(x)
			love.graphics.setColor(1, 1, 1) -- I don't know why I have to set this here, I think some other module may have set it to not-white?
			love.graphics.draw(
				heart,
				gWidth / 2,
				gHeight / 2,
				HEART_START_ANGLE - HEART_START_ANGLE * bounce,
				bounce * (heartDiameter / heartWidth),
				bounce * (heartDiameter / heartHeight),
				heartWidth / 2,
				heartHeight / 2
			)
		end

	else
		-- draw background
		love.graphics.setColor(0.1, 0.1, 0.15)
		love.graphics.rectangle("fill", 0, 0, gWidth, gHeight)
		love.graphics.setColor(1, 1, 1)

		-- calculate shift
		local x = (t - (HEART_AT + SHIFT_DELAY)) / SHIFT_DURATION
		x = math.min(1, x)
		local shift = interpolateMovement(x)

		love.graphics.draw(
			loveImage,
			gWidth / 2,
			gHeight / 2,
			0,
			(loveHDiameter / loveImageW),
			(loveHDiameter / loveImageW),
			loveImageW / 2 - (loveImageW / 2 * (shift * 1.2)),
			loveImageH / 2
		)
		love.graphics.draw(
			circleImage,
			gWidth / 2,
			gHeight / 2,
			math.pi / 4,
			(circleDiameter / circleImageW),
			(circleDiameter / circleImageH),
			circleImageW / 2 + circleImageW / 2 * (shift * 1.2) * 0.707, -- since we're at a 45 degree angle, multiply by 0.707 to counteract the angle
			circleImageH / 2 + circleImageW / 2 * (shift * 1.2) * -0.707 -- same here
		)
		love.graphics.draw(
			heart,
			gWidth / 2,
			gHeight / 2,
			0,
			(heartDiameter / heartWidth),
			(heartDiameter / heartHeight),
			heartWidth / 2 + heartWidth / 2 * (shift * 1.2) * (circleDiameter / heartDiameter),
			heartHeight / 2
		)
	end
end


function splashlib:update(dt)
	t = love.timer.getTime() - startTime
	gWidth, gHeight = love.graphics.getDimensions()
	minLength = math.min(gWidth, gHeight)
	loveHDiameter = minLength * 0.29
	heartDiameter = minLength * 0.17
	circleDiameter = minLength * 0.3

	if t > SPLASH_DURATION then
		if self.onDone then self.onDone() end
	end
end


function splashlib:skip()
	if self.onDone then self.onDone() end
end

setmetatable(splashlib, { __call = function(self, ...) return self.new(...) end })
return splashlib
