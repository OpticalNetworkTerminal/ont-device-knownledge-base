#!/bin/sh

set -u

# ==================== 全局配置 ====================
BIN="/root/apps/v2ray/v2ray"
CONFIG_FILE="/root/apps/v2ray/config.json"

RUN_DIR="/run/v2ray"
PID_FILE="${RUN_DIR}/v2ray.pid"
LOG_FILE="/root/apps/v2ray/v2ray.log"

MATCH_PATTERN="^${BIN}[[:space:]]+run[[:space:]]+-c[[:space:]]+${CONFIG_FILE}([[:space:]]|$)"
# =================================================


find_process_pid() {
    pgrep -f "${MATCH_PATTERN}" 2>/dev/null | head -n 1
}


is_running() {
    local pid=""

    if [[ -s "${PID_FILE}" ]]; then
        pid="$(cat "${PID_FILE}" 2>/dev/null)"

        if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
            return 0
        fi

        rm -f "${PID_FILE}"
    fi

    pid="$(find_process_pid)"

    if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
        echo "${pid}" > "${PID_FILE}"
        return 0
    fi

    return 1
}


start_service() {
    local pid=""

    mkdir -p "${RUN_DIR}"
    touch "${LOG_FILE}"

    if [[ ! -x "${BIN}" ]]; then
        echo "[ERROR] V2Ray 不存在或不可执行：${BIN}"
        exit 1
    fi

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        echo "[ERROR] V2Ray 配置文件不存在：${CONFIG_FILE}"
        exit 1
    fi

    if is_running; then
        echo "[INFO] V2Ray 已经运行，PID=$(cat "${PID_FILE}")"
        exit 0
    fi

    echo "[INFO] 正在启动 V2Ray，配置文件=${CONFIG_FILE}"

    nohup "${BIN}" run \
        -c "${CONFIG_FILE}" \
        >> "${LOG_FILE}" 2>&1 &

    sleep 2

    pid="$(find_process_pid)"

    if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
        echo "${pid}" > "${PID_FILE}"
        echo "[OK] V2Ray 启动成功，PID=${pid}"
    else
        echo "[ERROR] V2Ray 启动失败，请检查日志：${LOG_FILE}"
        tail -n 30 "${LOG_FILE}" 2>/dev/null
        exit 1
    fi
}


start_service
