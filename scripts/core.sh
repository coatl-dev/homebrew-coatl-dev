#!/bin/bash

formulae=(
  "bzip2"
  "unzip"
  "xz"
)
for formula in "${formulae[@]}"; do
  curl -s -o "Formula/$formula.rb" "https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/${formula:0:1}/$formula.rb"
done
