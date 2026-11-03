# UFW 容器进入方法

UFW 常见于运营商定制光猫/ONT 中，通常以 LXC 容器形式运行 OpenWrt/procd 风格的应用框架。host 主系统和 UFW 容器共享部分目录、DBus、网络或挂载点，但进程、挂载、UTS 等 namespace 可能不同。

本文记录从 host 侧进入 UFW 容器的通用方法。示例基于常见路径，实际设备需要按配置文件修正容器名和 LXC path。

## 优先使用 lxc-attach

如果设备自带 LXC 工具，优先使用 `lxc-attach`，它不依赖容器内是否配置 console/getty：

```sh
/usr/bin/lxc-info -P /opt/cu/framework -n ufw
/usr/bin/lxc-attach -P /opt/cu/framework -n ufw -- /bin/ash
```

如果容器内没有 `/bin/ash`，改试 `/bin/sh`：

```sh
/usr/bin/lxc-attach -P /opt/cu/framework -n ufw -- /bin/sh
```

进入后可检查是否已经处于 UFW/OpenWrt 环境：

```sh
ps
mount
ls /etc/config
ubus list 2>/dev/null
uci show 2>/dev/null
```

## 容器名和 LXC path

UFW 容器名通常可从 LXC 配置或进程信息判断。

常见配置文件：

```sh
/opt/cu/framework/ufw/config
```

常见配置项：

```sh
lxc.rootfs.path = overlayfs:/opt/cu/framework/ufw/rootfs:/opt/cu/apps/apps
lxc.uts.name = ufw
lxc.tty.max = 1
lxc.pty.max = 1024
lxc.net.0.type = none
```

其中 `lxc.uts.name = ufw` 通常说明容器名可按 `ufw` 尝试。`-P /opt/cu/framework` 用于指定 LXC path；如果不带 `-P`，工具可能去默认路径查找，导致提示找不到容器。

也可以设置环境变量：

```sh
export LXC_PATH=/opt/cu/framework
/usr/bin/lxc-info -n ufw
/usr/bin/lxc-attach -n ufw -- /bin/ash
```

## 使用 lxc-console

如果希望进入容器 console，可以尝试：

```sh
/usr/bin/lxc-console -P /opt/cu/framework -n ufw -t 0
```

退出 console 通常使用：

```text
Ctrl-a q
```

但 `lxc-console` 依赖容器内部有可交互 console/getty。很多 UFW/OpenWrt procd 环境没有为 LXC console 准备登录会话，因此 `lxc-console` 可能连上后无响应或无法登录。遇到这种情况应改用 `lxc-attach`。

## 从 ps 判断 UFW 是否已运行

host 侧常见 UFW 相关进程形态：

```sh
ufwmg service ...
/sbin/procd -S -d 4
/sbin/ubusd
/sbin/rpcd
/sbin/hpsrv
/sbin/proxy
/sbin/uappd
```

如果 `ps` 中能看到 `ufwmg service ...` 以及一组 `/sbin/procd`、`ubusd`、`rpcd` 等进程，通常说明 UFW 容器已启动。

可以进一步通过 cgroup 或 namespace 判断：

```sh
cat /proc/<pid>/cgroup
ls -l /proc/<pid>/ns
```

若 cgroup 中出现类似 `lxc.payload.ufw`，则该进程位于名为 `ufw` 的 LXC 容器中。

## 停止、启动与重启

UFW 通常不是单纯由 `lxc-start` 启动，而是由厂商管理程序负责准备 overlay、读取框架分区配置、注册 DBus 接口并启动 LXC。因此：

- 停止容器可优先使用 LXC 原生命令。
- 启动容器建议使用厂商 `ufwmg service ...`，不要直接 `lxc-start`，除非只是临时调试。

查看状态：

```sh
/usr/sbin/ufwmg -v
/usr/bin/lxc-info -P /opt/cu/framework -n ufw
ps | grep -E 'ufwmg|procd|uappd|hpsrv'
```

停止 UFW：

```sh
/usr/bin/lxc-stop -P /opt/cu/framework -n ufw
```

如果无法正常停止，可强制停止：

```sh
/usr/bin/lxc-stop -P /opt/cu/framework -n ufw -k
```

启动 UFW：

```sh
/usr/sbin/ufwmg service 9 10 11
```

重启 UFW：

```sh
/usr/bin/lxc-stop -P /opt/cu/framework -n ufw
sleep 2
/usr/sbin/ufwmg service 9 10 11
```

如果命令提示找不到容器，先指定 LXC path：

```sh
export LXC_PATH=/opt/cu/framework
lxc-info -n ufw
lxc-stop -n ufw
ufwmg service 9 10 11
```

不同厂商或型号的 `ufwmg service` 参数可能不同，应以设备实际 `ps` 中看到的 `ufwmg service ...` 命令行为准。

## 常见问题

### lxc-info 找不到容器

优先检查 LXC path：

```sh
/usr/bin/lxc-info -P /opt/cu/framework -n ufw
```

如果仍找不到，查看实际配置目录和容器名：

```sh
find /opt -name config | grep -i ufw
grep -R "lxc.uts.name" /opt 2>/dev/null
```

### lxc-console 无响应

这是常见情况。UFW 容器可能没有启动 console/getty。改用：

```sh
/usr/bin/lxc-attach -P /opt/cu/framework -n ufw -- /bin/ash
```

### lxc-attach 进入后命令不完整

UFW 容器可能是精简 OpenWrt rootfs，常用命令由 BusyBox、procd、ubus、uci 提供。可先检查：

```sh
echo "$PATH"
which busybox
busybox
ls /bin /sbin /usr/bin /usr/sbin
```

必要时使用绝对路径调用命令。

## G7615 示例

某些 ZTE G7615 固件中，UFW 配置为：

```sh
lxc.rootfs.path = overlayfs:/opt/cu/framework/ufw/rootfs:/opt/cu/apps/apps
lxc.uts.name = ufw
lxc.net.0.type = none
```

对应进入命令：

```sh
/usr/bin/lxc-info -P /opt/cu/framework -n ufw
/usr/bin/lxc-attach -P /opt/cu/framework -n ufw -- /bin/ash
```

如 `/bin/ash` 不存在：

```sh
/usr/bin/lxc-attach -P /opt/cu/framework -n ufw -- /bin/sh
```
