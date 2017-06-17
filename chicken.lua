--License for code WTFPL and otherwise stated in readmes

mobs:register_mob("mobs_mc:chicken", {
	type = "animal",

	hp_min = 4,
	hp_max = 4,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.69, 0.2},
	runaway = true,
	floats = 1,

	rotate = -180,
	visual = "mesh",
	mesh = "chicken.b3d",
	textures = {
		{"chicken.png"},
	},
	visual_size = {x=2.2, y=2.2},

	makes_footstep_sound = true,
	walk_velocity = 1,
	drops = {
		{name = "mobs_mc:chicken_raw",
		chance = 1,
		min = 1,
		max = 1,},
		{name = "mobs:feather",
		chance = 1,
		min = 0,
		max = 2,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	sounds = {
		random = "mobs_chicken",
		death = "Chickenhurt1", -- TODO: replace
		damage = "Chickenhurt1", -- TODO: replace
	},
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},

	follow = {"farming:seed_wheat", "farming:seed_cotton"},
	view_range = 16,

	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 30, 50, 80, false, nil) then return end
	end,

	do_custom = function(self, dtime)

		self.egg_timer = (self.egg_timer or 0) + dtime
		if self.egg_timer < 10 then
			return
		end
		self.egg_timer = 0

		if self.child
		or math.random(1, 100) > 1 then
			return
		end

		local pos = self.object:getpos()

		minetest.add_item(pos, "mobs_mc:egg")

		minetest.sound_play("mobs_mc_chicken_lay_egg", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 16,
		})
	end,	
	
})

-- egg entity

mobs:register_arrow("mobs_mc:egg_entity", {
	visual = "sprite",
	visual_size = {x=.5, y=.5},
	textures = {"mobs_chicken_egg.png"},
	velocity = 6,

	hit_player = function(self, player)
		player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
	end,

	hit_node = function(self, pos, node)

		if math.random(1, 10) > 1 then
			return
		end

		pos.y = pos.y + 1

		local nod = minetest.get_node_or_nil(pos)

		if not nod
		or not minetest.registered_nodes[nod.name]
		or minetest.registered_nodes[nod.name].walkable == true then
			return
		end

		local mob = minetest.add_entity(pos, "mobs_mc:chicken")
		local ent2 = mob:get_luaentity()

		mob:set_properties({
			textures = {"chicken.png"},
			visual_size = {
				x = ent2.base_size.x / 2,
				y = ent2.base_size.y / 2
			},
			collisionbox = {
				ent2.base_colbox[1] / 2,
				ent2.base_colbox[2] / 2,
				ent2.base_colbox[3] / 2,
				ent2.base_colbox[4] / 2,
				ent2.base_colbox[5] / 2,
				ent2.base_colbox[6] / 2
			},
		})

		ent2.child = true
		ent2.tamed = true
		ent2.owner = self.playername
	end
})

-- egg throwing item

local egg_GRAVITY = 9
local egg_VELOCITY = 19

-- shoot egg
local mobs_shoot_egg = function (item, player, pointed_thing)

	local playerpos = player:getpos()

	minetest.sound_play("default_place_node_hard", {
		pos = playerpos,
		gain = 1.0,
		max_hear_distance = 5,
	})

	local obj = minetest.add_entity({
		x = playerpos.x,
		y = playerpos.y +1.5,
		z = playerpos.z
	}, "mobs_mc:egg_entity")

	local ent = obj:get_luaentity()
	local dir = player:get_look_dir()

	ent.velocity = egg_VELOCITY -- needed for api internal timing
	ent.switch = 1 -- needed so that egg doesn't despawn straight away

	obj:setvelocity({
		x = dir.x * egg_VELOCITY,
		y = dir.y * egg_VELOCITY,
		z = dir.z * egg_VELOCITY
	})

	obj:setacceleration({
		x = dir.x * -3,
		y = -egg_GRAVITY,
		z = dir.z * -3
	})

	-- pass player name to egg for chick ownership
	local ent2 = obj:get_luaentity()
	ent2.playername = player:get_player_name()

	item:take_item()

	return item
end

-- egg
minetest.register_craftitem("mobs_mc:egg", {
	description = "Egg",
	inventory_image  = "mobs_chicken_egg.png",
	wield_image = "mobs_chicken_egg.png",
	on_use = mobs_shoot_egg,
})


-- chicken
minetest.register_craftitem("mobs_mc:chicken_raw", {
	description = "Raw Chicken",
	inventory_image = "chicken_raw.png",
	on_use = minetest.item_eat(2),
})

minetest.register_craftitem("mobs_mc:chicken_cooked", {
	description = "Cooked Chicken",
	inventory_image = "chicken_cooked.png",
	on_use = minetest.item_eat(6),
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:chicken_cooked",
	recipe = "mobs:chicken_raw",
	cooktime = 5,
})

-- leather, feathers, etc.
minetest.register_craftitem(":mobs:feather", {
	description = "Feather",
	inventory_image = "mobs_feather.png",
})


--spawn
mobs:register_spawn("mobs_mc:chicken", {"default:dirt_with_grass"}, 20, 8, 17000, 3, 31000)


-- compatibility
mobs:alias_mob("mobs:chicken", "mobs_mc:chicken")

-- spawn eggs
mobs:register_egg("mobs_mc:chicken", "Chicken", "chicken_inv.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC chicken loaded")
end
