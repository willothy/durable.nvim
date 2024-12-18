---@module "durable.db"

local sqlite = require("sqlite.db")

---@return sqlite_db
local db

---@class durable.db
local M = {}

---@param config durable.Config
function M.setup(config)
	db = sqlite({
		uri = config.db_path,
		opts = {},
	}) --[[@as sqlite_db]]

	db:open(config.db_path)
end

---@return sqlite_db
function M.get()
	return db
end

return M
