# hamal.nvim

> Fast and intuitive line navigation for Neovim.

![preview](./images/preview.png)
`hamal.nvim` recursively divides the current window, letting you reach any visible line with only a few keystrokes.

Instead of typing a line number or repeatedly pressing `j`/`k`, simply choose the region containing your destination until you get there.

## Features

- ⚡️ Fast visual line navigation
- ⚙️ Configurable number of divisions
- 🖊️ Customizable keymaps and highlights
- ⏱️ Lightweight
- 🐱 No dependencies

## Why?

With **3 divisions**, navigating within a 100-line window takes at most **5 keypresses**.

| Divisions | Max keypresses (100 lines) |
| --------: | -------------------------: |
|         2 |                          7 |
|         3 |                          5 |
|         4 |                          4 |
|         5 |                          3 |

The required keypresses are approximately:

```
ceil(logₙ(lines))
```

where `n` is the number of divisions.

## Usage

A minimal usage example is as follows.

```lua
{
    "ergodice/hamal.nvim"
    config = function()
        local hamal = require("hamal")

        -- keymaps
        vim.keymap.set("n", "<leader><leader>", hamal.split)
        vim.keymap.set("o", "<leader><leader>", hamal.split) -- To use hamal mode in the o-pending mode.
        -- you can also use hamal in visual mode
        -- vim.keymap.set("v", "<leader><leader>", hamal.split)

        -- You must call hamal.setup() at least once.
        hamal.setup({})
    end,
}
```

Please note that `split` should be defined outside of `opt.keymaps` in the `setup` argument.

#### Default Keymap

| Default Keys       | Description                                                        |
| ------------------ | ------------------------------------------------------------------ |
| `<leader><leader>` | Enter Hamal mode by splitting the current window.                  |
| `h`                | Focus the top split.                                               |
| `m`                | Focus the middle split.                                            |
| `l`                | Focus the bottom split.                                            |
| `-`                | Return focus to the previously focused split.                      |
| `H`                | Jump to the first line of the current region and exit Hamal mode.  |
| `M`                | Jump to the middle line of the current region and exit Hamal mode. |
| `L`                | Jump to the last line of the current region and exit Hamal mode.   |
| `s`                | Select the current split.                                          |
| `<esc>`            | Exit Hamal mode without moving the cursor.                         |

Hamal mode also works in operator-pending mode.

In the default configuration, `d<leader><leader><split>s` deletes the contents of the current split.

Linewise motions can also be passed to the pending operator.
For example, `y<leader><leader><motion>` yanks from the starting line to the destination line.

## Configuration

```lua
-- default configuration
{
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
```

#### Keymaps

You can customize `keymaps` freely.

The table uses the format `[<key>] = <function>`. To disable a keymap, set it to `[<key>] = false`.

#### Custom highlights

You can freely define your own `highlights`.

Highlights are applied in order, regardless of their names. If fewer highlight groups are provided than there are splits, the highlight groups are reused in a loop.

For example, you can define your own highlight group like this. Since this example defines only one highlight group, all sections will be rendered with the same color.

```lua
highlights = {
    section = {
        { "HamalMyCustomSection",  { fg = "#88c0d0" } },
    }
}
```

You can also customize the highlight group used for section borders with `border`.

Like `section`, each entry can be defined as a `{ <name>, <spec> }` pair.

Alternatively, you can define separate highlight groups for the top and bottom borders:

```lua
highlights = {
    border = {
        {
            -- you have to set both, top and bottom
            top = { "HamalFirstBorderTop",  { link = "ColorColumn" } },
            bottom = { "HamalFirstBorderBottom",  { link = "Search" } },
        },
        { "HamalSecondBorder", {} },
    }
}
```

## Public API

| Function       | Description                                                                                    |
| -------------- | ---------------------------------------------------------------------------------------------- |
| `split()`      | Enter hamal mode by dividing the current window. Usually mapped to a key outside of `setup()`. |
| `focus(index)` | Focus the `index`-th region of the current split (1 <= index <= divisions).                    |
| `pan_focus()`  | Focus the parent region (the previous split level).                                            |
| `top()`        | Jump to the first line of the current region.                                                  |
| `middle()`     | Jump to the middle line of the current region.                                                 |
| `bottom()`     | Jump to the last line of the current region.                                                   |
| `quit()`       | Exit hamal mode without moving the cursor.                                                     |
| `select()`     | Select the current split.                                                                      |
