ui_print "********************************************************"
ui_print "* OnePlus Pad 极致纯省电与能效调优模块 (Pure Saver) *"
ui_print "*   日常限频深度省电 + 游戏全核满血白名单 (支持自定义)  *"
ui_print "********************************************************"
ui_print "- 正在配置省电脚本与执行权限..."
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/post-fs-data.sh 0 0 0755
set_perm_recursive $MODPATH/scripts 0 0 0755 0755

# 初始化用户自定义游戏白名单
USER_CFG="/sdcard/pure_powersave_games.txt"
if [ ! -f "$USER_CFG" ]; then
    ui_print "- 正在创建默认游戏白名单配置: $USER_CFG"
    cp -f $MODPATH/games.txt "$USER_CFG" 2>/dev/null
    chmod 666 "$USER_CFG" 2>/dev/null
else
    ui_print "- 检测到已存在白名单配置: $USER_CFG (保留现有配置)"
fi

ui_print "- 正在激活系统级省电策略..."
settings put global low_power 1 2>/dev/null
ui_print "- 模块安装完成！"
ui_print "- 提示: 您可在 /sdcard/pure_powersave_games.txt 自行添加游戏包名！"
ui_print "- 保存后守护程序自动实时热生效，无需频繁重启。"
