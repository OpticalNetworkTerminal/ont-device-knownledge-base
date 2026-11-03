# GPL Index

本页保留 ZTE ONT 相关 GPL、开源构建树、Bootloader 与源码线索。

| ID | 条目 | 类型 | Evidence | 备注 | 链接 |
| --- | --- | --- | --- | --- | --- |
| GPL-001 | ZTE Open Source Center | 官方开源入口 | A | 页面内可见 `rest/product/tabDropDown` 与 `findProductByTitle` 接口 | <https://opensource.ztedevices.com/> |
| GPL-002 | msdos03/openwrt-avanta | OpenWrt 构建树 | B | 明确写到支持 `ZTE F660/F460/F620/F420 v3` | <https://github.com/msdos03/openwrt-avanta> |
| GPL-003 | msdos03/avanta-uboot-f660 | U-Boot 树 | B | 明确写到支持 `ZTE F460 v3/F660 v3/F420 v3/F620 v3` | <https://github.com/msdos03/avanta-uboot-f660> |
| GPL-004 | zx19930/openwrt-f660 | OpenWrt fork | C | 标注 `ZTE-F660 (Marvell 88f6560)` | <https://github.com/zx19930/openwrt-f660> |

## 待继续挖掘

- 官方 Open Source Center 中是否存在 `F660/F680/H196A/H388X` 相关源码压缩包
- 官方源码包里的 `kernel config`、`busybox config`、`buildroot`、`toolchain` 目录
- 厂商补丁与默认配置文件

## 当前研究结论

- 已确认存在官方开源总入口
- 已确认社区存在针对 `F660 v3` 的 OpenWrt/U-Boot 公开源码树
- 尚未确认中兴官方开源站是否直接公开特定 ZXHN ONT 的源码档案
