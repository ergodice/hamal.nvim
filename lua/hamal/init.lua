local M = {}

local state = require("hamal.state")
local defaults = require("hamal.config")
local split_utils = require("hamal.split_utils")
local Controller = require("hamal.controller")

local Searcher = require("hamal.searcher")

function M.setup(opts)
	opts = opts or {}
	state.opts = vim.tbl_deep_extend("force", defaults, opts)
	state.ns = vim.api.nvim_create_namespace("hamal")

	local normalized = {}

	for lhs, rhs in pairs(state.opts.keymaps) do
		normalized[vim.keycode(lhs)] = rhs
	end

	state.opts.keymaps = normalized

    -- register highlights
	for _, hl in ipairs(state.opts.highlights.section) do
		local name, spec = hl[1], hl[2]
        if name and spec then
            vim.api.nvim_set_hl(0, name, spec)
        end
	end

	for _, var in ipairs(state.opts.highlights.line) do
        if var.top or var.bottom then
            require("hamal.utils").assert(var.top, "HL_NOT_DEFINED_CORRECTLY")
            require("hamal.utils").assert(var.bottom, "HL_NOT_DEFINED_CORRECTLY")
            local name_top, spec_top = var.top[1], var.top[2]
            local name_bottom, spec_bottom = var.bottom[1], var.bottom[2]
            if name_top and spec_top then
                vim.api.nvim_set_hl(0, name_top, spec_top)
            end
            if name_bottom and spec_bottom then
                vim.api.nvim_set_hl(0, name_bottom, spec_bottom)
            end
        else
            local name, spec = var[1], var[2]
            if name and spec then
                vim.api.nvim_set_hl(0, name, spec)
            end
        end
	end
end

function M.split()
	local winid = vim.api.nvim_get_current_win()
	local split, err = split_utils.displayed_lines(winid)
	require("hamal.utils").assert(split, err)

	local searcher = Searcher.new(winid, state.opts.divisions, split)
	local controller = Controller.new(searcher)

	state.controllers[winid] = controller
	controller:split()
end

local function get_controller()
	local winid = vim.api.nvim_get_current_win()
	local controller = state.controllers[winid]
	return controller
end

function M.focus(index)
	local controller = get_controller()
	if controller == nil then
		return
	end
	controller:focus(index)
end

function M.pan_focus()
	local controller = get_controller()
	if controller == nil then
		return
	end

	controller:pan_focus()
end

function M.quit()
	local controller = get_controller()
	if controller == nil then
		return
	end
	controller:quit()
end

function M.top()
	local controller = get_controller()
	if controller == nil then
		return
	end
	controller.searcher:set_cursor(1)
end

function M.middle()
	local controller = get_controller()
	if controller == nil then
		return
	end

	controller.searcher:set_cursor(2)
end

function M.bottom()
	local controller = get_controller()
	if controller == nil then
		return
	end

	controller.searcher:set_cursor(3)
end

function M.select()
	local controller = get_controller()
	if controller == nil then
		return
	end
	controller:select()
end

return M
