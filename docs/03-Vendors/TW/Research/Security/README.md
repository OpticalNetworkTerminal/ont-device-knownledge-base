# Security

| 主题 | 型号 | 资料 | Evidence | 来源 | 最后收集时间 |
| --- | --- | --- | --- | --- | --- |
| 配置文件简单异或 | TEWA-708E | `byte ^ 0xff` | B | https://github.com/jonirrings/xor | 2026-07-12 |
| Telnet 指令过滤 | TEWA-1000E | Issue #24 认为 Telnet 后并非正常 shell，存在过滤层 | B | https://github.com/jonirrings/xor/issues/24 | 2026-07-12 |
| `;` 触发 root 现象 | TEWA-1000E | GitHub Issue 记录 `;` 后 `echo $USER` 返回 root | B | https://github.com/jonirrings/xor/issues/24 | 2026-07-12 |
| IPv6 防火墙默认阻断入站 | TEWA-1000E | GitHub Issue 记录需手动 `ip6tables` 放行 | B | https://github.com/jonirrings/xor/issues/24 | 2026-07-12 |
| `su` 密码由 MAC 或 SN 计算 | TEWA-1006G 等 | 社区帖子说法 | C | https://www.chinadsl.net/thread-177433-1-1.html | 2026-07-12 |
| 隐藏页面与 sessionKey | 多型号 | 社区帖子集中讨论 | C | https://www.right.com.cn/forum/thread-5128686-1-1.html | 2026-07-12 |

