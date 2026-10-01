#!/system/bin/sh
##########################################################################################
# OnePlus Pad - Pure Battery Saver & Dynamic Whitelist Performance Engine
# Platform: Snapdragon 8 Elite (SM8750) / ColorOS / Android 16
# Author: NinjaDraco
# Version: v1.3.0
##########################################################################################

LOG_FILE="/data/local/tmp/pure_powersave.log"
PID_FILE="/data/local/tmp/pure_powersave.pid"
SDCARD_CFG="/sdcard/pure_powersave_games.txt"
MODULE_CFG="/data/adb/modules/oneplus_pure_powersave/games.txt"

# Ensure single instance
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && [ "$OLD_PID" != "$$" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        exit 0
    fi
fi
echo $$ > "$PID_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [POWERSAVE] $1" >> "$LOG_FILE" 2>/dev/null
}

# Rotate log if size exceeds 128KB
if [ -f "$LOG_FILE" ]; then
    size=$(wc -c < "$LOG_FILE" 2>/dev/null || echo 0)
    if [ "$size" -gt 131072 ] 2>/dev/null; then
        tail -n 200 "$LOG_FILE" > "$LOG_FILE.tmp" 2>/dev/null
        mv "$LOG_FILE.tmp" "$LOG_FILE" 2>/dev/null
    fi
fi

# Ensure user config file exists on /sdcard
init_user_config() {
    [ ! -d "/sdcard" ] && return
    if [ ! -f "$SDCARD_CFG" ]; then
        cat << 'EOF' > "$SDCARD_CFG"
# ==============================================================================
# OnePlus Pad 极致纯省电模块 - 游戏/高性能应用白名单列表
# ==============================================================================
# 在此处填入您需要【全核满血释放性能 (4.32GHz + 540Hz触控)】的应用包名。
# 每行一个包名，支持 '#' 开头的注释。
# 保存此文件后，后台守护进程将自动在 3 秒内热重载生效，无需重启平板！
# ==============================================================================

# 网易 Blood Strike (血战突击)
com.netease.newspike

# --- 常用游戏示例（如需开启请去掉开头的 '#'） ---
# 原神
# com.miHoYo.Yuanshen
# 崩坏：星穹铁道
# com.miHoYo.hkrpg
# 绝区零
# com.miHoYo.Nap
# 王者荣耀
# com.tencent.tmgp.sgame
# 和平精英
# com.tencent.tmgp.pubgmhd
# 暗区突围
# com.tencent.tmgp.tiron
# 三角洲行动
# com.tencent.tmgp.df
# 使命召唤手游
# com.tencent.tmgp.cod
# 鸣潮
# com.kurogame.kjqyz.bilibili
EOF
        chmod 666 "$SDCARD_CFG" 2>/dev/null
        log "User whitelist config initialized at $SDCARD_CFG"
    fi
}

init_user_config

log "Pure Battery Saver Engine started (PID: $$)."

CURRENT_STATE=""

