#!/usr/bin/env bash

# echo "$PWD"
dotfiles_in_prev_dir=$(find -L .. -maxdepth 1 -type f -name ".*")
# echo $dotfiles_in_prev_dir

for dotfile in $dotfiles_in_prev_dir; do
  # echo $dotfile
  if [[ $dotfile =~ ".gitmodules" ]] | [[ $dotfile =~ .*".gitignore" ]] || [[ $dotfile =~ .*".prev" ]] || [[ $dotfile =~ .vim-arsync ]] || [[ $dotfile =~ .*"asynctasks" ]] || [[ $dotfile =~ "null-ls-root" ]] || [[ $dotfile =~ .exrc ]]; then
    echo -n ""
  else
    # echo "$dotfile"
    ln -sf "$dotfile" . 2>/dev/null
  fi
done

# ln -sf ../.vscode . 2>/dev/null
# ln -sf ../clean_builds.sh . 2>/dev/null
# ln -sf ../CPPLINT.cfg . 2>/dev/null
# ln -sf ../.devcontainer . 2>/dev/null
touch .root
