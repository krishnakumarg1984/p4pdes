#!/usr/bin/env sh

current_dir=$(pwd)
cd "$SLEPC_DIR"/share/slepc/examples/src/eps/tutorials/ || exit
c_files=$(find . -name "*.c")
for c_file in $c_files; do
  path_to_example="$(readlink -f "$c_file")"
  # echo $path_to_example
  cp "$path_to_example" "$current_dir"
done
cp "$SLEPC_DIR"/share/slepc/examples/src/eps/tutorials/makefile "$current_dir" || exit

cd "$current_dir" || exit
