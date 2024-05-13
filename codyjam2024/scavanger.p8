pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- scavenger
-- by brandon - music by nathan
--

-- init -------------------------------------------------------------------------
function _init()
	debug = nil


	gameover = false

poke(0x5f5c,255) -- set the btnp to not loop
poke(0x5f5d,255) -- 


title_screen_draw()

set_up()

end



-- _update -------------------------------------------------------------------------
function _update()

	if gameover then
		leave_screen_update()
		return
	end


	if not stat(56) then
		music(0)
	end



	if not stalker_spawned and time()-round_start > 60 then 
		st = stalker:new(pix(6),pix(4),room.first.x,room.first.y)
		add(sprites,st)
		stalker_spawned = true
	end







	-- play track one


	if screen_swipe or ship:update()
		then return end



 -- handle the camera
	set_map_camera()




	-- update the game stats
	take_off_timer:update()

	-- update player movement
	player:move()
	loot:update()

	player:update()

	for s in all(sprites) do
		s:update()
	end
end


--	_draw -------------------------------------------------------------------------
function _draw()
	-- increment the sprite timer
	if gameover then
		leave_screen_draw()
		return
	end



	
	if swipe() or ship:draw() then
		return
	end
	cls()



	-- draw the map
	camera(camera_offset.x,camera_offset.y)
	map()

	room:draw()



	-- draw the sprites
	sprite_timer += 1
	for s in all(sprites) do
		s:draw()
	end



	if debug != nil then
		rectfill(camera_offset.x,camera_offset.y,camera_offset.x+pix(16),camera_offset.y +pix(1),0)
		print(debug,camera_offset.x,camera_offset.y,7)
	end

end




-->8
--updates
--
function get_dir() 
	-- get the direction the player is moving
	x =	0
	y = 0
	if btn(0) then
		x	+= -1
	end
	if btn(1) then
		x += 1
	end
	if btn(2) then
		y += -1
	end
	if  btn(3) then
		y += 1
	end
	return {x,y}
end


function get_tile(x,y)
	-- get the tile at the x,y position
	return mget(flr(x/8),flr(y/8))
end

function is_wall(x,y)
	-- check if the tile is a wall
	return fget(get_tile(x,y),0)
end

function is_door(x,y)
	-- check if the tile is a door
	return fget(get_tile(x,y),1)
end

function is_drop_off(x,y)
	-- check if the tile is a drop off
	return fget(get_tile(x,y),2)
end




-- check where the player location is and deal with it
function set_map_camera()
	-- check if room is 2 
	if room.map[room.y][room.x] == 2 then
		-- draw the room
		if player.x < 200 then
			-- squig
		player.x += outside_map.x*8
		player.y += outside_map.y*8
		camera_offset.x += outside_map.x*8
		camera_offset.y += outside_map.y*8
		return
	end
	else
		camera_offset.x = -24
		camera_offset.y = -16
	end
end


-- loot -------------------------------------------------------------------------
loot = {
	loot_list = { --- loot ids
		{224,225,226,227}, -- 1
		{208},--- 2
		{209}, -- 3
		{210},	-- 4
		{211} -- 5
	}
}

loot.count = 0
loot.last_drop = 0

function loot:drop(amount, save_loot,x,y)
	save_loot = save_loot or false
	_x	= x or player.last_dir[1]*-1 
	_y	= y or player.last_dir[2]*-1 

	amount = amount or 1
	if self.count > 0 and time() - loot.last_drop  > 0.01 then
		self.count -= amount
		-- # create the loot
		if	save_loot then
			score += amount
		else
			l = loot:create(player.x+pix(_x),player.y+pix(_y))
		end
		loot.last_drop = time()
		return true
	end
end



function loot:pickup(amount)
	amount = amount or 1
	self.count += amount
end
function loot:draw(_x,_y)
	print("loot: " .. self.count,_x,_y,7)
end

-- calculate the weight of the player
function loot:update()
	if not player.dashing	then
	player.movement_speed =  ((player.movement_max_speed*10 - self.count)	/ 10)
end
end

-- create loot in x,y
function loot:create(x,y,room_x,room_y,sprite_id)
	sprite_id = sprite_id or (flr(rnd(4))+1)
	s = loot_meta.new(x,y)
	s.active_sprite	= self.loot_list[sprite_id]
	s.room = {}
	s.room.x	=	room_x or room.x
	s.room.y	=	room_y	or room.y
	s.time_drop = time()
	add(sprites,s)
	return s
end



-- check hit box -------------------------------------------------------------------------
function check_hit_box(x1,y1,w1,h1,x2,y2,w2,h2)
	-- check if the two hit boxes are colliding
	if x1 < x2 + w2 and
		x1 + w1 > x2 and
		y1 < y2 + h2 and
		y1 + h1 > y2 then
		return true
	end
	return false
end

function is_player(x,y)
	-- check if the player is at the x,y position
	return check_hit_box(player.x,player.y,player.w,player.h,x,y,8,8)
end




function swipe()


	if screen_swipe then
		screen_swipe_index += 4
		if screen_swipe_index < 8*8 then
			rectfill(camera_offset.x,camera_offset.y+8,camera_offset.x+8 + screen_swipe_index,camera_offset.y + 12*8,0)
			-- from oposite side
			rectfill(camera_offset.x+16*8 - screen_swipe_index,camera_offset.y+8,camera_offset.x+16*8,camera_offset.y + 12*8,0)
			--	from top
			rectfill(camera_offset.x,camera_offset.y+8,camera_offset.x+16*8,camera_offset.y + 8 + screen_swipe_index,0)
			-- from bottom
			rectfill(camera_offset.x,camera_offset.y+12*8 - screen_swipe_index,camera_offset.x+16*8,camera_offset.y + 12*8,0)
		else
			screen_swipe = false
			screen_swipe_index = 0
			set_map_camera()
			room:draw()
		end
	else
		screen_swipe_index = 0
	end

	return screen_swipe
end



function pix(x)
	return x*8
end


function same_room(x,y)
	return room.x == x and room.y == y
end


function set_up()


round_start	= time()


gameover	= false
-- gameover = true
score = 0 

	-- set the sprites array
	sprite_timer = 0
	sprites = {}


	stalker_spawned	= false


-- g = ghost:new(pix(6),pix(4))
-- add(sprites,g)
-- s = spike:new(pix(6),pix(4))
-- add(sprites,s)
-- st = stalker:new(pix(6),pix(4),room.x,room.y)
-- add(sprites,st)



room:init()




add(sprites,stats)



	screen_swipe = false

	-- create the player
	player:init(4*8,4*8)
	player.movement_speed = 1.5
	player.movement_max_speed = 1.5

	loot.count	= 0


	take_off_timer:init()


	-- move the camera 
	camera_offset = {x = -24,y = -16}

	camera(camera_offset.x,camera_offset.y)

	add(sprites,player)
	add(sprites,take_off_timer)

	-- coin = loot:create(2*8,2*8)
	music(0)

	cls()
end













-->8
--classes


-- node class	-------------------------------------------------------------------------
node_metatable = {}
node_metatable.__index = node_metatable

function node_metatable:update()

end
function node_metatable:draw()

end







-- sprites class -------------------------------------------------------------------------

sprite_metatable = {
	x = 0,
	y = 0,
	w = 8,
	h = 8,
	flip = false,
	ani_speed = 15,
	sprites = {240,241},
	active_sprite = {240,241}
}
sprite_metatable.__index = sprite_metatable
setmetatable(sprite_metatable,sprite_metatable)

--	create a new sprite
function sprite_metatable.new(x,y,w,h,flip,ani_speed,sprites)
	local s = {}
	setmetatable(s,sprite_metatable)
	s.x = x
	s.y = y
	s.w = w
	s.h = h
	s.flip = flip
	s.ani_speed = ani_speed
	s.sprites = sprites
	s.active_sprite = sprites
	return s
end

