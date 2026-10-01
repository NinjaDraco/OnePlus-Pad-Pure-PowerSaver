#!/system/bin/sh
MODDIR=${0%/*}

# Kernel VM writeback tuning (reduces flash wakeups & CPU wakeups)
echo 1500 > /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null
echo 3000 > /proc/sys/vm/dirty_expire_centisecs 2>/dev/null
echo 80 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
echo 10 > /proc/sys/vm/stat_interval 2>/dev/null

exit 0
