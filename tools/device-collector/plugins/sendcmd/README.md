# Sendcmd Plugins

`sendcmd-dump.sh` 通过插件声明“只读候选命令”，避免把 sendcmd 的各种实现方式写死在主脚本里。

## 插件接口

插件脚本调用方式：

```sh
sh plugin.sh probe
sh plugin.sh table <table_name>
```

### `probe`

输出若干条只读探测命令，用于发现：

- help
- show
- list
- dump
- DB / table 入口

每行一条完整命令。

### `table <table_name>`

针对某个自动发现的表名，输出若干条只读查询命令。

## 安全约束

- 不输出任何修改性命令
- 不包含 `set` / `delete` / `write` / `save` / `reboot` / `restore` / `upgrade` / `factory` / `commit`
- 仅声明探测和读取命令
