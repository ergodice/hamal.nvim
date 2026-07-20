return {
    quit_on_unmapped_keys = true,
    divisions = 3,
    keymaps = {
        ["<esc>"] = function()
            require("hamal").quit()
        end,

        ["h"] = function()
            require("hamal").focus(1)
        end,
        ["m"] = function()
            require("hamal").focus(2)
        end,
        ["l"] = function()
            require("hamal").focus(3)
        end,

        ["s"] = function()
            require("hamal").select()
        end,

        ["H"] = function()
            require("hamal").top()
            require("hamal").quit()
        end,
        ["M"] = function()
            require("hamal").middle()
            require("hamal").quit()
        end,
        ["L"] = function()
            require("hamal").bottom()
            require("hamal").quit()
        end,

        ["-"] = function()
            require("hamal").pan_focus()
        end,
    },
    highlights = {
        section = {
            { "HamalFirstSection",  { link = "ColorColumn" } },
            { "HamalSecondSection", {} },
        },
        line = {},
    },
}
