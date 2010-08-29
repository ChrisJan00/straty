-- Onoroubos
-- Copyright 2009-2010 Christiaan Janssen, December 2009 - January 2010
--
-- This file is part of Onoroubos.
--
--     Onoroubos is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
--
--     Onoroubos is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
--
--     You should have received a copy of the GNU General Public License
--     along with Onoroubos.  If not, see <http://www.gnu.org/licenses/>.

Soldiers = {}

function Soldiers.generate_list( Group, n )
	Group.list = {}
	for i=1,n do
		local px,py = 100+math.random(50),100+math.random(50)
		Group.list[i] =
		{
			pos = {px,py},
			look_dir = {0,1}, -- down
			walk_dir = {0,0}, -- stopped
			destination = {px,py},
			speed = 100 + math.random(50),
			status = Cte.states.standing, -- standing
			min_distance = 16,

			-- graphics
			image = Soldiers.random_sprite(),
			frame = 0,
			animation_timer = 0,
			animation_delay = 0.15, -- seconds
			livecolor = Sprites.warlordColor,

			-- stats
			stats = {
				max_hp = 10,
				hp = 10,
				attack = 3,
				defense = 2,
				speed = 10,
				range = 16,
			},

			-- timers
			death_timer = 5,
			attack_timer = 0,

			-- pointers
			mygroup  = Group
		}

	end

	Group.count = table.getn(Group.list)

end

function Soldiers.load()
end

function Soldiers.random_sprite()
	local sn = math.random(15)

	if sn==1 then return Sprites.graphics.barbarian end
	if sn==2 then return Sprites.graphics.bandit end
	if sn==3 then return Sprites.graphics.bandit2 end
	if sn==4 then return Sprites.graphics.bowman_she end
	if sn==5 then return Sprites.graphics.magician_she end
	if sn==6 then return Sprites.graphics.bowman end
	if sn==7 then return Sprites.graphics.magician end
	if sn==8 then return Sprites.graphics.knight end
	if sn==9 then return Sprites.graphics.paladin end
	if sn==10 then return Sprites.graphics.warrior_she end
	if sn==11 then return Sprites.graphics.warrior end
	if sn==12 then return Sprites.graphics.pirate end
	if sn==13 then return Sprites.graphics.necromancer end
	if sn==14 then return Sprites.graphics.necromancer_lord end
	if sn==15 then return Sprites.graphics.monk end
end


function Soldiers.update(dt)
	Soldiers.update_group(Soldiers, dt)

end

function Soldiers.update_group( Group, dt )
	if not Group.alive then return end
	if not Group.started then
--~ 		Soldiers.engage(Group)
--~ 		Squads.choose_enemysquad(Group)
		Group.started = true
	end

	for i, character in ipairs(Group.list) do
		if character.status ~= Cte.states.inexistent then

			Soldiers.update_timers( character, dt )
			Soldiers.follow_target( character )
			Sprites.update( character, dt )

			if character.status ~= Cte.states.inexistent and character.status ~= Cte.states.dead then
				if not mymath.distancegreaterthan( character.pos, character.destination, character.stats.range/2 ) then
					character.status = Cte.states.standing
					character.walk_dir = {0,0}
					character.look_dir = {0,1}
				else
					character.status = Cte.states.walking
				end

				if Soldiers.reached_target( character ) then
					-- if I am
					if character.target.stats.hp>0 then
						-- attack!
						Soldiers.surround_enemy( character )
						Soldiers.attack( character )
					else
						-- new victim!
						Soldiers.choose_target( character )
					end
				end

				Soldiers.avoid_buildings( character, dt )
				Soldiers.update_walk( character, dt )


			end
		end
	end


	Soldiers.compute_center(Group)

	if Group.following_group and not mymath.distancegreaterthan(Group.following_group.center, Group.center, 50 )
	then
		Squads.join( Group, Group.following_group )
	end

	if Group.target_group and Group.target_group.count == 0 and
		(not Group.ended) and Group.myarmy ~= Squads.player_squads then
