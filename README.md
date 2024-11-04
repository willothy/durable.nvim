# 📦 durable.nvim

*SQLite-backed key-value store and persistent objects for Neovim*

Inspired by my friends at [freestyle](https://github.com/freestyle-sh), and by Cloudflare Durable Objects.

[![License](https://img.shields.io/github/license/willothy/durable.nvim.svg)](https://github.com/willothy/durable.nvim/blob/main/LICENSE)
[![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.10+-green.svg)](https://neovim.io)

---

## Table of Contents

- [Introduction](#introduction)
- [🚀 Features](#-features)
- [🛠️ Installation](#️-installation)
  - [Requirements](#requirements)
  - [Plugin Managers](#plugin-managers)
- [📖 Usage](#-usage)
  - [Key-Value Store](#key-value-store)
  - [Persistent Objects](#persistent-objects-development-in-progress)
- [🔧 Configuration](#-configuration)
- [💡 Examples](#-examples)
  - [Caching API Responses](#caching-api-responses)
  - [Saving Plugin State](#saving-plugin-state)
- [🛣️ Roadmap](#️-roadmap)
- [🤝 Contributing](#-contributing)
- [📝 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)
- [🐞 Issues and Support](#-issues-and-support)

---

## Introduction

`durable.nvim` brings the power of persistent storage to your Neovim environment. By leveraging SQLite, it allows you to store and retrieve data across Neovim sessions effortlessly. Ideal for plugin developers and users who need a simple yet robust way to maintain state, cache data, or manage complex objects over time.

---

## 🚀 Features

- ⚡ **SQLite-backed key-value store**: Fast and reliable data storage using SQLite.
- 💾 **Persistent objects**: Store Lua tables and objects persistently.
- 🛠️ **Easy API**: Simple functions to get you started quickly.
- 🪶 **Lightweight**: Minimal dependencies and overhead.
- 🔧 **Customizable**: Configure storage paths and settings.

---

## 🛠️ Installation

### Requirements

- [Neovim](https://neovim.io/) 0.10 or higher
- [sqlite.lua](https://github.com/kkharji/sqlite.lua)

### Plugin Managers

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```vim
{
  "willothy/durable.nvim",
  config = true,
}
```

---

## 📖 Usage

### Key-Value Store

`durable.nvim` provides a simple API for key-value storage.

Keys should always be strings, but multiple value types are supported. `durable.nvim` tracks
value types to provide type-safety between Lua and SQLite.

Supported types are `string`, `number`, `boolean`, `table` (json), and `nil`.

**Setting a value**

```lua
local durable = require('durable')
local kv = durable.kv

-- Set a value
kv.set('theme', 'gruvbox')
```

**Getting a value**

```lua
-- Get a value
local theme = kv.get('theme')  -- returns 'gruvbox'
```

**Deleting a key**

```lua
-- Delete a key
kv.delete('theme')
```

#### Namespaces

By default all operations happen in a global namespace, but all functions accept
a namespace parameter which provides scoping/isolaiton for plugins and other use
cases.

```lua
kv.set('enable_my_plugin', true, "my_plugin")
```

### Persistent Objects (development in-progress)

Store complex Lua tables, including nested tables and complex state.

**Storing an object**

```lua
---@class PersistentCounter
---@field count number
local PersistentCounter = {}

function PersistentCounter:increment()
  self.count = self.count + 1
end

function PersistentCounter:decrement()
  self.count = self.count - 1
end

-- state is automatically persistent across sessions using the given id,
-- in this case "counter"
local counter = durable.persist("counter", PersistentCounter)

counter:increment()
```

---

## 🔧 Configuration

Customize the plugin by setting variables in your `init.lua` or `init.vim`.

```lua
require('durable').setup({
  db_path = vim.fn.stdpath('data') .. '/databases/durable.db',
})
```

---

## 💡 Examples

### Caching API Responses

```lua
local http = require('socket.http')

local function get_data()
  local cached = kv.get('api_response', "my_api_cache")
  if cached then
    return cached
  else
    local response = http.request('http://api.example.com/data')
    durable.set_object('api_response', response, "my_api_cache")
    return response
  end
end

vim.print(get_data())
```

### Saving Plugin State

```lua
-- Save window layout or other state information
kv.set('window_state', vim.fn.getwininfo())

-- Later, restore the state
local window_state = kv.get('window_state')
-- Use vim.fn.winrestview(window_state) or similar functions
```

---

## 🛣️ Roadmap

- [ ] Persistent objects (in progress)
- [ ] Add support for transactions
- [ ] Implement TTL (Time to Live) for keys
- [ ] Support for custom serialization methods
- [ ] Performance optimizations

See the [open issues](https://github.com/willothy/durable.nvim/issues) for a full list of proposed features (and known issues).

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a pull request.

Please make sure to update tests as appropriate.

---

## 📝 License

Distributed under the MIT License. See [LICENSE](https://github.com/willothy/durable.nvim/blob/main/LICENSE) for more information.

---

## 🙏 Acknowledgments

- [Neovim Lua API](https://neovim.io/doc/user/lua.html)
- [sqlite.lua](https://github.com/kkharji/sqlite.lua) - SQLite/LuaJIT binding for Lua and Neovim

---

## 🐞 Issues and Support

If you encounter any issues or have questions, feel free to open an [issue](https://github.com/willothy/durable.nvim/issues) on GitHub.
