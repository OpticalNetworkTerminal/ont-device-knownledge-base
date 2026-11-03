#!/bin/sh

OUT_DIR=$1
ENV_FILE=$2
PLUGIN_DIR="${OUT_DIR}/plugins/example-vendor"

mkdir -p "${PLUGIN_DIR}"

{
    echo "name=example-vendor"
    echo "status=template-only"
    echo "env_file=${ENV_FILE}"
    echo "note=copy this file and replace with vendor-specific collectors"
} > "${PLUGIN_DIR}/plugin-info.txt"
