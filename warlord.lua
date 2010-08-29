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

Warlord = {}
function Warlord.load()
	Warlord.selection ={
		active = true,
		what = Cte.wl_selection.squad,
		number = 1,
		box = { 0,0,0,0 },
		last_squad = 1,
		last_enemy = 0,
		last_map = 0,
		choosing = false,
		except = -1,
	}
	Warlord.menu = {
		active = false,
		option = Cte.wl_menu.move,
	}

end

function Warlord.update( dt )
	if Warlord.selection.what == Cte.wl_selection.squad and
		Squads.player_squads[ Warlord.selection.number ].count <= 0 then
		Warlord.select_random_squad()
	end
end

function Warlord.draw()
	if Warlord.selection.active then
		local ml = 5
		if Warlord.selection.what == Cte.wl_selection.squad then
			local squad = Squads.player_squads[Warlord.selection.number]
			Warlord.selection.box = { math.floor(squad.box[1] - ml), math.floor(squad.box[2] - ml),
				math.floor(squad.box[3] + ml), math.floor(squad.box[4] + ml) }
		elseif Warlord.selection.what == Cte.wl_selection.enemy then
			local squad = Squads.enemy_squads[Warlord.selection.number]
			Warlord.selection.box = { math.floor(squad.box[1] - ml), math.floor(squad.box[2] - ml),
				math.floor(squad.box[3] + ml), math.floor(squad.box[4] + ml) }
		elseif Warlord.selection.what == Cte.wl_selection.map then
			Warlord.selection.box = { math.floor((Warlord.selection.mappos[1]-0.5)*Game.move_cellwidth),
				math.floor((Warlord.selection.mappos[2]-0.5)*Game.move_cellheight),
				math.floor((Warlord.selection.mappos[1]+1.5)*Game.move_cellwidth),
				math.floor((Warlord.selection.mappos[2]+1.5)*Game.move_cellheight) }
		end

		love.graphics.setColor( Sprites.warlordColor )
		love.graphics.setLine( 2, love.line_rough )

		local box = Warlord.selection.box
		love.graphics.line(box[1]-1,box[2],box[1]+ml-1,box[2])
		love.graphics.line(box[1],box[2]-1,box[1],box[2]+ml-1)
		love.graphics.line(box[1]-1,box[4],box[1]+ml-1,box[4])
		love.graphics.line(box[1],box[4],box[1],box[4]-ml+1)
		love.graphics.line(box[3],box[2],box[3]-ml+1,box[2])
		love.graphics.line(box[3],box[2]-1,box[3],box[2]+ml-1)
		love.graphics.line(box[3]+1,box[4],box[3]-ml+1,box[4])
		love.graphics.line(box[3],box[4]+1,box[3],box[4]-ml+1)
	end

	if Warlord.menu.active then
		local squad = Squads.player_squads[Warlord.selection.number]
		local center = { math.floor((squad.box[1]+squad.box[3])/2), math.floor((squad.box[2]+squad.box[4])/2) }

		love.graphics.setLine(1, love.line_rough)
		love.graphics.setColor( Sprites.backgroundColor )
		love.graphics.rectangle( love.draw_fill, center[1] - 27, center[2]-25, 55, 50 )
		love.graphics.setColor( Sprites.textColor )
		love.graphics.rectangle( love.draw_line, center[1] - 27, center[2]-25, 55, 50 )
		love.graphics.line(center[1]-28,center[2]-25,center[1]-27,center[2]-25)

		if Warlord.menu.option == Cte.wl_menu.attack then
			love.graphics.setColor( Sprites.textColor )
		else
			love.graphics.setColor( Sprites.lt_gray )
		end
		love.graphics.draw("attack", center[1]-22, center[2]-20 )
		if Warlord.menu.option == Cte.wl_menu.move then
			love.graphics.setColor( Sprites.textColor )
		else
			love.graphics.setColor( Sprites.lt_gray )
		end
		love.graphics.draw("move", center[1]-22, center[2]-10 )
		if Warlord.menu.option == Cte.wl_menu.join then
			love.graphics.setColor( Sprites.textColor )
		else
			love.graphics.setColor( Sprites.lt_gray )
		end
		love.graphics.draw("join",center[1]-22,center[2])
		if Warlord.menu.option == Cte.wl_menu.split then
			love.graphics.setColor( Sprites.textColor )
		else
			love.graphics.setColor( Sprites.lt_gray )
		end
		love.graphics.draw("split",center[1]-22,center[2]+10)
	end

