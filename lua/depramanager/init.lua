local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local uv = vim.loop

-- Helper to create Telescope pickers
local function create_picker(title, results)
	pickers
		.new({}, {
			prompt_title = title,
			finder = finders.new_table({ results = results }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				map("i", "<CR>", function()
					local selection = action_state.get_selected_entry()
					if not selection then
						vim.notify("No selection made", vim.log.levels.WARN)
						return
					end
					actions.close(prompt_bufnr)
					vim.notify("Selected: " .. selection[1])
				end)
				return true
			end,
		})
		:find()
end

-- === Python ===
function M.python()
	local function find_venv()
		local paths = { ".venv", "venv", "env" }
		for _, dir in ipairs(paths) do
			local full = vim.fn.getcwd() .. "/" .. dir
			local python = full .. "/bin/python"
			if uv.fs_stat(python) then
				return python
			end
		end
		return nil
	end

	local python = find_venv()
	if not python then
		vim.notify("No virtual environment found (.venv/, venv/, env/)", vim.log.levels.ERROR)
		return
	end

	local cmd = python .. " -m pip list --outdated --format=columns"
	local results = vim.fn.systemlist(cmd)

	if vim.v.shell_error ~= 0 or #results == 0 then
		vim.notify("No outdated Python packages", vim.log.levels.INFO)
		return
	end

	create_picker("Outdated Python Packages", results)
end

-- === Go ===
function M.go()
	local results = vim.fn.systemlist("go list -m -u all")

	if vim.v.shell_error ~= 0 or #results == 0 then
		vim.notify("Go command failed or no modules found", vim.log.levels.INFO)
		return
	end

	local filtered = {}
	for _, line in ipairs(results) do
		if line:find("=>") then
			table.insert(filtered, line)
		end
	end

	if #filtered == 0 then
		vim.notify("No outdated Go modules", vim.log.levels.INFO)
		return
	end

	create_picker("Outdated Go Modules", filtered)
end

-- === npm ===
function M.npm()
	local cwd = vim.fn.getcwd()

	if not vim.fn.filereadable(cwd .. "/package.json") then
		vim.notify("No package.json found in project", vim.log.levels.ERROR)
		return
	end

	if not vim.fn.isdirectory(cwd .. "/node_modules") then
		vim.notify("No node_modules/ found — run `npm install` first", vim.log.levels.ERROR)
		return
	end

	local cmd = "npm outdated --depth=0 --color=false"
	local results = vim.fn.systemlist(cmd)

	if #results == 0 then
		if vim.v.shell_error ~= 0 then
			vim.notify(
				"npm outdated failed or no results:\n(exit code: " .. vim.v.shell_error .. ")",
				vim.log.levels.ERROR
			)
		else
			vim.notify("No outdated npm packages 🎉", vim.log.levels.INFO)
		end
		return
	end

	-- Remove header line if present
	if results[1]:match("^Package") then
		table.remove(results, 1)
	end

	create_picker("Outdated npm Packages", results)
end

return M
