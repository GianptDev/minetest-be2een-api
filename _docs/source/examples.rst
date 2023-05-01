
Examples
========

* quick way to call a function after some time:

.. code-block:: lua

	Be2eenApi.after(3.0, function (timer)
		minetest.chat_send_all("Hello everybody!");
	end);

* create a timer that after finishing it will enable loop and change his callback function:

.. code-block:: lua

	-- create the timer object
	local timer = Be2eenApi.Timer();

	timer.onStart = function (timer)
		minetest.chat_send_all(
			("See you after %.2f seconds..."):format(timer:get_time_left()));
	end

	-- set function to trigger when finished
	timer.onFinish = function(timer)
		minetest.chat_send_all("I just finished ! But now I will start again..");

		-- you can change the timer events...
		timer.onFinish = function (timer)
			minetest.chat_send_all("..and again");
		end

		-- ...and properties anywhere!
		timer.loop = true;
		timer:reset(1.0);
	end

	-- start the timer for the given amount of seconds
	timer:play(3.0);

* when a player joins it will, after 1 second, create an animated label that moves on the screen.

.. code-block:: lua

	local players = {};

	minetest.register_on_joinplayer(function (player)

		-- wait 1 second before creating the animation
		Be2eenApi.after(1.0, function ()

			-- make sure the player is still online
			if not minetest.get_player_by_name(player:get_player_name()) then return; end

			-- make animation object
			local tween = Be2eenApi.Tween();
			tween.loop = true; -- make the animation loop
			tween.pingpong = true; -- make the animation reverse
			tween.intepolation = Be2eenApi.Interpolations.elastic; -- not using boring linear animation.
			tween.duration = 4.0;

			-- create label to animate
			local id = player:hud_add({
				hud_elem_type = "text",
				offset = { x = 32, y = 120 },
				text = "Tween"
			});

			-- update animation each step
			function tween:onStep ()
				player:hud_change(id, "offset", {

					-- the property we are animating.
					x = self:get_animated(32, 300),
				
				y = player:hud_get(id).offset.y });
			end

			-- make sure to remove label
			function tween:onStopped ()
				player:hud_remove(id);
			end

			-- add animation object to list,
			-- it will be used to stop the animation when the player leave.
			players[player:get_player_name()] = tween:start();
		end);

	end);

	minetest.register_on_leaveplayer(function (player)
		local plr = player:get_player_name();

		-- just to be 100% sure
		if players[plr] then
			players[plr]:stop();
			players[plr] = nil;
		end
	end);