# 1. 满血游戏模式 (全核 4.32GHz + 540Hz 触控 + 120Hz/144Hz 刷新率)
apply_full_power() {
    local target_pkg="$1"
    [ "$CURRENT_STATE" = "FULL_POWER:$target_pkg" ] && return
    CURRENT_STATE="FULL_POWER:$target_pkg"
    log "Whitelisted game detected [$target_pkg]! Unleashing full performance (4.32GHz) & 540Hz touch."

    # 1. Uncap CPU frequencies to hardware max
    chmod 666 /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null
    echo 3532800 > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null

    chmod 666 /sys/devices/system/cpu/cpufreq/policy6/scaling_max_freq 2>/dev/null
    echo 4320000 > /sys/devices/system/cpu/cpufreq/policy6/scaling_max_freq 2>/dev/null

    # 2. Performance scheduler & task migration
    for w in /proc/sys/walt /proc/sys/kernel; do
        [ -f "$w/sched_downmigrate" ] && echo 40 > "$w/sched_downmigrate" 2>/dev/null
        [ -f "$w/sched_upmigrate" ] && echo 60 > "$w/sched_upmigrate" 2>/dev/null
        [ -f "$w/sched_boost" ] && echo 1 > "$w/sched_boost" 2>/dev/null
    done

    # 3. 540Hz esports touch & low touch latency
    if [ -d /proc/touchpanel ]; then
        chmod 666 /proc/touchpanel/* 2>/dev/null
        echo 1 > /proc/touchpanel/game_switch_enable 2>/dev/null
        echo 1 > /proc/touchpanel/sensitive_level 2>/dev/null
        echo 1 > /proc/touchpanel/smooth_level 2>/dev/null
    fi
    resetprop -n sys.input.resample.latency 0 2>/dev/null
    resetprop -n view.touch_slop 2 2>/dev/null

    # 4. Refresh rate: 120Hz
    settings put system peak_refresh_rate 120.0 2>/dev/null
    settings put system min_refresh_rate 60.0 2>/dev/null
}

# 2. 视频媒体深度省电模式 (锁定 60Hz + CPU 压制至 1.78GHz/1.69GHz，功耗骤降至 4.5W)
apply_video_powersave() {
    local target_pkg="$1"
    [ "$CURRENT_STATE" = "VIDEO_SAVER:$target_pkg" ] && return
    CURRENT_STATE="VIDEO_SAVER:$target_pkg"
    log "Video app active [$target_pkg]! 60Hz mode & deep media powersave engaged (target ~4.5W)."

    # 1. Cap CPU frequencies deeply (VPU handles hardware decoding, CPU load is < 5%)
    chmod 666 /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null
    echo 1785600 > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null

    chmod 666 /sys/devices/system/cpu/cpufreq/policy6/scaling_max_freq 2>/dev/null
    echo 1689600 > /sys/devices/system/cpu/cpufreq/policy6/scaling_max_freq 2>/dev/null

    # 2. WALT energy bias
    for w in /proc/sys/walt /proc/sys/kernel; do
        [ -f "$w/sched_downmigrate" ] && echo 60 > "$w/sched_downmigrate" 2>/dev/null
        [ -f "$w/sched_upmigrate" ] && echo 85 > "$w/sched_upmigrate" 2>/dev/null
        [ -f "$w/sched_boost" ] && echo 0 > "$w/sched_boost" 2>/dev/null
    done

    # 3. Touch power
    if [ -d /proc/touchpanel ]; then
        chmod 666 /proc/touchpanel/* 2>/dev/null
        echo 0 > /proc/touchpanel/game_switch_enable 2>/dev/null
        echo 0 > /proc/touchpanel/sensitive_level 2>/dev/null
        echo 0 > /proc/touchpanel/smooth_level 2>/dev/null
    fi
    resetprop -n sys.input.resample.latency 5 2>/dev/null
    resetprop -n view.touch_slop 8 2>/dev/null

    # 4. Lock display to 60Hz (matches 24/30/60fps video, avoids 120Hz 3K display rendering waste)
    settings put system peak_refresh_rate 60.0 2>/dev/null
    settings put system min_refresh_rate 60.0 2>/dev/null
}

# 3. 日常流畅省电模式 (桌面/聊天/浏览器/日常应用保持 120Hz 满帧，超大核封顶 2.65GHz)
apply_powersave_general() {
    [ "$CURRENT_STATE" = "POWERSAVE" ] && return
    CURRENT_STATE="POWERSAVE"
    log "General app/system active. Applying standard power-saving caps (120Hz smooth UI)."

    # 1. Cap CPU frequencies to avoid exponential power curve (save 40-50% power)
    chmod 666 /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null
    echo 2400000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null

    chmod 666 /sys/devices/system/cpu/cpufreq/policy6/scaling_max_freq 2>/dev/null
    echo 2649600 > /sys/devices/system/cpu/cpufreq/policy6/scaling_max_freq 2>/dev/null

    # 2. WALT energy bias
    for w in /proc/sys/walt /proc/sys/kernel; do
        [ -f "$w/sched_downmigrate" ] && echo 60 > "$w/sched_downmigrate" 2>/dev/null
        [ -f "$w/sched_upmigrate" ] && echo 85 > "$w/sched_upmigrate" 2>/dev/null
        [ -f "$w/sched_boost" ] && echo 0 > "$w/sched_boost" 2>/dev/null
    done

    # 3. Normal dynamic touch power
    if [ -d /proc/touchpanel ]; then
        chmod 666 /proc/touchpanel/* 2>/dev/null
        echo 0 > /proc/touchpanel/game_switch_enable 2>/dev/null
        echo 0 > /proc/touchpanel/sensitive_level 2>/dev/null
        echo 0 > /proc/touchpanel/smooth_level 2>/dev/null
    fi
    resetprop -n sys.input.resample.latency 5 2>/dev/null
    resetprop -n view.touch_slop 8 2>/dev/null

    # 4. Restore 120Hz smooth scrolling for daily apps & desktop
    settings put system peak_refresh_rate 120.0 2>/dev/null
    settings put system min_refresh_rate 60.0 2>/dev/null
}

# Built-in Video app packages
VIDEO_PACKAGES="tv.danmaku.bili com.bilibili.app.in com.google.android.youtube com.youku.phone com.qiyi.video com.tencent.qqlive com.netflix.mediaclient org.videolan.vlc"

# Initial apply powersave
apply_powersave_general

while true; do
    # Try init user config if sdcard is now mounted
    [ ! -f "$SDCARD_CFG" ] && init_user_config

    # Read active whitelist config
    ACTIVE_CFG=""
    if [ -f "$SDCARD_CFG" ]; then
        ACTIVE_CFG="$SDCARD_CFG"
    elif [ -f "$MODULE_CFG" ]; then
        ACTIVE_CFG="$MODULE_CFG"
    fi

    WHITELIST_GAMES=""
    if [ -n "$ACTIVE_CFG" ]; then
        WHITELIST_GAMES=$(grep -v '^[[:space:]]*#' "$ACTIVE_CFG" 2>/dev/null | grep -v '^[[:space:]]*$' | tr '\r' ' ' | tr '\n' ' ')
    fi

    # Fallback default
    if [ -z "$WHITELIST_GAMES" ]; then
        WHITELIST_GAMES="com.netease.newspike"
    fi

    # Check foreground window focus
    FOCUS_LINE=$(dumpsys window 2>/dev/null | grep -m1 'mCurrentFocus')

    MATCHED_GAME=""
    for game in $WHITELIST_GAMES; do
        [ -z "$game" ] && continue
        if echo "$FOCUS_LINE" | grep -q "$game"; then
            MATCHED_GAME="$game"
            break
        fi
    done

    if [ -n "$MATCHED_GAME" ]; then
        apply_full_power "$MATCHED_GAME"
    else
        # Check if foreground app is a video app
        MATCHED_VIDEO=""
        for vpkg in $VIDEO_PACKAGES; do
            if echo "$FOCUS_LINE" | grep -q "$vpkg"; then
                MATCHED_VIDEO="$vpkg"
                break
            fi
        done

        if [ -n "$MATCHED_VIDEO" ]; then
            apply_video_powersave "$MATCHED_VIDEO"
        else
            apply_powersave_general
        fi

        # If screen is off, trigger Doze deep sleep
        IS_SCREEN_OFF=$(dumpsys display 2>/dev/null | grep -m1 'mState=' | grep -o 'OFF')
        if [ -n "$IS_SCREEN_OFF" ]; then
            dumpsys deviceidle step >/dev/null 2>&1
        fi
    fi

    sleep 3
done
