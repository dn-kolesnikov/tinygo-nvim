--
local M = {}

local GetTinygoTargets = function()
	if vim.fn.executable("tinygo") ~= 1 then
		error("`tinygo`: executable file not found in $PATH")
	end
	local targets = vim.split(vim.fn.system({ "tinygo", "targets" }), "\n", { trimempty = true })
	table.insert(targets, "-")
	return targets
end

M.TinygoTargetsList = GetTinygoTargets()

M.ChangeTinygoTargetTo = function(target)
	local lsp_name = vim.lsp.get_active_clients()[1].name
	if lsp_name == "gopls" then
		if not vim.tbl_contains(M.TinygoTargetsList, target) then
			error("`" .. target .. "` is not valid target for tinygo")
		end
		if target ~= "-" then
			local json = vim.fn.system({ "tinygo", "info", "-json", "-target", target })
			local output = vim.json.decode(json)
			if output["goroot"] == nil or output["build_tags"] == nil then
				error("Some problem with `tinygo info -target" .. target .. "` execution")
			end
			vim.env.GOFLAGS = "-tags=" .. vim.fn.join(output["build_tags"], ",")
			vim.env.GOROOT = output["goroot"]
		else
			vim.env.GOFLAGS = nil
			vim.env.GOROOT = nil
		end
		vim.cmd("LspRestart")
	else
		vim.notify("Only for TinyGo (GoLang) projects!")
	end
end

return M