--~ 		Squads.choose_enemysquad(Group)
		Squads.choose_nearest_enemysquad(Group)
		if not Group.target_group then
			Soldiers.moveto( Group, 300, 100 )
			Group.ended = true
		end
	end

	if Group.count == 0 then Group.center = Group.list[1].pos end


end

function Soldiers.reached_target( character )
	if character.target and (not character.target.isbuilding) and
	(not mymath.distancegreaterthan( character.pos, character.target.pos, character.stats.range )) then
		return true
	end
	if character.target and character.target.isbuilding and
	(not mymath.distancegreaterthan( character.pos, character.target.pos, character.stats.range + character.target.radius )) then
		return true
	end
	return false
end


function Soldiers.compute_center(Group)

	Group.alive = false
	Group.count = 0
	Group.center = {0,0}
	Group.box = { screensize[1], screensize[2], 0, 0 }
	for  i,character in ipairs(Group.list) do
		if character.status ~= Cte.states.inexistent then
			Group.alive = true
		end

		if character.status ~= Cte.states.inexistent and character.status ~= Cte.states.dead then
			Group.center = { Group.center[1]+character.pos[1], Group.center[2]+character.pos[2] }
			Group.count = Group.count + 1

			if Group.box[1] > character.pos[1]-4 then Group.box[1]=character.pos[1]-4 end
			if Group.box[2] > character.pos[2]-4 then Group.box[2]=character.pos[2]-4 end
			if Group.box[3] < character.pos[1]+4 then Group.box[3]=character.pos[1]+4 end
			if Group.box[4] < character.pos[2]+4 then Group.box[4]=character.pos[2]+4 end
		end
	end
	if Group.count > 0 then
		Group.center = { Group.center[1]/Group.count, Group.center[2]/Group.count }
	end
end

function Soldiers.update_timers( character, dt )
	if character.attack_timer > 0 then
		character.attack_timer = character.attack_timer - dt
		if character.attack_timer <= 0 then
			Soldiers.impact( character )
		end
	end

	if character.stats.hp <= 0 and
		not (character.status==Cte.states.dead or character.status==Cte.states.inexistent) then
		character.stats.hp = 0
		character.status = Cte.states.dead
		character.mygroup.count = character.mygroup.count - 1
	end

	if character.status==Cte.states.dead and character.death_timer > 0 then
		character.death_timer = character.death_timer - dt
		if character.death_timer <= 0 then
			character.status = Cte.states.inexistent
			Sprites.disappear( character )
		end
	end

	if character.destination[1] ~= character.pos[1] or character.destination[2]~=character.pos[2] then
		character.walk_dir = mymath.get_dir_vector( character.pos, character.destination )
		character.look_dir = {character.walk_dir[1], character.walk_dir[2] }
	end

end

function Soldiers.arrived( character )
	return (character.pos[1]==character.destination[1] and character.pos[2]==character.destination[2])
end

function Soldiers.update_walk( character, dt )
	if not mymath.distancegreaterthan( character.pos, character.destination, character.speed * dt ) then
		character.pos = { character.destination[1], character.destination[2] }
	else
		character.pos = {
			character.pos[1] + character.walk_dir[1] * character.speed * dt,
			character.pos[2] + character.walk_dir[2] * character.speed * dt
		}
	end
end

function Soldiers.draw_group(Group)

	for i,soldier in ipairs(Group.list) do
		if soldier.status ~= Cte.states.inexistent then
			Sprites.updateInBuffer( soldier )
		end
	end

end

function Soldiers.moveto(Group,x,y)
	for i, soldier in ipairs(Group.list) do
		soldier.target = nil
		soldier.destination = {x-50+math.random(100),y-50+math.random(100)}
		soldier.walk_dir = mymath.get_dir_vector(soldier.pos, soldier.destination)
		soldier.look_dir = {soldier.walk_dir[1], soldier.walk_dir[2]}
	end
end

