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

Squads = {}

function Squads.load()
	Squads.player_squads = {}
	Squads.enemy_squads = {}
	Squads.player_squads.count = 3
	Squads.enemy_squads.count = 3

	for i=1,Squads.player_squads.count do
		Squads.player_squads[i] = Squads.init_squad(  )
		Squads.player_squads[i].myarmy = Squads.player_squads
		Squads.player_squads[i].target_army = Squads.enemy_squads
		for j,soldier in ipairs(Squads.player_squads[i].list) do
			soldier.pos[1] = soldier.pos[1]+100 * i
			soldier.destination[1] = soldier.destination[1]+100 * i
--~ 			soldier.pos[2] = enemy.pos[2]+400
		end

	end

	for i=1,Squads.enemy_squads.count do
		Squads.enemy_squads[i] = Squads.init_squad(  )
		Squads.enemy_squads[i].myarmy = Squads.enemy_squads
		--Squads.enemy_squads[i].target_army = Squads.player_squads
		Squads.enemy_squads[i].target_army = Archmage.schools

--~ 		Squads.choose_enemysquad( Squads.enemy_squads[i] )
		for j,enemy in ipairs(Squads.enemy_squads[i].list) do
			enemy.pos[1] = enemy.pos[1]+100 * i
			enemy.pos[2] = enemy.pos[2]+300
			enemy.destination[1] = enemy.destination[1]+100*i
			enemy.destination[2] = enemy.destination[2]+300
			enemy.livecolor = Sprites.enemyColor
		end
		Soldiers.compute_center(Squads.enemy_squads[i])
		Squads.choose_nearest_enemysquad( Squads.enemy_squads[i] )
	end

end

function Squads.init_squad(  )
	local Container = {}
	Soldiers.generate_list( Container, 5 )
	Container.started = false
	Container.ended = false

	Soldiers.compute_center(Container)
	return Container
end

function Squads.choose_enemysquad( Group )
	if Group.target_army.count == 0 then
		Group.target_group = nil
		return
	end

	local index = math.random(table.getn(Group.target_army))
	local dead_count = 0
	local i=0
	while index > 0 and dead_count < table.getn(Group.target_army) do
		i = i+1
		if i>table.getn(Group.target_army) then
			i=1
			dead_count = 0
			end

		if Group.target_army[i].count > 0 then
			index = index - 1
		else
			dead_count = dead_count + 1
		end
	end

	if dead_count < table.getn(Group.target_army) then
		Group.target_group = Group.target_army[i]
		Soldiers.engage(Group)
	else
		Group.target_group = nil
	end
end

function Squads.choose_nearest_enemysquad( Group )
	if Group.target_army.count == 0 then
		Group.target_group = nil
		return
	end

	local mindist = screensize[1]*screensize[1]+screensize[2]*screensize[2]
	local index = -1
	for i=1,table.getn(Group.target_army) do
		if Group.target_army[i].count > 0 and
			not mymath.distancegreaterthan(Group.center, Group.target_army[i].center, mindist) then
				mindist = mymath.get_distance(Group.center, Group.target_army[i].center)
				index = i
		end
	end

	if index>0 then
		Group.target_group = Group.target_army[index]
		Soldiers.engage(Group)
	else
		Group.target_group = nil
	end
end



function Squads.update( dt )
	-- update movement
	for i=1,table.getn(Squads.player_squads) do
		if Squads.player_squads[i].alive then
			Soldiers.update_group(Squads.player_squads[i], dt)
			if not Squads.player_squads[i].alive then
				Squads.player_squads.count = Squads.player_squads.count - 1
			end
		end
	end

	-- update movement
	for i=1,table.getn(Squads.enemy_squads) do
		if Squads.enemy_squads[i].alive then
			Soldiers.update_group(Squads.enemy_squads[i], dt)
			if not Squads.enemy_squads[i].alive then
				Squads.enemy_squads.count = Squads.enemy_squads.count - 1
			end
		end
	end

end

