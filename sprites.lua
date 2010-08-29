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

Sprites = {}

function Sprites.load()
	love.graphics.setColor(love.graphics.newColor(0,0,128))
 	love.graphics.setBackgroundColor(244,233,176)
	Sprites.graphics =
	{
		barbarian = love.graphics.newImage("images/Barbarian.png"),
		bandit = love.graphics.newImage("images/Bandit.png"),
		bandit2 = love.graphics.newImage("images/Bandit2.png"),
		bowman = love.graphics.newImage("images/Bowman.png"),
		bowman_she = love.graphics.newImage("images/Bowman_she.png"),
		knight = love.graphics.newImage("images/Knight.png"),
		magician = love.graphics.newImage("images/Magician.png"),
		magician_she = love.graphics.newImage("images/Magician_she.png"),
		monk = love.graphics.newImage("images/Monk.png"),
		necromancer = love.graphics.newImage("images/Necromancer.png"),
		necromancer_lord = love.graphics.newImage("images/Necromancer_lord.png"),
		paladin = love.graphics.newImage("images/Paladin.png"),
		pirate = love.graphics.newImage("images/Pirate.png"),
		warrior = love.graphics.newImage("images/Warrior.png"),
		warrior_she = love.graphics.newImage("images/Warrior_she.png"),
		stone_buildings = love.graphics.newImage("images/stone_buildings.png"),
		rural_bits = love.graphics.newImage("images/rural_bits.png"),

	}

	Sprites.buffer = nil
	Sprites.warlordColor = love.graphics.newColor(0, 168, 32)
	Sprites.enemyColor = love.graphics.newColor(208, 32, 0)
	Sprites.archmageColor = love.graphics.newColor(166,0,136)
	Sprites.textColor = love.graphics.newColor(0,0,166)
	Sprites.lt_gray = love.graphics.newColor(168,168,168)
	Sprites.mid_gray = love.graphics.newColor(96,96,96)
	Sprites.dk_gray = love.graphics.newColor(64,64,64)
	Sprites.backgroundColor = love.graphics.newColor(244,233,176)

	love.graphics.setLine( 1, love.line_rough )
end


function Sprites.draw_character( character )
	if character.status == Cte.states.inexistent then
		return
	end

	local px, py = math.floor(character.pos[1]), math.floor(character.pos[2])

	-- direction: 1: right, 2: left, 3: up, 4: down
	local direction = Cte.dircodes.right
	if math.abs(character.look_dir[1])>math.abs(character.look_dir[2]) then
		-- horizontal
		if character.look_dir[1]>=0 then
			direction = Cte.dircodes.right -- right
		else
			direction = Cte.dircodes.left -- left
		end
	else
		-- vertical
		if character.look_dir[2]>0 then
			direction = Cte.dircodes.down -- down
		else
			direction = Cte.dircodes.up -- up
		end
	end

	local status = character.status
	if status == Cte.states.standing then
		-- standing
		if direction==Cte.dircodes.right then
			love.graphics.draws( character.image, px, py, 0,0,8,8)
		elseif direction == Cte.dircodes.left then
			love.graphics.draws( character.image, px, py, 0,8,8,8)
		elseif direction == Cte.dircodes.up then
			love.graphics.draws( character.image, px, py, 0,24,8,8)
		else
			love.graphics.draws( character.image, px, py, 0,16,8,8)
		end

	elseif status == Cte.states.walking then
		-- walking
		if direction==Cte.dircodes.right then
			love.graphics.draws( character.image, px, py, 8*character.frame,0,8,8)
		elseif direction == Cte.dircodes.left then
 			love.graphics.draws( character.image, px, py, 8*character.frame,8,8,8)
		elseif direction == Cte.dircodes.up then
			love.graphics.draws( character.image, px, py, 8+8*character.frame,24,8,8)
		else
			love.graphics.draws( character.image, px, py, 8+8*character.frame,16,8,8)
		end

	elseif status == Cte.states.attacking then
		-- attacking
		if direction==Cte.dircodes.right then
			love.graphics.draws( character.image, px+1*character.frame, py, 32+8*character.frame,0,8,8)
			if character.frame == 1 then
				love.graphics.draws( character.image, px+9, py, 32+16, 0, 8, 8)
			end
		elseif direction == Cte.dircodes.left then
			if character.frame == 1 then
				love.graphics.draws( character.image, px-1*character.frame, py, 32+16, 8, 8, 8)
				love.graphics.draws( character.image, px-9, py, 32+8, 8, 8, 8)
			else
				love.graphics.draws( character.image, px, py, 32,8,8,8)
			end
		elseif direction == Cte.dircodes.up then
			love.graphics.draws( character.image, px, py, 32+8*character.frame,24,8,8)
		else
			love.graphics.draws( character.image, px, py, 32+8*character.frame,16,8,8)
		end

	elseif status == Cte.states.dead then
		-- dead
		love.graphics.draws( character.image, px, py, 0, 32, 8, 8)
	end

	-- life meter
	love.graphics.setColor( character.livecolor )
	love.graphics.setLine( 1, love.line_rough )
	local fraction = math.floor( 8 * character.stats.hp / character.stats.max_hp )
	if character.stats.hp>0 and fraction==0 then fraction=1 end
	love.graphics.line( px - 4, py - 6, px - 4 + fraction, py - 6)

