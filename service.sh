#!/system/bin/sh
MODDIR=${0%/*}

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# 1. 禁用底层后台高耗电 Wi-Fi / 蓝牙位置常驻扫描
settings put global wifi_scan_always_enabled 0 2>/dev/null
settings put global ble_scan_always_enabled 0 2>/dev/null

# 2. 禁用高耗电的 AI 视频超分、MEMC 运动插帧与色彩增强
settings put system osie_iris5_video_enhance 0 2>/dev/null
settings put system iris_video_enhance 0 2>/dev/null
settings put system video_color_enhance 0 2>/dev/null
settings put system video_motion_enhance 0 2>/dev/null
settings put system color_hdr_enhance 0 2>/dev/null
settings put system oplus_customize_video_super_resolution 0 2>/dev/null

# 3. 激活 Android 原生内核级墓碑休眠 (Cached Apps Freezer)
device_config put activity_manager_native_boot use_freezer true 2>/dev/null
settings put global cached_apps_freezer enabled 2>/dev/null

# 4. 优化重度社交与后台服务待机档位
am set-standby-bucket com.tencent.mobileqq working_set 2>/dev/null
am set-standby-bucket com.android.vending rare 2>/dev/null

# 5. 系统底层低功耗与默认 120Hz/60Hz 动态刷新率
settings put global low_power 1 2>/dev/null
settings put system peak_refresh_rate 120.0 2>/dev/null
settings put system min_refresh_rate 60.0 2>/dev/null

# 6. 启动三档智能动态省电引擎
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