function Soldiers.choose_target(character)
	local Group = character.target_group
	character.target = nil
	if not Group or Group.count==0 then return end
	local number = math.random(Group.count)
	local chosen = 0
	local i=1
	while number>0 do
		local character = Group.list[i]
		if character.status ~= Cte.states.inexistent and character.status ~= Cte.states.dead then
			number = number - 1
		end
		if number==0 then chosen=i end
		i = i + 1
		if i>table.getn(Group.list) then i=1 end
	end
	if chosen>0 then
		character.target= Group.list[chosen]
	else
		return
	end

end

function Soldiers.choose_friend(character)
	local Group = character.following_group
	character.following_dude = nil
	if not Group or Group.count==0 then return end
	local number = math.random(Group.count)
	local chosen = 0
	local i=1
	while number>0 do
		local character = Group.list[i]
		if character.status ~= Cte.states.inexistent and character.status ~= Cte.states.dead then
			number = number - 1
		end
		if number==0 then chosen=i end
		i = i + 1
		if i>table.getn(Group.list) then i=1 end
	end
	if chosen>0 then
		character.following_dude = Group.list[chosen]
	else
		return
	end

end

function Soldiers.follow_target( character )
	if not character.target then
		if character.following_group then
			if (not character.following_dude) or character.following_dude.stats.hp <= 0 then
				Soldiers.choose_friend( character )
			end
			if character.following_dude then
				character.destination = { character.following_dude.pos[1], character.following_dude.pos[2] }
				character.walk_dir = mymath.get_dir_vector( character.pos, character.destination )
				character.look_dir = {character.walk_dir[1], character.walk_dir[2]}
			end
		end
	else
		if not Soldiers.reached_target( character ) then
			character.destination = { character.target.pos[1], character.target.pos[2] }
			character.walk_dir = mymath.get_dir_vector( character.pos, character.destination )
			character.look_dir = {character.walk_dir[1], character.walk_dir[2]}
		end
	end
end

function Soldiers.attack( character )
	-- first check if we can attack
	if not Soldiers.reached_target( character ) then
		return
	end

	character.status = Cte.states.attacking

	if character.attack_timer <= 0 then
		-- is my victim still alive?
		if character.target.stats.hp <= 0 then
			Soldiers.choose_target( character )
			return
		else
			-- launch attack
			character.attack_timer = -math.log(1-math.random())*10/character.stats.speed
		end
	end
end

function Soldiers.impact( character )
	-- target still exists?
	if not character.target then return end

	-- is target alive?
	if character.target.stats.hp <= 0 then
		return
	end

	-- is target reachable?
	if not Soldiers.reached_target( character ) then
		return
	end

	-- if it did not, hit him
	local damage = character.stats.attack - character.target.stats.defense
	if damage < 0 then damage = 0 end
	character.target.stats.hp = character.target.stats.hp - damage
	if character.target.stats.hp <= 0 then
 		character.target.stats.hp = 0
	else
	-- tell him I've hit him (just in case)
		Soldiers.tell_hit( character.target, character )
	end

end

function Soldiers.tell_hit( victim, attacker )
	if victim.target and victim.target.target and victim.target.target == victim then
		-- I am already engaged with my victim, so I ignore you
		return
	end

	if victim.target and victim.target == attacker then
		-- we were already engaged, nothing to do
		return
	end

	-- ok, so you're hitting me but I was busy with someone else who does not care... rather I defend myself
	victim.target = attacker

	Squads.tell_hit( victim.mygroup, attacker.mygroup )

end

-- all soldiers choose targets
function Soldiers.engage(Group)
	for i,character in ipairs(Group.list) do
		Soldiers.engage_single( character, Group.target_group )
	end
end

function Soldiers.engage_single( character, target_group )
	character.target_group = target_group
	Soldiers.choose_target( character )
	character.whohitme = nil
end