end

function Sprites.draw_building( building )
	love.graphics.draws( building.image, building.graphic_pos[1], building.graphic_pos[2], building.image_box[1], building.image_box[2],
		building.image_box[3]-building.image_box[1], building.image_box[4]-building.image_box[2] )

	if building.stats then
		-- life meter
		love.graphics.setColor( Sprites.archmageColor )
		love.graphics.setLine( 3, love.line_rough )
		local fraction = math.floor( 32 * building.stats.hp / building.stats.max_hp )
		if building.stats.hp>0 and fraction==0 then fraction=1 end
		love.graphics.line( building.graphic_pos[1] - 16, building.graphic_pos[2] - 32, building.graphic_pos[1] - 16 + fraction, building.graphic_pos[2] - 32)
	end
end


function Sprites.update( character, dt )
	if character.animation_timer <= 0 and
		( character.status == Cte.states.walking or character.status == Cte.states.attacking ) then
		character.animation_timer = character.animation_delay
		character.frame = 1 - character.frame
	else
		character.animation_timer = character.animation_timer - dt
	end
end

function Sprites.drawBuffer()
	local elem = Sprites.buffer
	while elem do
		local next_z = elem.next_z
		if not elem.isbuilding then Sprites.draw_character(elem) else Sprites.draw_building(elem) end
		elem=elem.next_z
	end

end

function Sprites.updateInBuffer( character )
	local z = math.floor( character.pos[2] )

	if (not character.next_z) and (not character.prev_z) and Sprites.buffer~=character then
		character.z = z
		character.prev_z = nil
		character.next_z = nil

		if not Sprites.buffer then
			Sprites.buffer = character
			return
		end

		if z <= Sprites.buffer.z then
			Sprites.buffer.prev_z = character
			character.next_z = Sprites.buffer
			Sprites.buffer = character
			return
		end

		local elem = Sprites.buffer
		while elem.next_z and elem.next_z.z < z do elem=elem.next_z end

		character.prev_z = elem
		if elem.next_z then
			character.next_z = elem.next_z
			elem.next_z.prev_z = character
		end
		elem.next_z = character

		return
	end

	character.z = z

	local morethanprev = true
	if character.prev_z and character.prev_z.z > character.z then morethanprev = false end
	local lessthannext = true
	if character.next_z and character.next_z.z < character.z then lessthannext = false end

	if morethanprev and lessthannext then return end

	if character.prev_z then
		character.prev_z.next_z = character.next_z
	end
	if character.next_z then
		character.next_z.prev_z = character.prev_z
	end
	if Sprites.buffer == character then Sprites.buffer = character.next_z end


	if not morethanprev then
		local elem = character.prev_z
		while elem.prev_z and elem.prev_z.z > z do elem=elem.prev_z end
		if elem.prev_z then
			elem.prev_z.next_z = character
		end
		character.prev_z = elem.prev_z
		elem.prev_z = character
		character.next_z = elem

		if Sprites.buffer == elem then Sprites.buffer = character end
		return
	end

	if not lessthannext then
		local elem = character.next_z
		while elem.next_z and elem.next_z.z < z do elem=elem.next_z end

		if Sprites.buffer == character then Sprites.buffer=character.next_z end
		if elem.next_z then
			elem.next_z.prev_z = character
		end
		character.next_z = elem.next_z
		elem.next_z = character
		character.prev_z = elem
		return
	end

end

function Sprites.disappear(character)
	if character.prev_z then
		character.prev_z.next_z = character.next_z
	end

	if character.next_z then
		character.next_z.prev_z = character.prev_z
	end

	if Sprites.buffer == character then
		Sprites.buffer = character.next_z
	end

 	character.prev_z = nil
 	character.next_z = nil

end
