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

Cte = {}


Cte.states =
{
	inexistent = 0,
	dead = 1,
	standing = 2,
	walking = 3,
	attacking = 4
}

Cte.dircodes =
{
	right = 1,
	left = 2,
	up = 3,
	down = 4
}

Cte.wl_selection =
{
	none = 0,
	squad = 1,
	enemy = 2,
	map = 3,
}

Cte.wl_menu =
{
	none = 0,
	move = 1,
	attack = 2,
	join = 3,
	split = 4
}

Cte.wl_keys =
{
	up = love.key_e,
	down = love.key_d,
	right = love.key_f,
	left = love.key_s,
	select = love.key_z,
	cancel = love.key_a
}

Cte.am_keys =
{
	up = love.key_up,
	down = love.key_down,
	right = love.key_right,
	left = love.key_left,
	select = love.key_period,
	cancel = love.key_comma
}
