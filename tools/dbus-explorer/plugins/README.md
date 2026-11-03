# DBus Explorer Plugins

Vendor plugins are optional POSIX shell files loaded from this directory.

Reserved hook:

```sh
dbus_explorer_plugin_after_object() {
    service=$1
    object_path=$2
    introspect_file=$3
    # vendor-specific parsing can be added here
}
```

Suggested future plugin names:

- `huawei.sh`
- `zte.sh`
- `fiberhome.sh`
- `tw.sh`

