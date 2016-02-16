splashes [![join on gitter](https://badges.gitter.im/love2d-community/splashes.svg)](https://gitter.im/love2d-community/splashes)
========
A collection of splash screens for LÖVE.

Usage
-----
Pick the splash you want to use from our wide variety of **1** (*one*) splashes and move the directory somewhere into your project.
Require the file and instantiate the splash using `splash.new()`.
Make sure to hook the love callbacks up to `splash:update(dt)` and `splash:draw()` and call `splash:skip()` to let the player skip the splash screen.

    local splash = require "o-ten-one"
    
    function love.load()
      splash = o_ten_one.new()
      splash.onDone = function() print "DONE" end
    end
    
    function love.update(dt)
      splash.update(dt)
    end
    
    funciton love.draw()
      splash.draw()
    end
    
    function love.keypressed()
      splash:skip()
    end

Splash Interface
----------------

The following members of the `splash` variable are of importance to you as a user:

### `splash:update(dt)`
Update the splash screen

### `splash:draw()`
Draw the splash screen

### `splash:skip()`
Skip the splash screen.
Splash may still run an exit transition after this, wait for the `onDone()` callback to fire.

### `splash.onDone()`
A callback you can add on the `splash` table.
Gets called when the splash exits or is skipped.
