-- plugin/tinygo-nvim.lua
if vim.g.loaded_tinygo_nvim then
	return
end
vim.g.loaded_tinygo_nvim = true

local tinygo = require("tinygo-nvim")

-- Основная команда для установки цели
vim.api.nvim_create_user_command("TinygoTarget", function(opts)
	tinygo.set_target(opts.args)
end, {
	nargs = 1,
	complete = function(arg_lead)
		return tinygo.complete_targets(arg_lead)
	end,
	desc = "Set TinyGo target environment and restart LSP"
})

-- Команда для просмотра доступных целей
vim.api.nvim_create_user_command("TinygoTargets", function()
	tinygo.show_targets()
end, {
	desc = "Show available TinyGo targets"
})

-- Автоматическая проверка при открытии Go файлов
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		if vim.fn.executable("tinygo") == 1 then
			vim.notify("TinyGo plugin ready (use :TinygoTarget)", vim.log.levels.INFO)
		end
	end
})
