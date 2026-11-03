# Boot Research

最后收集时间：`2026-07-12`

| 对象 | 来源 | 观察点 | 型号 | Evidence | 链接 |
| --- | --- | --- | --- | --- | --- |
| `U-Boot 2010.03` | GitHub 启动日志 | 双镜像 `bootA/bootB`、`kernelA/kernelB`、`rootfsA/rootfsB` | `HG8012H` | B | https://github.com/logon84/Hacking_Huawei_HG8012H_ONT |
| `startcode` | GitHub 启动日志 | `startcode` 独立分区 | `HG8012H` | B | same-as-above |
| `flashcfg` | GitHub 启动日志 | 启动相关配置分区 | `HG8012H` | B | same-as-above |
| `slave_param` | GitHub 启动日志 | 参数分区 | `HG8012H` | B | same-as-above |
| `reserved` | GitHub 启动日志 | 保留分区 | `HG8012H` | B | same-as-above |

## 原始分区字符串

`mtdparts=hi_sfc:0x40000(startcode),0x40000(bootA)ro,0x40000(bootB)ro,0x40000(flashcfg)ro,0x40000(slave_param)ro,0x200000(kernelA)ro,0x200000(kernelB)ro,0x480000(rootfsA)ro,0x480000(rootfsB)ro,0x180000(file_system),-(reserved)`

来源：`HG8012H` GitHub 启动日志，最后收集时间 `2026-07-12`，Evidence `B`。
