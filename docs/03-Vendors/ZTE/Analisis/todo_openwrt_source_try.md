# G7615 后续代办与 OpenWrt 19.07.7 试源清单

## 一、当前总代办

### 1. 分析宿主机内可能自行添加启动脚本的路径

目标：

- 评估在 **不破坏原厂启动链** 的前提下，宿主机是否存在适合插入自定义启动逻辑的位置。

后续细分检查项：

- 检查 `etc/inittab` 中是否还有可复用入口
- 检查 `etc/init.d/rcS` 是否会固定遍历 `/etc/rcS.d/S??*`
- 检查 `/etc/rcS.d/` 中是否允许新增自定义 `Sxx*` 脚本
- 检查宿主 `/usr/sbin` overlay 机制是否可用于覆盖或追加宿主脚本
- 检查 `/opt/cu/apps/*`、`/userconfig/*` 中是否已有厂商预留自定义脚本/钩子
- 检查 `dbus-rcS`、`regioncode`、`default/S0*` 这类宿主启动脚本是否存在可借用挂点
- 区分：
  - 只读分析可插入点
  - 低风险临时注入点
  - 高风险核心启动链改写点

当前已知直接证据：

- `etc/inittab` 通过 `/bin/shellproxy ttyAMA0 115200 /etc/init.d/rcS /dev/ttyp0` 拉起 `rcS`
- `etc/init.d/rcS` 会遍历执行 `/etc/rcS.d/S??*`
- 宿主已对 `/usr/sbin` 使用 overlay：
  - `lowerdir=/usr/sbin`
  - `upperdir=/opt/cu/apps/usrsbin`
  - `workdir=/opt/cu/apps/usrsbin_work`

初步判断：

- 宿主侧“可追加启动逻辑”的可能性是存在的
- 但优先应寻找 **新增脚本/新增调用** 的路径，而不是直接改宿主核心原始脚本

### 2. 离线构建方案，收敛最可能可用的 SDK / toolchain / triplet

目标：

- 在不直接污染设备 rootfs 的前提下，找出最可能匹配当前 ABI 的离线构建方案。

后续细分检查项：

- 明确宿主与 UFW 容器分别使用的 ABI
- 区分宿主工具链与容器工具链是否可共用
- 评估是优先找：
  - 原厂 SDK
  - OpenWrt 19.07.7 近似 SDK
  - Buildroot/glibc 交叉工具链
- 收敛 triplet 候选：
  - `arm-linux-gnueabi`
  - `arm-linux-gnueabihf`
  - 厂商私有 OpenWrt SDK 变体
- 优先测试：
  - 单文件纯用户态工具
  - 静态或近静态构建
  - 不依赖 `ubus/procd/libhguapi` 的程序

当前已知直接证据：

- CPU 是 ARMv8，但当前用户态是 **32 位 ARM EABI5**
- libc 是 **glibc 2.26**
- GCC 线索是 **Buildroot 2017.05 / GCC 5.3.1**
- 容器 `opkg print-architecture`：
  - `arch all 1`
  - `arch noarch 1`
  - `arch arm_zte_ZX279132K419_F 10`

初步判断：

- 最终可用 triplet 还不能唯一确定
- 但“直接拿常规 aarch64-openwrt-musl 套件来装”这条路已经可以排除

## 二、当前可试的 OpenWrt 19.07.7 源候选

这里的目标不是“直接接入 OPKG 安装”，而是：

- 先找到 **最接近当前系统的官方/半官方目录**
- 先下载 `.ipk`
- 先解包、看架构、试运行单个 ELF
- 暂不执行 `opkg install`

### 1. 已在设备内配置中出现的源

这些 URL 是设备当前 `distfeeds.conf` 直接给出的，优先级最高，因为它们至少反映了厂商当初预期使用的源格式：

```text
http://downloads.openwrt.org/releases/19.07.7/targets/zte/zte_132_K419_hgu_fttr/packages
http://downloads.openwrt.org/releases/19.07.7/packages/arm_zte_ZX279132K419_F/base
http://downloads.openwrt.org/releases/19.07.7/packages/arm_zte_ZX279132K419_F/luci
http://downloads.openwrt.org/releases/19.07.7/packages/arm_zte_ZX279132K419_F/packages
http://downloads.openwrt.org/releases/19.07.7/packages/arm_zte_ZX279132K419_F/routing
```

判断：

- `targets/zte/zte_132_K419_hgu_fttr/packages`：
  - 这是当前最应该优先检查的目录
  - 因为它和设备 `OPENWRT_BOARD` 完全一致
