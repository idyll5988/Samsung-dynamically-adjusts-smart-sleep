#!/system/bin/sh
# 三星 S24 Ultra 骁龙8 Gen3 智能调优脚本 v2.0
# 核心功能：亮屏 - 智能休眠关闭/熄屏 - 智能休眠开启
[ ! "$MODDIR" ] && MODDIR=${0%/*}
LOG_DIR="${MODDIR}/ll/log"
[[ ! -e ${LOG_DIR} ]] && mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/智能.log"
source "${MODPATH}/scripts/GK.sh"
MAX_LOG_SIZE=1048576  
$su_write renice -n 10 $$

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
    while true; do
        cd ${MODDIR}/ll/log
        log
        
        # 获取当前状态
        screen_status=$(dumpsys window | grep "mScreenOn" | grep true)
        
        if [[ "${screen_status}" ]]; then
            $su_write "cmd settings put system intelligent_sleep_mode 0" || log_error "关闭intelligent_sleep_mode失败"
            $su_write "cmd settings put global adaptive_battery_management 0" || log_error "关闭adaptive_battery_management失败"
            $su_write "resetprop -n persist.sys.power.tweak_mode high" || log_error "设置高性能模式失败"
            echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 📲 亮屏 - 智能休眠关闭 - 性能" >> "$LOG_FILE"
        else
            $su_write "cmd settings put system intelligent_sleep_mode 1" || log_error "启用intelligent_sleep_mode失败"
            $su_write "cmd settings put global adaptive_battery_management 1" || log_error "启用adaptive_battery_management失败"
            $su_write "resetprop -n persist.sys.power.tweak_mode saver" || log_error "设置省电模式失败"
            echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 💤 熄屏 - 智能休眠开启 - 省电" >> "$LOG_FILE"
        fi  
    # 获取系统负载
    system_load=$(awk '{print $1}' /proc/loadavg)
    # 阶梯式配置
    if (( $(echo "$system_load >= 25" | bc) )); then
        sleep_time=20 
    elif (( $(echo "$system_load >= 15" | bc) )); then
        sleep_time=15   
    elif (( $(echo "$system_load >= 5" | bc) )); then
        sleep_time=10    
    else
        sleep_time=25    
    fi
    sleep $sleep_time
    done
}

# 安全启动
{
    echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 🚀 启动智能调优服务" >> "$LOG_FILE"
    main_loop
} &  