end


function Warlord.keypressed ( key )
	if key== Cte.wl_keys.right then -- right
		if Warlord.menu.active then
			Warlord.change_menu_option( Cte.dircodes.down )
		else
			Warlord.move_selection( Cte.dircodes.right )
		end
	end

	if key== Cte.wl_keys.left then -- left
		if Warlord.menu.active then
			Warlord.change_menu_option( Cte.dircodes.up )
		else
			Warlord.move_selection( Cte.dircodes.left )
		end
	end

	if key== Cte.wl_keys.down then -- down
		if Warlord.menu.active then
			Warlord.change_menu_option( Cte.dircodes.down )
		else
			Warlord.move_selection( Cte.dircodes.down )
		end
	end

	if key== Cte.wl_keys.up then -- up
		if Warlord.menu.active then
			Warlord.change_menu_option( Cte.dircodes.up )
		else
			Warlord.move_selection( Cte.dircodes.up )
		end
	end

	if key == Cte.wl_keys.select then -- select
		if not Warlord.menu.active then
			if not Warlord.selection.choosing then
				-- activate menu
				Warlord.selection.last_squad = Warlord.selection.number
				if Squads.enemy_squads.count > 0 then
					Warlord.menu.option = Cte.wl_menu.attack
				else
					Warlord.menu.option = Cte.wl_menu.move
				end
				Warlord.menu.active = true
			else
				-- confirm selection
				if Warlord.menu.option == Cte.wl_menu.attack then
					Squads.player_squads[ Warlord.selection.last_squad ].target_group =
						Squads.enemy_squads[ Warlord.selection.number ]
					Soldiers.engage( Squads.player_squads[ Warlord.selection.last_squad ] )

				elseif Warlord.menu.option == Cte.wl_menu.join then
					Warlord.selection.except = -1
					Squads.forget_enemies( Squads.player_squads[ Warlord.selection.last_squad ] )
					Squads.trytojoin( Squads.player_squads[Warlord.selection.last_squad ],
						Squads.player_squads[Warlord.selection.number] )
				elseif Warlord.menu.option == Cte.wl_menu.move then
					Warlord.selection.number = Warlord.selection.last_squad
					local dest = Warlord.maptopos(  Warlord.selection.mappos )
					Squads.moveto( dest[1], dest[2] )
				elseif Warlord.menu.option == Cte.wl_menu.split then
				end

				Warlord.selection.choosing = false
				Warlord.selection.what = Cte.wl_selection.squad
				Warlord.select_random_squad()
			end
		else
			-- menu was active
			Warlord.menu.active = false
			Warlord.selection.last_squad = Warlord.selection.number
			if Warlord.menu.option == Cte.wl_menu.attack then
				Warlord.select_random_enemy()
				Warlord.selection.active = true
				Warlord.selection.choosing = true
				Warlord.selection.what = Cte.wl_selection.enemy
			elseif Warlord.menu.option == Cte.wl_menu.join then
				Warlord.selection.except = Warlord.selection.number
				Warlord.selection.active = true
				Warlord.selection.choosing = true
				Warlord.select_random_squad()
			elseif Warlord.menu.option == Cte.wl_menu.move then
				Warlord.selection.what = Cte.wl_selection.map
				local squad = Squads.player_squads[ Warlord.selection.last_squad ]
				Warlord.selection.mappos = Warlord.postomap ( squad.center )
				Warlord.selection.choosing = true
				Warlord.selection.active = true
			elseif Warlord.menu.option == Cte.wl_menu.split then
				Squads.forget_enemies( Squads.player_squads[ Warlord.selection.last_squad ] )
				Squads.split( Squads.player_squads[Warlord.selection.number] )
			end
		end
