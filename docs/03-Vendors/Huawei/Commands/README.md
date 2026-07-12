# Commands

本页为华为光猫命令索引第一版，只收录当前已整理的高频命令。所有条目统一采用以下字段：

- `功能`
- `参数`
- `返回值`
- `示例`
- `适用型号`
- `风险等级`
- `验证状态`
- `来源`

## 命令索引

| 命令 | 主要用途 | 风险等级 | 验证状态 |
| --- | --- | --- | --- |
| `telnet <ip>` | 进入维护入口 | 中 | `社区资料` `多源一致` `待实机验证` |
| `su` | 切换更高权限 | 中 | `社区资料` `多源一致` `待实机验证` |
| `shell` | 进入 Dopra Linux Shell | 高 | `社区资料` `多源一致` `待实机验证` |
| `cd /mnt/jffs2` | 进入配置持久化目录 | 低 | `社区资料` `多源一致` `待实机验证` |
| `tftp -p -l <file> -r <file> <server_ip>` | 导出配置到本地 TFTP 服务器 | 中 | `社区资料` `多源一致` `待实机验证` |
| `tftp -g -l <file> -r <file> <server_ip>` | 上传配置到设备 | 高 | `社区资料` `多源一致` `待实机验证` |
| `touch /mnt/jffs2/Equip.sh` | 社区资料中的 root 开关手段之一 | 高 | `社区资料` `待实机验证` |
| `rm /mnt/jffs2/Equip.sh` | 关闭上述 root 开关 | 中 | `社区资料` `待实机验证` |
| `aescrypt2 1 <in> <out>` | 解密华为配置文件 | 中 | `社区资料` `多源一致` `待实机验证` |
| `aescrypt2 0 <in> <out>` | 加密华为配置文件 | 高 | `社区资料` `多源一致` `待实机验证` |
| `load pack by tftp ...` | 导入升级包或补全包 | 高 | `社区资料` `待实机验证` |
| `display version` | 查看版本信息 | 低 | `社区资料` `待实机验证` |
| `display sysinfo` | 查看 CPU、内存、系统时间 | 低 | `社区资料` `待实机验证` |
| `display deviceInfo` | 查看 ONU 设备信息 | 低 | `社区资料` `待实机验证` |
| `restorehwmode.sh` | 恢复华为原厂模式的社区命令名 | 高 | `社区资料` `待实机验证` |
| `reboot` | 重启设备 | 中 | `社区资料` `多源一致` `待实机验证` |

## 详细条目

### `telnet <ip>`

- 功能：连接光猫维护入口。
- 参数：`<ip>` 为设备管理地址，社区资料常见为 `192.168.1.1` 或 `192.168.100.1`。
- 返回值：成功时出现登录提示；失败时可能表现为连接超时、被过滤或直接断开。
- 示例：`telnet 192.168.100.1`
- 适用型号：`HG8245`、`HG8245H`、`HS8145C5`、`HN8145X6`、`HS8346V5`、`HG8321R` 等社区案例。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://github.com/logon84/Hacking_Huawei_HG8012H_ONT

### `su`

- 功能：在维护 CLI 中切换到更高权限上下文。
- 参数：无。
- 返回值：成功时进入更高权限状态；失败时通常会提示权限不足或无变化。
- 示例：`su`
- 适用型号：见 `telnet` 条目涉及的社区机型。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `shell`

- 功能：从 `WAP>` 进入底层 `Dopra Linux` Shell。
- 参数：无。
- 返回值：成功时提示符通常变化为 Shell 环境；失败时可能无权限进入。
- 示例：`shell`
- 适用型号：`HN8145X6`、`HS8145C5`、`HG8321R` 等社区案例。
- 风险等级：高
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `cd /mnt/jffs2`

- 功能：进入常见的配置持久化目录。
- 参数：路径固定为 `/mnt/jffs2`。
- 返回值：成功时当前工作目录改变；失败时提示目录不存在或权限不足。
- 示例：`cd /mnt/jffs2`
- 适用型号：多见于华为民用 ONT 社区资料。
- 风险等级：低
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `tftp -p -l <file> -r <file> <server_ip>`

- 功能：将设备上的文件导出到本地 TFTP 服务器。
- 参数：
  - `-p`：社区资料中表示向 TFTP 服务器发送文件。
  - `-l <file>`：本地源文件名，通常为设备侧文件。
  - `-r <file>`：远端文件名。
  - `<server_ip>`：本地 TFTP 服务器地址。
- 返回值：成功时 TFTP 目录出现文件；失败时通常返回传输错误或无文件生成。
- 示例：`tftp -p -l hw_ctree.xml -r hw_ctree.xml 192.168.1.2`
- 适用型号：`HN8145X6`、`HG8240`、`HS8346V5` 等社区案例。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://cherrot.com/snippet/2017/02/05/hack-huawei-hg8346r-to-enable-bridge-mode.html

### `tftp -g -l <file> -r <file> <server_ip>`

