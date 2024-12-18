---@module "durable.kv"

---@alias durable.kv.Key string

---@alias durable.kv.Type
---       | "string"
---       | "number"
---       | "table"
---       | "boolean"
---       | "nil"

---@alias durable.kv.Value
---       | string
---       | number
---       | boolean
---       | table
---       | nil

---@class durable.kv.Entry
---@field key durable.kv.Key
---@field value durable.kv.Value
---@field ltype durable.kv.Type
---@field ns string

local config_ref

local serde = require("durable.serde")
local db = require("durable.db")

local GLOBAL = "__GLOBAL__"

---@class durable.kv
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
		not db.get():update("willothy_kv", {
			where = { key = key },
			set = {
				value = ser,
				ltype = ty,
				namespace = ns,
			},
		})
	then
		db.get():insert("willothy_kv", {
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

	---@diagnostic disable-next-line: missing-fields
	local res = db.get():select("willothy_kv", {
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
	db.get():delete("willothy_kv", {
		---@diagnostic disable-next-line: assign-type-mismatch
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
	---@diagnostic disable-next-line: missing-fields
	return db.get():select("willothy_kv", {
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

---@param config durable.Config
function kv.setup(config)
	local _ = config

	db.get():execute([[
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