- `packages/arm_zte_ZX279132K419_F/*`：
  - 这是设备私有架构名
  - 官方通用 OpenWrt 站点上 **大概率并不存在这个目录**
  - 但仍建议你先手动访问/检查一次，确认是否真有历史保留目录或镜像

### 2. “最近”的候选应如何理解

按当前证据，“最近”不应该理解成“最新版本”，而应该理解成：

1. **同版本优先**
   - 必须优先 `19.07.7`

2. **同 target 优先**
   - 优先 `zte/zte_132_K419_hgu_fttr`

3. **同架构名优先**
   - 优先 `arm_zte_ZX279132K419_F`
   - 但它是私有架构名，官方源未必存在

4. **同 ABI 次之**
   - 32 位 ARM
   - glibc
   - EABI5

### 3. 目前最值得试的下载顺序

建议按下面顺序试，不要一上来就抓大包或核心包：

1. 先检查 `targets/zte/zte_132_K419_hgu_fttr/packages`

原因：

- 这是唯一一个和设备 board 字符串完全一致的目录
- 即使里面主要是 target/core 包，也比盲猜其他 arch 目录更靠谱

2. 再检查 `packages/arm_zte_ZX279132K419_F/*`

原因：

- 虽然大概率是厂商私有架构名
- 但这是设备当前 `distfeeds.conf` 直接写出来的路径
- 值得先验证这个目录是否真的存在过

3. 如果上面两个都不存在，再进入“近似 ABI 人工试包”阶段

注意：

- 这一步不能再叫“匹配源”
- 只能叫“近似 ABI 单包试运行”
- 且只能拿来解包、看依赖、试 ELF 是否能启动

## 三、试包原则

### 1. 当前阶段禁止做的事

- 不要执行 `opkg update`
- 不要执行 `opkg install`
- 不要执行 `opkg upgrade`
- 不要替换任何现有系统包
- 不要碰：
  - `base-files`
  - `busybox`
  - `procd`
  - `ubus`
  - `ubusd`
  - `uci`
  - `netifd`
  - `libc`
  - `libgcc`
  - `kmod-*`

### 2. 当前阶段允许做的事

- 下载 `.ipk`
- 解包 `.ipk`
- 查看 `control` / `data.tar.*`
- 用 `file` 看 ELF 架构
- 用 `strings` / `readelf` / `objdump` 看依赖
- 把单个二进制复制出来后手工试运行

### 3. 优先试的包类型

优先级从高到低：

- 纯脚本包
- `Architecture: all` / `noarch` 的小包
- 纯用户态单文件工具
- 不依赖 `ubus/procd/libhguapi` 的工具

可以优先考虑的测试方向：

- `jq`
- `nano`
- `vim`
- `tmux`
- `htop`
- `socat`

不建议先试的：

- `dropbear`
- `openssh-server`
- `bash`
- 任何网络核心组件

## 四、你现在可以直接做的动作

### 方案 A：先验证目录是否存在

按这个顺序人工检查：

```text
http://downloads.openwrt.org/releases/19.07.7/targets/zte/zte_132_K419_hgu_fttr/packages
http://downloads.openwrt.org/releases/19.07.7/packages/arm_zte_ZX279132K419_F/base
http://downloads.openwrt.org/releases/19.07.7/packages/arm_zte_ZX279132K419_F/packages
http://downloads.openwrt.org/releases/19.07.7/packages/arm_zte_ZX279132K419_F/luci
http://downloads.openwrt.org/releases/19.07.7/packages/arm_zte_ZX279132K419_F/routing
```

把你看到的：

- 目录是否存在
- `Packages.gz` 是否存在
- 目录里大概有哪些 `.ipk`

告诉我。

### 方案 B：如果你已经准备直接下载包

建议你先只下载：

- 一个最小的、非核心的、纯用户态包
- 最好再带上它的 `control` 信息或文件名列表

你把包名和来源目录发我，我帮你先判断：

- 是不是值得试
- 是应该“只解包看 ELF”
- 还是可以进一步“手工运行单个二进制”

## 五、当前一句话判断

现在最接近你这台机器的 OpenWrt 19.07.7 试源，不是“最新官方源”，而是：

1. `targets/zte/zte_132_K419_hgu_fttr/packages`
2. `packages/arm_zte_ZX279132K419_F/*`

但第二组大概率是设备私有目录名，官方站未必真实存在；因此第一步先做“目录存在性验证”，再决定下一轮试包。

