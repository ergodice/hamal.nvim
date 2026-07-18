return {
    quit_on_unmapped_keys = true,
    divisions = 3,
    keymaps = {
        ["q"] = function()
            require("hamal").quit()
        end,
        ["H"] = function()
            require("hamal").focus(1)
        end,
        ["M"] = function()
            require("hamal").focus(2)
        end,
        ["L"] = function()
            require("hamal").focus(3)
        end,

        ["h"] = function()
            require("hamal").top()
        end,
        ["m"] = function()
            require("hamal").middle()
        end,
        ["l"] = function()
            require("hamal").bottom()
        end,

        ["<Esc>"] = function()
            require("hamal").pan_focus()
        end,
    },
    highlights = {
        { "HamalTop", { link = "IncSearch" } },
        { "HamalMid", { link = "Search" } },
        { "HamalBot", { link = "CurSearch" } },
    },
}
