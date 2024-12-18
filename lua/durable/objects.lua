---@module "durable.objects"

---@class durable.objects
local M = {}

local db = require("durable.db")
local kv = require("durable.kv")

--
-- list:
-- - id
-- - index -- entry index
-- - value -- entry value
--
-- map:
-- - id
-- - key   -- entry key
-- - value -- entry value
-- - ltype -- entry value type
--
-- atoms:
-- - key   -- field key
-- - value -- field value
-- - ltype -- value type
--
-- roots
--



return M
