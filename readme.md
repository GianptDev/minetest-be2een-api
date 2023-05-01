
<p align=center>
	<img src="screenshot.png">
</p>

# Be2een Api

> timers, animation and action! *ciack*

This is a library written in lua for the game [minetest](https://www.minetest.net/) that implements tools for creating timers and animations as objects that can be configurated with properties and events.

The animation system is flessible, is possible to define custom functions to change ui elements or world behaviour.

## Usage

The library acts like a mod, just add it in your mod list and enable it in your world. by itself it does nothing, because it implements features for other mods.

Add the dependency in your mod and use the namespace to access the api functionality, see the wiki for a detailed list of all functions.

## Wiki

The wiki can be found [here]() with a much detailed documentation of classes, functions and examples.

## Quick examples

Here two quick examples, you can find more in the wiki.

Call a function after time elapse:
```lua
-- call function after 3.0 seconds.
Be2eenApi.after(3.0, function (timer)
	minetest.chat_send_all("Hello everybody!");
end);
```

Animate value from start to end and call function for each frame with the animated value:
```lua
-- animate value from 10 to 30 in 2.0 seconds and call function each global step with value.
Be2eenApi.animate(10, 30, 2.0, function (tween, value)
	minetest.chat_send_all(("Animation step: %.2f"):format(value));
end);
```
