#!/bin/sh
# Sets build-environment variables. Like ./configure but without the overhead.

SRC_GNOME_KEYRING_H="$1"
SRC_XPCOM_ABI_CPP="$2"

set -o errexit

XUL_VERSION=$(echo '#include "mozilla-config.h"'|
		${CXX} ${XUL_CFLAGS} ${CXXFLAGS} -shared -x c++ -w -E -fdirectives-only - |
		sed -n -e 's/\#[[:space:]]*define[[:space:]]\+MOZILLA_VERSION[[:space:]]\+\"\(.*\)\"/\1/gp')

XUL_VER_MIN=$(echo $XUL_VERSION | sed -r -e 's/([^.]+\.[^.]+).*/\1/g')
XUL_VER_MAX=$(echo $XUL_VERSION | sed -rn -e 's/([^.]+).*/\1.*/gp')

HAVE_NSILMS_GETISLOGGEDIN=$({ echo '#include "'"$SRC_GNOME_KEYRING_H"'"'; echo 'NS_IMETHODIMP GnomeKeyring::GetIsLoggedIn(bool *aIsLoggedIn) { return NS_OK; }'; } |
	  $CXX $XUL_CFLAGS $GNOME_CFLAGS $CXXFLAGS -x c++ -w -c -o /dev/null - && echo 1 || echo 0)

HAVE_MOZGLUE=$($CXX $XUL_CFLAGS $XUL_LDFLAGS $XPCOM_ABI_FLAGS $CXXFLAGS $LDFLAGS -lmozglue -shared -o /dev/null && echo 1 || echo 0)

if [ $HAVE_MOZGLUE = 1 ]; then
	XPCOM_ABI_FLAGS="$XPCOM_ABI_FLAGS -Wl,-whole-archive -lmozglue -Wl,-no-whole-archive"
fi
DST_XPCOM_ABI="$(dirname $0)/xpcom_abi"
$CXX $SRC_XPCOM_ABI_CPP -o "$DST_XPCOM_ABI" $XUL_CFLAGS $XUL_LDFLAGS $XPCOM_ABI_FLAGS $CXXFLAGS $LDFLAGS
PLATFORM="$("$DST_XPCOM_ABI")"

echo export XUL_VERSION="$XUL_VERSION"
echo export XUL_VER_MIN="$XUL_VER_MIN"
echo export XUL_VER_MAX="$XUL_VER_MAX"
echo export HAVE_NSILMS_GETISLOGGEDIN="$HAVE_NSILMS_GETISLOGGEDIN"
echo export HAVE_MOZGLUE="$HAVE_MOZGLUE"
echo export PLATFORM="$PLATFORM"
echo export HAVE_CONFIG_VARS=1
