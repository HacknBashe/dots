return {
	statusMap = {
    -- stylua: ignore start 
    [" M"] = { symbol = "", hlGroup  = "GitSignsChange"}, -- Modified in the working directory
    ["M "] = { symbol = "", hlGroup  = "GitSignsChange"}, -- modified in index
    ["MM"] = { symbol = "", hlGroup  = "GitSignsChange"}, -- modified in both working tree and index
    ["A "] = { symbol = "", hlGroup  = "GitSignsAdd"   }, -- Added to the staging area, new file
    ["AA"] = { symbol = "≈", hlGroup  = "GitSignsAdd"   }, -- file is added in both working tree and index
    ["D "] = { symbol = "", hlGroup  = "GitSignsDelete"}, -- Deleted from the staging area
    ["AM"] = { symbol = "", hlGroup  = "GitSignsChange"}, -- added in working tree, modified in index
    ["AD"] = { symbol = "󱓉", hlGroup  = "GitSignsChange"}, -- Added in the index and deleted in the working directory
    ["R "] = { symbol = "", hlGroup  = "GitSignsChange"}, -- Renamed in the index
    ["U "] = { symbol = "‖", hlGroup  = "GitSignsChange"}, -- Unmerged path
    ["UU"] = { symbol = "⇄", hlGroup  = "GitSignsAdd"   }, -- file is unmerged
    ["UA"] = { symbol = "", hlGroup  = "GitSignsAdd"   }, -- file is unmerged and added in working tree
    ["??"] = { symbol = "󱀶", hlGroup  = "GitSignsDelete"}, -- Untracked files
    ["!!"] = { symbol = "", hlGroup  = "GitSignsChange"}, -- Ignored files
		-- stylua: ignore end
	},
}
