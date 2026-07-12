# Debug

本页先建立 `Debug` 操作索引，聚焦串口、bootlog、启动参数和恢复判断。

## 已验证内容

- 公开 bootlog 显示 FiberHome 部分机型采用嵌入式 Linux + `JFFS2` + `MTD` 分区布局。
- `Reset` 键在官方资料中承担重启与恢复出厂功能。

## 待验证内容

- 各型号串口参数是否一致
- 各型号恢复后配置分区保留策略

## 命令索引

### `cat /proc/cmdline`

| 字段 | 内容 |
| --- | --- |
| 功能 | 查看启动参数 |
| 语法 | `cat /proc/cmdline` |
| 参数 | 无 |
| 返回值 | 启动参数字符串 |
| 示例 | `cat /proc/cmdline` |
| 适用型号 | 已获得 shell 的机型 |
| 风险等级 | 低 |
| 验证状态 | 与公开 bootlog 结构吻合 |
| 来源 | [AN5506 bootlog](https://gist.github.com/platkaw/926b7176714e02f3c729680584400f2d) |

### `mount`

| 字段 | 内容 |
| --- | --- |
| 功能 | 查看文件系统挂载点 |
| 语法 | `mount` |
| 参数 | 无 |
| 返回值 | 挂载列表 |
| 示例 | `mount` |
| 适用型号 | 已获得 shell 的机型 |
| 风险等级 | 低 |
| 验证状态 | 通用命令，未实机验证 |
| 来源 | Linux/BusyBox 通用 |
