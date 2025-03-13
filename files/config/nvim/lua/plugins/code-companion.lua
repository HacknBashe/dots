return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("codecompanion").setup({
			display = {
				action_palette = {
					-- broken for now
					-- provider = "mini_pick",
				},
				chat = {
					intro_message = "󱙺 Press ? for options",
					start_in_insert_mode = true,
				},
				diff = {
					provider = "mini_diff",
				},
			},
			strategies = {
				chat = {
					adapter = "claude",
					slash_commands = {
						["file"] = {
							opts = {
								provider = "telescope",
							},
						},
					},
				},
				inline = {
					adapter = "claude",
				},
			},
			opts = {
				system_prompt = function(opts)
					return [[You are an AI programming assistant named "CodeCompanion". You are currently plugged in to the Neovim text editor on a user's machine.

Your core tasks include:
- Answering general programming questions.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code in a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Running tools.

You must:
- Follow the user's requirements carefully and to the letter.
- Keep your answers short and impersonal, especially if the user responds with context outside of your tasks.
- Minimize other prose.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.
- Avoid including line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.
- Use actual line breaks instead of '\n' in your response to begin new lines.
- Use '\n' only when you want a literal backslash followed by a character 'n'.
- All non-code responses must be in %s.

When given a task:
1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.
2. Output the code in a single code block, being careful to only return relevant code.
3. You should always generate short suggestions for the next user turns that are relevant to the conversation.
4. You can only give one reply for each conversation turn.

Rules are user-provided instructions for the AI to follow to help work with the codebase.

Rules live in *.rules.md files. If a rule file is attached, you must follow it's instructions closely.

Rules are extra documentation provided by the user to help the AI understand the codebase.

Use them if they seem useful to the user's most recent query, but do not use them if they seem unrelated.]]
				end,
			},
			adapters = {
				opts = {
					show_defaults = false,
				},
				-- ml_nlp = require("plugins.cc-ml-nlp"),
				claude = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "claude-3.7-sonnet",
							},
							max_tokens = {
								default = 65536,
							},
						},
					})
				end,
				o3 = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "o3-mini-2025-01-31",
							},
							max_tokens = {
								default = 65536,
							},
						},
					})
				end,
				["4o"] = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "gpt-4o",
							},
							max_tokens = {
								default = 65536,
							},
						},
					})
				end,
			},
		})

		vim.keymap.set(
			{ "n", "v" },
			"<leader>at",
			"<cmd>CodeCompanionChat Toggle<cr>",
			{ desc = "AI Chat Toggle", noremap = true, silent = true }
		)

		vim.keymap.set(
			{ "n", "v" },
			"<leader>ac",
			"<cmd>CodeCompanionChat claude<cr>",
			{ desc = "New AI Chat", noremap = true, silent = true }
		)

		vim.keymap.set(
			"n",
			"<leader>ae",
			"<cmd>CodeCompanionChat claude<cr>@editor #buffer<cr>",
			{ desc = "New AI Editor", noremap = true, silent = true }
		)
		vim.keymap.set(
			"v",
			"<leader>ae",
			"<cmd>CodeCompanionChat claude<cr><cr>@editor #buffer<cr>",
			{ desc = "New AI Editor", noremap = true, silent = true }
		)

		vim.keymap.set(
			{ "n", "v" },
			"<leader>aA",
			"<cmd>CodeCompanionActions<cr>",
			{ desc = "AI Actions", noremap = true, silent = true }
		)

		vim.keymap.set(
			"v",
			"<leader>aa",
			"<cmd>CodeCompanionChat Add<cr>",
			{ desc = "Add to AI Chat", noremap = true, silent = true }
		)

		-- Expand 'cc' into 'CodeCompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end,
}
