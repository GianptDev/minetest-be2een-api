--- @package Be2eenApi
--- @author _gianpy_
--- @license MIT

--- module

local abs = math.abs;
local sin = math.sin;
local cos = math.cos;
local sqrt = math.sqrt;
local pi = math.pi;

--- List of active timers processed by the server.
--- @type table<integer, Be2eenApi.Timer>
--- @since 1.0
local queue_timer = {};

--- List of active tweens processed by the server.
--- @type table<integer, Be2eenApi.Tween>
--- @since 1.0
local queue_tween = {};


--[[
This is a library that implements functionality for timer events and animation tools for the game minetest.
]]
--- @class Be2eenApi
--- @since 1.0
Be2eenApi = {};

--- --

--[[
Get the current version of the api as a string with 2 dots to separate major number, minor number and release type.

The structure of the string is `[major].[minor].[release]` example: `1.0.dev`

### Note
* The **dev** release comes from the repository and is intended to be used for development purpose because it may contain experimental functionality.

* The **stable** release comes from a release that has been tested and is intended for usage purpose.
]]
--- @return string version
--- @nodiscard
--- @since 1.0
function Be2eenApi.get_version() return "1.0.stable"; end
-- TODO: remember to update string each version !!


--[[
Get the linear interpolated value between the given points at the given position.
]]
--- @param x number # The first point to begin.
--- @param y number # The last point to end.
--- @param t number # The position of the interpolation in range from 0.0 to 1.0
--- @return number value # The interpolated value between the given points.
local function lerp(x, y, t) return (1.0 - t) * x + t * y; end
Be2eenApi.lerp = lerp;


--[[
Will round the given input to the input precision given.
]]
--- @param position number # The input number to snap to the nearset precision point.
--- @param precision number # The size of the precision.
--- @return number value # The snapped point from the given position to the nearest precision.
function Be2eenApi.snap(position, precision) return (precision == 0.0) and 0.0 or (math.floor((position / precision) + 0.5) * precision); end


--[[
Will clamp the given value between the area (min and max) given, if the value is outside those limit it will snap back from the other side.
]]
--- @param value number # The input number to wrap with.
--- @param min number # The begin of the wrapping area.
--- @param max number # The end of the wrapping area.
--- @return number value # The point wrapped around the given area.
function Be2eenApi.wrap(value, min, max) return (min == max) and min or ((value - max) % (min - max) + max) end


--[[
Get the count of how many timers are currently running.
]]
--- @return integer count # Total amount of timers currently running.
function Be2eenApi.get_timers_count() return #queue_timer; end


--[[
Get the count of how many tweens are currently running.
]]
--- @return integer count # Total amount of tweens currently running.
function Be2eenApi.get_tweens_count() return #queue_tween; end


--[[
Will create a timer with the given duration and callback to call after the coutdown, is the same as doing the following:

	local timer = Be2eenApi.Timer();
	timer.onFinished = callback;
	timer:start(duration);

This function does the same thing as `minetest.after()` but using the api functionality instead.
]]
--- @param duration number # Time in seconds to wait before calling the callback.
--- @param callback fun(timer: Be2eenApi.Timer) # The function to call as a callback after the timer finishes.
--- @return Be2eenApi.Timer timer # The timer that has been created.
--- @since 1.0
function Be2eenApi.after(duration, callback)
	local timer = Be2eenApi.Timer();
	timer.onFinished = callback;
	return timer:start(duration);
end


--[[
Will create a tween to animate the value in between of the start and finish in the given time calling each step the callback, is the same as doing:

	local tween = Be2eenApi.Tween();
	tween.duration = time;
	tween.onStep = function(tween, value)
		callback(tween, Be2eenApi.lerp(start, finish, value));
	end
	tween:start();
]]
--- @param start number # Starting point of the animation.
--- @param finish number # Final point of the animation.
--- @param time number # Amount of time in seconds wich the animation will elapse.
--- @param callback fun(tween: Be2eenApi.Tween, value: number) # Function to call each step of the animation.
--- @return Be2eenApi.Tween tween # The newly created tween for the animation.
function Be2eenApi.animate(start, finish, time, callback)
	local tween = Be2eenApi.Tween();
	tween.duration = time;
	function tween:onStep(value)
		callback(tween, lerp(start, finish, value));
	end
	return tween:start();
end

--- -- Timer class