--~ 		if Warlord.selection.what == Cte.wl_selection.squad then
--~ 			Warlord.selection.last_squad = Warlord.selection.number
--~ 			Warlord.selection.what = Cte.wl_selection.enemy
--~ 			Warlord.select_random_enemy()
--~ 		elseif Warlord.selection.what == Cte.wl_selection.enemy then
--~ 			Warlord.selection.last_enemy = Warlord.selection.number
--~ 			Warlord.selection.what = Cte.wl_selection.squad
--~ 			Warlord.select_random_squad()
--~ 		end
	end

	if key==Cte.wl_keys.cancel then
		Warlord.menu.active = false
		Warlord.selection.choosing = false
		Warlord.selection.what = Cte.wl_selection.squad
		Warlord.selection.number = Warlord.selection.last_squad
		Warlord.selection.except = -1
	end
end



function Warlord.keyreleased( key )

end

function Warlord.move_selection( direction )
	if Warlord.selection.what == Cte.wl_selection.squad then
		Warlord.select_squad( direction )
	elseif Warlord.selection.what == Cte.wl_selection.enemy then
		Warlord.select_enemy( direction )
	elseif Warlord.selection.what == Cte.wl_selection.map then
		Warlord.select_map( direction )
	end
end

function Warlord.select_squad( direction )
	-- find the nearest squad that is in direction
	local selection = Squads.player_squads[ Warlord.selection.number ]
	local original = selection
	local min_distance = screensize[1]*screensize[1] + screensize[2]*screensize[2]
	local index = Warlord.selection.number
	for i,squad in ipairs(Squads.player_squads) do
		if squad ~= original and
			squad.count > 0 and
			((direction == Cte.dircodes.up and squad.center[2] < original.center[2] ) or
			 (direction == Cte.dircodes.down and squad.center[2] > original.center[2] ) or
			 (direction == Cte.dircodes.left and squad.center[1] < original.center[1] ) or
			 (direction == Cte.dircodes.right and squad.center[1] > original.center[1] )) then

			local distance = mymath.get_distance(squad.center, original.center)
			if distance < min_distance and i~=Warlord.selection.except then
				min_distance = distance
				selection = squad
				index = i
			end
		end
	end

	Warlord.selection.number = index
end

function Warlord.select_random_squad()
--~ 	if Squads.player_squads[Warlord.selection.last_squad] and
--~ 		Squads.player_squads[Warlord.selection.last_squad].count > 0 then
--~ 		Warlord.selection.number = Warlord.selection.last_squad
--~ 		return
--~ 	end

	if Squads.player_squads.count == 0 then return end
	local number = math.random( table.getn( Squads.player_squads ) )
	local alive = false
	local index = 0
	while number > 0 do
		index = index + 1
		if index>table.getn(Squads.player_squads) then index = 1
			if not alive then return end end
		if Squads.player_squads[index].count > 0 and index~=Warlord.selection.except then
			number = number - 1
			alive = true
		end
	end

	Warlord.selection.number = index
end


function Warlord.select_enemy( direction )
	-- find the nearest squad that is in direction
	local selection = Squads.enemy_squads[ Warlord.selection.number ]
	local original = selection
	local min_distance = screensize[1]*screensize[1] + screensize[2]*screensize[2]
	local index = Warlord.selection.number
	for i,squad in ipairs(Squads.enemy_squads) do
		if squad ~= original and
			squad.count > 0 and
			((direction == Cte.dircodes.up and squad.center[2] < original.center[2] ) or
			 (direction == Cte.dircodes.down and squad.center[2] > original.center[2] ) or
			 (direction == Cte.dircodes.left and squad.center[1] < original.center[1] ) or
			 (direction == Cte.dircodes.right and squad.center[1] > original.center[1] )) then

			local distance = mymath.get_distance(squad.center, original.center)
			if distance < min_distance then
				min_distance = distance
				selection = squad
				index = i
			end
		end
	end

	Warlord.selection.number = index
end

