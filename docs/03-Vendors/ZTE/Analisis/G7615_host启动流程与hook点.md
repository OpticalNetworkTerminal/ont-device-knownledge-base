# G7615 host 启动流程与 hook 点

本文记录 G7615 rootfs 中 host 侧启动链路，以及可在可写持久分区中插入自定义命令的 hook 点。分析对象是 host 主系统；`/opt/cu/framework` 或 `/opt/cu/framwork` 下的 UFW/LXC rootfs 不计入 host 启动脚本。

## 结论

host 启动过程中可稳定利用的持久 hook 点主要来自 `/opt/cu/apps` 这个 UBIFS 可写分区。关键机制是开机中途将 `/usr/sbin` overlay 到 `/opt/cu/apps/usrsbin`，使后续裸命令查找优先命中可写上层目录。

可挂 hook 点共 5 个：

| 启动优先级 | hook 路径 | 触发位置 | 推荐真实转发目标 | 风险等级 |
|---:|---|---|---|---|
| 1 | `/opt/cu/apps/usrsbin/dbus-uuidgen` | `/etc/init.d/dbus-rcS` 中 `dbus-uuidgen --ensure` | `/usr/bin/dbus-uuidgen "$@"` | 中 |
| 2 | `/opt/cu/apps/usrsbin/getkerpdinfo` | `/etc/init.d/rcS` 中 `getkerpdinfo` | 无需转发，执行后 `exit 0` | 低 |
| 3 | `/opt/cu/apps/usrsbin/lowpower` | `/etc/init.d/rcS` 中 `lowpower rgmii`、`lowpower ipsec` | `/bin/lowpower "$@"` | 中低 |
| 4 | `/opt/cu/apps/usrsbin/pc` | `/etc/init.d/rcS` 中 `pc&` | `/bin/pc "$@"` | 高 |
| 5 | `/opt/cu/apps/tt/ufwmg` | `dbus-rcS` 创建 `/usr/sbin/ufwmg` 指向后，后续业务启动 UFW 时触发 | `/bin/ufwmg "$@"` | 中高 |

如果只需要一个早期 host hook，优先考虑 `/opt/cu/apps/usrsbin/dbus-uuidgen`。如果希望利用厂商已有预留逻辑，并且接受它触发时间更靠后，则可使用 `/opt/cu/apps/tt/ufwmg`。

## host 启动主流程

1. `/init` 执行 `exec /bin/busybox init`。
2. BusyBox init 读取 `/etc/inittab`。
3. `/etc/inittab` 未直接启用普通 `::sysinit:/etc/init.d/rcS`，而是通过 shellproxy 启动：

   ```sh
   /bin/shellproxy ttyAMA0 115200 /etc/init.d/rcS /dev/ttyp0
   ```

4. `/etc/init.d/rcS` 执行 `mount -a`，设置 PATH：

   ```sh
   PATH="/sbin:/usr/sbin:/usr/bin:/bin:/dbus/bin:/dbus/sbin:/dbus/usr/bin:/dbus/usr/sbin:/usr/ovs/bin:/usr/ovs/sbin:/var/tmp/wireless"
   ```

5. `rcS` source `/etc/default/S00tagparam`，挂载 `/tagparam`：

   ```sh
   mount -n -t jffs2 -o nosuid /dev/mtdblock3 /tagparam
   ```

6. `rcS` source `/etc/default/S01userconfig`，挂载一批 tmpfs 和可写持久分区：

   ```sh
   mount -n -t jffs2 -o nosuid /dev/mtdblock5 /userconfig
   mount -t ubifs ubi0_0 /opt/cu/apps -o nosuid
   ```

7. `rcS` 挂载 `/kmodule` 后，按顺序执行 `/etc/rcS.d/S??*`：

   ```sh
   /etc/rcS.d/S02wlan
   /etc/rcS.d/S20tsmac
   /etc/rcS.d/S30network
   /etc/rcS.d/S43BSPDriver
   /etc/rcS.d/S99modules
   ```

8. `S02wlan` 挂载 `/wlan`：

   ```sh
   mount -n -t jffs2 -o nosuid /dev/mtdblock4 /wlan
   ```

9. `rcS` 创建 `/CuInform` overlay：

   ```sh
   mount -t overlay overlay -o lowerdir=/usr/pre_plugin/pre_CuInform_$host_name,upperdir=/opt/cu/apps/CuInformUpper,workdir=/opt/cu/apps/CuInformWork /CuInform
   ```

10. `rcS` source `/etc/init.d/dbus-rcS`。
11. `dbus-rcS` 创建 `/usr/sbin` overlay：

    ```sh
    mount -t overlay overlay -o lowerdir=/usr/sbin,upperdir=/opt/cu/apps/usrsbin,workdir=/opt/cu/apps/usrsbin_work /usr/sbin
    ```

