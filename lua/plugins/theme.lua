return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        transparent_background = true,
        term_colors = true,
        custom_highlights = function(c)
            local blend = require("catppuccin.utils.colors").blend
            return {
                DiffAdd = { bg = blend(c.green, c.base, 0.25) },
                DiffDelete = { bg = blend(c.red, c.base, 0.25), fg = blend(c.red, c.base, 0.5) },
                DiffChange = { bg = blend(c.yellow, c.base, 0.12) },
                DiffText = { bg = blend(c.blue, c.base, 0.4) },
            }
        end,
        integrations = {
            mason = true,
            fidget = true

        }

    }
}
