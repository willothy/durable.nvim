---@module "durable"

local kv = require("durable.kv")
local db = require("durable.db")

---@class durable
local M = {}

M.kv = kv

local config = {
	db_path = vim.fn.stdpath("data") .. "/databases/durable.db",
}

---@class durable.Config
---@field db_path string

---@class durable.PartialConfig
---@field db_path? string

---@param opts durable.PartialConfig
function M.setup(opts)
	opts = opts or {}

	config = vim.tbl_deep_extend("force", config, opts)

	db.setup(config)
	kv.setup(config)
end

return M