--- @class Be2eenApi.Timer
local Timer = {
	--[[
Amount of seconds to wait before the timer ends, this value is subtracted each global step.
]]
	--- @type number
	--- @since 1.0
	_time_left = 0.0,
	--[[
Total duration of the timer in seconds.
]]
	--- @type number
	--- @since 1.0
	duration = 1.0,
	--[[
If enabled the timer will automatically restart until is stopped manually.

Use this if you want to loop the timer because it can fix possible time overflows each loop.
]]
	--- @type boolean
	--- @since 1.0
	loop = false,
	--[[
Event called once in `:start()` after the timer is added to the queue process.
]]
	--- @type fun(self: Be2eenApi.Timer) | nil
	--- @since 1.0
	onStart = nil,
	--[[
Event called after the timer has been removed from the queue in the expected duration time that has been set.
]]
	--- @type fun(self: Be2eenApi.Timer) | nil
	--- @since 1.0
	onFinished = nil,
	--[[
Event called after the timer has been removed from the process queue before the expected duration, this event is called when the server shutdowns because timers *will not* be saved.
]]
	--- @type fun(self: Be2eenApi.Timer) | nil
	--- @since 1.0
	onStopped = nil,
};
local mTimer = { __name = "Be2eenApi.Timer", __index = Timer };


--[[
Object that define the basic functionality of a delayed callback by time,
once created his properties can be changed and his events can be set to custom
actions.

After setting everything up the timer require to start, once done it will add itself
to the queue to be processed by global steps from the server.

The timer will remove itself from the queue once finished automatically or if being stopped manually.
]]
--- @return Be2eenApi.Timer timer
--- @nodiscard
--- @since 1.0
function Be2eenApi.Timer() return setmetatable({}, mTimer); end


--[[
Get how much time in seconds is left before the timer ends.
]]
--- @return number time # Time in seconds.
--- @nodiscard
--- @since 1.0
function Timer:get_time_left() return self._time_left; end


--[[
Get how much time has elapsed since the timer started.
]]
--- @return number time # Time in seconds.
--- @nodiscard
--- @since 1.0
function Timer:get_time_elapsed() return self.duration - self._time_left; end


--[[
Calculate the percentuage in range from 0.0 to 1.0 of the coutdown from the current time left and the total duration.

### note
If the duration is 0.0 this function will return 1.0 to not raise any division error.
]]
--- @return number time # Value in range between 0.0 to 1.0
--- @since 1.0
function Timer:get_time_position() return self.duration == 0.0 and 1.0 or 1.0 - (self._time_left / self.duration); end


--[[
Get the index position wich the timer is stored inside the timer queue, but only if the object is running otherwise it will return `nil`.
]]
--- @return number | nil index # The index position inside the queue or `nil` if the object is not inside of it.
--- @nodiscard
--- @since 1.0
function Timer:get_queue_index()
	for i, t in ipairs(queue_timer) do
		if t == self then
			return i;
		end
	end

	return nil;
end


--[[
Check if the timer is inside the process queue and is processing the advancement of time.
]]
--- @return boolean running
--- @nodiscard
--- @since 1.0
function Timer:is_running() return self:get_queue_index() ~= nil; end


--[[
Will start the timer to run, it will add itself to the process queue and since that it will start the advancement of time until his target duration.

This function will call the `:onStart()` event, wich it will be only called once by this function, if the internal countdown has already finished
(that happen when the timer has been created) it will be resetted to the configured duration.

When the timer finishes his coutdown it will call the `:onFinished()` event.

	function timer.onFinished (timer)
		print(("finished countdown after %.2f seconds !"):format(timer.duration));
	end

### Note
If the internal countdown has already finished, wich happen on a newly created timer, this function will reset it.

When the timer finished his countdown it will reset itself automatically, however check if the timer has finished to make sure
it will run in the duration you expect, here 3 examples:

	timer:reset():play(); -- start timer with previus duration
	timer:start(3.0);     -- start timer with new duration
	if timer:get_time_left() == 0.0 then ... end -- check by condition
]]
--- @param duration? number # If specified it will reset and override the wait time of the timer, otherwhise it will just continue from the previus time left.
--- @return self self
--- @since 1.0
function Timer:start(duration)
	if self:is_running() then
		minetest.log("error", ("[be2een] Timer:start %p : tried to start timer when it was already running."):format(self));
		return self;
	end

	if duration then
		self:reset(duration);
	elseif self._time_left <= 0.0 then
		self._time_left = self.duration;
	end

	table.insert(queue_timer, self);
	minetest.log("info", ("[be2een] Timer:start %p : timer added to queue, now is running and it will finish after %.2f seconds."):format(self, self._time_left));
	if self.onStart then self:onStart(); end
	return self;
end


