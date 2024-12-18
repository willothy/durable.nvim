---@module "durable.serde"

---@type table<durable.kv.Type, fun(value: string): durable.kv.Value>
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

---@type table<durable.kv.Type, fun(value: durable.kv.Value): string>
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

---@class durable.serde
local M = {}

---@param value durable.kv.Value
---@return string, durable.kv.Type
function M.serialize(value)
	local t = type(value)
	if t == "function" then
		error("Cannot serialize function")
	end
	---@cast t durable.kv.Type
	return serializers[t](value), t
end

---@param str string
---@param type durable.kv.Type
---@return durable.kv.Value
function M.deserialize(str, type)
	return deserializers[type](str)
end

return M
