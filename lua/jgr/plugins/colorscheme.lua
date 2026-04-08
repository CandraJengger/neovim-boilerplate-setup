return {
	"folke/tokyonight.nvim",
	-- "shaunsingh/nord.nvim",
	priority = 1000,
	config = function()
		vim.cmd("colorscheme tokyonight")
		-- vim.cmd("colorscheme nord")
	end,
}
