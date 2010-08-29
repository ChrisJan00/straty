Sprites={
	buffer = nil
	}

function updateInBuffer( character )
	local z = math.floor( character.a )

--~ 	if true then
--~ 		Sprites.drawCharacter(character)
--~ 		return
--~ 	end

	-- hi ha un bug que fa que es pengi... segurament una fuita de memoria...
	-- imagino que al eliminar coses es queden nodes penjats por ahi


	-- END TEST END TEST
	if (not character.next_z) and (not character.prev_z) and Sprites.buffer~=character then
	--if not character.z then
		character.z = z
		character.prev_z = nil
		character.next_z = nil

	--  si la llista esta buida, afegir al principi
		if not Sprites.buffer then
			Sprites.buffer = character
			return
		end

	--  si el meu z es menor que el primer, posar-me al principi
		if z <= Sprites.buffer.z then
			Sprites.buffer.prev_z = character
			character.next_z = Sprites.buffer
			Sprites.buffer = character
			return
		end

	-- si no, recorrer la llista fins que trobi un z major o igual que jo i inserir-m'hi
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

	-- si el meu nou z es adient a la posicio que ocupo (l'anterior es menor o igual que jo) retornar
	local morethanprev = true
	if character.prev_z and character.prev_z.z > character.z then morethanprev = false end
	local lessthannext = true
	if character.next_z and character.next_z.z < character.z then lessthannext = false end

	if morethanprev and lessthannext then return end

	-- no em cal buscar-me pq ja tinc els enllassos, simplement "desconnectar-me"
	if character.prev_z then
		character.prev_z.next_z = character.next_z
	end
	if character.next_z then
		character.next_z.prev_z = character.prev_z
	end
	if Sprites.buffer == character then Sprites.buffer = character.next_z end


	-- si el meu z ha augmentat, buscar cap amunt, si ha disminuit, buscar cap avall
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

function disappear(character)
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

function p()

local elem = Sprites.buffer
local r=""
while elem do
	r = r..elem.z.." "
	elem = elem.next_z
end
print (r)
end

math.randomseed(os.time())
--math.randomseed(1)
a = math.random(9)
A={}
st = ""
for i=1,20 do
	A[i]={a = math.random(9) }
	updateInBuffer( A[i] )
	st = st..A[i].a.." "
end

for j=1,2 do
st  = st.."\n"
for i=1,table.getn(A) do
	A[i].a = math.random(9)
  	updateInBuffer( A[i] )
	st = st..A[i].a.." "
end
end

--~ for j=1,19 do
--~ disappear(A[j])
--~ end

print(st)
p()


