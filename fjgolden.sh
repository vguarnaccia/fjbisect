#! /bin/sh

# Try `$ firejail --noprofile <command>` first.

set -euo pipefail

export COUNTER='fjbisect.count'
export ORIG='original.profile'
export TEST='devel.profile'

help_me() {
    cat <<EOM
Use the golden-section search to find out which line is causing issues in your
Firejail profile. 
EOM
}

cp_range() {
    tail -n +"$1" "$ORIG" | head -n $(($2 - $1 + 1)) >"$TEST"
}

save_interval() {
    : >"$COUNTER"
    for num in "$@"; do
        printf "%s\\t" $num >>"$COUNTER"
    done
}

is_failure() {
    if [ "$1" -gt "$2" ]; then
        echo "Search failed."
        exit 1
    fi
}

command="$1"

case "$command" in
start | begin)
    cp "$2" "$ORIG"
    end=$(wc -l "$ORIG" | cut -d' ' -f1)
    save_interval 0 0 0 $((end - 1))
    cp $ORIG $TEST
    ;;

good) ;;

bad) ;;

stop | end)
    cat "$TEST"
    rm $ORIG $TEST $COUNTER
    ;;
*)
    help_me
    ;;
esac
