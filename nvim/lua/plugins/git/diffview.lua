vim.api.nvim_create_user_command("DiffviewOpenOnly", function()
  vim.cmd("DiffviewOpen")
  vim.cmd("tabonly")
end, {})

return {
  "sindrets/diffview.nvim",
  keys = function()
    local function diff_back()
      if vim.v.count > 0 then
        vim.cmd("DiffviewOpen HEAD~" .. tostring(vim.v.count))
        return
      end

      require("snacks.input").input({
        prompt = "Diffview {git-rev}: ",
        default = "HEAD~1",
      }, function(input)
        if input then
          vim.cmd("DiffviewOpen " .. input)
        end
      end)
    end

    return {
      { "<leader>k", "", desc = "+diffview", mode = { "n", "v" } },
      { "<leader>kD", "<cmd>DiffviewOpen<cr>", desc = "Git: Diffview" },
      { "<leader>kl", "<cmd>DiffviewFileHistory<cr>", desc = "Git: Log" },
      { "<leader>k%", "<cmd>DiffviewFileHistory %<cr>", desc = "Git: Log for file" },
      { "<leader>k~", diff_back, desc = "Git: Diffview HEAD~{count}..HEAD" },
    }
  end,
  opts = function()
    local diffview = require("diffview")
    local actions = require("diffview.actions")

    local function git_commit()
      vim.cmd("DiffviewClose")
      vim.cmd("tabnew")
      vim.cmd("Git")
      vim.cmd("wincmd o")

      local prefix = vim.o.columns < 120 and "" or "vertical"
      vim.cmd(prefix .. " Git commit")
    end

    local function quit()
      if #vim.api.nvim_list_tabpages() == 1 then
        vim.cmd("qa")
      else
        vim.cmd("DiffviewClose")
      end
    end

    return {
      enhanced_diff_hl = true,
      file_panel = {
        win_config = {
          width = 50,
        },
      },
      keymaps = {
        view = {
          {
            "n",
            "<tab>",
            actions.select_next_entry,
            { desc = "Open the diff for the next file" },
          },
          {
            "n",
            "<s-tab>",
            actions.select_prev_entry,
            { desc = "Open the diff for the previous file" },
          },
          {
            "n",
            "[F",
            actions.select_first_entry,
            { desc = "Open the diff for the first file" },
          },
          {
            "n",
            "]F",
            actions.select_last_entry,
            { desc = "Open the diff for the last file" },
          },
          {
            "n",
            "<leader>e",
            actions.focus_files,
            { desc = "Bring focus to the file panel" },
          },
          { "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
          {
            "n",
            "gf",
            actions.goto_file_edit,
            { desc = "Open the file in the previous tabpage" },
          },
          {
            "n",
            "<C-w><C-f>",
            actions.goto_file_split,
            { desc = "Open the file in a new split" },
          },
          {
            "n",
            "<C-w>gf",
            actions.goto_file_tab,
            { desc = "Open the file in a new tabpage" },
          },
          {
            "n",
            "g<C-x>",
            actions.cycle_layout,
            { desc = "Cycle through available layouts" },
          },
          {
            "n",
            "[x",
            actions.prev_conflict,
            { desc = "Jump to the previous conflict" },
          },
          {
            "n",
            "]x",
            actions.next_conflict,
            { desc = "Jump to the next conflict" },
          },
          { "n", "co", actions.conflict_choose("ours"), { desc = "Choose OURS" } },
          { "n", "ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS" } },
          { "n", "cb", actions.conflict_choose("all"), { desc = "Choose BOTH" } },
          { "n", "c0", actions.conflict_choose("none"), { desc = "Choose NONE" } },
          ["<leader>ca"] = false,
          ["<leader>cb"] = false,
          ["<leader>co"] = false,
          ["<leader>ct"] = false,
          ["<leader>cA"] = false,
          ["<leader>cB"] = false,
          ["<leader>cO"] = false,
          ["<leader>cT"] = false,
          ["q"] = quit,
        },
        file_panel = {
          ["i"] = actions.prev_entry,
          ["k"] = actions.next_entry,
          ["j"] = actions.close_fold,
          ["l"] = actions.select_entry,
          ["h"] = false,

          ["<up>"] = actions.prev_entry,
          ["<down>"] = actions.next_entry,
          ["<cr>"] = actions.select_entry,
          ["o"] = actions.select_entry,
          ["<2-LeftMouse>"] = actions.select_entry,

          ["-"] = actions.toggle_stage_entry,
          ["s"] = actions.toggle_stage_entry,
          ["S"] = actions.stage_all,
          ["U"] = actions.unstage_all,
          ["X"] = actions.restore_entry,

          ["<tab>"] = actions.select_next_entry,
          ["<s-tab>"] = actions.select_prev_entry,
          ["[F"] = actions.select_first_entry,
          ["]F"] = actions.select_last_entry,

          ["zo"] = actions.open_fold,
          ["zc"] = actions.close_fold,
          ["za"] = actions.toggle_fold,
          ["zR"] = actions.open_all_folds,
          ["zM"] = actions.close_all_folds,

          ["<c-b>"] = actions.scroll_view(-0.25),
          ["<c-f>"] = actions.scroll_view(0.25),

          ["<leader>e"] = actions.focus_files,
          ["<leader>b"] = actions.toggle_files,
          ["g<C-x>"] = actions.cycle_layout,

          ["gf"] = actions.goto_file_edit,
          ["<C-w><C-f>"] = actions.goto_file_split,
          ["<C-w>gf"] = actions.goto_file_tab,

          ["f"] = actions.toggle_flatten_dirs,
          ["R"] = actions.refresh_files,
          ["L"] = actions.open_commit_log,

          ["[x"] = actions.prev_conflict,
          ["]x"] = actions.next_conflict,
          ["<leader>cO"] = actions.conflict_choose_all("ours"),
          ["<leader>cT"] = actions.conflict_choose_all("theirs"),
          ["<leader>cB"] = actions.conflict_choose_all("base"),
          ["<leader>cA"] = actions.conflict_choose_all("all"),
          ["dX"] = actions.conflict_choose_all("none"),

          ["g?"] = actions.help("file_panel"),
          ["q"] = quit,
          ["cc"] = git_commit,
        },
        file_history_panel = {
          ["i"] = actions.prev_entry,
          ["k"] = actions.next_entry,
          ["j"] = actions.close_fold,
          ["l"] = actions.select_entry,
          ["h"] = false,

          ["<c-k>"] = actions.select_next_commit,
          ["<c-i>"] = actions.select_prev_commit,

          ["<up>"] = actions.prev_entry,
          ["<down>"] = actions.next_entry,
          ["<cr>"] = actions.select_entry,
          ["o"] = actions.select_entry,
          ["<2-LeftMouse>"] = actions.select_entry,

          ["<tab>"] = actions.select_next_entry,
          ["<s-tab>"] = actions.select_prev_entry,
          ["[F"] = actions.select_first_entry,
          ["]F"] = actions.select_last_entry,

          ["zo"] = actions.open_fold,
          ["zc"] = actions.close_fold,
          ["za"] = actions.toggle_fold,
          ["zR"] = actions.open_all_folds,
          ["zM"] = actions.close_all_folds,

          ["y"] = actions.copy_hash,
          ["X"] = actions.restore_entry,

          ["<c-b>"] = actions.scroll_view(-0.25),
          ["<c-f>"] = actions.scroll_view(0.25),

          ["<leader>e"] = actions.focus_files,
          ["<leader>b"] = actions.toggle_files,
          ["g<C-x>"] = actions.cycle_layout,

          ["gf"] = actions.goto_file_edit,
          ["<C-w><C-f>"] = actions.goto_file_split,
          ["<C-w>gf"] = actions.goto_file_tab,

          ["L"] = actions.open_commit_log,
          ["g!"] = actions.options,
          ["<C-A-d>"] = actions.open_in_diffview,

          ["<leader>hd"] = function()
            diffview.emit("copy_hash")
            vim.cmd("DiffviewOpen " .. vim.fn.getreg("*") .. "^!")
          end,

          ["g?"] = actions.help("file_history_panel"),
          ["q"] = quit,
        },
        option_panel = {
          ["<tab>"] = actions.select_entry,
          ["q"] = actions.close,
          ["g?"] = actions.help("option_panel"),
        },
        help_panel = {
          ["q"] = actions.close,
          ["<esc>"] = actions.close,
        },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          vim.schedule(function()
            vim.api.nvim_buf_call(bufnr, function()
              vim.cmd("normal! gg]czz")
            end)
          end)
        end,
      },
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
    }
  end,
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
}