--[[
Will stop the timer right now, it will remove itself from the process queue and his countdown will stop, after being stopped it will call the `:onStopped()` event.

	function timer.onStopped (timer)
		print(("timer elapsed less than %.2f seconds."):format(timer.duration));
	end

### Note
After being stopped the timer *will not* reset his left time, in fact the timer will simply pause itself.
]]
--- @return self self
--- @since 1.0
function Timer:stop()
	local index = self:get_queue_index();

	if not index then
		minetest.log("error",
		("[be2een] Timer:stop %p : nothing to stop, the timer has already been stopped."):format(self));
		return self;
	end

	table.remove(queue_timer, index);
	minetest.log("info", ("[be2een] Tween:stop %p : timer has been stopped, it was left %.2f seconds before it finished."):format(self,
	self:get_time_left()));
	if self.onStopped then self:onStopped(); end
	return self;
end


--[[
Restart the timer current countdown to his configured duration or the new given one, this function *can* be called while the timer is running or if has been stopped.
]]
--- @param duration? number # If defined it will override the previus duration set with the given one.
--- @return self self
--- @since 1.0
function Timer:reset(duration)
	if duration then
		--- tell the user time travel hasn't been invented yet.
		if duration <= 0.0 then
			minetest.log("warning", ("[be2een] Timer:reset %p : duration time must be greater than 0.0 but %.2f has been given instead, duration of %.2f will be used instead.")
			:format(self, duration, self.duration));
			duration = self.duration;
		end

		self.duration = duration;
	end

	self._time_left = self.duration;
	return self;
end


--[[
Advance the internal time left by the given amount and handle the execution of the `:onFinished()` event if the time left finishes,
this function can be used to skip a portion of time that need to elapse.

If negative time is given it will instead increase the time that require to elapse.

	local timer = Be2eenApi.after(3.0, callback);
	timer:time_step(2.0);	-- skip 2 seconds from original duration.

### Note
This function is directly used to process the global step by the internal process loop.
]]
--- @param time number # Amount of time in seconds to advance.
--- @return self self
--- @since 1.0
function Timer:time_step(time)
	self._time_left = self._time_left - time;

	if self._time_left <= 0.0 then
		local overflow = self.duration + self._time_left;

		minetest.log("info", ("[be2een] Timer:time_step %p : timer removed from queue, it finished to run with an overflow of %.4f seconds."):format(self, -self._time_left));

		self._time_left = 0.0;
		if self.onFinished then self:onFinished(); end

		--- finished the job, remove from queue, go home.
		if not self.loop then
			table.remove(queue_timer, self:get_queue_index());

			--- loop enabled, start from overflowed time to be more precise.
		else
			self._time_left = overflow;
		end
	end

	return self;
end

--- -- Tween class

--- @class Be2eenApi.Tween: Be2eenApi.Timer
local Tween = {
	--- @type fun(value: number): number | nil
	interpolation = nil,
	--[[
If enabled makes the animation move in reverse, from the end to the start.
]]
	--- @type boolean
	reverse = false,
	--[[
If enabled makes the animation twince faster and use half of the time to repeat the animation in reverse.
]]
	--- @type boolean
	pingpong = false,
	--[[
Event called once in `:start()` after the timer is added to the queue process.
]]
	--- @type fun(self: Be2eenApi.Tween) | nil
	onStart = nil,
	--[[
Event called after the timer has been removed from the queue in the expected duration time that has been set.
]]
	--- @type fun(self: Be2eenApi.Tween) | nil
	onFinished = nil,
	--[[
Event called after the timer has been removed from the process queue before the expected duration, this event is called when the server shutdowns because timers *will not* be saved.
]]
	--- @type fun(self: Be2eenApi.Tween) | nil
	onStopped = nil,
	--[[
Called each process step and gives the current interpolated value.
]]
	--- @type fun(self: Be2eenApi.Tween, value: number) | nil #
	onStep = nil,
};
setmetatable(Tween, mTimer);
local mTween = { __name = "Be2eenApi.Tween", __index = Tween };


--[[
Object that extend the functionality of the timer by adding interpolation properties for animations.

It will run in a separated queue *after* the timers.
]]
--- @return Be2eenApi.Tween tween
--- @nodiscard
--- @since 1.0
function Be2eenApi.Tween() return setmetatable({}, mTween); end


--[[
Get the index position wich the tween is stored inside the tween queue, but only if the object is running otherwise it will return `nil`.
]]
--- @return number | nil index # The index position inside the queue or `nil` if the object is not inside of it.
--- @nodiscard
--- @since 1.0
function Tween:get_queue_index()
	for i, t in ipairs(queue_tween) do
		if t == self then
			return i;
		end
	end

	return nil;
