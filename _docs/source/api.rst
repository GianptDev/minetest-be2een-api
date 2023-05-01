
Api namespace
=============

Here is everything defined inside the *Be2eenApi* namespace, avaiable after imported.

Functions
---------

.. py:function:: Be2eenApi.get_version()

	Get the current version of the api as a string with 2 dots to separate major number, minor number and release type.

	"[major].[minor].[release]" -- structure of the version
	"1.0.dev" -- example

	:rtype: string
	:since: 1.0

	.. Note::
		* The **dev** release comes from the repository and is intended to be used for development purpose because it may contain experimental functionality.

		* The **stable** release comes from a release that has been tested and is intended for usage purpose.


.. py:function:: Be2eenApi.lerp(x, y, t)

	Get the linear interpolated value between the given points at the given position.

	:param x: The first point.
	:type x: number
	:param y: The second point.
	:type y: number
	:param t: The position in range 0.0 to 1.0
	:type t: number
	:rtype: number


.. py:function:: Be2eenApi.snap (value, snap)

	Will round the given input to the input precision given.

	:param value: the value to snap.
	:type value: number
	:param snap: the size of the snap, should be positive and more than 0 .
	:type snap: number
	:rtype: number


.. py:function:: Be2eenApi.wrap (value, min, max)

	Will clamp the given value between the area (min and max) given, if the value is outside those limit it will snap back from the other side.

	:param value: the value to wrap.
	:type value: number
	:param min: start point when the value wrap after being over max.
	:type min: number
	:param max: final point before the value wrap and start to min again.
	:type max: number
	:rtype: number


.. py:function:: Be2eenApi.get_timers_count ()

	Get the count of how many timers are currently running.

	:rtype: integer


.. py:function:: Be2eenApi.get_tweens_count ()

	Get the count of how many tweens are currently running.

	:rtype: integer


.. py:function:: Be2eenApi.after(duration, callback)

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

Classes
-------

.. py:class:: Timer


.. py:class:: Tween
