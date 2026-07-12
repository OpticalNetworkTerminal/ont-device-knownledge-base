# Boot流程

## 当前状态

待验证。

## 已确认到的公开线索

- 串口和维护入口在中兴社区资料中长期存在，说明至少部分机型可通过低层控制台观察启动过程。
- `zte_modem_tools` 公开提供了 `serial` 开关逻辑，表明社区普遍认为部分机型存在可由网页 factory mode 触发的串口相关控制路径。
- FCC 对多款中兴 ONT 公开了内部照片，为后续识别 UART 焊点、Flash 与主控提供了一手材料。

## 当前不能下的结论

- 不能把所有中兴 ONT 统一描述为同一个 Bootloader/分区/启动参数流程。
- 不能在没有样本日志时直接写出 U-Boot、内核、rootfs、配置恢复的精确顺序。

## 后续补充方向

- 收集具体型号的串口启动日志
- 结合 FCC 内部照片标注 UART
- 对接分区表、升级包和恢复机制文档

## 来源

- <https://github.com/douniwan5788/zte_modem_tools/blob/main/zte_factroymode.py>
- <https://fccid.io/Q78-ZXHNF660>
- <https://fccid.io/Q78-ZXHNF670E>
- <https://fccid.io/Q78-ZXHNF680V9>