end


--[[
Will get the current step position of the interpolation, calculated from the set interpolation function and properties of the tween.
]]
--- @param position? number # If defined it will calculate the position of this point, otherwise it will use the current position of the tween.
--- @return number step # Interpolation point.
function Tween:get_step(position)
	if not position then position = self:get_time_position(); end

	-- desmos: 1-\operatorname{abs}\left(a\cdot2-1\right)
	if self.pingpong then
		position = abs(position * 2.0 - 1.0);
		if not self.reverse then position = 1.0 - position; end
	elseif self.reverse then position = 1.0 - position; end

	return position;
end


--[[
Get the interpolated value between the 2 given points at the position of the tween animation.
]]
--- @param x number # The initial point.
--- @param y number # The final point.
--- @param t? number # If defined it will use this instead of the tween's current position.
--- @return number value # The final animated value.
function Tween:get_animated(x, y, t)
	t = self:get_step(t);
	return lerp(x, y, self.interpolation and self.interpolation(t) or t);
end


--[[
Will start the tween to run, it will add itself to the process queue and since that it will start the advancement of time until his target duration, after being inserted in the queue it will call the `:onStart()` event.

After calling the `:onStart()` event the `:onStep()` event will be called to immediatly set the animation on the current interpolation of the tween.

	function tween.onStep (tween, step)
		print(("interpolation value is %.2f"):format(value));
	end

When the tween finished his animation whitout being stopped it will reset his coutdown timer.

### Note
If the internal countdown has already finished, wich happen on a newly created tween, this function will reset it.
]]
--- @return self self
--- @since 1.0
function Tween:start()

	if self:is_running() then
		minetest.log("error", ("[be2een] Tween:start %p : tried to start the tween twince, it must be stopped first."):format(self));
		return self;
	end

	if self._time_left <= 0.0 then self._time_left = self.duration; end

	table.insert(queue_tween, self);
	minetest.log("info", ("[be2een] Tween:start %p : tween added to queue, now is running."):format(self));
	if self.onStart then self:onStart(); end
	if self.onStep then self:onStep(self:get_step()); end
	return self;
end


--[[
Will stop the tween immediatly, it will remove itself from the process queue and his countdown will stop, after being stopped it will call the `:onStopped()` event.

	function tween.onStopped (tween)
		print("the animation has been stopped.");
	end
]]
--- @return self self
--- @since 1.0
function Tween:stop()
	local index = self:get_queue_index();

	if not index then
		minetest.log("error", ("[be2een] Tween:stop %p : nothing to stop, the tween has already been stopped."):format(self));
		return self;
	end

	table.remove(queue_tween, index);
	minetest.log("info", ("[be2een] Tween:stop %p : tween has been stopped."):format(self));
	if self.onStopped then self:onStopped(); end
	return self;
end


--[[
Advance the internal time left by the given amount and handle the execution of the `:onFinished()` event if the time left finishes,
this function can be used to skip a portion of time that need to elapse.

It will also calculate the current interpolation point and call the `:onStep()` event, making sure to keep the range between 0 and 1.

If negative time is given it will instead increase the time that require to elapse.

### Note
This function is directly used to process the global step by the internal process loop.
]]
--- @param time number # Amount of time in seconds to advance.
--- @return self self
--- @since 1.0
function Tween:time_step(time)
	self._time_left = self._time_left - time;

	if self._time_left <= 0.0 then
		local overflow = self.duration + self._time_left;

		minetest.log("info", ("[be2een] Tween:time_step %p : timer removed from queue, it finished to run with an overflow of %.4f seconds."):format(self, -self._time_left));

		self._time_left = 0.0;
		if self.onStep then self:onStep(self:get_step(1.0)); end
		if self.onFinished then self:onFinished(); end

		--- finished the job, remove from queue, go home.
		if not self.loop then
			table.remove(queue_tween, self:get_queue_index());

			--- loop enabled, start from overflowed time to be more precise.
		else
			self._time_left = overflow;
		end
	elseif self.onStep then
		self:onStep(self:get_step());
	end

	return self;
end


