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

Buildings = {}

function Buildings.new_building( index, px, py )
	local nb = {}
	nb.pos = {px,py}
	if index <= 5 then
		nb.image = Sprites.graphics.stone_buildings
	else
		nb.image = Sprites.graphics.rural_bits
	end

	if index==1 then
		nb.image_box = {0,0,64,128}
	elseif index==2 then
		nb.image_box = {64,0,96,64}
	elseif index==3 then
		nb.image_box = {96,0,128,32}
	elseif index==4 then
		nb.image_box = {96,32,128,64}
	elseif index==5 then
		nb.image_box = {64,64,128,128}
	elseif index==6 then
		nb.image_box = {0,0,32,32}
	elseif index==7 then
		nb.image_box = {32,0,64,32}
	elseif index==8 then
		nb.image_box = {64,0,96,32}
	elseif index==9 then
		nb.image_box = {96,0,128,32}
	elseif index==10 then
		nb.image_box = {128,0,160,32}
	elseif index==11 then
		nb.image_box = {0,32,64,96}
	elseif index==12 then
		nb.image_box = {64,32,96,96}
	elseif index==13 then
		nb.image_box = {96,32,128,96}
	elseif index==14 then
		nb.image_box = {128,32,160,96}
	elseif index==15 then
		nb.image_box = {160,0,224,32}
	elseif index==16 then
		nb.image_box = {224,0,256,32}
	elseif index==17 then
		nb.image_box = {160,32,192,64}
	elseif index==18 then
		nb.image_box = {192,32,224,64}
	elseif index==19 then
		nb.image_box = {160,64,192,96}
	elseif index==20 then
		nb.image_box = {192,64,224,96}
	elseif index==21 then
		nb.image_box = {224,32,256,96}
	elseif index==22 then
		nb.image_box = {0,96,32,128}
	elseif index==23 then
		nb.image_box = {32,96,64,128}
	elseif index==24 then
		nb.image_box = {0,128,32,160}
	elseif index==25 then
		nb.image_box = {32,128,64,160}
	elseif index==26 then
		nb.image_box = {64,96,128,128}
	elseif index==27 then
		nb.image_box = {64,128,128,160}
	elseif index==28 then
		nb.image_box = {128,96,192,160}
	elseif index==29 then
		nb.image_box = {192,96,224,160}
	elseif index==30 then
		nb.image_box = {224,96,256,160}
	end

	-- radius and center...
	if nb.image_box[3]-nb.image_box[1] == 32 and nb.image_box[4]-nb.image_box[2] == 32 then
		nb.graphic_center = {16,16}
		nb.relative_center = {16,16}
		nb.radius = 16 --*math.sqrt(2)

		elseif nb.image_box[3]-nb.image_box[1] == 64 and nb.image_box[4]-nb.image_box[2] == 32 then
		nb.graphic_center = {32,16}
		nb.relative_center = {32,16}
		nb.radius = 32 -- math.sqrt(5)*16

		elseif nb.image_box[3]-nb.image_box[1] == 32 and nb.image_box[4]-nb.image_box[2] == 64 then
		nb.graphic_center = {16,32}
		nb.relative_center = {16,48}
		nb.radius = 16 --*math.sqrt(2) math.sqrt(2)*16
		-- special case
		if index>25 then
			nb.relative_center = {16,32}
			nb.radius=32
		end

		elseif nb.image_box[3]-nb.image_box[1] == 64 and nb.image_box[4]-nb.image_box[2] == 64 then
		nb.graphic_center = {32,32}
		nb.relative_center = {32,48}
		nb.radius = 32 -- math.sqrt(5)*16
		-- special case
		if index==11 then
			nb.radius=16
		end

	elseif nb.image_box[3]-nb.image_box[1] == 64 and nb.image_box[4]-nb.image_box[2] == 128 then
		nb.graphic_center = {32,64}
		nb.relative_center = {32,96}
		nb.radius = 32 -- *sqrt(2)
	end


	nb.graphic_pos = {nb.pos[1]-nb.relative_center[1]+nb.graphic_center[1], nb.pos[2]-nb.relative_center[2]+nb.graphic_center[2]}
	nb.isbuilding = true

	return nb
end

function Buildings.generate_buildings()
	for i=1,5 do
		local nb = Buildings.new_building( math.random(30), math.random(800), math.random(600) )
		Sprites.updateInBuffer( nb )
	end
end

function Buildings.generate_map()
	Buildings.map = {}
	local cellwidth,cellheight = Game.map_cellwidth, Game.map_cellheight
	local xlimit = math.floor(screensize[1]/cellwidth)
	local ylimit = math.floor(screensize[2]/cellheight)
	local i,j
	for i=1,xlimit do
		Buildings.map[i]={}
		for j=1,ylimit do
			if math.random(4)==1 then --if math.random(3)==1 then
				--local nb = Buildings.new_building( math.random(30), math.random(cellwidth), math.random(cellheight) )
				local nb = Buildings.new_building( math.random(8)+6, math.random(cellwidth), math.random(cellheight) )
				if nb.pos[1] - nb.radius < 8 then nb.pos[1] = 8 + nb.radius end
				if nb.pos[1] + nb.radius > cellwidth - 8 then nb.pos[1] = cellwidth - 8 - nb.radius end
				if nb.pos[2] - nb.radius < 8 then nb.pos[2] = 8 + nb.radius end
				if nb.pos[2] + nb.radius > cellheight - 8 then nb.pos[2] = cellheight - 8 - nb.radius end

				nb.pos[1] = math.floor(nb.pos[1] + (i-1)*cellwidth)
				nb.pos[2] = math.floor(nb.pos[2] + (j-1)*cellheight)

				nb.graphic_pos = {nb.pos[1]-nb.relative_center[1]+nb.graphic_center[1], nb.pos[2]-nb.relative_center[2]+nb.graphic_center[2]}

				Sprites.updateInBuffer( nb )
				Buildings.map[i][j]=nb
			end
		end
	end

end
