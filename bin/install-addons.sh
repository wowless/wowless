#!/bin/bash
set -e
wowroot=$1
if ! [ -d "$wowroot" ]
then
  echo "$wowroot is not a directory"
  exit 1
fi
wowless="$(dirname "$(dirname "$(readlink -f "$0")")")"
function install() {
  wowproduct="$1"
  addonproduct="$2"
  wowdir="$wowroot/$wowproduct/Interface/AddOns"
  if [ -d "$wowdir" ]
  then
    echo "installing in $wowproduct"
    rm -rf "$wowdir/Wowless"
    rm -rf "$wowdir/WowlessData"
    rm -rf "$wowdir/WowlessTracker"
    ln -sf "$wowless/addon/Wowless" "$wowdir"
    ln -sf "$wowless/addon/WowlessTracker" "$wowdir"
    ln -sf "$wowless/build/products/$addonproduct/WowlessData" "$wowdir"
  fi
}
install _retail_ wow
install _ptr_ wowt
install _xptr_ wowxptr
install _beta_ wow_beta
install _classic_ wow_classic
install _classic_beta_ wow_classic_beta
install _classic_era_ wow_classic_era
install _classic_era_ptr_ wow_classic_era_ptr
install _classic_ptr_ wow_classic_ptr
