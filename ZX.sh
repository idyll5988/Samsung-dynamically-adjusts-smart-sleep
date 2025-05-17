#!/system/bin/sh
# 三星 S24 Ultra 骁龙8 Gen3 智能调优脚本 v2.0
# 核心功能：亮屏 - 智能休眠关闭/熄屏 - 智能休眠开启 + 低电量保护
[ ! "$MODDIR" ] && MODDIR=${0%/*}
LOG_DIR="${MODDIR}/ll/log"
[[ ! -e ${LOG_DIR} ]] && mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/智能.log"
MAX_LOG_SIZE=1048576  
su -c renice -n 10 $$

# 错误日志记录函数
log_error() {
    echo "$(date '+%Y年%m月%d日%H时%M分%S秒') [错误] $1" >> "$LOG_FILE"
}

# 日志管理函数
log() {
    if [ -f "$LOG_FILE" ] && [ $(wc -c < "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 日志清空..." > "$LOG_FILE"
    fi
}

# 主循环
main_loop() {
    # 初始化状态变量
    current_screen_status=""
    current_battery_status=""
    
    while true; do
        cd ${MODDIR}/ll/log
        log
        
        # 获取当前状态
        screen_status=$(dumpsys window | grep "mScreenOn" | grep true)
        ba=$(cat /sys/class/power_supply/battery/capacity)
        
        # 低电量状态（<20%）
        if [ $ba -lt 20 ]; then
            new_battery_status="low"
        else
            new_battery_status="normal"
        fi
        
        # 确定新的屏幕状态
        if [[ "${screen_status}" ]]; then
            new_screen_status="on"
        else
            new_screen_status="off"
        fi
        
        # 低电量状态处理（优先于屏幕状态）
        if [ "$new_battery_status" != "$current_battery_status" ]; then
            if [ "$new_battery_status" = "low" ]; then
                su -c "cmd settings put system intelligent_sleep_mode 1" || log_error "[低电量] 启用intelligent_sleep_mode失败"
                su -c "cmd settings put global adaptive_battery_management 1" || log_error "[低电量] 启用adaptive_battery_management失败"
                su -c "resetprop -n persist.sys.power.tweak_mode saver" || log_error "[低电量] 设置省电模式失败"
                echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 🔋 电量${ba}% <20% - 强制智能休眠开启" >> "$LOG_FILE"
            else
                # 电量恢复正常，根据屏幕状态调整
                if [ "$new_screen_status" = "on" ]; then
                    su -c "cmd settings put system intelligent_sleep_mode 0" || log_error "关闭intelligent_sleep_mode失败"
                    su -c "cmd settings put global adaptive_battery_management 0" || log_error "关闭adaptive_battery_management失败"
                    su -c "resetprop -n persist.sys.power.tweak_mode high" || log_error "设置高性能模式失败"
                    echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 📲 亮屏 - 智能休眠关闭 - 性能（电量恢复）" >> "$LOG_FILE"
                else
                    su -c "cmd settings put system intelligent_sleep_mode 1" || log_error "启用intelligent_sleep_mode失败"
                    su -c "cmd settings put global adaptive_battery_management 1" || log_error "启用adaptive_battery_management失败"
                    su -c "resetprop -n persist.sys.power.tweak_mode saver" || log_error "设置省电模式失败"
                    echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 💤 熄屏 - 智能休眠开启 - 省电（电量恢复）" >> "$LOG_FILE"
                fi
            fi
            current_battery_status="$new_battery_status"
        fi
        
        # 屏幕状态处理（仅当非低电量时）
        if [ "$new_battery_status" != "low" ]; then
            if [ "$new_screen_status" != "$current_screen_status" ]; then
                if [ "$new_screen_status" = "on" ]; then
                    su -c "cmd settings put system intelligent_sleep_mode 0" || log_error "关闭intelligent_sleep_mode失败"
                    su -c "cmd settings put global adaptive_battery_management 0" || log_error "关闭adaptive_battery_management失败"
                    su -c "resetprop -n persist.sys.power.tweak_mode high" || log_error "设置高性能模式失败"
                    echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 📲 亮屏 - 智能休眠关闭 - 性能" >> "$LOG_FILE"
                else
                    su -c "cmd settings put system intelligent_sleep_mode 1" || log_error "启用intelligent_sleep_mode失败"
                    su -c "cmd settings put global adaptive_battery_management 1" || log_error "启用adaptive_battery_management失败"
                    su -c "resetprop -n persist.sys.power.tweak_mode saver" || log_error "设置省电模式失败"
                    echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 💤 熄屏 - 智能休眠开启 - 省电" >> "$LOG_FILE"
                fi
                current_screen_status="$new_screen_status"
            fi
        fi
        
    # 获取系统负载
    system_load=$(awk '{print $1}' /proc/loadavg)
    # 根据系统负载动态调整暂停时间
    if (( $(echo "$system_load > 5.0" | bc -l) )); then
        sleep_time=5
    elif (( $(echo "$system_load > 1.0" | bc -l) )); then
        sleep_time=10
    else
        sleep_time=20
    fi
    sleep $sleep_time
    done
}

# 安全启动
{
    echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 🚀 启动智能调优服务" >> "$LOG_FILE"
    main_loop
} &