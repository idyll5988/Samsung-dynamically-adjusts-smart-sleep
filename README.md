# Samsung-dynamically-adjusts-smart-sleep
Samsung dynamically adjusts smart sleep
![ABF509760F709EDB4766C07AD5C6CF8D](https://github.com/user-attachments/assets/e7a74bf6-e388-4455-a936-782d507424a7)

Dynamically adjust the system power saving strategy - When the screen is on: turn off smart sleep + high performance mode When the screen is off: turn on smart sleep + power saving mode Battery < 20%: Force power saving (override screen status)

​核心逻辑​

根据屏幕状态（亮屏/熄屏）及电量（<20%）动态调整系统省电策略：

​亮屏时​：关闭智能休眠+高性能模式

​熄屏时​：开启智能休眠+省电模式

​电量<20%​​：强制省电（覆盖屏幕状态）

添加变量跟踪当前状态，避免重复设置相同的值
Core Logic​
Dynamically adjust the system power saving strategy according to the screen status (screen on/off) and power (<20%):

When the screen is on: turn off smart sleep + high performance mode

When the screen is off: turn on smart sleep + power saving mode

Power <20%​​: force power saving (override screen status)

Add variables to track the current state to avoid repeatedly setting the same value