function Squads.draw()
	for i=1,table.getn(Squads.player_squads) do
		if Squads.player_squads[i].alive then
			Soldiers.draw_group(Squads.player_squads[i])
		end
	end
	for i=1,table.getn(Squads.enemy_squads) do
		if Squads.enemy_squads[i].alive then
			Soldiers.draw_group(Squads.enemy_squads[i])
		end
	end
end

function Squads.moveto(x,y)
	Soldiers.moveto(Squads.player_squads[Warlord.selection.number],x,y)
	Squads.player_squads[Warlord.selection.number].target_group = nil
	for i,soldier in ipairs(Squads.player_squads[Warlord.selection.number].list) do
		soldier.target = nil
	end
end

function Squads.tell_hit( victim_group, attacker_group )
	-- buildings cannot attack
	if victim_group.isbuilding then return end

--~ if true then return end
	if victim_group.target_group and victim_group.target_group.target_group
		and victim_group.target_group.target_group == victim_group then
		-- I am already engaged with my victim, so I ignore you
		return
	end

	if victim_group.target_group and victim_group.target_group == attacker_group then
		-- we were already engaged, nothing to do
		return
	end

	-- ok, so you're hitting me but I was busy with someone else who does not care... rather I defend myself
	victim_group.target_group = attacker_group
	Soldiers.engage(victim_group)

end

function Squads.split( squad )
	if squad.count <= 1 then return end

	local newsize = math.floor(squad.count/2)

	-- find a free slot for the new Squad
	local i=1
	while Squads.player_squads[i] and Squads.player_squads[i].alive do i=i+1 end

	-- prepare two random centers
	local angle = math.random() * 2 * math.pi
	local vector = {50*math.cos(angle),50*math.sin(angle)}
	local newcenter1 = {squad.center[1] - vector[1], squad.center[2]-vector[2]}
	local newcenter2 = {squad.center[1] + vector[1], squad.center[2]+vector[2]}

	-- initialize the new squad
	Squads.player_squads[i]={}
	local newsquad = Squads.player_squads[i]
	newsquad.list = {}
	newsquad.count = 0
	i = 1
	while newsize>0 do
		if squad.list[i].stats.hp > 0 then
			squad.list[i].mygroup  = newsquad
			squad.list[i].myarmy = Squads.player_squads
			squad.list[i].target_army = Squads.enemy_squads
			table.insert(newsquad.list,squad.list[i])
			table.remove(squad.list,i)
			newsize = newsize-1
			newsquad.count = newsquad.count+1
		end
		i = i+1
	end
	newsquad.started = false
	newsquad.ended = false
	newsquad.myarmy = Squads.player_squads
	newsquad.target_army = Squads.enemy_squads

	Soldiers.compute_center(newsquad)
	Squads.player_squads.count = Squads.player_squads.count + 1

	Soldiers.moveto( squad, newcenter1[1], newcenter1[2] )
	Soldiers.moveto( newsquad, newcenter2[1], newcenter2[2] )
end

function Squads.join(squadfrom, squadto)

	Soldiers.moveto( squadfrom, squadto.center[1], squadto.center[2] )

	for i=1,table.getn(squadfrom.list) do
		squadfrom.list[i].mygroup = squadto
		squadfrom.list[i].following_group = nil
		squadfrom.list[i].following_dude = nil
		squadfrom.list[i].target_group = squadto.list[1].target_group
		Soldiers.engage_single( squadfrom.list[i], squadfrom.list[i].target_group )
		table.insert(squadto.list,squadfrom.list[i])
	end

	squadto.count = squadto.count + squadfrom.count
	squadfrom.count = 0
	squadfrom.alive = false
end

function Squads.forget_enemies( Group )
	for i=1,table.getn(Group.list) do
		local s = Group.list[i]
		if s.target then
			s.target = nil
			s.target_group = nil
			s.destination = {s.pos[1],s.pos[2]}
			s.walk_dir = {0,0}
		end
	end
end

function Squads.trytojoin( squadfrom, squadto )
	squadfrom.following_group = squadto
	for i=1,table.getn(squadfrom.list) do
		squadfrom.list[i].following_group = squadto
	end

end
