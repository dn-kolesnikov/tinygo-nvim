-- lua/tinygo-nvim.lua
local M = {}

-- Кэш для списка целей и информации о них
local cache = {
	targets = {},
	info = {}
}

-- Проверка наличия tinygo в $PATH
local function check_tinygo_available()
	if vim.fn.executable("tinygo") ~= 1 then
		vim.notify("tinygo: executable not found in $PATH", vim.log.levels.ERROR)
		return false
	end
	return true
end

-- Получение списка целей с кэшированием
local function get_tinygo_targets()
	if #cache.targets > 0 then
		return cache.targets
	end

	if not check_tinygo_available() then
		return {}
	end

	local targets = vim.split(vim.fn.system({ "tinygo", "targets" }), "\n", { trimempty = true })
	table.insert(targets, "-") -- Специальный символ для сброса
	cache.targets = targets
	return targets
end

-- Получение информации о цели с кэшированием
local function get_tinygo_info(target)
	if cache.info[target] then
		return cache.info[target]
	end

	local json = vim.fn.system({ "tinygo", "info", "-json", "-target", target })
	local ok, output = pcall(vim.json.decode, json)
	if not ok or not output.goroot or not output.build_tags then
		vim.notify("Failed to get info for target: " .. target, vim.log.levels.ERROR)
		return nil
	end

	cache.info[target] = output
	return output
end

-- Перезапуск LSP сервера
local function restart_lsp()
	-- Получаем список всех клиентов
	local clients = vim.lsp.get_clients()

	-- Собираем конфигурации активных клиентов
	local configs = {}
	for _, client in ipairs(clients) do
		if client.attached_buffers[vim.api.nvim_get_current_buf()] then
			table.insert(configs, client.config)
		end
	end

	-- Останавливаем и перезапускаем клиенты
	for _, config in ipairs(configs) do
		-- Находим клиента по имени и останавливаем его
		for _, client in ipairs(vim.lsp.get_clients({ name = config.name })) do
			vim.lsp.stop_client(client.id)
		end

		-- Перезапускаем с небольшой задержкой
		vim.defer_fn(function()
			vim.lsp.start(config)
		end, 100)
	end

	vim.notify("LSP servers restarted", vim.log.levels.INFO)
end

-- Функция для автодополнения
function M.complete_targets(arg_lead)
	local targets = get_tinygo_targets()
	local matches = {}

	for _, target in ipairs(targets) do
		if target:find("^" .. arg_lead) then
			table.insert(matches, target)
		end
	end

	return matches
end

-- Основные функции
function M.set_target(target)
	if not target or target == "" then
		vim.notify("Please specify target", vim.log.levels.WARN)
		return
	end

	local targets = get_tinygo_targets()
	if not vim.tbl_contains(targets, target) then
		vim.notify("Invalid target: " .. target, vim.log.levels.ERROR)
		return
	end

	-- Проверяем, что это не gopls
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == "gopls" then
			vim.notify("This plugin is for TinyGo projects only!", vim.log.levels.WARN)
			return
		end
	end

	if target == "-" then
		vim.env.GOFLAGS = nil
		vim.env.GOROOT = nil
		vim.notify("Reset TinyGo environment", vim.log.levels.INFO)
	else
		local info = get_tinygo_info(target)
		if not info then return end

		vim.env.GOFLAGS = "-tags=" .. table.concat(info.build_tags, ",")
		vim.env.GOROOT = info.goroot
		vim.notify(string.format("Set target: %s\nGOROOT: %s\nTags: %s",
				target, info.goroot, table.concat(info.build_tags, ", ")),
			vim.log.levels.INFO)
	end

	-- Перезапускаем LSP сервер
	restart_lsp()
end

function M.show_targets()
	local targets = get_tinygo_targets()
	if #targets == 0 then
		vim.notify("No targets available", vim.log.levels.WARN)
		return
	end

	local msg = { "Available TinyGo targets:", "" }
	for _, target in ipairs(targets) do
		table.insert(msg, "  • " .. target)
	end
	vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO)
end

return M
