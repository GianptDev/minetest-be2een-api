
Api namespace
=============

Here is everything defined inside the *Be2eenApi* namespace, avaiable after imported.

Functions
---------

.. lua:function:: Be2eenApi.get_version()

	Get the current version of the api as a string with 2 dots to separate major number, minor number and release type.

	The structure of the string is `[major].[minor].[release]` example: `1.0.dev`

	:rtype: string

	.. Note::
		* The **dev** release comes from the repository and is intended to be used for development purpose because it may contain experimental functionality.

		* The **stable** release comes from a release that has been tested and is intended for usage purpose.


.. lua:function:: Be2eenApi.lerp(x, y, t)

	Get the linear interpolated value between the given points at the given position.

	:param x: The first point.
	:type x: number
	:param y: The second point.
	:type y: number
	:param t: The position in range 0.0 to 1.0
	:type t: number
	:rtype: number


.. lua:function:: Be2eenApi.snap (value, snap)

	Will round the given input to the input precision given.

	:param value: the value to snap.
	:type value: number
	:param snap: the size of the snap, should be positive and more than 0 .
	:type snap: number
	:rtype: number


.. lua:function:: Be2eenApi.wrap (value, min, max)

	Will clamp the given value between the area (min and max) given, if the value is outside those limit it will snap back from the other side.

	:param value: the value to wrap.
	:type value: number
	:param min: start point when the value wrap after being over max.
	:type min: number
	:param max: final point before the value wrap and start to min again.
	:type max: number
	:rtype: number


.. lua:function:: Be2eenApi.get_timers_count ()

	Get the count of how many timers are currently running.

	:rtype: integer


.. lua:function:: Be2eenApi.get_tweens_count ()

	Get the count of how many tweens are currently running.

	:rtype: integer


.. lua:function:: Be2eenApi.after(duration, callback)

	Will create a timer with the given duration and callback to call after the coutdown, is the same as doing the following:

	.. code:: lua

		local timer = Be2eenApi.Timer();
		timer.onFinished = callback;
		timer:start(duration);

	This function does the same thing as `minetest.after()` but using the api functionality instead.

	:param duration: Time in seconds to wait before calling the callback.
	:type duration: number
	:param callback: The function to call as a callback after the timer finishes.
	:type callback: function
	:rtype: Timer


.. lua:function:: Be2eenApi.animate(start, finish, time, callback)

	Will create a tween to animate the value in between of the start and finish in the given time calling each step the callback, is the same as doing:

	.. code:: lua

		local tween = Be2eenApi.Tween();
		tween.duration = time;
		tween.onStep = function(tween, value)
			callback(tween, Be2eenApi.lerp(start, finish, value));
		end
		tween:start();
	
	:param start: Starting point of the animation.
	:type start: number
	:param finish: Final point of the animation.
	:type finish: number
	:param time: Amount of time in seconds wich the animation will elapse.
	:type time: number
	:param callback: Function to call each step of the animation.
	:type callback: function(tween: Tween, value: number)
	:rtype: Tween

Classes
-------


