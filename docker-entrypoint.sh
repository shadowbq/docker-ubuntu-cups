#!/usr/bin/env bash
set -euo pipefail

# Configuration with defaults
CUPS_ADMIN_USERNAME="${CUPS_ADMIN_USERNAME:-admin}"
CUPS_LOG_LEVEL="${CUPS_LOG_LEVEL:-warn}"

# Validate required environment variables
if [[ -z "${CUPS_ADMIN_PASSWORD:-}" ]]; then
    echo "ERROR: CUPS_ADMIN_PASSWORD environment variable is required" >&2
    exit 1
fi

# Create admin user if it doesn't exist
if ! id "$CUPS_ADMIN_USERNAME" >/dev/null 2>&1; then
    echo "Creating CUPS admin user: $CUPS_ADMIN_USERNAME"
    useradd -m -G lpadmin -s /usr/sbin/nologin "$CUPS_ADMIN_USERNAME"
    echo "$CUPS_ADMIN_USERNAME:$CUPS_ADMIN_PASSWORD" | chpasswd
fi

# Configure log level
sed -i /etc/cups/cupsd.conf -e "s|^LogLevel .*$|LogLevel $CUPS_LOG_LEVEL|"

# Ensure PDF output directory has proper permissions
chmod 1777 /var/spool/cups-pdf/ANONYMOUS

# Run custom initialization scripts if they exist
if [[ -d /docker-entrypoint.d ]]; then
    if [[ -n "$(ls -A /docker-entrypoint.d 2>/dev/null)" ]]; then
        echo "Running initialization scripts from /docker-entrypoint.d"
        run-parts --exit-on-error /docker-entrypoint.d
    fi
fi

# If first argument starts with /, treat as a command to exec
if [[ ${1:-} == /* ]]; then
    exec "$@"
fi

# Start CUPS in foreground
echo "Starting CUPS server..."
exec cupsd -f "$@"