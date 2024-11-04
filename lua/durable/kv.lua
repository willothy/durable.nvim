local config_ref
local db

local sqlite = require("sqlite.db")
local serde = require("durable.serde")

local GLOBAL = "__GLOBAL__"

local kv = {}

kv.GLOBAL = GLOBAL

---@param key durable.kv.Key
---@param value durable.kv.Value
---@param ns  string | nil
function kv.set(key, value, ns)
	if type(key) ~= "string" then
		error("expected string key")
	end
	ns = ns or GLOBAL
	local ser, ty = serde.serialize(value)
	if
		not db:update("willothy_kv", {
			where = { key = key },
			set = {
				value = ser,
				ltype = ty,
				namespace = ns,
			},
		})
	then
		db:insert("willothy_kv", {
			key = key,
			value = value,
			namespace = ns,
		})
	end
end

---@param key durable.kv.Key
---@param ns  string | nil
---@return durable.kv.Value
function kv.get(key, ns)
	if type(key) ~= "string" then
		error("expected string key")
	end
	ns = ns or GLOBAL

	local res = db:select("willothy_kv", {
		where = {
			key = key,
			namespace = ns,
		},
	})[1]

	if res then
		return serde.deserialize(res.value, res.ltype)
	end
end

---@param key durable.kv.Key
---@param ns  string | nil
function kv.delete(key, ns)
	if type(key) ~= "string" then
		error("expected string key")
	end
	ns = ns or GLOBAL
	db:delete("willothy_kv", {
		where = {
			key = key,
			namespace = ns,
		},
	})
end

---@param ns string | nil
---@return durable.kv.Entry[]
function kv.list(ns)
	ns = ns or GLOBAL
	return db:select("willothy_kv", {
		where = {
			namespace = ns,
		},
	})
end

---@param key durable.kv.Key
---@param ns  string | nil
---@param f   fun(value: durable.kv.Value): durable.kv.Value
function kv.update(key, ns, f)
	local val = kv.get(key, ns)

	local res = f(val)

	kv.set(key, res, ns)
end

---@alias durable.kv.Key string

---@alias durable.kv.Value string | number | table | nil

---@class durable.kv.Entry
---@field key durable.kv.Key
---@field value durable.kv.Value
---@field ltype "string" | "number" | "table" | "nil"
---@field ns string

---@param config durable.Config
function kv.setup(config)
	config_ref = config

	db = sqlite({
		uri = config_ref.db_path,
		opts = {},
	}) --[[@as sqlite_db]]

	db:open(config_ref.db_path)
	db:execute([[
    CREATE TABLE IF NOT EXISTS willothy_kv (
      key       TEXT NOT NULL,
      namespace TEXT NOT NULL,
      ltype     TEXT NOT NULL,
      value     TEXT,
      PRIMARY KEY (key, namespace)
    );

    CREATE UNIQUE INDEX IF NOT EXISTS idx_kv_key_ns ON willothy_kv(key, namespace);
  ]])
end

return kv
