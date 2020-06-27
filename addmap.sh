#!/usr/bin/env bash

JQ="${JQ-jq}"

genseed() (\
  perl -l -e 'print(int(rand(4294967296)))'
)

while true ; do
  IFS= read -p 'Terrain id (e.g. "Enoch"): ' -e -r -i "$ID" ID

  if [[ -z "$ID" ]]; then
    echo
    echo "FATAL: Empty terrain id" 1>&2
    exit 1
  fi

  if [[ -d maps/"$ID" ]]; then
    echo "maps/$ID already exists" 1>&2
  else
    break
  fi
done

#IFS= read -p 'randomSeed: ' -e -r -i "$(genseed)" RANDOMSEED
IFS= read -p 'Human-readable terrain name (e.g. "Livonia"): ' -e -r -i "$ID" NAME
IFS= read -p 'Human-readable terrain name for the PBO file: ' -e -r -i "$NAME" PBONAME

[[ $PBONAME = $NAME ]] && unset PBONAME
[[ $NAME = $ID ]] && unset NAME

JSON="$(
  #| jq ".randomseed = \"$RANDOMSEED\"" \
  echo '{}' \
  | jq ".id = \"$ID\"" \
  | { [[ -n "$NAME" ]] && jq ".name = \"$NAME\"" || cat ; } \
  | { [[ -n "$PBONAME" ]] && jq ".pboname = \"$PBONAME\"" || cat ; }
)"

TMP="$(mktemp)"
cleanup() { rm -f "$TMP" ; }
trap cleanup EXIT

{
  set -e
  cat maps.json >"$TMP"
  echo "$JSON"
  cat "$TMP" \
  | jq ". + [$JSON]" \
  | sponge "$TMP"
} && mv "$TMP" maps.json || { echo "FATAL: meta.json update failed" ; exit 1 ; }

mkdir maps/"$ID"