12. overlay 后，`dbus-rcS` 执行裸命令：

    ```sh
    dbus-uuidgen --ensure
    ```

13. `dbus-rcS` 处理 `ufwmg` 链接：

    ```sh
    if [ -f /opt/cu/apps/tt/ufwmg ]; then
        ln -sf /opt/cu/apps/tt/ufwmg /usr/sbin/ufwmg
    elif [ -f /bin/ufwmg ]; then
        ln -sf /bin/ufwmg /usr/sbin/ufwmg
    fi
    ```

14. 返回 `rcS` 后，继续执行：

    ```sh
    getkerpdinfo
    lowpower rgmii
    lowpower ipsec
    pc&
    hostname -F /proc/csp/boardtype
    ```

15. `pc` 启动后管理 `dbus-daemon`、`cspd` 等 host 业务；`cspd` 再拉起 `httpd`、`scpd`、`telnetd`、`voip`、`upnpd`、`nas_main`、`mqttd` 等进程。后续 UFW/LXC 框架会通过 `ufwmg service ...` 启动。

## hook 点详解

### 1. `/opt/cu/apps/usrsbin/dbus-uuidgen`

这是最早的明确 hook 点。`dbus-rcS` 挂上 `/usr/sbin` overlay 后立刻调用 `dbus-uuidgen --ensure`。原始二进制位于 `/usr/bin/dbus-uuidgen`，但 PATH 中 `/usr/sbin` 排在 `/usr/bin` 前面，所以 `/opt/cu/apps/usrsbin/dbus-uuidgen` 会优先命中。

推荐 wrapper：

```sh
#!/bin/sh

/bin/sh /opt/cu/apps/tt/boot_hook.sh >/tmp/boot_hook.log 2>&1 &
exec /usr/bin/dbus-uuidgen "$@"
```

优点：

- 触发早，在 `pc` 启动之前。
- 与业务进程关系较弱，转发目标明确。

风险：

- 如果 wrapper 阻塞，整个 `rcS` 会卡在 `dbus-uuidgen` 这里。
- 如果不转发真实 `/usr/bin/dbus-uuidgen`，可能影响 DBus machine-id 初始化。

### 2. `/opt/cu/apps/usrsbin/getkerpdinfo`

`rcS` 中有裸命令：

```sh
getkerpdinfo
```

rootfs 中未找到明确的真实 `getkerpdinfo` 文件，因此可将它作为纯 hook 使用：

```sh
#!/bin/sh

/bin/sh /opt/cu/apps/tt/boot_hook.sh >/tmp/boot_hook.log 2>&1 &
exit 0
```

优点：

- 触发早，在 `pc` 启动之前。
- 不需要转发真实程序，失败影响相对小。

风险：

- 如果脚本阻塞，同样会卡住 `rcS`。
- 如果真实设备某些版本存在厂商 `getkerpdinfo`，不转发可能丢失诊断信息采集。

### 3. `/opt/cu/apps/usrsbin/lowpower`

`rcS` 在部分地区码条件下执行：

```sh
lowpower rgmii
lowpower ipsec
```

真实程序位于 `/bin/lowpower`，可通过 `/opt/cu/apps/usrsbin/lowpower` 包装：

```sh
#!/bin/sh

/bin/sh /opt/cu/apps/tt/boot_hook.sh >/tmp/boot_hook.log 2>&1 &
exec /bin/lowpower "$@"
```

优点：

- 在 `pc` 之前触发。
- 会被调用两次，可在 hook 中用 flag 防止重复执行。

风险：

- 不转发会影响低功耗/硬件省电设置。
- 某些地区码为 `334` 时，该分支不会执行，因此不是所有配置下都稳定触发。

防重复示例：

```sh
#!/bin/sh

flag=/tmp/boot_hook.lowpower.done
if [ ! -f "$flag" ]; then
    touch "$flag"
    /bin/sh /opt/cu/apps/tt/boot_hook.sh >/tmp/boot_hook.log 2>&1 &
fi

exec /bin/lowpower "$@"
```

### 4. `/opt/cu/apps/usrsbin/pc`

`rcS` 最后用裸命令后台启动：

```sh
pc&
```

真实程序位于 `/bin/pc`。可包装为：

```sh
#!/bin/sh

/bin/sh /opt/cu/apps/tt/boot_hook.sh >/tmp/boot_hook.log 2>&1 &
exec /bin/pc "$@"
```

优点：

- 一定处在 host 主业务启动前。
- 若需要在 `cspd/httpd/telnetd` 等业务进程前准备环境，这个点位置合适。

风险：

