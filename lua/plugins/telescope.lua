return
{
    'nvim-telescope/telescope.nvim',
    version = '*',
    cmd = "Telescope",
    keys = {
        { '<leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Telescope find files' },
        { '<leader>fw', function() require('telescope.builtin').live_grep() end, desc = 'Telescope live grep' },
        { '<leader>fb', function() require('telescope.builtin').buffers() end, desc = 'Telescope buffers' },
        { '<leader>fh', function() require('telescope.builtin').help_tags() end, desc = 'Telescope help tags' },
        { '<leader>fr', function() require('telescope.builtin').diagnostics() end, desc = 'Telescope all diagnostics' },
        { '<leader>ft', '<cmd>TodoTelescope<CR>', desc = 'Open Telescope TODO List' },
    },
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        local actions = require('telescope.actions')
        require('telescope').setup {
            defaults = {
                vimgrep_arguments = {
                    'rg', '--color=never', '--no-heading', '--with-filename',
                    '--line-number', '--column', '--smart-case',
                    '--no-ignore', '--hidden',
                },
                file_ignore_patterns = { '^%.git/', '/%.git/', 'node_modules/' },
                mappings = {
                    i = {                             -- Mappings for insert mode
                        ["<M-q>"] = actions.send_to_qflist,
                    },
                    n = {                             -- Mappings for normal mode
                        ["<M-q>"] = actions.send_to_qflist
                    },
                },
            },
            pickers = {
                find_files = { hidden = true, no_ignore = true },
            },
        }
    end
}
