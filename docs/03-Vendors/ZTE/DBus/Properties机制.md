# Properties 机制

## 厂商属性接口

设备使用 `com.cuc.igd1.Properties` 作为主要属性访问接口。采集确认该接口广泛存在于业务对象上，提供：

| Method | 作用 |
| --- | --- |
| `Get` | 读取单个属性 |
| `GetAll` | 读取某个业务接口的全部属性 |
| `Set` | 修改单个属性 |
| `SetValues` | 批量修改多个属性 |

## 为什么不是标准接口

通用 DBus 规范里标准属性接口是 `org.freedesktop.DBus.Properties`。本设备的核心业务对象大多使用 `com.cuc.igd1.Properties`，因此自动化工具不能只检查标准接口。

这也解释了本次采集摘要里 `GetAll 成功数量` 只有 6：采集工具对标准接口支持更完整，但设备真正的业务读取入口是厂商接口。

## 读取示例

读取 WiFi 1 全部属性：

```sh
gdbus call --system \
  --dest com.cuc.igd1 \
  --object-path /com/cuc/igd1/Config/WLAN/Devices/1 \
  --method com.cuc.igd1.Properties.GetAll \
  com.cuc.igd1.WLANConfiguration
```

读取 DHCP 全部属性：

```sh
gdbus call --system \
  --dest com.cuc.igd1 \
  --object-path /com/cuc/igd1/Config/DHCPServer \
  --method com.cuc.igd1.Properties.GetAll \
  com.cuc.igd1.DHCPServer
```

读取客户端对象：

```sh
gdbus call --system \
  --dest com.cuc.igd1 \
  --object-path /com/cuc/igd1/Config/LANHosts/1 \
  --method com.cuc.igd1.Properties.GetAll \
  com.cuc.igd1.LANHost
```

## 修改示例

单字段修改的签名需要以设备 introspection 为准。根据采集到的方法声明，`Set` 至少包含：

```text
Set(in s interface_name, ...)
```

示例模板：

```sh
gdbus call --system \
  --dest com.cuc.igd1 \
  --object-path /com/cuc/igd1/Config/WLAN/Devices/1 \
  --method com.cuc.igd1.Properties.Set \
  com.cuc.igd1.WLANConfiguration \
  SSID \
  '<variant-value>'
```

注意：`<variant-value>` 的具体 GVariant 写法需要通过 raw introspection 或实际调用验证。不要直接在生产设备上测试密码、DHCP 地址池、WAN、系统对象。

## `SetValues`

`SetValues` 是批量修改入口。推测 Web 后台保存页面时会使用该接口一次性提交多个字段。

适合批量提交的场景：

- WiFi：`SSID/PWD/Enable/Channel/TransmitPower`
- DHCP：`LocalIP/Submask/DHCPStartIP/DHCPEndIP/DHCPDuration`
- QoS：`UpSpeed/DownSpeed/DSCPRemark`

## 修改原则

1. 先 `GetAll` 备份当前值。
2. 只修改 `readwrite` 字段。
3. 优先测试无副作用字段，例如 `DevName`。
4. 避免直接修改 `LocalIP`、`DHCPStartIP`、`PWD`、`Password`、`PPPoE`、`SysCmd`。
5. 修改后立刻重新 `GetAll` 校验。
