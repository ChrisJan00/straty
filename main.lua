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

function load()

	-- Dependencies
	love.filesystem.require("constants.lua")
	love.filesystem.require("mymath.lua")
	love.filesystem.require("sprites.lua")
	love.filesystem.require("soldiers.lua")
	love.filesystem.require("squads.lua")
	love.filesystem.require("enemies.lua")
	love.filesystem.require("game.lua")
	love.filesystem.require("warlord.lua")
	love.filesystem.require("archmage.lua")
	love.filesystem.require("buildings.lua")

	-- Initialization
	start_time = love.timer.getTime()
	math.randomseed(os.time())

	-- Init graphics mode
    screensize = { 800, 500 }
	local fullscreen = false
	if not love.graphics.setMode( screensize[1], screensize[2], fullscreen, true, 0 ) then
--~ 	if not Graphics.setWindowed() then
		love.system.exit()
	end

	Game.load()


	-- Audio system
	--if Sounds.active then
	love.audio.setChannels(16)
	love.audio.setVolume(.3)
	--end

	-- Font
	love.graphics.setFont( love.graphics.newImageFont ("images/pixelfont.png",
		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,!?0123456789 ") )


--~ 	Game.titlescreen()


--~ 	Music.start()


end

function update(dt)

    Game.update(dt)

end


function draw()

	Game.draw()

end


function keypressed(key)
	if key == love.key_escape then
		love.system.exit()
	end

	Game.keypressed(key)

end


function keyreleased(key)

	Game.keyreleased(key)

end


function mousepressed(x, y, button)



	Game.mousepressed(x,y,button)

end



function mousereleased(x, y, button)

	Game.mousereleased(x,y, button)

end



