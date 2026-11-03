# Security Research

最后收集时间：`2026-07-12`

| 条目 | 来源 | 日期 | 型号 | 原始信息 | Evidence | 链接 |
| --- | --- | --- | --- | --- | --- | --- |
| 超管与受限账号 | 社区/GitHub | 未标明 | 多型号 | `telecomadmin`、`root`、`admin`、`getaccess` 等账号线索 | C | https://github.com/palmerc/AESCrypt2 |
| 配置文件 AES key | GitHub | 未标明 | `HG8245` 类资料 | `hex:13395537D2730554A176799F6D56A239` | B | https://github.com/palmerc/AESCrypt2 |
| Web 管理密码存储 | GitHub | 未标明 | `HG8245` | `SHA256(MD5(password))` 样例描述 | B | https://github.com/palmerc/AESCrypt2 |
| Web 漏洞 | WebSec | 2018-01-02 | `HG532` 近缘华为设备 | XSS/命令执行等旧研究线索 | D | https://websec.net/blog/huawei-home-gateway-hg532-remote-command-execution-51431 |
| Root 开关 `Equip.sh` | 恩山帖子 | 论坛帖时间为准 | `HN8145X6` 等 | 社区认为可触发 root 行为 | C | https://www.right.com.cn/forum/thread-8372902-1-1.html |

## 备注

- `HG532` 不是 ONT，但属于华为家庭网关研究生态的近缘资料，因此保留为侧向线索。