- 功能：将本地 TFTP 服务器文件上传到设备。
- 参数：
  - `-g`：社区资料中表示从 TFTP 服务器获取文件。
  - `-l <file>`：设备侧目标文件名。
  - `-r <file>`：TFTP 服务器上的源文件名。
  - `<server_ip>`：TFTP 服务器地址。
- 返回值：成功时设备侧文件被更新；失败时通常表现为传输失败、重启后回滚或文件被拒绝。
- 示例：`tftp -g -l hw_ctree.xml -r hw_ctree.xml 192.168.1.2`
- 适用型号：`HN8145X6`、`HS8145C5`、`HG8321R` 等社区案例。
- 风险等级：高
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `touch /mnt/jffs2/Equip.sh`

- 功能：社区资料中的“开启 root 权限”手段之一。
- 参数：固定写入 `/mnt/jffs2/Equip.sh`。
- 返回值：通常需要配合重启后观察是否生效；无统一返回文本。
- 示例：`touch /mnt/jffs2/Equip.sh`
- 适用型号：当前仅见于部分高版本社区案例。
- 风险等级：高
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html

### `rm /mnt/jffs2/Equip.sh`

- 功能：删除上面的权限开关文件。
- 参数：固定路径 `/mnt/jffs2/Equip.sh`。
- 返回值：成功时文件被删除；通常配合重启确认。
- 示例：`rm /mnt/jffs2/Equip.sh`
- 适用型号：同上。
- 风险等级：中
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html

### `aescrypt2 1 <input> <output>`

- 功能：对华为配置文件执行 AES 解密。
- 参数：
  - `1`：社区资料中表示解密模式。
  - `<input>`：输入密文文件，常见为 `.xml.gz`。
  - `<output>`：输出路径或临时目标。
- 返回值：成功时得到可进一步 `gzip -d` 的解密文件；失败时可能产生不可读内容。
- 示例：`aescrypt2 1 myconfig.xml.gz tmp`
- 适用型号：`HG8245`、`HG8321R` 以及其他使用 `hw_ctree.xml` 的社区机型。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://github.com/palmerc/AESCrypt2
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `aescrypt2 0 <input> <output>`

- 功能：对修改后的配置文件重新加密。
- 参数：
  - `0`：社区资料中表示加密模式。
  - `<input>`：待加密文件。
  - `<output>`：输出密文文件。
- 返回值：成功时生成可回传设备的密文文件；失败时可能导致配置无法导入。
- 示例：`aescrypt2 0 myconfig.xml.gz tmp`
- 适用型号：见上。
- 风险等级：高
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://github.com/palmerc/AESCrypt2
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `load pack by tftp svrip <server_ip> remotefile <file>`

- 功能：通过 TFTP 导入升级包、补全包或 Shell 包。
- 参数：
  - `svrip <server_ip>`：TFTP 服务器地址。
  - `remotefile <file>`：包文件名。
- 返回值：成功时设备进入升级或导入流程；失败时通常报命令不存在、文件不存在或升级失败。
- 示例：`load pack by tftp svrip 192.168.100.2 remotefile SA1456CV2.bin`
- 适用型号：`HG8321R`、`HS8145C5` 及部分社区改机案例。
- 风险等级：高
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md
  - https://www.right.com.cn/forum/thread-4001738-1-1.html

### `display version`

- 功能：查看设备版本信息。
- 参数：无。
- 返回值：通常输出固件版本、平台版本或相关版本字符串。
- 示例：`display version`
- 适用型号：当前见于社区 WAP CLI 资料。
- 风险等级：低
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `display sysinfo`

- 功能：查看 CPU、内存占用率和系统时间。
- 参数：无。
- 返回值：通常输出系统资源与时间信息。
- 示例：`display sysinfo`
- 适用型号：当前见于社区 WAP CLI 资料。
- 风险等级：低
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `display deviceInfo`

- 功能：查看 ONU 相关设备信息。
- 参数：无。
- 返回值：通常输出设备识别信息与运行信息。
- 示例：`display deviceInfo`
- 适用型号：当前见于社区 WAP CLI 资料。
- 风险等级：低
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `restorehwmode.sh`

- 功能：社区资料中用于“恢复华为原厂模式”的脚本名。
- 参数：当前未见统一参数说明。
- 返回值：未知，需实机补充。
- 示例：`restorehwmode.sh`
- 适用型号：当前来源不足，暂不下结论。
- 风险等级：高
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `reboot`

- 功能：重启设备，使配置或补丁生效。
- 参数：无。
- 返回值：设备重启，当前连接中断。
- 示例：`reboot`
- 适用型号：广泛见于社区资料。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

## 尚未纳入正式条目的命令

以下主题已被记录，但因来源冲突或说明不足，暂不作为正式命令条目：

- `descrypt`
- `reset`
- `getcustominfo.sh`
- `display optic`
- `display access mode`
- `get rogue status`

后续待补充参数、返回值和适用型号后再转入正式条目。
