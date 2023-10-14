

function prettyByte(byte)
	local v = string.format("%x", byte)
	if byte <= 0xF then
		v = "0" .. v
	end
	return v
end

function stringToHex(s)
	local v = ""
	local length = s:len()
	for i = 1, length do
		v = v .. prettyByte(string.byte(s, i))
	end
	return v
end

function read16S(address)
	return emu:read8(address) * 256 + emu:read8(address + 1)
end

function pad(s, size)
	if s:len() >= size then
		return s
	else
		return pad(s .. " ", size)
	end
end

function split(str, delim)
	local v = {}
	while true do
		local start = string.find(str, delim)
		if start then
			table.insert(v, str:sub(0, start - 1))
			str = str:sub(start + 1)
		else
			break
		end
	end
	table.insert(v, str)
	return v
end