function Warlord.select_random_enemy()
	if Squads.enemy_squads[Warlord.selection.last_enemy] and
		Squads.enemy_squads[Warlord.selection.last_enemy].count > 0 then
		Warlord.selection.number = Warlord.selection.last_enemy
		return
	end

	if Squads.enemy_squads.count == 0 then return end
	local number = math.random( table.getn( Squads.enemy_squads ) )
	local index = 0
	local alive = false
	while number > 0 do
		index = index + 1
		if index>table.getn(Squads.enemy_squads) then
			index = 1
			if not alive then return end
		end
		if Squads.enemy_squads[index].count > 0 then
			number = number - 1
			alive = true
		end
	end

	Warlord.selection.number = index
	Warlord.selection.last_enemy = index
end

function Warlord.select_map( direction )
	if direction == Cte.dircodes.up then
		Warlord.selection.mappos[2] = Warlord.selection.mappos[2]-1
		if Warlord.selection.mappos[2]<0 then Warlord.selection.mappos[2]=0 end
	end

	if direction == Cte.dircodes.down then
		Warlord.selection.mappos[2] = Warlord.selection.mappos[2]+1
		if math.floor( (Warlord.selection.mappos[2]+0.5)* Game.move_cellheight)>screensize[2] then
			Warlord.selection.mappos[2]=Warlord.selection.mappos[2]-1
		end
	end

	if direction == Cte.dircodes.right then
		Warlord.selection.mappos[1] = Warlord.selection.mappos[1]+1
		if math.floor( (Warlord.selection.mappos[1]+0.5)* Game.move_cellwidth)>screensize[1] then
			Warlord.selection.mappos[1]=Warlord.selection.mappos[1]-1
		end
	end

	if direction == Cte.dircodes.left then
		Warlord.selection.mappos[1] = Warlord.selection.mappos[1]-1
		if Warlord.selection.mappos[1]<0 then Warlord.selection.mappos[1]=0 end
	end

end

function Warlord.change_menu_option( direction )
	if direction == Cte.dircodes.up then
		local ok = false
		while not ok do
			if Warlord.menu.option == Cte.wl_menu.attack then
				Warlord.menu.option = Cte.wl_menu.split
				if Squads.player_squads[Warlord.selection.number].count > 1 then ok=true end
			elseif Warlord.menu.option == Cte.wl_menu.move then
				Warlord.menu.option = Cte.wl_menu.attack
				if Squads.enemy_squads.count > 0 then ok=true end
			elseif Warlord.menu.option == Cte.wl_menu.join then
				Warlord.menu.option = Cte.wl_menu.move
				ok = true
			else
				Warlord.menu.option = Cte.wl_menu.join
				if Squads.player_squads.count > 1 then ok=true end
			end
		end
	end

	if direction == Cte.dircodes.down then
		local ok = false
		while not ok do
			if Warlord.menu.option == Cte.wl_menu.move then
				Warlord.menu.option = Cte.wl_menu.join
				if Squads.player_squads.count > 1 then ok=true end
			elseif Warlord.menu.option == Cte.wl_menu.join then
				Warlord.menu.option = Cte.wl_menu.split
				if Squads.player_squads[Warlord.selection.number].count > 1 then ok=true end
			elseif Warlord.menu.option == Cte.wl_menu.attack then
				Warlord.menu.option = Cte.wl_menu.move
				ok = true
			else
				Warlord.menu.option = Cte.wl_menu.attack
				if Squads.enemy_squads.count > 0 then ok=true end
			end
		end
	end

end

function Warlord.postomap ( pos )
	return { math.floor(pos[1]/Game.move_cellwidth), math.floor(pos[2]/Game.move_cellheight) }
end

function Warlord.maptopos ( map )
	return { math.floor((map[1]+0.5)*Game.move_cellwidth), math.floor((map[2]+0.5)*Game.move_cellheight) }
end


-- el great commander controla una serie de squads
-- el fitxer squads controla un conjunt de soldats
-- el fitxer soldiers controla un soldat en particular
-- el fitxer enemies controla una serie de squads
-- despres hi ha schools, que controla les escoles (funciona com squads)
-- archmage es el player que controla les schools
-- maps genera els mapes
-- game controla les condicions de victoria, enganxa enemies, archmage i commander i maps
-- main crida a game pel joc, i s'encarrega dels menus

-- mes endevant hi hauria network, per a partides via lan i el dedicated server
