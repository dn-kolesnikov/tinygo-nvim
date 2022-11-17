if vim.g.loaded_tinygo_target then
	return
end
vim.g.loaded_tinygo_target = true

vim.api.nvim_create_user_command("TinygoTarget", function(opts)
	require("tinygo-nvim").ChangeTinygoTargetTo(opts.args)
end, {
	nargs = 1,
	complete = function(_, _, _)
		return require("tinygo-nvim").TinygoTargetsList
	end,
})
