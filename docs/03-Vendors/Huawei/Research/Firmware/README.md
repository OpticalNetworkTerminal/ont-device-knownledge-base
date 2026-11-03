# Firmware Research

最后收集时间：`2026-07-12`

| 型号 | 固件/资料 | 发布日期 | 运营商/地区 | 下载/来源 | Bootloader | Rootfs | Kernel | Filesystem | 是否加密 | 加密方式/工具 | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `HG8240` | 官方产品资料页 | 未标明 | Global | https://support.huawei.com/enterprise/en/access-network/echolife-hg8240-pid-4977718 | 未定 | 未定 | 未定 | 未定 | 未定 | 未定 | A |
| `HG8245` | 官方产品资料页 | 未标明 | Global | https://support.huawei.com/enterprise/en/access-network/echolife-hg8245-pid-4977710 | 未定 | 未定 | 未定 | 未定 | 未定 | 未定 | A |
| `HG8245H` | 官方产品资料页 | 未标明 | Global | https://support.huawei.com/enterprise/en/access-network/echolife-hg8245h-pid-8952133 | 未定 | 未定 | 未定 | 未定 | 未定 | 未定 | A |
| `HG8245W5` | 官方产品资料页 | 未标明 | Global | https://support.huawei.com/enterprise/en/access-network/echolife-hg8245w5-pid-23582068 | 未定 | 未定 | 未定 | 未定 | 未定 | 未定 | A |
| `HG8247H` | 官方产品资料页 | 未标明 | Global | https://support.huawei.com/enterprise/en/access-network/echolife-hg8247h-pid-21674439 | 未定 | 未定 | 未定 | 未定 | 未定 | 未定 | A |
| `HG8012H` | `U-Boot 2010.03` 启动日志 | 2015-07-31 build | Europe | https://github.com/logon84/Hacking_Huawei_HG8012H_ONT | `U-Boot 2010.03` | initramfs + squashfs/jffs2 迹象 | `Linux 2.6.34.10_sd5115v100_wr4.3` | `squashfs` `jffs2` | 未定 | 未定 | B |
| `HG8321R` | 社区 Shell/升级资料 | 未标明 | CN | https://github.com/QingNetwork/FuckingHuaweiHG8321R | 未定 | 未定 | 未定 | `jffs2` 迹象 | 是 | `aescrypt2` | C |
| `HS8545M` | 社区固件线程 | 论坛帖时间为准 | CN | https://www.chinadsl.net/thread-167519-1-1.html | 未定 | 未定 | 未定 | 未定 | 未定 | 未定 | C |
| `HN8145X6` | 社区高版本固件讨论 | 论坛帖时间为准 | CN | https://www.chinadsl.net/search.php?mod=forum&searchid=2047&orderby=lastpost&ascdesc=desc&searchsubmit=yes&kw=HN8145X6%20%E5%9B%BA%E4%BB%B6 | 未定 | 未定 | 未定 | 未定 | 未定 | 未定 | C |
| `HG8347R` | 固件镜像文档 | 镜像页未标明 | CN | https://www.scribd.com/document/697385060/Huawei-HG8347R-Firmware | 未定 | 未定 | 未定 | 未定 | 未定 | 未定 | D |

## 待跟进字段

- `Factory` 包与 `Upgrade` 包命名差异
- 是否存在 `hw_ctree.xml.enc`
- 是否存在签名校验与 header/checksum
- Bootloader 环境区与分区表
