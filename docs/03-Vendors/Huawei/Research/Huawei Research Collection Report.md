# Huawei Research Collection Report

收集时间：`2026-07-12`

本次工作仅建设 `docs/03-Vendors/Huawei/Research/`，不整理正式手册，不清洗未验证资料。

## 1. 收集来源统计

| 来源类别 | 数量 |
| --- | ---: |
| 官方资料 | 11 |
| GPL/开源入口 | 7 |
| 固件资料 | 10 |
| 命令索引项 | 34 |
| 社区帖子/社区索引 | 18 |
| GitHub/GitLab/Gitee/代码托管 | 11 |
| FCC/监管 | 5 |
| 博客/镜像 | 8 |
| 未分类 | 6 |

## 2. 型号数量

- 已建立型号索引：`23` 个

## 3. 固件数量

- 已建立固件/固件资料索引：`10` 条

## 4. 命令数量

- 已建立命令索引：`34` 项

## 5. GPL 数量

- 已建立 GPL/开源入口索引：`7` 条

## 6. 社区帖子数量

- 已建立社区帖子或社区检索入口：`18` 条

## 7. 官方资料数量

- 已建立官方资料入口：`11` 条

## 8. 未分类资料

- 当前未分类：`6` 条
- 主要集中在：
  - `descrypt`
  - `hwcli`
  - `hw_diag`
  - `choose*.xml`
  - GPL 直链
  - DBus 线索

## 9. 重复资料

- `HG8012H` GitHub 项目同时覆盖：拆机、启动日志、串口、替换设备、文件系统。
- `AESCrypt2` 同时覆盖：工具、AES key、配置加解密、密码存储线索。
- `FuckingHuaweiHG8321R` 同时覆盖：Telnet、Shell、命令样本、配置回传、TFTP。
- 恩山与 ChinaDSL 中关于 `HS8145C5`、`HN8145X6`、`TR069`、`LOID` 的讨论存在交叉重复。

## 10. 后续建议整理优先级

1. `Config`
   - 优先补全 `hw_ctree.xml`、`hw_boardinfo`、`telecomadmin`、`PassMode`、`UserLevel` 的来源池。
2. `Debug`
   - 优先补全 `Telnet`、`Serial`、`Engineering Mode`、隐藏页面与串口参数。
3. `Firmware`
   - 优先补全固件版本、运营商、发布日期、是否加密、Bootloader 与文件系统。
4. `GPL`
   - 优先锁定华为 ONT 相关 GPL 直链、源码包文件名、Kernel/BusyBox/Buildroot 版本。
5. `Community`
   - 优先把恩山、ChinaDSL 的高价值帖子做原始归档，补发布时间、适用地区、适用运营商。
6. `FCC`
   - 优先提取内部图、芯片信息、标签图和硬件修订号。
7. `Unknown`
   - 继续挂载 `descrypt`、`hwcli`、`hw_diag` 等未定对象，等待后续归类。

## 当前结论边界

- 本次输出是 `Research Collection`，不是正式参考手册。
- 社区资料已尽量保留，不因缺乏实机验证而删除。
- 所有 `C/D` 级资料保留在库中，等待 Session B（Curator）继续处理。
