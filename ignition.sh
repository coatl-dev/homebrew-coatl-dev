#!/bin/bash

set -euo pipefail;

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function update_formulae {
  cd Formula

  while IFS=, read -r version partial_url sha256
  do
    case $partial_url in
      *-Edge-*)
        name="IgnitionEdgeAT"
        formula_prefix="ignition-edge@"
        ;;
      *)
        name="IgnitionAT"
        formula_prefix="ignition@"
        ;;
    esac

    case $version in
      7.*)
        template_file="$CURR_DIR/Templates/ignition7.rb.tmpl"
        ;;
      *)
        template_file="$CURR_DIR/Templates/ignition8.rb.tmpl"
        ;;
    esac
    filename="$formula_prefix$version"

    # Create new formula of if it doesn't already exist
    if [[ ! -f "$filename.rb" ]]; then
      echo "Creating new formula: $filename.rb"
      cp "$template_file" "$filename.rb"

      name+="${version//./}"

      < "$template_file" sed -E "s/\\{formula_name\\}/$name/g" \
      | sed -E "s|\\{formula_url\\}|$partial_url|g" \
      | sed -E "s/\\{shasum\\}/$sha256/g" \
      > "$filename.rb" ; \
    fi
  done < "$CURR_DIR/ignition-releases.csv"
}

update_formulae

cd -