- 这是最高风险点。`pc` 是主进程管理器，负责拉起和监控核心业务。
- wrapper 写错、权限错误、没有 `exec /bin/pc "$@"`，会导致 DBus、CSPD、Web、Telnet、VoIP 等 host 业务异常。

### 5. `/opt/cu/apps/tt/ufwmg`

`dbus-rcS` 明确预留了可写替换逻辑：

```sh
if [ -f /opt/cu/apps/tt/ufwmg ]; then
    ln -sf /opt/cu/apps/tt/ufwmg /usr/sbin/ufwmg
fi
```

因此可创建 `/opt/cu/apps/tt/ufwmg`，接收所有参数并转发到真实 `/bin/ufwmg`：

```sh
#!/bin/sh

/bin/sh /opt/cu/apps/tt/boot_hook.sh >/tmp/boot_hook.log 2>&1 &
exec /bin/ufwmg "$@"
```

注意：这里必须调用 `/bin/ufwmg`，不要调用 `/usr/sbin/ufwmg`，否则会递归进入 wrapper。

优点：

- 是厂商脚本中显式支持的可写替换点。
- 不需要依赖 PATH 抢占，逻辑更直接。

风险：

- 触发时间较晚，通常要等后续业务框架启动 UFW/LXC。
- wrapper 写错会影响 UFW 容器、插件框架、`cuinform` 等功能。
- 对 host 基础业务影响通常小于 `pc`，但对运营商插件/应用框架影响较大。

## 启动优先级排序

按实际触发先后排序：

1. `/opt/cu/apps/usrsbin/dbus-uuidgen`
2. `/opt/cu/apps/usrsbin/getkerpdinfo`
3. `/opt/cu/apps/usrsbin/lowpower`
4. `/opt/cu/apps/usrsbin/pc`
5. `/opt/cu/apps/tt/ufwmg`

说明：

- `/opt/cu/apps/tt/ufwmg` 的 symlink 在 `dbus-rcS` 阶段就会创建，但 wrapper 的实际执行要等后续某处调用 `ufwmg`。
- `lowpower` 受地区码分支影响；`regionidx == 334` 时不会执行。
- `getkerpdinfo` 依赖裸命令查找，当前 rootfs 未见真实文件，因此适合做纯 hook，但跨版本要复核。

## 风险排序

按“写错后对系统正常启动影响”从高到低排序：

1. `/opt/cu/apps/usrsbin/pc`
2. `/opt/cu/apps/tt/ufwmg`
3. `/opt/cu/apps/usrsbin/dbus-uuidgen`
4. `/opt/cu/apps/usrsbin/lowpower`
5. `/opt/cu/apps/usrsbin/getkerpdinfo`

风险理由：

- `pc` 是 host 主进程管理器，影响 DBus、CSPD、Web、Telnet、VoIP、网络业务等核心进程。
- `ufwmg` 影响 UFW/LXC/插件框架，host 基础业务通常已启动，但插件框架会受影响。
- `dbus-uuidgen` 位置早，阻塞会卡住启动；但只要正确转发，功能面影响较小。
- `lowpower` 主要影响低功耗或硬件省电设置，且可能被调用两次。
- `getkerpdinfo` 更像诊断采集命令，当前未见真实二进制，影响最小。

## 通用 wrapper 注意事项

1. wrapper 文件需要可执行权限。
2. hook 脚本建议后台执行，避免阻塞启动：

   ```sh
   /bin/sh /opt/cu/apps/tt/boot_hook.sh >/tmp/boot_hook.log 2>&1 &
   ```

3. 需要转发真实程序时使用绝对路径，避免 PATH 再次命中 wrapper。
4. `ufwmg` wrapper 必须转发 `/bin/ufwmg "$@"`，不能转发 `/usr/sbin/ufwmg "$@"`。
5. 对可能多次触发的 hook 使用 `/tmp/*.done` flag 防重复。
6. 不建议包装 `mount`、`grep`、`mkdir`、`rm`、`ln` 等基础命令；虽然理论上可通过 `/usr/sbin` 抢占 PATH，但调用面太广，出错会严重破坏启动流程。

## 其他目录判断

- `/userconfig`：启动阶段读取 `flag_type`、`upgrade_status`、`cfg/db_*` 等配置，未见直接遍历执行脚本。
- `/tagparam`：用于参数区和硬件/地区等 tag 参数，未见直接脚本执行。
- `/wlan`：用于无线参数和校准数据，未见直接脚本执行。
- `/tmp`、`/var`、`/var/tmp`：多为 tmpfs，运行期可写但不适合作为持久开机 hook。
- `/opt/cu/apps/apps`：属于 UFW/LXC overlay 上层，不计入 host 主启动脚本。
- `/CuInform`：由 `/opt/cu/apps/CuInformUpper` overlay 到 `/CuInform`，偏插件/应用环境，不作为 host 主启动优先 hook。

