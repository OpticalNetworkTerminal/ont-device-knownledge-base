# ZTE Research Collection Report

统计范围：

- 仅统计 `docs/03-Vendors/ZTE/Research/`
- 时间点：2026-07-12
- 口径：以当前研究库已落地条目为准，不代表全网资料总量上限

## 1. 官方资料数量

`8`

口径：

- `Official/index.md` 中 `OFF-001` 到 `OFF-008`

## 2. GPL 数量

`4`

口径：

- `GPL/index.md` 中 `GPL-001` 到 `GPL-004`

## 3. Firmware 数量

`9`

口径：

- `Firmware/index.md` 中 `FW-001` 到 `FW-009`

## 4. 型号数量

`29`

口径：

- `Models/index.md` 当前型号条目数

## 5. sendcmd 数量

`61`

口径：

- `Commands/sendcmd-index.md` 当前命令样本行数
- 这是“出现记录数量”，不是“已验证可执行数量”

## 6. DBus 资料数量

`24`

口径：

- `DBus/index.md` 当前对象/表条目数

## 7. Community 帖子数量

`23`

口径：

- `Community/index.md` 中 `COM-001` 到 `COM-023`

## 8. 运营商资料数量

`14`

口径：

- `Operators/ChinaTelecom`、`ChinaUnicom`、`ChinaMobile` 中当前主题行数合计
- `ChinaBroadnet` 目前为占位，不计入

## 9. 截图数量

`11`

口径：

- `Images/index.md` 中 `IMG-001` 到 `IMG-011`

## 10. 待验证资料数量

`41`

口径说明：

- 包括 `GPL` 官方 ONT 源码包未定位项
- 包括 `Platform` 中仅有平台名、未定位到具体型号的线索
- 包括 `Firmware` 中尚未拿到升级包文件名/签名/分区策略的项目
- 包括 `Commands` 中 `D` 级与部分 `C` 级命令样本
- 包括 `ChinaBroadnet`、`Mesh`、`LED`、`双模切换` 等保留主题

## 11. 重复资料数量

`5`

口径：

- 当前已明确识别出的重复资料簇数量
- 例如 `F660 Telnet 设置代码大全` 在 ChinaDSL 与恩山的互引/转载

## 12. 建议 Curator 下一步优先整理内容

1. `sendcmd`/`sidbg`/`setmac` 三个命令族
   当前 Research 已有足够原始样本，适合进入“去重、分组、标风险、标适用型号”的 Curator 阶段。

2. `F660`、`F7610M`、`G7615` 三条型号线
   这三条线同时具备官方/FCC/社区/工具四类资料，最适合作为首批样板型号。

3. `db_user_cfg.xml` / `config.bin` / `db_default_auto_cfg.xml`
   配置文件与配置数据库是 ZTE ONT 研究主轴，适合单独做 Curator 索引。

4. 运营商差异
   尤其是 `CMCCAdmin`、`CUAdmin`、`telecomadmin`、`TR-069`、`桥接`、`地区码`、`TelnetCfg`。

5. F660 v3 平台链
   当前已命中 OpenWrt Wiki、OpenWrt Forum、`openwrt-avanta`、`avanta-uboot-f660`，适合整理成平台样板。

## 备注

- 本报告是 Research Collection Report，不是正式手册。
- 未实机验证资料均已保留，不因暂时无法确认而删除。
