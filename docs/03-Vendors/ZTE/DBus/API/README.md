# API

本目录不是原始导出结果，而是面向开发和逆向的 API 手册。

当前采用“按功能域组织”的方式，避免把 141 个对象拆成难以维护的小文件。对象实例使用模式表示，例如：

```text
/com/cuc/igd1/Config/WLAN/Devices/{1..8}
/com/cuc/igd1/Config/LANHosts/{1..19}
```

## 文档

- [对象手册](./对象手册.md)

## 通用调用模板

Introspect：

```sh
gdbus introspect --system \
  --dest com.cuc.igd1 \
  --object-path /com/cuc/igd1/Config/WLAN/Devices/1
```

读取全部属性：

```sh
gdbus call --system \
  --dest com.cuc.igd1 \
  --object-path /com/cuc/igd1/Config/WLAN/Devices/1 \
  --method com.cuc.igd1.Properties.GetAll \
  com.cuc.igd1.WLANConfiguration
```

读取集合：

```sh
gdbus call --system \
  --dest com.cuc.igd1 \
  --object-path /com/cuc/igd1/Config/LANHosts \
  --method com.cuc.igd1.ObjectManager.GetManagedObjects
```
