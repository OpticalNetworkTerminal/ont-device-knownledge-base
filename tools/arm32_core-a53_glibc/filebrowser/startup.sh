#!/usr/bin/env bash

set -u

# ==================== 全局配置 ====================
PORT=8881
BIND_ADDRESS="0.0.0.0"

BIN="/root/apps/filebrowser/filebrowser"
ROOT_DIR="/root"
DATABASE="/root/apps/filebrowser/filebrowser.db"

RUN_DIR="/run/filebrowser"
PID_FILE="${RUN_DIR}/filebrowser-${PORT}.pid"
LOG_FILE="/root/apps/filebrowser/filebrowser-${PORT}.log"

MATCH_PATTERN="^${BIN}[[:space:]].*-p[[:space:]]+${PORT}([[:space:]]|$)"
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
    mkdir -p "$(dirname "${DATABASE}")"
    touch "${LOG_FILE}"

    if [[ ! -x "${BIN}" ]]; then
        echo "[ERROR] File Browser 不存在或不可执行：${BIN}"
        exit 1
    fi

    if [[ ! -d "${ROOT_DIR}" ]]; then
        echo "[ERROR] File Browser 根目录不存在：${ROOT_DIR}"
        exit 1
    fi

    if is_running; then
        echo "[INFO] File Browser 已经运行，PID=$(cat "${PID_FILE}")，端口=${PORT}"
        exit 0
    fi

    echo "[INFO] 正在启动 File Browser，监听=${BIND_ADDRESS}:${PORT}"

    nohup "${BIN}" \
        -a "${BIND_ADDRESS}" \
        -p "${PORT}" \
        -r "${ROOT_DIR}" \
        -d "${DATABASE}" \
        >> "${LOG_FILE}" 2>&1 &

    sleep 1

    pid="$(find_process_pid)"

    if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
        echo "${pid}" > "${PID_FILE}"
        echo "[OK] File Browser 启动成功，PID=${pid}，端口=${PORT}"
    else
        echo "[ERROR] File Browser 启动失败，请检查日志：${LOG_FILE}"
        tail -n 30 "${LOG_FILE}" 2>/dev/null
        exit 1
    fi
}


start_service