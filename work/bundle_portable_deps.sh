#!/bin/zsh
set -euo pipefail

app="$1"
resources="$app/Contents/Resources"
frameworks="$app/Contents/Frameworks"
mkdir -p "$resources/bin" "$frameworks"

cp -X -L /opt/homebrew/bin/scrcpy "$resources/bin/scrcpy"
cp -X -L /opt/homebrew/bin/adb "$resources/bin/adb"
cp -X "$(brew --prefix scrcpy)/share/scrcpy/scrcpy-server" "$resources/scrcpy-server"
chmod u+wx "$resources/bin/scrcpy" "$resources/bin/adb"

typeset -a queue
typeset -A seen
queue=("$resources/bin/scrcpy")
integer index=1
while (( index <= ${#queue[@]} )); do
  current="${queue[$index]}"
  (( index += 1 ))
  while IFS= read -r dependency; do
    [[ "$dependency" == /opt/homebrew/* ]] || continue
    real_dependency="$(realpath "$dependency")"
    name="${dependency:t}"
    if [[ -z "${seen[$name]-}" ]]; then
      seen[$name]=1
      cp -X -L "$real_dependency" "$frameworks/$name"
      chmod u+w "$frameworks/$name"
      queue+=("$frameworks/$name")
    fi
  done < <(otool -L "$current" | tail -n +2 | awk '{print $1}')
done

for target in "$resources/bin/scrcpy" "$frameworks"/*.dylib; do
  [[ -f "$target" ]] || continue
  while IFS= read -r dependency; do
    [[ "$dependency" == /opt/homebrew/* ]] || continue
    name="${dependency:t}"
    if [[ "$target" == "$resources/bin/scrcpy" ]]; then
      replacement="@executable_path/../../Frameworks/$name"
    else
      replacement="@loader_path/$name"
    fi
    install_name_tool -change "$dependency" "$replacement" "$target"
  done < <(otool -L "$target" | tail -n +2 | awk '{print $1}')
  if [[ "$target" == *.dylib ]]; then install_name_tool -id "@rpath/${target:t}" "$target"; fi
done
