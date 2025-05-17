#!/system/bin/sh
# 三星 S24 Ultra 骁龙8 Gen3 智能调优脚本 v2.0
# 核心功能：亮屏 - 智能休眠关闭/熄屏 - 智能休眠开启 + 系统负载自适应
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
    current_intelligent_sleep=""
    current_adaptive_battery=""
    current_power_mode=""
    
    while true; do
        cd ${MODDIR}/ll/log
        log
        
        # 获取当前屏幕状态
        screen_status=$(dumpsys window | grep "mScreenOn" | grep true)
        new_screen_status="off"
        [[ "${screen_status}" ]] && new_screen_status="on"
        
        # 只有当屏幕状态变化时才执行设置
        if [ "$new_screen_status" != "$current_screen_status" ]; then
            if [ "$new_screen_status" = "on" ]; then
                # 亮屏状态
                new_intelligent_sleep="0"
                new_adaptive_battery="0"
                new_power_mode="high"
                action_text="亮屏 - 智能休眠关闭 - 性能"
            else
                # 熄屏状态
                new_intelligent_sleep="1"
                new_adaptive_battery="1"
                new_power_mode="saver"
                action_text="熄屏 - 智能休眠开启 - 省电"
            fi
            
            # 检查并设置 intelligent_sleep_mode
            if [ "$new_intelligent_sleep" != "$current_intelligent_sleep" ]; then
                su -c "cmd settings put system intelligent_sleep_mode $new_intelligent_sleep" || log_error "设置intelligent_sleep_mode失败"
                current_intelligent_sleep="$new_intelligent_sleep"
            fi
            
            # 检查并设置 adaptive_battery_management
            if [ "$new_adaptive_battery" != "$current_adaptive_battery" ]; then
                su -c "cmd settings put global adaptive_battery_management $new_adaptive_battery" || log_error "设置adaptive_battery_management失败"
                current_adaptive_battery="$new_adaptive_battery"
            fi
            
            # 检查并设置 power_mode
            if [ "$new_power_mode" != "$current_power_mode" ]; then
                su -c "resetprop -n persist.sys.power.tweak_mode $new_power_mode" || log_error "设置power_mode失败"
                current_power_mode="$new_power_mode"
            fi
            
            echo "$(date '+%Y年%m月%d日%H时%M分%S秒') 📲 $action_text" >> "$LOG_FILE"
            current_screen_status="$new_screen_status"
        fi
        
        # 获取系统负载并动态调整休眠时间
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