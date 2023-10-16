#!/usr/bin/env bash

printf "Deleting compiled executables and other build artefacts ...\n"

find . -name "*.x" -print -delete 2>/dev/null
find . -name "*.dwo" -print -delete 2>/dev/null
find . -name "*.exe" -print -delete 2>/dev/null
find . -name "*.o" -print -delete 2>/dev/null
find . -name "*.out" -print -delete 2>/dev/null
find . -name "*.su" -print -delete 2>/dev/null
find . -name "cppcheck_suppressions.txt" -size 0 -print -delete 2>/dev/null
find . -type d -name "*.out" -print -exec rm -rf "{}" \; 2>/dev/null
find . -type d -name "cppcheck_build" -print -exec rm -rf "{}" \; 2>/dev/null
find . -type d -name ".ccls-cache" -print -exec rm -rf "{}" \; 2>/dev/null
find . -type d -name ".cmake" -print -exec rm -rf "{}" \; 2>/dev/null
find . -type d -name "build" -print -exec rm -rf "{}" \; 2>/dev/null
find . -type d -name "build_*" -print -exec rm -rf "{}" \; 2>/dev/null
find . -type d -name "buildtree" -print -exec rm -rf "{}" \; 2>/dev/null
find . -type d -name "CMakeFiles" -print -exec rm -rf "{}" \; 2>/dev/null
find . -type d \( -name "debug" -o -name "release" \) -print -exec rm -rf "{}" \; 2>/dev/null
find . -name "*.out" -print -delete 2>/dev/null
find . -name "*.x" -print -delete 2>/dev/null
find . -name "cmake_install.cmake" -print -delete 2>/dev/null
find . -name "CMakeCache.txt" -print -delete 2>/dev/null
find . -name "CTestTestfile.cmake" -print -delete 2>/dev/null
find . -name "CPackConfig.cmake" -print -delete 2>/dev/null
# find . -iname "MakeFile" -print -delete 2>/dev/null
find . -iname "hello.txt" -print -delete 2>/dev/null
find . -iname "hello.data" -print -delete 2>/dev/null
find . -name "hello" -type f \( -perm -u=x -o -perm -g=x -o -perm -o=x \)  -print -delete 2>/dev/null

echo "Removed build-output files. DONE!"