--[[
This is a build-in collection of varius interpolation function that can be used for animations in tweens.
]]
--- @class Be2eenApi.Interpolations
Be2eenApi.Interpolations = {}
local I = Be2eenApi.Interpolations;


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.ease_in(t)
	return t ^ 2.0;
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.ease_out(t)
	return 1.0 - sqrt(1.0 - t);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.ease_in_out(t)
	return lerp(I.ease_in(t), I.ease_out(t), t);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.quadratic_in(t)
	return t ^ 2;
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.quadratic_out(t)
	return t * (2.0 - t);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.quadratic_in_out(t)
	return lerp(I.quadratic_in(t), I.quadratic_out(t), t);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.cubic_in(t)
	return t ^ 3;
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.cubic_out(t)
	return 1.0 + ((t - 1.0) ^ 3);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.cubic_in_out(t)
	t = t * 2; if t < 1.0 then return 0.5 * (t ^ 3) end;
	t = t - 2.0; return 0.5 * (t ^ 3 + 2.0);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.quartic_in(t)
	return t ^ 4;
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.quartic_out(t)
	return 1.0 - ((t - 1.0) ^ 4);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.quartic_in_out(t)
	t = t * 2;
	if t < 1.0 then return 0.5 * (t ^ 4); end
	t = t - 2.0;
	return -0.5 * (t ^ 4 - 2.0);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.sinusoidal_in(t)
	return 1.0 - cos(t * pi / 2.0);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.sinusoidal_out(t)
	return sin(t * pi / 2.0);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.sinusoidal_in_out(t)
	return 0.5 * (1.0 - cos(pi * t));
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.circular_in(t)
	return 1.0 - sqrt(1.0 - t * t);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.circular_out(t)
	t = t - 1.0; return sqrt(1.0 - (t * t));
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.circular_in_out(t)
	t = t * 2;
	if t < 1.0 then return -0.5 * (sqrt(1.0 - t * t) - 1.0); end
	t = t - 2.0;
	return 0.5 * (sqrt(1.0 - t * t) + 1.0);
end


--- @param t number
--- @return number
--- @nodiscard
--- @since 1.0
function Be2eenApi.Interpolations.elastic(t)
	return (2.0 ^ -(10.0 * t) * sin((t - 0.1) * (2.0 * pi) / 0.4)) + 1.0;
end

--- -- handlers

minetest.register_chatcommand("be2een", {
	description = ("Be2eenApi : %s made by _gianpy_\n"):format(Be2eenApi.get_version())
		.. "This command grant you to access the varius panels of the library and management functions.\n"
		.. "\n* require no privilege:\n"
		.. "be2een [v | version] -- Will display current version of the package.\n"
		.. "\n* require [debug] privilege:\n"
		.. "be2een list <timer | tween> -- Will display a list of currently running object.\n",

	--- @param name string
	--- @param param string
	func = function(name, param)
		param = param:lower();

		--- get the argouments.
		local argouments = {}
		for s in param:gmatch("[^%s]+") do
			table.insert(argouments, s);
		end

		--- message to display at the end of the command.
		local message = "";

		local panel = nil;
		if #argouments > 0 then panel = argouments[1]; end

		if not panel or panel == "v" or panel == "version" then
			message = ("[be2een] Be2eenApi : %s made by _gianpy_\n"):format(Be2eenApi.get_version());

		elseif not minetest.get_player_privs(name, { debug = true }) then
			message = "[be2een] you need at least [debug] privilege to see this panel.";

		elseif panel == "list" then

			if #argouments <= 1 then
				message = "[be2een] no item to list given.";

			elseif argouments[2] == "timer" then
				if #queue_timer >= 1 then
					message = "[be2een] List of timers currently active:";
					for i, timer in ipairs(queue_timer) do
						message = message ..
						("\n%d [Timer] (%p) : %.3f - %.3f%s"):format(i, timer, timer.duration, timer:get_time_left(),
						timer.loop and " (loop)" or "");
					end
				else
					message = "[be2een] no timers currently running.";
				end

			elseif argouments[2] == "tween" then
				if #queue_tween >= 1 then
					message = "[be2een] List of tweens currently active:";
					for i, tween in ipairs(queue_tween) do
						message = message ..
						("\n%d [Tween] (%p) : %.3f - %.3f%s"):format(i, tween, tween.duration, tween:get_time_left(),
						tween.loop and " (loop)" or "");
					end
				else
					message = "[be2een] no tweens currently running.";
				end

			else
				message = ("[be2een] unknow item '%s' to list."):format(argouments[2]);
			end
		
		else message = ("[be2een] unknow '%s' panel."):format(panel); end

		return true, message;
	end
});


minetest.register_globalstep(function(dtime) --- @param dtime number

	--- process timers.
	for _, timer in ipairs(queue_timer) do
		timer:time_step(dtime);
	end

	--- process tweens.
	for _, tween in ipairs(queue_tween) do
		tween:time_step(dtime);
	end
end);

--- --
