#!/bin/bash -e

if (( $# != 1 )); then
  echo "Usage: $(basename $0) <version>"
  exit 1
fi

sedscript="s/\"version\": \".*\"/\"version\": \"$1\"/"

sed -i "$sedscript" package.json
sed -i "$sedscript" elm-package.json
sed -i "$sedscript" tests/elm-package.json
echo "Version bumped to $1."
