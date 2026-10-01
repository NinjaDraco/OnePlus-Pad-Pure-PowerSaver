#!/system/bin/sh
MODDIR=${0%/*}

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Enable system low power flags & dynamic refresh
settings put global low_power 1 2>/dev/null
settings put system peak_refresh_rate 120.0 2>/dev/null
settings put system min_refresh_rate 60.0 2>/dev/null

# Launch lightweight powersave daemon
if [ -f "$MODDIR/scripts/pure_powersave_daemon.sh" ]; then
    (
        while :; do
            if [ ! -f "$MODDIR/scripts/pure_powersave_daemon.sh" ] || [ -f "$MODDIR/disable" ] || [ -f "$MODDIR/remove" ]; then
                break
            fi
            sh "$MODDIR/scripts/pure_powersave_daemon.sh" >/dev/null 2>&1
            sleep 5
        done
    ) &
fi

exit 0
