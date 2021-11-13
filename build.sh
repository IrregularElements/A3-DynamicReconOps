#!/usr/bin/env bash
#
# Run with KEEP_PBODIRS=1 to keep pbo directories after packaging.

set -ex
shopt -s nullglob globstar

# Executable dependencies
RSYNC="${RSYNC-rsync}"
GNUFIND="${GNUFIND-find}"
#GNUCP="${GNUCP-cp}"
ARMAKE2="${ARMAKE2-armake2}"
PYTHON3="${PYTHON3-python3}"
RUBY="${RUBY-ruby}"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

# urlencoded-like character replacement for Arma pbos.
# Converts
#  "Dynamic Recon Ops - G.O.S Al Rayak.pja310.pbo"
# to
#  "Dynamic%20Recon%20Ops%20-%20G%2eO%2eS%20Al%20Rayak.pja310.pbo"
urlencode_pbo() (
  ue()("${RUBY}" -e 'puts ARGF.read.gsub(/[^\w-]/){|c|sprintf"%%%02x",c.ord}';)
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
rm -rf *

ls -1 "$DIR"/maps | while IFS= read -r ID ; do
  NAMEFILE="$DIR/maps/$ID/mapname.txt"
  [[ -e $NAMEFILE ]] && NAME="$(cat "$NAMEFILE")" || NAME="${ID}"
  PBODIR="Dynamic Recon Ops - $NAME.$ID"
  PBOFILE="$PBODIR.pbo"
  rm -rf "$PBODIR"
  mkdir "$PBODIR"
  cleanup() {
    [[ -z $KEEP_PBODIRS ]] && rm -rf "$PBODIR"
  }
  trap cleanup EXIT

  pushd "$PBODIR"
  "$RSYNC" -aq -- "$DIR"/src/ .
  while IFS= read -r PATCH ; do
    echo "$PATCH"
    patch --quiet -p2 <"${DIR}/patches/${PATCH}"
  done <"${DIR}/patches/series"

  if [[ -e $DIR/maps/$ID/patches/series ]]; then
    while IFS= read -r PATCH ; do
      echo "$PATCH"
      patch --quiet -p1 <"${DIR}/maps/$ID/patches/${PATCH}"
    done <"${DIR}/maps/$ID/patches/series"
  fi

  RSYNC_EXCLUDE=(mapname.txt 'patches/*.patch' patches/series)
  "${RSYNC}" -aq "${RSYNC_EXCLUDE[@]/#/--exclude=}" -- "${DIR}/maps/${ID}/" .
  "$GNUFIND" . -type f -print0 | xargs -0 unix2dos
  popd

  "${ARMAKE2}" pack -f "$PBODIR" "$PBOFILE"
  urlencode_pbo "$PBOFILE"
  [[ -z $KEEP_PBODIRS ]] && rm -rf "$PBODIR"
done

if git describe 1>/dev/null 2>/dev/null ; then
  VERSION="$(git describe --tags --dirty)"
else
  VERSION=g"$(git describe --tags --dirty --always)"
fi
DATE="$(git log -1 --pretty='%cd' --date=format:'%Y.%m.%d')"

zip -9 ../DynamicReconOps-"${DATE}"-"${VERSION}".zip *.pbo
