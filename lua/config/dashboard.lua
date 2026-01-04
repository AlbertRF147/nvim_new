return {
	sections = {
		{ section = "header" },
		-- In your snacks dashboard sections
		{
			section = "terminal",
			cmd = "chafa ~/.config/nvim/plain_concepts.png --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
			height = 17,
			padding = 1,
		},
		{ section = "keys", gap = 1, padding = 1 },
		{
			pane = 2,
			icon = " ",
			title = "Recent Files",
			section = "recent_files",
			indent = 2,
			padding = 1,
		},
		{ pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
		{
			pane = 2,
			title = "Git Status",
			section = "terminal",
			enabled = function()
				return Snacks.git.get_root() ~= nil
			end,
			-- Adding 'args' and using 'git' directly is cleaner than a raw string
			cmd = "git status --short --branch",
			height = 5,
			padding = 1,
			ttl = 5 * 60,
			indent = 3,
		},
		{ section = "startup" },
	},
}
