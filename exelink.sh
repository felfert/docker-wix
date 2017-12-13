#!/bin/bash
binlst=/usr/local/etc/wixbins.lst
if [ -d "$1" ] ; then
    touch $binlst
    find "$1" -name "*.exe" -type f -exec sh $0 "{}" \;
elif [ -f "$1" ] ; then
    bn="`basename $1 .exe`"
    sname="/usr/local/bin/$bn"
    ( echo '#!/bin/sh'; echo 'exec wine "'$1'" "$@"' ) > "$sname"
    test "$bn" = "candle" || echo -n " \"$bn\"" >> $binlst
    chmod +x "$sname"
fi
