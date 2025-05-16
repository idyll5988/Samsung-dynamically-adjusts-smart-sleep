#!/system/bin/sh
# 三星 S24 Ultra 骁龙8 Gen3 智能调优脚本 v2.0
# 核心功能：亮屏 - 智能休眠关闭/熄屏 - 智能休眠开启 + 低电量保护 
[ ! "$MODDIR" ] && MODDIR=${0%/*}
LOG_DIR="${MODDIR}/ll/log"
[[ ! -e ${LOG_DIR} ]] && mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/智能.log"
MAX_LOG_SIZE=1048576  
su -c renice -n 10 $$
log_error() {
    echo "$(date '+%Y年%m月%d日%H时%M分%S秒') [错误] $1" >> "$LOG_FILE"
}

log() {
    if [ -f "$LOG_FILE" ] && [ $(wc -c < "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 日志清空..." > "$LOG_FILE"
    fi
}

main_loop() {
    while true; do
	    cd ${MODDIR}/ll/log
        log  
        ba=$(cat /sys/class/power_supply/battery/capacity)
        if [ "$ba" -lt 20 ]; then
            su -c "cmd settings put system intelligent_sleep_mode 1" || log_error "设置intelligent_sleep_mode失败"
            su -c "cmd settings put global adaptive_battery_management 1" || log_error "设置adaptive_battery_management失败"
            su -c "resetprop -n persist.sys.power.tweak_mode saver" || log_error "设置tweak_mode失败"
            echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 🔋 电量<20% 强制智能休眠开启-省电模式" >> "$LOG_FILE"
        else
			screen_status=$(dumpsys window | grep "mScreenOn" | grep true)
            if [[ "${screen_status}" ]]; then
                su -c "cmd settings put system intelligent_sleep_mode 0" || log_error "关闭intelligent_sleep_mode失败"
                su -c "cmd settings put global adaptive_battery_management 0" || log_error "关闭adaptive_battery_management失败"
                su -c "resetprop -n persist.sys.power.tweak_mode high" || log_error "设置高性能模式失败"
                echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 📲 亮屏 - 智能休眠关闭 - 性能" >> "$LOG_FILE"
            else
                su -c "cmd settings put system intelligent_sleep_mode 1" || log_error "启用intelligent_sleep_mode失败"
                su -c "cmd settings put global adaptive_battery_management 1" || log_error "启用adaptive_battery_management失败"
                su -c "resetprop -n persist.sys.power.tweak_mode saver" || log_error "设置省电模式失败"
                echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 🌙 熄屏 - 智能休眠开启 - 省电" >> "$LOG_FILE"
            fi
        fi
        sleep 30
    done
}

echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 启动智能休眠调控" >> "$LOG_FILE"
main_loop