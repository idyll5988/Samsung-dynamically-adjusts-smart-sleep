# Samsung-dynamically-adjusts-smart-sleep
Samsung dynamically adjusts smart sleep
![D6A12B06511F8AB5603F6CF919C5605D](https://github.com/user-attachments/assets/68a6ca3f-740f-47a1-80cd-882dc7a9a9b3)

Dynamically adjust the system power saving strategy - When the screen is on: turn off smart sleep + high performance mode When the screen is off: turn on smart sleep + power saving mode Battery 
​核心逻辑​

根据屏幕状态（亮屏/熄屏）及电量

​亮屏时​：关闭智能休眠+高性能模式

​熄屏时​：开启智能休眠+省电模式

变量跟踪当前状态，避免重复设置相同的值

根据系统负载动态调整休眠时间

Core Logic​

When the screen is on: turn off smart sleep + high performance mode

When the screen is off: turn on smart sleep + power saving mode


variables to track the current state to avoid repeatedly setting the same value

Dynamically adjust sleep time based on system load
