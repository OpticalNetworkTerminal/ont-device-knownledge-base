#!/usr/bin/env bash

set -u

# ==================== 全局配置 ====================
BIN="/root/apps/cloudflare/cloudflared"

# 优先读取环境变量 CLOUDFLARED_TOKEN。
# 环境变量为空时，从此文件读取 Token。
TOKEN_FILE="/root/apps/cloudflare/tunnel.token"

RUN_DIR="/run/cloudflared"
PID_FILE="${RUN_DIR}/cloudflared.pid"
LOG_FILE="/root/apps/cloudflare/cloudflared.log"

MATCH_PATTERN="^${BIN}[[:space:]]+tunnel[[:space:]]+run([[:space:]]|$)"
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


get_token() {
    local token="${CLOUDFLARED_TOKEN:-}"

    if [[ -z "${token}" ]] && [[ -r "${TOKEN_FILE}" ]]; then
        token="$(tr -d '\r\n' < "${TOKEN_FILE}")"
    fi

    printf '%s' "${token}"
}


start_service() {
    local pid=""
    local token=""

    mkdir -p "${RUN_DIR}"
    touch "${LOG_FILE}"

    if [[ ! -x "${BIN}" ]]; then
        echo "[ERROR] cloudflared 不存在或不可执行：${BIN}"
        exit 1
    fi

    if is_running; then
        echo "[INFO] cloudflared 已经运行，PID=$(cat "${PID_FILE}")"
        exit 0
    fi

    token="$(get_token)"

    if [[ -z "${token}" ]]; then
        echo "[ERROR] 未设置 Cloudflare Tunnel Token"
        echo "[INFO] 请设置环境变量 CLOUDFLARED_TOKEN，或写入：${TOKEN_FILE}"
        exit 1
    fi

    echo "[INFO] 正在启动 cloudflared"

    nohup "${BIN}" tunnel run \
        --token "${token}" \
        >> "${LOG_FILE}" 2>&1 &

    unset token

    sleep 2

    pid="$(find_process_pid)"

    if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
        echo "${pid}" > "${PID_FILE}"
        echo "[OK] cloudflared 启动成功，PID=${pid}"
    else
        echo "[ERROR] cloudflared 启动失败，请检查日志：${LOG_FILE}"
        tail -n 30 "${LOG_FILE}" 2>/dev/null
        exit 1
    fi
}


start_service