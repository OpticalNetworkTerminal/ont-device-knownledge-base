# Plugins

`plugins/` 用于放置厂商或设备类型特定的扩展采集脚本。

## 调用约定

主入口会按如下方式执行每个插件：

```sh
sh plugin.sh "<output_dir>" "<environment_file>"
```

参数说明：

- `$1`: 采集输出根目录
- `$2`: `environment.txt` 路径

## 设计建议

- 每个插件只负责自己的输出子目录
- 不要修改主采集逻辑的既有输出
- 插件内部也应遵守“失败不影响整体”的原则
- 建议在插件中输出：
  - `plugin-info.txt`
  - `commands/`
  - `artifacts/`

## 推荐命名

- `huawei.sh`
- `zte.sh`
- `fiberhome.sh`
- `tw.sh`

## 后续可扩展点

- 增加插件 `manifest`
- 支持按设备指纹自动启用插件
- 支持插件声明所需命令与风险等级
