local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

treesitter.setup({
	highlight = {
		enable = true,
	},
	indent = { enable = true },
	autotag = { enable = true },
	ensure_installed = {
		"json",
		"html",
		"css",
		"markdown",
		-- "lua",
		"bash",
		"vim",
		"dockerfile",
		"gitignore",
		"python",
	},
	auto_install = true,
})
