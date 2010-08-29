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

Game = {}


function Game.load()
	Game.surround_enemies = true
	Game.move_cellwidth = 50
	Game.move_cellheight = 50
	Game.map_cellwidth = 50
	Game.map_cellheight = 50


	Sprites.load()
	Archmage.load()
	Soldiers.load()
	Squads.load()
	Enemies.load()
	Warlord.load()


--~ 	Buildings.generate_map()
end


function Game.update(dt)
	Squads.update( dt )
	Warlord.update( dt )
	Archmage.update( dt )
end

function Game.draw()
	Squads.draw()
	Sprites.drawBuffer()

	Warlord.draw()
	Archmage.draw()
end

function Game.keypressed( key )
	Warlord.keypressed ( key )
	Archmage.keypressed( key )
end


function Game.keyreleased(key)
	Warlord.keyreleased( key )
	Archmage.keyreleased( key )
end


function Game.mousepressed(x,y,button)

--~ 	Squads.moveto(x,y)

end

function Game.mousereleased(x,y, button)

end