function Soldiers.surround_enemy( character )
	character.walk_dir  = {0,0}

	if not Game.surround_enemies then return end

	if not character.target_group then return end

 	-- if we are losing, forget about it
	if character.mygroup.count <= character.target_group.count then
		return
	end

	-- if there is only one, any direction will surround him, nothing to do
	if character.target_group.count <= 1 then
		return
	end

	-- no target? forget it
	if not character.target then return end

	-- try to surround him if we are not already engaged
	if character.target.target == character then
		return
	end

	-- target is right in the center
	if not mymath.distancegreaterthan(character.target_group.center, character.target.pos, 1) then
		return
	end

	-- get the direction that separates the enemy from its group center
	local vector = mymath.get_dir_vector( character.target_group.center, character.target.pos )

	-- add my half-range to it
	character.destination = {
		character.target.pos[1] + vector[1] * character.stats.range/2,
		character.target.pos[2] + vector[2] * character.stats.range/2 }
 	if mymath.distancegreaterthan( character.pos, character.destination, 1 ) then
		character.walk_dir = mymath.get_dir_vector( character.pos, character.destination )
		character.look_dir = {character.walk_dir[1], character.walk_dir[2]}
 	end
end

function Soldiers.avoid_buildings( character, dt )
	local cellwidth,cellheight = Game.map_cellwidth, Game.map_cellheight

	-- check if destination is inside building, if it is, move it out
	local ix,iy = math.floor(character.destination[1]/cellwidth)+1, math.floor(character.destination[2]/cellheight)+1
	if ix<1 then ix=1 end
	if iy<1 then iy=1 end
	if ix>=math.floor(screensize[1]/cellwidth)+1 then ix = math.floor(screensize[1]/cellwidth)  end
	if iy>=math.floor(screensize[2]/cellheight)+1 then iy = math.floor(screensize[2]/cellheight)  end

	local building = Buildings.map[ix][iy]
	if building and not mymath.distancegreaterthan( character.destination, building.pos, building.radius+4) then
		local vector = mymath.get_dir_vector(building.pos, character.destination)
		if building.pos[1]==character.destination[1] and building.pos[2]==character.destination[2] then
			local angle = math.random()*2*math.pi
			vector = { math.cos(angle), math.sin(angle) }
		end
		character.destination = {
			math.floor(building.pos[1] + vector[1] * (building.radius + 4.5)),
			math.floor(building.pos[2] + vector[2] * (building.radius + 4.5))
		}
	end


	-- check if character is about to enter building
	ix,iy = math.floor(character.pos[1]/cellwidth)+1, math.floor(character.pos[2]/cellheight)+1
	if ix<1 then ix=1 end
	if iy<1 then iy=1 end
	if ix>=math.floor(screensize[1]/cellwidth)+1 then ix = math.floor(screensize[1]/cellwidth)  end
	if iy>=math.floor(screensize[2]/cellheight)+1 then iy = math.floor(screensize[2]/cellheight)  end

	building = Buildings.map[ix][iy]
	if not building then return end

	-- check if character is going inside building, if he is, walk away
	if not mymath.distancegreaterthan( character.pos, building.pos, building.radius + 4 ) then
		character.walk_dir = mymath.get_dir_vector( character.pos, character.destination )
		character.look_dir = { character.walk_dir[1], character.walk_dir[2] }
	else
		-- check if character is about to enter building, if he is, walk in circles
		local nextpos = {
			character.pos[1] + character.walk_dir[1] * character.speed * dt,
			character.pos[2] + character.walk_dir[2] * character.speed * dt
		}

		if not mymath.distancegreaterthan( nextpos, building.pos, building.radius + 4 ) then
			local vector = { character.pos[1] - building.pos[1], character.pos[2] - building.pos[2] }
			local ortovector = { -vector[2], vector[1] }
			if character.walk_dir[1]*ortovector[1]+character.walk_dir[2]*ortovector[2] < 0 then
				ortovector = { -ortovector[1], -ortovector[2] }
			end
			local ortomod = math.sqrt(ortovector[1]*ortovector[1]+ortovector[2]*ortovector[2])
			character.walk_dir = { ortovector[1]/ortomod, ortovector[2]/ortomod }
			character.look_dir = { character.walk_dir[1], character.walk_dir[2] }
		end
	end

end
