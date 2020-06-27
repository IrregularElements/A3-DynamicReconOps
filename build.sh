#!/usr/bin/env bash

set -ex
shopt -s nullglob globstar

# Executable dependencies
JQ="${JQ-jq}"
RSYNC="${RSYNC-rsync}"
#GNUFIND="${GNUFIND-find}"
#GNUCP="${GNUCP-cp}"
ARMAKE2="${ARMAKE2-armake2}"
PYTHON3="${PYTHON3-python3}"
RUBY="${RUBY-ruby}"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

QUILT_TOP="$(quilt top || echo)"
SRCDIR="$(readlink -f ./src)"
quilt push -aq
find "$DIR"/src -type f -print0 | xargs -0 unix2dos
cleanup() {
  find "$DIR"/src -type f -print0 | xargs -0 dos2unix
  # shellcheck disable=SC2086
  quilt pop -aqf $QUILT_TOP
}
trap cleanup EXIT

# urlencoded-like character replacement for Arma pbos.
# Converts
#  "Dynamic Recon Ops - G.O.S Al Rayak.pja310.pbo"
# to
#  "Dynamic%20Recon%20Ops%20-%20G%2eO%2eS%20Al%20Rayak.pja310.pbo"
urlencode_pbo() (
  ue()(ruby -e 'puts ARGF.read.gsub(/[^\w-]/){|c|sprintf"%%%02x",c.ord}';)
  set -ex
  PBONAME="$1" ; shift
  EXT="${PBONAME##*.}"
  SCENARIO="${PBONAME%.*}"
  TERRAIN="${SCENARIO##*.}"
  SCENARIO="${SCENARIO%.*}"
  NEW_PBONAME="$(printf "%s" "$SCENARIO" | ue).$TERRAIN.$EXT"
  mv -n "$PBONAME" "$NEW_PBONAME"
)

cd pbo

jq -r '.[] | "\(.id)\t\(.name//"")\t\(.pboname//"")"' <"$DIR"/maps.json \
| while IFS=$'\t' read -r ID NAME PBONAME ;
do
  [[ -z $NAME ]] && NAME="$ID"
  [[ -z $PBONAME ]] && PBONAME="$NAME"
  PBODIR="Dynamic Recon Ops - $PBONAME.$ID"
  PBOFILE="$PBODIR.pbo"
  mkdir "$PBODIR"
  cleanup() {
    rm -rf "$PBODIR"
  }
  trap cleanup EXIT
  "$RSYNC" -aq -- "$DIR"/src/ "$PBODIR"
  "$RSYNC" -aq -- "$DIR"/maps/"$ID"/ "$PBODIR"
  "$ARMAKE2" pack -f "$PBODIR" "$PBOFILE"
  urlencode_pbo "$PBOFILE"
  rm -rf "$PBODIR"
done
