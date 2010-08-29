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

Archmage = {}

function Archmage.load()
	Buildings.generate_map()

	-- generate schools
	Archmage.school_count = 7
	Archmage.schools = {}
	for i=1,Archmage.school_count do
		Archmage.schools[i] = Archmage.newschool()
	end

	-- selection and map
	Archmage.selection ={
		active = true,
		number = 1,
		box = { 0,0,0,0 },
	}
	Archmage.menu = {
		active = false,
		option = Cte.wl_menu.move,
	}
end

function Archmage.newschool()
	local nx,ny = math.floor(screensize[1]/Game.map_cellwidth), math.floor(screensize[2]/Game.map_cellheight)
	local ix,iy = math.random(nx-2)+1,math.random(ny-2)+1
	while Buildings.map[ix][iy] and Buildings.map[ix][iy].is_school do
		ix,iy = math.random(nx-2)+1,math.random(ny-2)+1
	end
	local px,py = math.floor((ix-0.5)*Game.map_cellwidth),math.floor((iy-0.5)*Game.map_cellheight)
	local school= Buildings.new_building( 2, px, py )
	school.is_school = true
	Sprites.updateInBuffer( school )
	if Buildings.map[ix] and Buildings.map[ix][iy] then
			Sprites.disappear( Buildings.map[ix][iy] )
			Buildings.map[ix][iy]=nil
	end
	Buildings.map[ix][iy] = school
	school.count = 1
	school.stats = {
		max_hp = 100,
		hp = 100,
		attack = 0,
		defense = 0,
		speed = 0,
		range = 0,
	}
	school.center = { school.pos[1], school.pos[2] }
	school.list={school}
	school.mygroup = school
	return school
end

function Archmage.update(dt)
 -- update school timers
	Archmage.school_count = 0
	for i=1,table.getn(Archmage.schools) do
		if Archmage.schools[i].stats.hp <= 0 then
			Archmage.schools[i].count=0
		else
			Archmage.school_count = Archmage.school_count + 1
		end
	end
end

function Archmage.draw()
	-- draw selection
	if Archmage.selection.active then
		local ml = 5
		local school = Archmage.schools[Archmage.selection.number]
		Archmage.selection.box = { math.floor(school.pos[1] - 24), math.floor(school.pos[2] - 56),
			math.floor(school.pos[1] + 24), math.floor(school.pos[2] + 24) }


		love.graphics.setColor( Sprites.archmageColor )
		love.graphics.setLine( 2, love.line_rough )

		local box = Archmage.selection.box
		love.graphics.line(box[1]-1,box[2],box[1]+ml-1,box[2])
		love.graphics.line(box[1],box[2]-1,box[1],box[2]+ml-1)
		love.graphics.line(box[1]-1,box[4],box[1]+ml-1,box[4])
		love.graphics.line(box[1],box[4],box[1],box[4]-ml+1)
		love.graphics.line(box[3],box[2],box[3]-ml+1,box[2])
		love.graphics.line(box[3],box[2]-1,box[3],box[2]+ml-1)
		love.graphics.line(box[3]+1,box[4],box[3]-ml+1,box[4])
		love.graphics.line(box[3],box[4]+1,box[3],box[4]-ml+1)
	end
	-- draw menu
end

function Archmage.keypressed( key )
	if key == love.key_up then
		if Archmage.menu.active then Archmage.move_menu( Cte.dircodes.up ) else
		Archmage.move_selection( Cte.dircodes.up ) end
	end

	if key == love.key_down then
		if Archmage.menu.active then Archmage.move_menu( Cte.dircodes.down ) else
		Archmage.move_selection( Cte.dircodes.down ) end
	end
	if key == love.key_left then
		if Archmage.menu.active then Archmage.move_menu( Cte.dircodes.left ) else
		Archmage.move_selection( Cte.dircodes.left ) end
	end
	if key == love.key_right then
		if Archmage.menu.active then Archmage.move_menu( Cte.dircodes.right ) else
		Archmage.move_selection( Cte.dircodes.right ) end
	end
end

function Archmage.keyreleased( key )
end

function Archmage.move_menu( direction )
end

function Archmage.move_selection( direction )
-- find the nearest school that is in direction
	local selection = Archmage.schools[ Archmage.selection.number ]
	local original = selection
	local min_distance = screensize[1]*screensize[1] + screensize[2]*screensize[2]
	local index = Archmage.selection.number
	for i,school in ipairs(Archmage.schools) do
		if school ~= original and
--~ 			school.count > 0 and
			((direction == Cte.dircodes.up and school.pos[2] < original.pos[2] ) or
			 (direction == Cte.dircodes.down and school.pos[2] > original.pos[2] ) or
			 (direction == Cte.dircodes.left and school.pos[1] < original.pos[1] ) or
			 (direction == Cte.dircodes.right and school.pos[1] > original.pos[1] )) --and
--~ 			(((direction == Cte.dircodes.up or direction == Cte.dircodes.down) and
--~ 				math.abs(school.pos[2]-original.pos[2]) >= math.abs(school.pos[1]-original.pos[1]) ) or
--~ 			 ((direction == Cte.dircodes.left or direction == Cte.dircodes.right) and
--~ 				math.abs(school.pos[2]-original.pos[2]) <= math.abs(school.pos[1]-original.pos[1]) ))
			then

			local distance = mymath.get_distance(school.pos, original.pos)
			if distance < min_distance then
				min_distance = distance
				selection = school
				index = i
			end
		end
	end

	Archmage.selection.number = index
end
