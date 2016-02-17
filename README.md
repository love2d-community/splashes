splashes [![join on gitter](https://badges.gitter.im/love2d-community/splashes.svg)](https://gitter.im/love2d-community/splashes)
========
A collection of splash screens for LÖVE.

Run this repo with `love .` to check out all splash screens.
Press any key to skip ahead.

Usage
-----
Pick the splash you want to use from our wide variety of **1** (*one*) splashes and move the directory somewhere into your project.
Require the file and instantiate the splash using `splash.new()`.
Make sure to hook the love callbacks up to `splash:update(dt)` and `splash:draw()` and call `splash:skip()` to let the player skip the splash.

```lua
local splash = require "o-ten-one"

function love.load()
  splash = o_ten_one()
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
```

Splash Interface
----------------

The library only has one function you should use:

### `lib.new(...)`
Instantiate a new `splash`.
You can also do this by calling the library itself: `lib(...)`.
Accepts a table with parameters depending on the specific splash (see below).

The following members of the `splash` variable are of importance to you as a user:

### `splash:update(dt)`
Update the splash.

### `splash:draw()`
Draw the splash.

### `splash:skip()`
Skip the splash.
Splash may still run an exit transition after this, wait for the `onDone()` callback to fire.

### `splash.onDone()`
A callback you can add on the `splash` table.
Gets called when the splash exits or is skipped.

Splashes
--------

### `o-ten-one`
Splash with the new 0.10.1 (windows) logo.

`new()` parameters:

* `background`: `{r,g,b,a}` table used to clear the screen with.
  Set to `false` to draw underneath.

  Example: _Setting a pink background color_

  ```lua
  splash = lib.new({background={255,0,255}})
  ```

* `lighten`: boolean, if truthy instead of shrinking the background to a circle the oustide gets lightened up.

* `delay_before`: number of seconds to delay before the animation.
  Defaults to `0`.

* `delay_after`: number of seconds to delay before the animation.
  Defaults to `0`.
