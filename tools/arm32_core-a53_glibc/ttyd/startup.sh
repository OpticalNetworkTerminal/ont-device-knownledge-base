#!/usr/bin/env bash

set -u

# ==================== 全局配置 ====================
PORT=7681
BIND_ADDRESS="0.0.0.0"

BIN="/root/apps/ttyd/ttyd"
WORK_DIR="/root/apps/ttyd"
SHELL_BIN="/bin/bash"

MAX_CLIENTS=1
PING_INTERVAL=30
SIGNAL_NUMBER=15
TERMINAL_TYPE="xterm-256color"

RUN_DIR="/run/ttyd"
PID_FILE="${RUN_DIR}/ttyd-${PORT}.pid"
LOG_FILE="/root/apps/ttyd/ttyd-${PORT}.log"

MATCH_PATTERN="^${BIN}[[:space:]].*--port[[:space:]]+${PORT}([[:space:]]|$)"
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
        echo "[ERROR] ttyd 不存在或不可执行：${BIN}"
        exit 1
    fi

    if [[ ! -x "${SHELL_BIN}" ]]; then
        echo "[ERROR] Shell 不存在或不可执行：${SHELL_BIN}"
        exit 1
    fi

    if [[ ! -d "${WORK_DIR}" ]]; then
        echo "[ERROR] ttyd 工作目录不存在：${WORK_DIR}"
        exit 1
    fi

    if is_running; then
        echo "[INFO] ttyd 已经运行，PID=$(cat "${PID_FILE}")，端口=${PORT}"
        exit 0
    fi

    echo "[INFO] 正在启动 ttyd，监听=${BIND_ADDRESS}:${PORT}"

    nohup "${BIN}" \
        --interface "${BIND_ADDRESS}" \
        --port "${PORT}" \
        --writable \
        --max-clients "${MAX_CLIENTS}" \
        --ping-interval "${PING_INTERVAL}" \
        --signal "${SIGNAL_NUMBER}" \
        --cwd "${WORK_DIR}" \
        --terminal-type "${TERMINAL_TYPE}" \
        "${SHELL_BIN}" --noprofile --norc \
        >> "${LOG_FILE}" 2>&1 &

    sleep 1

    pid="$(find_process_pid)"

    if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
        echo "${pid}" > "${PID_FILE}"
        echo "[OK] ttyd 启动成功，PID=${pid}，端口=${PORT}"
    else
        echo "[ERROR] ttyd 启动失败，请检查日志：${LOG_FILE}"
        tail -n 30 "${LOG_FILE}" 2>/dev/null
        exit 1
    fi
}


start_service