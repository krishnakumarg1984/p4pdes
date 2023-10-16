-- vim: foldmethod=marker:foldlevel=0:

-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/SOURCES.md
-- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/859
local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
  return
end
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

-- list of globally installed sources in $PATH (not those installed with ':FInstall')
null_ls.register {
  formatting.stylua,
  -- .with { condition = function(utils)
  --     return utils.root_has_file { "stylua.toml", ".stylua.toml" }
  --   end,
  -- },
  -- formatting.beautysh,
  -- formatting.black,  -- not in $PATH, but installed with ':FInstall' which is automatically made available with ':e!'
  -- formatting.shellharden,
  -- diagnostics.clang_check,
  diagnostics.checkmake,
  diagnostics.cppcheck,
  -- diagnostics.cpplint,
  formatting.clang_format,
}
null_ls.enable {}

-- Other project-specific 'diagnostic-linters' and 'formatters' to consider {{{
-- formatting.asmformat,
-- formatting.bibclean,
-- formatting.brittany,
-- formatting.format_r, -- needs the 'R' command to be in $PATH
-- formatting.fprettify,
-- formatting.goformat,
-- formatting.goimports,
-- formatting.latexindent,
-- formatting.mdformat,
-- formatting.perltidy,
-- formatting.reorder_python_imports,
-- formatting.rustfmt,
-- formatting.shfmt.with { extra_args = { "-i", "2", "-ci" } },
-- formatting.sqlfluff,
-- formatting.standardrb,
-- formatting.styler, -- needs the 'R' command to be in $PATH
-- formatting.taplo,
-- diagnostics.actionlint,
-- diagnostics.ansiblelint,
-- diagnostics.checkmake,
-- diagnostics.chktex,
-- diagnostics.codespell,
-- diagnostics.cspell,  -- requires 'npm'
-- diagnostics.flake8,
-- diagnostics.gitlint,
-- diagnostics.hadolint,
-- diagnostics.jsonlint,
-- diagnostics.markdownlint,
-- diagnostics.mlint,
-- diagnostics.mypy,
-- diagnostics.proselint,
-- diagnostics.pydocstyle.with { extra_args = { "--config=$ROOT/setup.cfg" } },
-- diagnostics.pylama,
-- diagnostics.pylint,
-- diagnostics.pyproject_flake8,
-- diagnostics.revive.with { method = null_ls.methods.DIAGNOSTICS_ON_SAVE },
-- diagnostics.rstcheck,
-- diagnostics.selene,
-- diagnostics.semgrep,
-- diagnostics.shellcheck.with { diagnostics_format = "[#{c}] #{m} (#{s})" },
-- diagnostics.sqlfluff,
-- diagnostics.staticcheck.with { method = null_ls.methods.DIAGNOSTICS_ON_SAVE },
-- diagnostics.stylint,
-- diagnostics.textlint,
-- diagnostics.vale,
-- diagnostics.vint,
-- diagnostics.vulture, -- usually not available in path
-- diagnostics.write_good,
-- diagnostics.yamllint,
-- }}}

local status_ok_nvim_lint, nvim_lint = pcall(require, "lint")
if not status_ok_nvim_lint then
  return
end
nvim_lint.linters_by_ft = {
  -- c = { "clazy", "flawfinder" },
  c = {},
  cmake = { "cmakelint" },
  -- cpp = { "clangtidy", "flawfinder" },
  cpp = {},
  java = { "checkstyle" },
  latex = { "lacheck" },
  python = { "pycodestyle" },
  tex = { "lacheck" },
  rst = { "rstlint" },
}

local utils = require "astronvim.utils"
if vim.fn.executable "clang-tidy" == 1 then
  -- print "clang-tidy is installed"
  utils.list_insert_unique(nvim_lint.linters_by_ft.c, "clangtidy")
  utils.list_insert_unique(nvim_lint.linters_by_ft.cpp, "clangtidy")
end
if vim.fn.executable "flawfinder" == 1 then
  -- print "flawfinder is installed"
  utils.list_insert_unique(nvim_lint.linters_by_ft.cpp, "flawfinder")
end

-- vim.cmd [[autocmd BufWritePost * lua require('lint').try_lint()]]
vim.cmd [[
autocmd BufReadPost * lua require('lint').try_lint()
autocmd BufWritePost * lua require('lint').try_lint()
]]
