local M = {}

M.notify_err = function(msg)
    vim.notify(msg, vim.log.levels.ERROR, {
        icon = "",
        title = "hamal.nvim",
    })
end

M.notify_warn = function(msg)
    vim.notify(msg, vim.log.levels.WARN, {
        icon = "",
        title = "hamal.nvim",
        hide_from_history = true,
        timeout = 50,
    })
end

M.notify_info = function(msg)
    vim.notify(msg, vim.log.levels.INFO, {
        icon = "",
        title = "hamal.nvim",
    })
end


M.assert = function(target, msg)
    if target == nil then
        M.notify_err(msg)
    end
end

return M
