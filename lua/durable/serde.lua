local deserializers = setmetatable({
	string = function(s)
		return s
	end,
	number = function(s)
		return tonumber(vim.base64.decode(s))
	end,
	table = function(s)
		return vim.json.decode(s, {
			luanil = {
				object = true,
				array = true,
			},
		})
	end,
	boolean = function(s)
		if s == "true" then
			return true
		end
		return false
	end,
	["nil"] = function() end,
}, {
	__index = function(_, k)
		error(string.format("Unsupported type %s", k))
	end,
})

local serializers = setmetatable({
	string = function(s)
		return s
	end,
	number = function(num)
		return vim.base64.encode(tostring(num))
	end,
	table = function(tbl)
		return vim.json.encode(tbl)
	end,
	boolean = function(bool)
		return tostring(bool)
	end,
	["nil"] = function() end,
}, {
	__index = function(_, k)
		error(string.format("Unsupported type %s", k))
	end,
})

local M = {}

function M.serialize(value)
	local t = type(value)
	return serializers[t](value), t
end

function M.deserialize(str, type)
	return deserializers[type](str)
end

return M