--	draw the sprite
function sprite_metatable:draw()
	spr(self.active_sprite[flr(sprite_timer / self.ani_speed) % #self.active_sprite +1], ceil(self.x), ceil(self.y), self.w/8, self.h/8,self.flip)
end

function sprite_metatable:remove()
	del(sprites,self)
end

function sprite_metatable:update()
end

-- enemy class	-------------------------------------------------------------------------
enemy_meta = {
	x = 0,
	y = 0,
	w = 8,
	h = 8,
	speed	= 0.25,
	active_sprite = {240,241},
	sprites = {240,241},
	health = 1,
	dmg = 1,
	room = {x = 0, y = 0},
	dead = false,
	default_pos = {x = pix(3), y = pix(4)},
	dir = {
		x	= 0,
		y	= 0
	}
}
setmetatable(enemy_meta,sprite_metatable)
enemy_meta.__index = enemy_meta

function enemy_meta:new(x,y,dmg,room_x,room_y,sprites)
	local e = {}
	setmetatable(e,enemy_meta)
	e.x = x
	e.y = y
	e.sprites = sprites or self.sprites
	e.active_sprite = sprites or	self.sprites
	e.dmg	= dmg or self.dmg
	e.room = {}
	e.room.x = room_x or room.x
	e.room.y = room_y or room.y
	e.flip = false
	return e
end

function enemy_meta:update()
	if not same_room(self.room.x,self.room.y) then
		self.x	= self.default_pos.x
		self.y	= self.default_pos.y
		return
	end
	self:move()
	if(is_player(self.x,self.y)) then
		player:hit(self.dmg,self.dir.x,self.dir.y)
	end
	if self.dead then
		self:remove()
	end
end

function enemy_meta:draw()
	if	not same_room(self.room.x,self.room.y) then
		return
	end

	spr(self.active_sprite[flr(sprite_timer / self.ani_speed) % #self.active_sprite +1], ceil(self.x), ceil(self.y), self.w/8, self.h/8,self.flip)
end



function enemy_meta:move()
	if player.x < self.x then
		self.x -= 1*	self.speed
		self.dir.x = -1
	end
	if player.x > self.x then
		self.x += 1*	self.speed
		self.dir.x = 1
	end
	if player.y < self.y then
		self.y -= 1*	self.speed
		self.dir.y = -1
	end
	if player.y > self.y then
		self.y += 1*	self.speed
		self.dir.y = 1
	end
end

-- diffrent types of enenmies

-- ghost class	-------------------------------------------------------------------------
ghost = {
	sprites = {229,230},
	active_sprite = {229,230},
}
setmetatable(ghost,enemy_meta)
ghost.__index = ghost

-- spike ball	class	-------------------------------------------------------------------------

spike = {
	sprites = {213,214},
	active_sprite = {213,214},
	speed = 1.75,
	dir	= {
		x = 1,
		y = 0
	}
}
setmetatable(spike,enemy_meta)
spike.__index = spike

function spike:new(x,y,room_x,room_y)
	local s = {}
	setmetatable(s,spike)
	s.x = x
	s.y = y
	s.default_pos = {x = x, y = y}
	s.room = {}
	s.room.x = room_x or room.x
	s.room.y = room_y or room.y
	return s
end

-- overide the move function
function spike:update()
	if not same_room(self.room.x,self.room.y) then
		return
	end
	self:move()
	if(is_player(self.x,self.y)) then
		player:hit(self.dmg,self.dir.x,self.dir.y)
	end
	if self.dead then
		self:remove()
	end
end

function spike:move()
	if is_wall(self.x + self.dir.x*self.speed ,self.y+ self.dir.y*self.speed)  then
		self.dir.x = self.dir.x *-1
	elseif is_wall(self.x + self.dir.x*self.speed +pix(1) ,self.y+ self.dir.y*self.speed) then
		self.dir.x = self.dir.x *-1
	end

		self.x += self.dir.x * self.speed
end


-- stalker class	-------------------------------------------------------------------------

stalker = {
	idle = {245,246},
	walk = {247,248},
	active_sprite = {247,248},
	speed = 0.4,
	last_room = {x = 0, y = 0},
	last_change = 0,
	dir	= {
		x = 1,
		y = 0
	}
}

setmetatable(stalker,enemy_meta)
stalker.__index = stalker

function stalker:new(x,y,room_x,room_y)
	local s = {}
	setmetatable(s,stalker)
	s.x = x
	s.y = y
	s.room = {}
	s.room.x = room_x or room.x
	s.room.y = room_y or room.y
	return s
end




function stalker:update()

	local same = same_room(self.room.x,self.room.y)

		if time() - self.last_change >3 then
			self.last_change = time()
		end

	if not same then

		if time() - self.last_change < 2 then
			return 
		end

		-- self.last_room.x = self.room.x
		-- self.last_room.y = self.room.y
		dir = {x = 0, y = 0}
		--

		if room.x > self.room.x then
			self.room.x += 1
			dir.x = 1
		elseif room.x < self.room.x then
			self.room.x -= 1
			dir.x = -1
		elseif room.y > self.room.y then
			self.room.y += 1
			dir.y = 1
		elseif room.y < self.room.y then
			self.room.y -= 1
			dir.y = -1
		end

			if same_room(self.room.x,self.room.y) then

					self.x = camera_offset.x + pix(room.w)/2 +	10
					self.y = camera_offset.y + pix(room.h/2) +	10
				if dir.y == 1 then
					self.y = camera_offset.y +	pix(2)
				elseif dir.y == -1 then
					self.y = camera_offset.y + pix(7)
			 elseif dir.x == 1 then
					self.x = camera_offset.x + pix(3)
				elseif dir.x == -1  then
					self.x = pix(7)
				end
			end

			self.last_change = time()
			return
	end


	self:move()
	if(is_player(self.x,self.y)) then
		player:hit(self.dmg,self.dir.x,self.dir.y)
		if loot.count == 0 and not player.invincible	then
			gameover = true
			player.dead = true
		end
	end
	if self.dead then
		self:remove()
	end
end

function stalker:move()
	if player.x < self.x then
		self.x -= 1*	self.speed
		self.dir.x = -1
		self.flip = true
	end
	if player.x > self.x then
		self.x += 1*	self.speed
		self.dir.x = 1
		self.flip = false
	end
	if player.y < self.y then
		self.y -= 1*	self.speed
		self.dir.y = -1
	end
	if player.y > self.y then
		self.y += 1*	self.speed
		self.dir.y = 1
	end
end


function stalker:draw()
	if not same_room(self.room.x,self.room.y) then
		return
	end
	spr(self.active_sprite[flr(sprite_timer / self.ani_speed) % #self.active_sprite +1], ceil(self.x), ceil(self.y), self.w/8, self.h/8,self.flip)
end





-- enemy class	-------------------------------------------------------------------------
enemy ={}
add(enemy,spike)
add(enemy,ghost)

function enemy:create(room_x,room_y)
	local choice = flr(rnd(100) % #enemy) + 1
	
	local e = enemy[choice]:new(pix(3),pix(4)-flr(rnd(16)),room_x,room_y)
	-- e = ghost:new(pix(3),pix(4))
	add(sprites,e)
end
















--- loot item  class	-------------------------------------------------------------------------
loot_meta = {
	x = 0,
	y = 0,
	w = 8,
	h = 8,
	ani_speed = 5,
	active_sprite = {224,225,226,227},
	amount = 1,
	time_drop = 0
}

-- inherit from sprite
setmetatable(loot_meta,sprite_metatable)
loot_meta.__index = loot_meta


function loot_meta.new(x,y,amount, room_x ,room_y, sprites)
	local l = {}
	setmetatable(l,loot_meta)
	l.x = x
	l.y = y
	l.amount = amount or 1
	l.sprites = sprites 
	l.active_sprite = sprites
	l.room = {}
	l.room.x = room_x or	room.x
	l.room.y = room_y or	room.y
	return l
end




function loot_meta:update()

	if self.room.x != room.x or self.room.y != room.y then return end

	if time()	- self.time_drop < 0.5 then return end

	for i = -1,1	do
		for j = -1,1	do
			if is_player(self.x + i,self.y + j) then
				
				loot:pickup(self.amount)
				self:remove()
				return
			end
		end
	end

	if is_player(self.x,self.y) then
		loot:pickup(self.amount)
		self:remove()
	end
end

function loot_meta:remove()
	del(sprites,self)
end

function loot_meta:draw()
	if self.room.x != room.x or self.room.y != room.y then
		return
	end
	spr(self.active_sprite[flr(sprite_timer / self.ani_speed) % #self.active_sprite +1], ceil(self.x), ceil(self.y), self.w/8, self.h/8)
end













-- player class -------------------------------------------------------------------------
--
player = {}

player = sprite_metatable.new(0,0,8,8,false,15,{240,241})
player.movement_speed = 1
player.movement_max_speed = 1.5

player.idle = {240,241}
player.walk = {242,243}
player.dashing = false
player.invincible = false
player.dash_speed = 2
player.dash_time = 0.5
player.dash_cooldown = 2
player.dash_timer = 0
player.hit = false





function player:init(x,y)
	self.movement_speed = 1
	self.movement_max_speed = 1.5

	self.dashing = false
	self.invincible = false
	self.dash_speed = 2
	self.dash_time = 0.5
	
	self.dash_cooldown = 2
	self.dash_timer = 0
	self.x = x
	self.y = y
	self.last_dir = {0,0}
	self.flip = false
	self.dead = false
	self.hitted = false
	self.hit_time = 0
end

function player:update()
	-- check if dash time is over
	if	self.dashing and time() - self.dash_timer > self.dash_time then
		self.dashing = false
		self.invincible = false
	end

	if self.hitted	and time() - self.hit_time > 0.5 and not self.dashing then
		self.hitted	= false
		self.invincible = false
	end




	-- check if action button is pressed
	if btnp(5) then 
		loot:drop(1)
	end
	if btnp(4) then
		self:dash()
	end
end


function player:dash()
	if	time() - self.dash_timer < self.dash_cooldown then return end
	if	self.dashing then return end
	self.dashing = true
	self.movement_speed = self.movement_max_speed *	self.dash_speed
	self.invincible = true
	self.dash_timer = time()
end






function player:move(x,y)
	local dir = get_dir()
	if (x != nil and y != nil) then
		dir = {x,y}
		self.speed = 6
	end

	-- get the future x,y position
	x_to,	y_to = self.x,self.y



	-- the 4 is used to center the sprite i use it instead of a var to save data

	if dir[1] <	0 then
		x_to = self.x + dir[1] * self.movement_speed
	elseif dir[1] > 0 then
		x_to = self.x + dir[1] * self.movement_speed + self.w
	else 
		x_to = self.x + 4
	end

	if	dir[2] <	0 then
		y_to = self.y + dir[2] * self.movement_speed
	elseif dir[2] > 0 then
		y_to = self.y + dir[2] * self.movement_speed + self.h
	else
		y_to = self.y + 4
	end


	-- check for colisions with doors
	if	is_door( x_to,y_to) then
		-- set swipe flag
		screen_swipe = true

		-- check that the dir is not diagonal
		if dir[1] != 0 and dir[2] != 0 then

			t = get_tile(x_to,y_to)
			if t == 4 or t == 5 then
				dir[2] = 0
			else
				dir[1] = 0
			end
		end
		




		-- set the player position to the oposite door
		tile_width = 8
		if dir[1] < 0 then --	left
			self.x = room.w * 8 - self.w -	tile_width
		elseif dir[1] > 0 then	--	right
			self.x = 0 + tile_width
		elseif dir[2] < 0 then	--	up
			self.y = room.h * 8 - self.h -	tile_width
		elseif dir[2] > 0 then --	down
			self.y = 0 + tile_width
		end

		if room.map[room.y][room.x] == 2 then

			-- play the door sound
			-- open the door
			-- play the door open sound
			self.x -=	outside_map.x*8

		end
		--
		-- play the door sound
		-- open the door
		-- play the door open sound

		room:move(dir[1],dir[2])
		return
	end


	if is_drop_off(	x_to,y_to) then
		ship.inside	= true
	end

	-- check for colisions with walls
	if	is_wall( x_to,y_to)  then
		dir = {0,0}
		-- play the wall sound
	end




	--	check if the player is moving
	if dir[1] != 0 or dir[2] != 0 then
		if (self.active_sprite != self.walk) then
			--set the player to the walk animation
			self.active_sprite = self.walk
			self.ani_speed = 5
		end


		self.x += dir[1] *	self.movement_speed
		self.y += dir[2] *	self.movement_speed

		-- prevent coblestoning
		if (dir[1] != 0 and dir[2] != 0) and (self.last_dir[1] != dir[1]  or self.last_dir[2] != dir[2]) then
			self.x = flr(self.x) +0.5
			self.y = flr(self.y) +0.5
		end


		-- set the last direction
		if(dir[1] != 0) then
			self.last_dir[1] = dir[1]
		end
		if(dir[2] != 0) then
			self.last_dir[2] = dir[2]
		end


		-- set the flip
		if self.last_dir[1] == 1 then
			self.flip = false
		elseif self.last_dir[1] == -1 then
			self.flip = true
		end

		-- if the	player is not moving
	else
		-- set the player to the idle animation
		self.active_sprite = self.idle
		self.ani_speed = 15
	end
end

function player:hit(dmg,x,y)
	if not self.invincible then
		self.hitted = true
		self.hit_time = time()
		self.invincible = true



		self:move(x,y)

		if loot.count == 0 then
			return
		end

		for	i = 1, dmg do
			loot:drop(1,false,x,y)
		end
	end
end



-- room class -------------------------------------------------------------------------------
room = {}
room.x = 5
room.y = 7
room.w = 9
room.h = 7
room.first = {x=5,y=7}
room.map =	{
	{0,0,0,0,0,2,0,0,0},
	{0,0,0,0,1,1,0,0,0},
	{0,0,0,0,1,0,0,0,0},
	{0,1,1,1,1,0,0,0,0},
	{0,1,0,0,1,1,1,1,0},
	{0,1,1,1,2,1,0,1,0},
	{0,0,0,0,1,1,0,0,0}
}



outside_map = {}
outside_map.x = 30
outside_map.y = 9



function room:draw()
	-- draw the room
	x = self.x
	y = self.y




	-- set the walls to smooth
	mset(flr(self.w/2),0,1)
	mset(flr(self.w/2),self.h-1,1)
	mset(self.w-1,flr(self.h/2),1)
	mset(0,flr(self.h/2),1)


	-- set the top door
	if  y-1 > 0 then
		if self.map[y-1][x] != 0 then
			mset(flr(self.w/2),0,3)
		end
	end

	-- set the bottom door
	if y+1 <= self.h then
		if self.map[y+1][x] == 1 then
			mset(flr(self.w/2),self.h-1,2)
		end
	end

	--set right door
	if x+1 <= self.w then
		if self.map[y][x+1] == 1 then
			mset(self.w-1,flr(self.h/2),5)
		end
	end

	--	set left door
	if	x-1 > 0 then
		if self.map[y][x-1] == 1 then
			mset(0,flr(self.h/2),4)
		end
	end

	// the last draw call
	
end


function room:move(dir_x,dir_y)
	-- add the x and y to the room
	if self.map[self.y][self.x] == 2 then
		-- add stuff here latter

	end

	self.x += dir_x
	self.y += dir_y
end


-- generate map ---------------------------------------------------------------

-- room = {}
-- room.x = 5
-- room.y = 7
-- room.w = 9
-- room.h = 7
-- room.map =	{
-- 	{0,0,0,0,0,2,0,0,0},
-- 	{0,0,0,0,1,1,0,0,0},
-- 	{0,0,0,0,1,0,0,0,0},
-- 	{0,1,1,1,1,0,0,0,0},
-- 	{0,1,0,0,1,1,1,1,0},
-- 	{0,1,1,1,2,1,0,1,0},
-- 	{0,0,0,0,1,1,0,0,0}
-- }
function room:init()
	-- initialize the map with 0
	local map =	{}
	for i = 1, self.h do
		map[i] = {}
		for j = 1, self.w do
			map[i][j] = 0
		end
	end

	-- randomly select the end	room
		local end_room = {flr(rnd(self.w-1)+2),1}
		map[end_room[2]][end_room[1]] = 2
		-- set the room bellow the end room to 1
		map[end_room[2]+1][end_room[1]] = 1

	-- randomly select the start room
	local start_room = {flr(rnd(self.w)+1),flr(rnd(self.h)+1)}

	if	start_room[1] == end_room[1] and start_room[2] == end_room[2] then
		start_room = {flr(rnd(self.w)+1),flr(rnd(self.h)+1)}
	end

	map[start_room[2]][start_room[1]] = 1

	room.x	= start_room[1]
	room.y	= start_room[2]

	room.touch = false
	
	branch_out(start_room[1],start_room[2], 13,map)


	create_path(start_room[1],start_room[2],end_room[1],end_room[2]+1,map)

	room.first = {x=start_room[1],y=start_room[2]}
	room.map = map


end

-- create a chance to go in a direction
function branch_out(_x,_y ,_r,_map)



	while _r > 0 do
		local x = flr(rnd(room.w)+1)
		local y = flr(rnd(room.h)+1)

		if	_map[y][x] == 0 then
			_map[y][x] = 1
			-- fill_room(x,y)
			_r -= 1
			if rnd(1) > 0.5 then
					loot:create(pix(4),pix(3),x,y)
				end		
			if	rnd(1) > 0.5 then
					enemy:create(x,y)
				end


			-- generate if there is loot
				-- loot:create(pix(4),pix(4),x,y)
				-- make a check and generate rando enemy here in the future
		end --	end of if

	end -- end of while

	-- check each room and see if there is a room that is not connected 
	-- if there is a room that is not connected create a path to it
	
	local connected = false
	for i = 1, room.h do
		for j = 1, room.w do
			if _map[i][j] == 1 then
				connected = false
				-- check if the room is connected
				if i-1 > 0 then
					if _map[i-1][j] == 1 then
						connected = true
					end
				end

				if i+1 <= room.h then
					if _map[i+1][j] == 1 then
						connected = true
					end
				end

				if j-1 > 0 then
					if _map[i][j-1] == 1 then
						connected = true
					end
				end

				if j+1 <= room.w then
					if _map[i][j+1] == 1 then
						connected = true
					end
				end

				if not connected then
					-- find the nearest room
					local nearest_room = find_nearest_room(j,i,_map)
					-- create a path to the nearest room
					create_path(j,i,room.x,room.y,_map)
					
				end
			end
		end
	end
end


-- find nearest room
function find_nearest_room(_x,_y,_map)
	local nearest_room = {0,0}
	local nearest_distance = 1000
	for i = 1, room.h do
		for j = 1, room.w do
			if _map[i][j] == 1 then
				local distance = abs(_x-j) + abs(_y-i)
				if distance < nearest_distance then
					nearest_distance = distance
					nearest_room = {j,i}
				end
			end
		end
	end
	return nearest_room
end

-- create a path from one room to another
function create_path(_x1,_y1,_x2,_y2,_map)
	local x = _x1
	local y = _y1

	while x != _x2 or  y != _y2 do

		if rnd(1) > 0.5  then
			if x < _x2 then
				x += 1
			elseif x > _x2 then
				x -= 1
			end
		else
			if y < _y2 then
				y += 1
			elseif y > _y2 then
				y -= 1
			end
		end

		if	_map[y][x] == 0 then
			_map[y][x] = 1
			if room.x != x and room.y != y then
			
			if rnd(1) > 0.5 then
					loot:create(pix(4),pix(4),x,y)
				end		
			if	rnd(1) > 0.7 then
					enemy:create(x,y)
				end
			end
	end
end


function fill_room(x,y)
		if rnd(1) > 0.9 then
				loot:create(pix(4),pix(4),x,y)
			end		
		-- if	rnd(1) > 0.9 then
		-- 		enemy:create(pix(3),pix(4),x,y)
		-- 	end
		end
end
























-- dungeon timer class ---------------------------------------------------------------

-- time in dungeon  variables
take_off_timer = {}
setmetatable(take_off_timer,node_metatable)
take_off_timer.start_time	= 0
take_off_timer.duration = 120
take_off_timer.start = function()
	take_off_timer.start_time = time()
end

function take_off_timer:init()
	self.elapsed_time = 0
	self.remaining_time = self.duration
	self.start()
end

function take_off_timer:update()
	self.elapsed_time = time() - self.start_time 
	self.remaining_time = self.duration - self.elapsed_time
	if self.remaining_time <= 0 then
		gameover = true
		player.dead	= true

	end
end


-- stats class	-----------------------------------------------------------------------

stats = {}
setmetatable(stats,node_metatable)

function stats:draw()
	_weight = loot.count *5
	_time = take_off_timer.remaining_time
	_score = score
	_x = camera_offset.x
	_y = camera_offset.y
	rectfill(_x,_y,_x+pix(15),_y+pix(2)-6,0)
	rect(_x,_y,_x+pix(15),_y+pix(2)-6,2)

	t = take_off_timer.duration

	-- check	the time
	if _time > t/2	then
		_color = 3 -- green
	elseif _time > t/3 then
		_color = 10	-- yellow
		else
		_color = 8	-- red
	end


	_time = flr(_time/60)..":"..flr(_time % 60)


	print("time to take off: ",_x+ pix(2),_y+3,7)
	print(_time,_x+ pix(11),_y+3,_color)

	


	-- check the weight
	if _weight < 5*5 then
		_color = 3 -- green
	elseif _weight < 5*8 then
		_color = 10	-- yellow
		else
		_color = 8	-- red
	end

  -- draw 
	_y = camera_offset.y + pix(12) +1
	-- draw a rectangle
	rectfill(_x,_y,_x+pix(15),_y+pix(2),0)
	rect(_x,_y,_x+pix(15),_y+pix(2),1)
	-- print the stats
	_y += 6

	print("weight: ".._weight.." lb",_x+ pix(1),_y,_color)
	print("on ship: ".. _score,_x+ pix(9),_y,7)

end


--- ship class -----------------------------------------------------------------------


ship	= {}
setmetatable(ship,node_metatable)

ship.inside = false
ship.index= 0
ship.leave = false


function ship:update()

	if self.leave then
		self.inside = false
		self.leave = false
		self.index = 0
	end



	if self.inside then
		if	btnp(2) then
			self.index +=1
		elseif  btnp(3) then
			self.index -=1
		elseif	btnp(5) then
			self.leave = true
		elseif btnp(4) and self.index == 0 then
			-- add the score
			score += loot.count
			-- reset the loot
			loot.count = 0

			loot:drop(self.amount,true)

			self.inside = false
		elseif btnp(4) and self.index == 1 then
			score += loot.count
			-- reset the loot
			loot.count = 0
			-- drop the loot
			loot:drop(self.amount,true)
			self.leave = true

			gameover =	true
		end

		-- handle the	index
		if	self.index > 1 then
			self.index = 0
		elseif self.index < 0 then
			self.index = 1
		end



	end

	return self.inside
end

function ship:draw()
	if self.inside then
		-- draw rect  8x8
		_x	= camera_offset.x + pix(3)
		_y = camera_offset.y + pix(8)
		_x2 = _x + pix(9)
		_y2 = _y + pix(4)



		rectfill(_x,_y,_x2,_y2,0)
		rect(_x,_y,_x2,_y2,7)

		_y	+= 6

		print("➡️",_x+pix(1),_y+pix(self.index),7)

		print("drop loot",_x+pix(3),_y,7)
		print("leave",_x+pix(3),_y+pix(1),7)
		print("press	❎ to exit",_x+2,_y+flr(pix(2)),7)
	end
	return self.inside
end




--- death / meanu class -----------------------------------------------------------------------

gameover_time = 0

function leave_screen_draw()
	cls()

	local timerstart = time()


	_x = camera_offset.x + pix(3)
	_y = camera_offset.y + pix(8)
	_x2 = _x + pix(9)
	_y2 = _y + pix(6)
	if not stat(56) then
		music(23)
	end
	cls()
	rectfill(_x,_y,_x2,_y2,0)
	rect(_x,_y,_x2,_y2,7)

	_y	+= 6
	if player.dead then
		print("you died",_x+pix(2.5),_y,7)
	else
		print(score.." points",_x+pix(2.5),_y-pix(4),7)
		print("you left",_x+pix(2.5),_y,7)
	end

	print("  🅾️ to continue",_x+2,_y+flr(pix(2)),7)
	print("  ❎ to menue",_x+2,_y+flr(pix(3)),7)
end


function leave_screen_update()
	if gameover_time == 0 then
		gameover_time = time()
	music(23)
	end

	if btnp(4) and time() - gameover_time > 1 then
		set_up()
		reset()
		gameover_time = 0

	elseif btnp(5) and time() - gameover_time > 1 then
		reset()
		title_screen_draw()

		set_up()
		gameover_time = 0
	end

end
	


function title_screen_draw()
	local time_start = time()
	-- set music to play
	music(23)

	local x	= pix(62)
	local y = pix(3)
	camera(x,y)

	local index = 0
	while not btnp(4) do
		_update_buttons()
		index += 1
		if btnp(5) then
			-- exit the game
			extcmd("shutdown")
		end

		if not stat(56) then
			music(23)

		end



		cls()

		circfill(x+pix(12),y+pix(9),pix(2),5)
		circfill(x+pix(4),y+pix(2),pix(2),2)


		map()
		-- rectfill(x+pix(6),y+pix(6),x+pix(11),y+pix(7),0)
		-- print("scavanger",pix(6)+x,pix(6)+y,7)

		-- circ(x+pix(12),y+pix(9),pix(2),7)




		rectfill(x+pix(2),y+pix(12),x+pix(15),y+pix(17),0)


		print("press ❎ to start",pix(2)+x,pix(12)+y,7)
		print("press 🅾️ to exit",pix(2)+x,pix(13)+y,7)
		print("made by brandon carpenter",pix(2)+x,pix(14)+y,7)
		print("music by nathan",pix(2)+x,pix(15)+y,7)
		flip()
	end

	-- reset()
	local timer = time()

	while time() - timer < 3 and not gameover do
		cls()

		circfill(x+pix(12),y+pix(9),pix(2),5)
		circfill(x+pix(4),y+pix(2),pix(2),2)


		map()
		-- rectfill(x+pix(6),y+pix(6),x+pix(11),y+pix(7),0)


		print("❎ drop 🅾️ dash",pix(4)+x,pix(10)+y,7)
		rectfill(x+pix(2),y+pix(12),x+pix(13),y+pix(13.7),0)
		print("return to the ship with",pix(2)+x,pix(12)+y,7)
		print("as much loot as you can",pix(2)+x,pix(13)+y,7)

		-- print("scavanger",pix(6)+x,pix(6)+y,7)

		-- circ(x+pix(12),y+pix(9),pix(2),7)

		flip()
	end
end





__gfx__
00000000000000000000900000440400000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000660606600444044064040406660606000406066000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000000000000404044000000040a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000606660606066606064040046606660400466606000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000404940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007006660666066606660604040406660664a0460666000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000004044044000000400400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000660660606606606064004004660660400406606000000000000000000000000000000000000000000000000000000000000000000000000000000000
32222232322222323244443233333332223333323222223200000000000000000000000000000000000000000000000000000000000000000000000000000000
22323322223233222244442222333322233333322282332200000000000000000000000000000000000000000000000000000000000000000000000000000000
22223223222232232244442322444423333333332898322300000000000000000000000000000000000000000000000000000000000000000000000000000000
3232222232322222324444223244442233333333328222a200000000000000000000000000000000000000000000000000000000000000000000000000000000
22233232222999322244443222444432333333332223323200000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222949222244442222444422333333332222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
32322233323999333444444332444433333333333a32223300000000000000000000000000000000000000000000000000000000000000000000000000000000
23223222232232224444444423444422333333322322322200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000077777000000777770007777777700077000777007777777770077777700000000777770007777777700077777777000000
00000000000000000000000000000077777000000777770007777777700077000777007777777770077777700000000777770007777777700077777777000000
00000000000000000000000000000077777000000777770007777777700077000777007777777770077777700000000777770007777777700077777777000000
22232232222322222322322200000077777000000777770007777777700077000777007777777770077777700000000777770007777777700077777777000000
23223225454444545223223200000077777000000777770007777777700077000777007777777770077777700000000777770007777777700077777777000000
22222244444444444422222200000077777000000777770007777777700077000777007777777770077777700000000777770007777777700077777777000000
32322544411111144452232300000077777000000777770007777777700077000777007777777770077777700000000777770007777777700077777777000000
22222444155555514442222200077700000000777000000007770077700077000777007770007770077700077000777000000007770000000077000777000000
23325441516666151445233200077700000000777000000007770077700077000777007770007770077700077000777000000007770000000077000777000000
22224441561661651444222200077700000000777000000007770077700077000777007770007770077700077000777000000007770000000077000777000000
23232541566116651452323200077700000000777000000007770077700077000777007770007770077700077000777000000007770000000077000777000000
32222441566116651452322300077700000000777000000007770077700077000777007770007770077700077000777000000007770000000077000777000000
22232541566116651442223200077700000000777000000007770077700077000777007770007770077700077000777000000007770000000077000777000000
23224441566116651445222200077777777000777000000007777777700077000777007777777770077700077000777000000007777700000077777000000000
22224541566116651444232200077777777000777000000007777777700077000777007777777770077700077000777000000007777700000077777000000000
22324441566116651454222200077777777000777000000007777777700077000777007777777770077700077000777000000007777700000077777000000000
22225441566116651444223200077777777000777000000007777777700077000777007777777770077700077000777000000007777700000077777000000000
23222441566116651452322200077777777000777000000007777777700077000777007777777770077700077000777000000007777700000077777000000000
32232541566116651442222300077777777000777000000007777777700077000777007777777770077700077000777000000007777700000077777000000000
22322541511111151452232200000000077000777000000007770077700077777777007770007770077700077000777007770007770000000077000777000000
22224441100000011444222200000000077000777000000007770077700077777777007770007770077700077000777007770007770000000077000777000000
23225441100000011445223200000000077000777000000007770077700077777777007770007770077700077000777007770007770000000077000777000000
22222444100000014442222200000000077000777000000007770077700077777777007770007770077700077000777007770007770000000077000777000000
23222544100000014452223200000000077000777000000007770077700077777777007770007770077700077000777007770007770000000077000777000000
32232244100000014422322300000000077000777000000007770077700077777777007770007770077700077000777007770007770000000077000777000000
22222225550000555222222200077777700000000777770007770077700000777000007770007770077700077000777777770007777777700077000777000000
22322322255555522232232200077777700000000777770007770077700000777000007770007770077700077000777777770007777777700077000777000000
00000000000000000000000000077777700000000777770007770077700000777000007770007770077700077000777777770007777777700077000777000000
00000000000000000000000000077777700000000777770007770077700000777000007770007770077700077000777777770007777777700077000777000000
00000000000000000000000000077777700000000777770007770077700000777000007770007770077700077000777777770007777777700077000777000000
00000000000000000000000000077777700000000777770007770077700000777000007770007770077700077000777777770007777777700077000777000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000700000000000000070000000000004000070000000070000000000000000000000000000000000000000000
00000000000000000000000000000000070007000000000000700000000000000404000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000400005551155500000000000000000000000000000000000000000000
00000000000000000000000000000000000808000007000000000000000000700007000007005565565500000000000000000000000000000000000000000000
00000000000000000000000000000000008808800000000000000700000000000000000000005655556500070000000000000000000000000000000000000000
00000000000000000000000000000000008800000000000000000000000000000000000000044444444440000000000000000000000000000000000000000000
00000000000000000000000000000000008088000000000700700000000070000040400000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000080000070000000000000000000000000000000000000070000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007000000007000000000000000000000000070000000008800000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000007000000000000000000000000888888800000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000888888880000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000007000000008888888880000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000070000000000000070000000000000008888888888000000000000000000000000000000000000000000
00000000000000000000000000000000000007000000000000000000000000000000000000008888888888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000088888888888000000000055555555551111111555555555550000
00000000000000000000000000000000000000000000000000000000000000000000000000008888888880000000000055555555551111111555555555550000
00000000000000000000000000000000000000000000000000000000000000000000000000008888888880000000000055555555551111111555555555550000
00000000000000000000000000000000000000000000000000070000000070000000007000000888888800000000000055555556665555555666655555550000
00000000000000000000000000000000000000000000000000000000000000000000000000000088888000000000000055555556665555555666655555550000
00000000000000000000000000000000000000000000000000000000000000000000000000000088888000000000000055555556665555555666655555550000
00000000000000000000000000000000000000700000000000000000000000000000000000000008880000000000000055555556665555555666655555550000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055566665555555555555566655550000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055566665555555555555566655550000
00000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000055566665555555555555566655550000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444444444444444444444444444444440
00000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000444444444444444444444444444444444440
00000000000000000000000000000000000000000000000000007000000000000000700000000000000000000000444444444444444444444444444444444440
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000700070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000660000000000000000000000000000000005050050000005005000000000000000000000000000000000000000000000000000000000000000000000000
00000666066660000000000000008880000000000500500005050050000000000000000000000000000000000000000000000000000000000000000000000000
0000666606116000000dd00000008c80000000000052250550522505000000000000000000000000000000000000000000000000000000000000000000000000
00066600061160000dd99dd00888888000000000002a9250002a9200000000000000000000000000000000000000000000000000000000000000000000000000
00666000055550000dd99dd008998000000000000029a2000529a250000000000000000000000000000000000000000000000000000000000000000000000000
66660000056650000222222008998000000000005052250050522505000000000000000000000000000000000000000000000000000000000000000000000000
66600000055550000000000008888000000000000505005000050050000000000000000000000000000000000000000000000000000000000000000000000000
06600000000000000000000000000000000000000000500500500500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000007000000070000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000070000700700000000000000000000000000000000000000000000000000000000000000000000000000
000aa000000aa0000000a000000aa000000000000700c0700700c070000000000000000000000000000000000000000000000000000000000000000000000000
00a98a00000aa0000000a000000aa000000000000000007000070000000000000000000000000000000000000000000000000000000000000000000000000000
00a89a00000aa0000000a000000aa000000000000070700007007070000000000000000000000000000000000000000000000000000000000000000000000000
000aa000000aa0000000a000000aa000000000000700070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000070007007007070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000707070700070007000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660000501600005016000000000000000000000088000050280000502800000000000000000000000000000000000000000000000000000000000
00066000000110000001100007011000000000000008800000022000000220000802200000000000000000000000000000000000000000000000000000000000
00011000000110000501100005011000000000000002200000000000050200000502000000000000000000000000000000000000000000000000000000000000
01011010000110000001100007011010000000000200002000022000000220000802202000000000000000000000000000000000000000000000000000000000
00011000010110100501101005011000000000000002200002022020050220200502200000000000000000000000000000000000000000000000000000000000
00000000000000000000000000500000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000
00500500005005000050050000005000000000000050050000500500005005000000500000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000700000000222222222222200700000000000000000000000700000000000000000000000000000000000000000000000000000000000000
00070000000000000000000022272222222222222000000000070000000000000000000000070000000000000000000000070000000000000007000000070000
00000000000070000000000222222222222272222200000000000000000070000000000000000000000070000000000000000000000070000000000000000000
00000000000000000000022222222222222222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000222222222222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000700000000000000722222222722222222222222700000000700000000000000700000000700000000000000000000000700000000000000070000000700
00000000000000000002222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022222222222222222222222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022222222222222222222222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000222222222222222222222222222222200000000000700000000000000000000000000000000000000000000000000000000000000000000
00070000000700000222722222222222222722222222722200070000000000000000700000000000000700000000700000000000000700000000000000000000
00000000000000000222222222222222222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002222222222222222222222222222222220000000000007000000000000000000000000000000000000000000000000000000000000000000
00000000000000002222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002222222222222222227222222222222220000000000000000000000000700000000000000000000000000000000000000000000000000000
00000000000000002222222222222222222222222222222220000000000700000000000000000000000000000000000000000000000000000000000000000000
00000000000000002222722222222222222222222222722220000000000000000000700000000000000000000000700000000000000000000000000000000000
00000000000070000222222222222222222227222222222200000000000000000000000000000700000070000000000000000000000070000000000000000000
00000000000000000222222222222222222222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
00700000000000000222222222722222227222222222222200700000000007000000000000700000000000000000000000700000000000000070000000700000
00000000000000000022222222222222222222222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022227777722222277777222777777770007700077700777777777007777770000000077777000777777770007777770000000000000000
00700000000000000002227777722222277777222777777770007700077700777777777007777770000000077777000777777770007777770000000000000000
00000000000000000000227777722222277777222777777770007700077700777777777007777770000000077777000777777770007777770000000000000000
00000000000070000000227777722222277777222777777770007700077700777777777007777770000000077777000777777770007777770000000000000000
00000700000000000007772222222277722222222777007770007700077700777000777007770007700077700000000777000000007700070000000000007000
00000000000000000007770222222277722222222777007770007700077700777000777007770007700077700000000777000000007700070000000000000000
00700000000000000007770022222277722222222777007770007700077700777000777007770007700077700000000777000000007700070070000000000000
00000000000000000007770000222277722222200777007770007700077700777000777007770007700077700000000777000000007700070000000000000000
00000000000000000007770000000277722200000777007770007700077700777000777007770007700077700000000777000000007700070000000000000000
00000000000000000007770000000077700000000777007770007700077700777000777007770007700077700000000777000000007700070000000000000000
00000000000000000007777777700077700000000777777770007700077700777777777007770007700077700000000777770000007777700000000000000000
00000000000070000007777777700077700000000777777770007700077700777777777007770007700077700000000777770000007777700000700000000070
00007000000000000007777777700077700000000777777770007700077700777777777007770007700077700000000777770000007777700000000000000000
00000000000000000007777777700077700000000777777770007700077700777777777007770007700077700000000777770000007777700000000000000000
00000000000000000007777777700077700000000777777770007700077700777777777007770007700077700000000777770000007777700000000000000000
00000000000000000007777777700077700000000777777770007700077700777777777007770007700077700000000777770000007777700000000000000000
00000000000000000000000007700077700000000777007770007777777700777000777007770007700077700777000777000000007700070000000000000000
00000000000000000000000007700077700000000777007770007777777700777000777007770007700077700777000777000000007700070000000000000000
00070000000000000000000007700077700000000777007770007777777700777000777007770007700077700777000777000000007700070000000000000000
00000000000070000000000007700077700000000777007770007777777700777000777007770007700077700777000777000000007700070000700000000000
00000000000000000000000007700077700000000777007770007777777700777000777007770007700077700777000777000000007700070000000000007000
00000000000000000000000007700077700000000777007770007777777700777000777007770007700077700777000777000000007700070000000000000000
00000700000000000007777770000000077777000777007770000077700000777000777007770007700077777777000777777770007700070000000000000000
00000000000000000007777770000000077777000777007770000077700000777000777007770007700077777777000777777770007700070000000000000000
00000000000000000007777770000000077777000777007770000077700000777000777007770007700077777777000777777770007700070000000000000000
00000000000000000007777770000000077777000777007770000077700000777000777007770007700077777777000777777770007700070000000000000000
00000000000000000007777770000000077777000777007770000077700000777000777007770007700077777777000777777770007700070000000000000000
00007000000700000007777770000000077777000777007770000077700000777000777007770007700077777777000777777770007700070000700000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000055555555551111111555555555550000000000000000055555550000000000000000000000000000
00000000000000000700000007000000000000000000000055555555551111111555555555550000000000000055555555555550070000000000000000000000
00000700000000000000000000000000000000000000000055555555551111111555555555550000000700005557555555555555500000000000070000070000
00000000000070000000000000000000000070000000000055555556665555555666655555550000000000055555555555557555550000000000000000000000
00000000000000000000000000000000000000000000000055555556665555555666655555550000000005555555555555555555555500000000000000000000
00070000000000000000000000000000000000000000000055555556665555555666655555550000000055555555555555555555555550000007000000000000
00000000000000000000700000007000000000000000000055555556665555555666655555550000000057555555575555555555555570000000000000000700
00000000000000000000000000000000000000000000000055566665555555555555566655550000000555555555555555555555555555000000000000000000
00000000000000000000000000000000000000000000000055566665555555555555566655550000005555555555555555555555555555500000000000000000
00000000070000000000000000700000000000000000000055566665555555555555566655550000005555555555555555555555555555500700000000000000
00000000000000000000070000000000000700000000444444444444444444444444444444444440055555555555555555575555555555550000000000000000
00000070000000000000000000000000000000000000444444444444444444444444444444444440055555555555555555555555555575550000000000000000
00000000000000000000000000000700000000000000444444444444444444444444444444444440055555555555555555555555555555550000000000000000
00000000000000000007000000000000000000000000000000000000000000000000000000000000555555555555555555555555555555555000000000000000
00000000000070000000000000700000000007000000000000000000000000000000000000000000555555555555555555555755555555555000700000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555555555555555555555000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555555555555555555555000000000000000
00000000000000000000000000700000000000000000000000000000070000000000000000000000575555555555555555555555555555555000000000000000
00000700000000000000000000000000000000000007000000000000000000000007000000000000555555555555555555555555555555555000000000000000
00000000000070000000007000000000000070000000000000007000000000000000000000007000555555555555555555555555555755555000700000000000
00000000000000000000000000000700000000000000000000000000000000000000000000000000055555555555555555555555555555550000000000000000
00070000000000000000000000000000000000000000000000000000000000000000000000000000055555555555555555555555555555550000000000000000
00000000000000000000000000700000000000000000070000000000000070000000070000000000055575555575555555555555555555550000000000700000
00000000000000000000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555500000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555500000000000000000
00000000000000000000000000000000000000000700000000000000000000000000000007000000000555555555555555555555575555000000000000000000
00000000000000000000000000070000000000000000000000000700000700000000000000000000000057555557555555555555555550000000070000070000
00000070000070000000000000000000000070000000000000000000000000000000700000000000000055555555555555557555555550000000000000000000
00000000000000000000700000000000000000000000000000000000000000000000000000000000000005555555555555555555555500000000000000000000
00000000000000000000000000000000000000000000000000070000000000000000000000000000000700055555555555555555550000000007000000000000
00000000000000000000000000000700000000000000700000000000000007000000000000007000000000005555575555555555500070000000000000000700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555555550000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555550000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000
00000000000000000000700000000000000700000000700000000070000000000007000000007000000000700000000000070000000070000000007000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770777077700770077000000777770000007770077000000770777077707770777000000000000000000000000000000000000000000000
00000000000000007070707070007000700000007707077000000700707000007000070070707070070000000000000000000000000000000000000000000000
00070000000000007770770077007770777000007770777000000700707000007770070077707700070000000000000000000000000000000000000000000700
00000000000070007000707070000070007000007707077000000700707000000070070070707070070000000000000000000000000000000000000000000000
00000000000000007000707077707700770000000777770000000700770000007700070070707070070000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000
00000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770777077700770077000000777770000007770077000007770707077707770000000000000000000000000000000000000000000000000
00000000000000007070707070007000700000007700077000000700707000007000707007000700000000000000000000000000000000000000000007000000
00000700000700007770770077007770777000007707077000000700707000007700070007000700000000000000000000000000000000000000000000000000
00000000000000007000707070000070007000007700077000000700707000007000707007000700000000000000000000000000000000000000000000000000
00000000000000007000707077707700770000000777770000000700770000007770707077700700000000000000000000000000000000000000000000000000
00070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770777077007770000077707070000077707770777077007700077077000000077077707770777077707700777077707770000000000000
00000000000000007770707070707000000070707070000070707070707070707070707070700000700070707070707070007070070070007070000000000000
00000000000000007070777070707700000077007770000077007700777070707070707070700000700077707700777077007070070077007700000000000000
00000070000000007070707070707000000070700070000070707070707070707070707070700000700070707070700070007070070070007070000000007000
00000000000000007070707077707770000077707770000077707070707070707770770070700000077070707070700077707070070077707070000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770707007707770077000007770707000007700777077707070777077000000000000000000000000000000000000000000000000000000
00000000000000007770707070000700700000007070707000007070707007007070707070700000000000000000000000000000000000000000000000000000
00000000000000007070707077700700700000007700777000007070777007007770777070700000000000000000000000000000000000000000000000000000
00000000000000007070707000700700700000007070007000007070707007007070707070700000000000000000000000000000000000000000000000007000
00007000000000007070077077007770077000007770777000007070707007007070707070700000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0101030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010103010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009596979895969798959697989596979895969798959697a5a6a7a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010606060606060601000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a5a6a7a8a5a6a7a8a5a6a7a8a5a6a7a8a5a6a7a8a5a6a7b5b6b7b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010606060606060601000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b5b6b7b8b5b6b7b8b5b6b7b8b5b6b7b8b5b6b7b8b5b6b7959697980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04060606060606060500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000095a697a7a695a7979596979596979596a5959695959697a5a6a7a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010606060606060601000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a5a6a7a8a6a6a6a7a5a6a7a69596a5a6a7a5a6a5a5a6a7b5b6b7b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010606060606060601000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a6b6b7b8b8b5b6b7b586b7b5959686b6b7b5b6b5b5b6b7959697980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010201010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a5a6a7a8a686a7434445464748494a4b4c4d4eb5b6b7b8a5a6a7a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b5b6b7b8b5b6b7535455565758595a5b5c5d5ea7a89697b5b6b7b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000010101010000000000000000000000000000000000000000000a5a6a7a8a79596636465666768696a6b6c6d6eb7b8a6a7959697980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000101011101015101000000000000000000000000000000000000000b5b6b7b8b5a7a6737475767778797a7b7c7d7ea7b5b6b7a5a6a7a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000010101410404142101410000000000000000000000000000000000000a5a6a7a89798969797b7abacadaeaf9595969798959697b5b6b7b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000010151310505152101210000000000000000000000000000000000000b5b6b7b8a7a897988695bbbcbdbebfa5a5959697a5a6a7959697980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000101210606162101110000000000000000000000000000000000000959697989798a7a88696959697959697b5a5a6a7b5b6b7a5a6a7a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000101010101010151000000000000000000000000000000000000000a5a6a7a8a7a8b7b8959697989596979895969798959697b5b6b7b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000010111010100000000000000000000000000000000000000000b5b6b7b897989596a5a6a7a8a5a6a7a8a5a6a7a8959697959697980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000010101010102010101010100000000000000000000000000000000000095969798959697a5b6b7b8b5b6b7b8b5b6b7b898a6a7a5a6a7a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000010101010101010101010100000000000000000000000000000000009596959697989596979895969798959697989596979895969798b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000001010101010101010101010000000000000000000000000000000000a5a6a5a6a7a8a5a6a7a8a5a6a7a8a5a6a7a8a5a6a7a8a5a6a7a8980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000001010101010101010101010000000000000000000000000000000000b5b6b5b6b7b8b5b6b7b8b5b6b7b8b5b6b7b8b5b6b7b8b5b6b7b8a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b5b6b7b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000500001606016060160601606013060130601306013060120601206012060120601206012060120601206022060220602206022060000000000000000000001606016060160601606013060130601306013060
900500001615016150161501615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
900500001165511655116551165500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000a0500a050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001206012060120601206012060120601206012060110501105011050110501105011050110501105012050120501205012050120501205000000000001606016060160601606013060130601306013060
000500001206012060000000000012060120600000000000220602206022060220601306013060130601306012060120600000000000120601206000000000002206022060220602206013060130601306013060
000500001206012060000000000012060120600000000000220602206022060220601b0601b0601b0601b06016060160601606016060130601306013060130601206012060120601206012060120601206012060
00050000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0500a0500000000000090500905000000000000a0500a050090500905000000000000000000000
000500002206022060220602206000000000000000000000160601606016060160601306013060130601306012060120601206012060120601206012060120602206022060220602206021060210602106021060
900500000c6550c6550c6550c65500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c6550c6550c6550c65500000000000000000000
000500000a0500a0500000000000000000000000000000000a0500a0500000000000090500905000000000000a0500a0500905009050000000000000000000000a0500a0500f0500f05000000000000e0500e050
00050000220602206022060220601e0601e0601e0601e0602106021060210602106024060240602406024060220602206022060220601c0601c0601c0601c0601606016060160601606010060100601006010060
900500000c6550c6550c6550c6550000000000000000000000000000000000000000000000000000000000000c6550c6550c6550c655000000000000000000000000000000000000000000000000000000000000
000500000d0500d05000000000000a0500a0500000000000090500905000000000000b0500b05000000000000a0500a050000000000000000000000000000000100501005000000000000d0500d0500000000000
00050000130601306013060130601c0601c0601c0601c06016060160601606016060220602206022060220601c0601c0601c0601c0601f0601f0601f0601f0602205022050220502205023050230502305023050
9005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b1502b1502b1502b1502e1502e1502e1502e1502f1502f1502f1502f150
900500000000000000000000000000000000000000000000000000000000000000000c6550c6550c6550c65500000000000000000000000000000000000000000c6550c6550c6550c65500000000000000000000
00050000000000000000000000000a0500a0500000000000000000000000000000000a0500a05000000000000d0500d05000000000000c0500c05000000000000b0500b050000000000009050090500000000000
900500002e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e150
90050000000000000000000000000000000000000000000000000000000000000000000000000000000000000c6550c6550c6550c655000000000000000000000000000000000000000000000000000000000000
000500000a0500a0500000000000090500905000000000000a0500a0500905009050000000000000000000000a0500a0500000000000000000000000000000000a0500a050000000000009050090500000000000
0005000012060120601206012060120601206012060120602206022060220602206021060210602106021060220602206022060220601e0601e0601e0601e0602106021060210602106024060240602406024060
900500002d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d150
9005000000000000000000000000000000000000000000000c6550c6550c6550c655000000000000000000000c6550c6550c6550c655000000000000000000000000000000000000000000000000000000000000
000500000a0500a0500905009050000000000000000000000a0500a0500f0500f05000000000000e0500e0500d0500d05000000000000a0500a0500000000000090500905000000000000b0500b0500000000000
900500003015030150301503015030150301503015030150301503015030150301503015030150301503015030150301503015030150301503015030150301503015030150301503015030150301503015030150
90050000116551165511655116550000000000000000000000000000000000000000000000000000000000000c6550c6550c6550c655000000000000000000000000000000000000000000000000000000000000
0005000012060120601206012060120601206012060120602206022060220602206021060210602106021060220602206022060220601e0601e0601e0601e060210602106021060210601e0601e0601e0601e060
9005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a1502a1502a1502a1502d1502d1502d1502d1502a1502a1502a1502a150
900500002715027150271502715027150271502715027150271502715027150271502715027150271502715027150271502715027150271502715027150271502515025150251502515025150251502515025150
9005000025150251502515025150251502515025150251502815028150281502815028150281502815028150281502815028150281501e1501e1501e1501e1501f1501f1501f1501f1501e1501e1501e1501e150
000500001606016060160601606013060130601306013060120601206012060120601206012060120601206016060160601606016060000000000000000000001606016060160601606013060130601306013060
900500001f1501f1501f1501f1501f1501f1501f1501f15022150241502515027150291502a1502d1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e150
900500001165511655116551165500000000000000000000116551165511655116550000000000000000000011655116551165511655000000000000000000001165511655116551165500000000000000000000
000500000c0500c050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0500a050000000000009050090500000000000
000500001206012060120601206012060120601206012060220602206022060220600000000000000000000016060160601606016060130601306013060130601206012060120601206012060120601206012060
900500002e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502e1502d1502d1502d1502d1502d1502d1502d1502d1502d150
9005000000000000000000000000000000000000000000000c6550c6550c6550c6550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000a0500a0500905009050000000000000000000000a0500a0500000000000000000000000000000000a0500a0500000000000090500905000000000000a0500a050090500905000000000000000000000
000500002206022060220602206021060210602106021060220602206022060220601e0601e0601e0601e06021060210602106021060240602406024060240601606016060160601606013060130601306013060
900500002d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d1502d150301503015030150301503015030150301503015030150
900500000c6550c6550c6550c655000000000000000000000c6550c6550c6550c6550000000000000000000000000000000000000000000000000000000000001165511655116551165500000000000000000000
000500000a0500a0500f0500f05000000000000e0500e0500d0500d05000000000000a0500a0500000000000090500905000000000000b0500b05000000000000a0500a050000000000009050090500000000000
900500003015030150301503015030150301503015030150301503015030150301503015030150301503015030150301503015030150301503015030150000000000000000000000000000000000000000000000
000500002206022060220602206021060210602106021060220602206022060220601e0601e0601e0601e060210602106021060210601e0601e0601e0601e0601606016060160601606013060130601306013060
9005000000000000000000000000000000000000000000000000000000000002a1502a1502a1502a1502d1502d1502d1502d1502a1502a1502a1502a150271502715027150271502715027150271502715027150
900500002715027150271502715027150271502715027150271502715027150271502715027150271502515025150251502515025150251502515025150251502515025150251502515025150251502515024150
900500002415024150241502415024150241502415024150241502415024150211502115021150211502115021150211502115021150211502115021150221502215022150221500000000000000000000000000
900500000c6550c6550c6550c655000000000000000000000c6550c6550c6550c6550000000000000000000000000000000000000000000000000000000000000c6550c6550c6550c65500000000000000000000
000500000a0500a0500f0500f05000000000000e0500e0500d0500d05000000000000a0500a0500000000000090500905000000000000b0500b05000000000000a0500a050000000000000000000000000000000
0005000012060120601206012060120601206012060120602206022060220602206000000000000000000000220602206022060220601c0601c0601c0601c0601606016060160601606010060100601006010060
90050000000000000000000000000000000000000002215022150221502215000000000000000000000221502215022150221500000000000000000000000000000000000000000000000000000000000001f150
0005000000000000000000000000000000000000000000000a0500a0500000000000000000000000000000000a0500a0500000000000000000000000000000000000000000000000000000000000000000000000
00050000130601306013060130601c0601c0601c0601c06016060160601606016060220602206022060220601c0601c0601c0601c0601f0601f0601f0601f0602205022050220502205026050260502605026050
900500001f1501f1501f150000000000000000000000000000000000000000022150221502215022150000000000000000000001f1501f1501f1501f150221502215022150221500000000000000000000000000
000500000000000000000000000000000000000000000000000000000000000000000a0500a050000000000000000000000000000000000000000000000000000a0500a050000000000000000000000000000000
0005100024060240602406024060220602206022060220601c0601c0601c0601c0601906019060190601906001400014000140001400014000140001400014000140001400014000140001400014000140001400
900507000000000000000001615016150161501615001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400
90050800000000000000000000000c6550c6550c6550c655014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400
00050600000000000000000000000a0500a0500140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400
0060000004060040600606006060000000406004060070600706000000050600506008060080600806004060040600a0600a0600a060040600406006060060600000004060040600706007060000000506005060
006000001706017060160601606000000170601706019060190600000016060160601706015060160601306013060140601406011060130601006010060120601206000000100601006013060130600000011060
00601c0008060080600806004060040600a0600a0600a06000000000000606006060000000000000000070600706000000050600506008060080600806000000000000a0600a0600a06001400014000140001400
00601f001106014060140601406010060100601406014060110601306010060100601206012060000001006010060130601306000000110601106014060140601406010060100601406014060110601306001400
__music__
01 00010203
00 04404040
00 05404040
00 06404007
00 0840090a
00 0b400c0d
00 0e0f1011
00 00121314
00 15161718
00 00191a14
00 1b1c1718
00 001d1a14
00 151e1718
00 1f202122
00 23242526
00 2728292a
00 232b2526
00 2c2d292a
00 232e2526
00 272f3031
00 32331734
00 35361037
02 38393a3b
01 3c3d4040
02 3e3f4040

