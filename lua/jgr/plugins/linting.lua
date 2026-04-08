return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },

	config = function()
		local lint = require("lint")

		-- Function: detect biome.json in project root
		local function has_biome_config()
			local biome_files = vim.fs.find(
				{ "biome.json", "biome.jsonc" },
				{ upward = true, type = "file", stop = vim.loop.os_homedir() }
			)
			return #biome_files > 0
		end

		-- Auto-select linter depending on biome
		local function get_linters(ft)
			local biome = has_biome_config()

			local eslint_types = {
				javascript = true,
				typescript = true,
				javascriptreact = true,
				typescriptreact = true,
				svelte = true,
			}

			if eslint_types[ft] then
				if biome then
					return { "biomejs" }
				else
					return { "eslint_d" }
				end
			end

			-- default for other languages
			if ft == "python" then
				return { "pylint" }
			end

			return {}
		end

		-- Override linters_by_ft dynamically using a function
		lint.linters_by_ft = setmetatable({}, {
			__index = function(_, ft)
				return get_linters(ft)
			end,
		})

		-- Autocmd to run linting
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
