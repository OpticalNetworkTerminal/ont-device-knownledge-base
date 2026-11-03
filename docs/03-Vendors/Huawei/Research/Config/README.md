# Config Research

最后收集时间：`2026-07-12`

| 对象 | 来源 | 适用型号 | 原始信息 | Evidence | 链接 |
| --- | --- | --- | --- | --- | --- |
| `hw_ctree.xml` | 社区/GitHub | 多型号 | 常见运行配置文件名 | C | https://github.com/QingNetwork/FuckingHuaweiHG8321R |
| `hw_default_ctree.xml` | 社区/GitHub | 多型号 | 默认配置文件名 | C | same-as-above |
| `hw_boardinfo` | 社区/GitHub | 多型号 | 设备标识配置文件名 | C | same-as-above |
| `myconfig.xml.gz` | GitHub | `HG8321R` | 社区操作中的临时文件名 | C | same-as-above |
| `X_HW_WebUserInfoInstance` | GitHub | `HG8245` | Web 用户配置节点示例 | B | https://github.com/palmerc/AESCrypt2 |
| `UserLevel="0"` | GitHub | `HG8245` | 高权限级别线索 | B | same-as-above |
| `PassMode="2"` | GitHub | `HG8245` | 密码存储模式线索 | B | same-as-above |
| `telecomadmin` | 社区/博客 | 多型号 | 超管账号线索 | C | https://www.right.com.cn/forum/thread-8372902-1-1.html |
| `LOID` | 社区 | `HN8145X6` 等 | 注册参数相关线索 | C | https://www.chinadsl.net/search.php?mod=forum&searchid=2047&orderby=lastpost&ascdesc=desc&searchsubmit=yes&kw=LOID%20%E5%8D%8E%E4%B8%BA%20%E5%85%89%E7%8C%AB |
| `SN/MAC` | 社区 | `HN8145X6` `HG8245U` | 注册和替换设备相关线索 | C | https://github.com/logon84/Hacking_Huawei_HG8012H_ONT |

## 加解密相关

| 对象 | 原始信息 | Evidence | 来源 |
| --- | --- | --- | --- |
| `aescrypt2` | 社区常见 AES 配置工具 | B | https://github.com/palmerc/AESCrypt2 |
| `descrypt` | 已见关键词，但来源分散 | C | ChinaDSL / 恩山搜索结果 |
| 8-byte header | `AESCrypt2` README 提到 header/checksum | B | https://github.com/palmerc/AESCrypt2 |
