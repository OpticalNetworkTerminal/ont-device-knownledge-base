#!/bin/sh

# Markdown and report rendering helpers.

render_collector_readme() {
    out_dir="$1"

    cat >"$out_dir/README.md" <<EOF
# DBus Dump

该目录由 \`dbus-dump.sh\` 自动生成。

## 内容说明

- \`services.txt\`：原始 service 列表
- \`service-index.md\`：service 索引
- \`summary.md\`：采集统计摘要
- \`logs/\`：运行日志与错误日志
- \`services/\`：每个 service 的详细结构化输出

## 说明

如果目标系统存在 \`gdbus\`，会优先使用 \`gdbus\`。

如果不存在 \`gdbus\`，则回退到 \`dbus-send\`。
EOF
}

render_service_index() {
    out_file="$1"
    services_file="$2"

    {
        echo "# Service 索引"
        echo
        echo "| Service | 目录 |"
        echo "|---|---|"

        if [ -f "$services_file" ]; then
            while IFS= read -r service; do
                [ -n "$service" ] || continue
                service_slug=$(safe_name "$service")
                echo "| \`$service\` | \`services/$service_slug/\` |"
            done <"$services_file"
        fi
    } >"$out_file"
}

render_tree_md() {
    tree_txt="$1"
    tree_md="$2"

    {
        echo "# Object Tree"
        echo
        echo '```text'
        cat "$tree_txt" 2>/dev/null
        echo '```'
    } >"$tree_md"
}

render_object_md() {
    out_file="$1"
    service="$2"
    object_path="$3"
    introspect_file="$4"
    interfaces_file="$5"
    methods_file="$6"
    signals_file="$7"
    properties_file="$8"
    children_file="$9"
    getall_index="${10}"
    managed_index="${11}"

    {
        echo "# Object"
        echo
        echo "- Service: \`$service\`"
        echo "- Object Path: \`$object_path\`"
        echo

        echo "## Interfaces"
        echo
        if [ -s "$interfaces_file" ]; then
            sed 's/^/- `/' "$interfaces_file" | sed 's/$/`/'
        else
            echo "- 无"
        fi
        echo

        echo "## Methods"
        echo
        if [ -s "$methods_file" ]; then
            sed 's/^/- `/' "$methods_file" | sed 's/$/`/'
        else
            echo "- 无"
        fi
        echo

        echo "## Signals"
        echo
        if [ -s "$signals_file" ]; then
            sed 's/^/- `/' "$signals_file" | sed 's/$/`/'
        else
            echo "- 无"
        fi
        echo

        echo "## Properties"
        echo
        if [ -s "$properties_file" ]; then
            sed 's/^/- `/' "$properties_file" | sed 's/$/`/'
        else
            echo "- 无"
        fi
        echo

        echo "## Child Objects"
        echo
        if [ -s "$children_file" ]; then
            sed 's/^/- `/' "$children_file" | sed 's/$/`/'
        else
            echo "- 无"
        fi
        echo

        echo "## GetAll"
        echo
        if [ -s "$getall_index" ]; then
            while IFS= read -r line; do
                [ -n "$line" ] || continue
                iface=${line%%|*}
                file=${line#*|}
                echo "### Interface \`$iface\`"
                echo
                echo '```text'
                quote_md "$file"
                echo '```'
                echo
            done <"$getall_index"
        else
            echo "无可用输出。"
            echo
        fi

        echo "## ManagedObjects"
        echo
        if [ -s "$managed_index" ]; then
            while IFS= read -r line; do
                [ -n "$line" ] || continue
                iface=${line%%|*}
                file=${line#*|}
                echo "### Interface \`$iface\`"
                echo
                echo '```text'
                quote_md "$file"
                echo '```'
                echo
            done <"$managed_index"
        else
            echo "无可用输出。"
            echo
        fi

        echo "## Introspection Raw Output"
        echo
        echo '```text'
        quote_md "$introspect_file"
        echo '```'
    } >"$out_file"
}

render_summary_md() {
    out_file="$1"
    tool_name="$2"
    services_count="$3"
    objects_count="$4"
    interfaces_count="$5"
    methods_count="$6"
    signals_count="$7"
    properties_count="$8"
    objectmanagers_count="$9"
    getall_count="${10}"
    failures_count="${11}"

    {
        echo "# DBus 采集摘要"
        echo
        echo "- DBus 工具：\`$tool_name\`"
        echo "- Service 数量：\`$services_count\`"
        echo "- Object 数量：\`$objects_count\`"
        echo "- Interface 数量：\`$interfaces_count\`"
        echo "- Method 数量：\`$methods_count\`"
        echo "- Signal 数量：\`$signals_count\`"
        echo "- Property 数量：\`$properties_count\`"
        echo "- ObjectManager 数量：\`$objectmanagers_count\`"
        echo "- GetAll 成功数量：\`$getall_count\`"
        echo "- 失败数量：\`$failures_count\`"
    } >"$out_file"
}
