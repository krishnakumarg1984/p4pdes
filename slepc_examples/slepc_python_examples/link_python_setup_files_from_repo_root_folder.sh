#!/usr/bin/env bash

touch ".root" 2>/dev/null
ln -sf "../.vscode" . 2>/dev/null
ln -sf "../.nvim.lua" . 2>/dev/null
ln -sf "../.ruff.toml" . 2>/dev/null
ln -sf "../.root" . 2>/dev/null
ln -sf "../setup.cfg" . 2>/dev/null
# ln -sf "../pyproject.toml" . 2>/dev/null
