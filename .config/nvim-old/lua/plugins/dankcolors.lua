return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({

				base00 = '#101418',
				base01 = '#101418',
				base02 = '#1d2024',
				base03 = '#8d979f',
				base0B = '#fff332',
				base04 = '#e8f4ff',
				base05 = '#f5faff',
				base06 = '#f5faff',
				base07 = '#f5faff',
				base08 = '#ff739e',
				base09 = '#ff739e',
				base0A = '#60b8ff',
				base0C = '#abd9ff',
				base0D = '#60b8ff',
				base0E = '#7cc4ff',
				base0F = '#7cc4ff',
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
