#!/bin/sh

collect_firmware_all() {
    ensure_dir "${COLLECT_BASE}/firmware"
    write_text "${COLLECT_BASE}/firmware/README.txt" \
        "Firmware collection is reserved for future expansion." \
        "Planned features:" \
        "- Offline firmware image input" \
        "- UBI / UBIFS / SquashFS extraction" \
        "- Vendor header parsing" \
        "- Partition map reconstruction"
}
