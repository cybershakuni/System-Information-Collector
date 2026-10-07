```bash
#!/usr/bin/env bash

# ============================================================
# System Information Collector - Linux
# ============================================================
#
# Purpose:
#   Collect system, hardware, network, process, service,
#   storage, user and security-relevant information.
#
# Intended Use:
#   Authorized defensive security assessments,
#   system administration, troubleshooting and
#   incident-response triage.
#
# ============================================================

set +e

TIMESTAMP="$(date '+%Y-%m-%d_%H%M%S')"
REPORT="system_info_${TIMESTAMP}.txt"

# ------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------

section() {
    echo ""
    echo "======================================================================"
    echo " $1"
    echo "======================================================================"
}

run_cmd() {
    local description="$1"
    shift

    echo ""
    echo "[$description]"

    if command -v "$1" >/dev/null 2>&1; then
        "$@" 2>&1
    else
        echo "Command not available: $1"
    fi
}

# ------------------------------------------------------------
# Start Report
# ------------------------------------------------------------

{
    echo "======================================================================"
    echo "              SYSTEM INFORMATION COLLECTOR"
    echo "======================================================================"
    echo ""
    echo "Collection Time : $(date)"
    echo "Hostname        : $(hostname)"
    echo "Current User    : $(id -un 2>/dev/null)"
    echo "Kernel          : $(uname -r)"
    echo "Architecture    : $(uname -m)"
    echo "Report File     : $REPORT"
    echo ""
    echo "Purpose:"
    echo "Defensive system inventory, endpoint assessment,"
    echo "troubleshooting and authorized security/incident-response triage."
    echo ""
    echo "======================================================================"
} > "$REPORT"

# ------------------------------------------------------------
# Operating System
# ------------------------------------------------------------

{
    section "OPERATING SYSTEM"

    if [ -f /etc/os-release ]; then
        cat /etc/os-release
    else
        uname -a
    fi

    echo ""
    echo "Kernel:"
    uname -a

    echo ""
    echo "Uptime:"
    uptime
} >> "$REPORT"

# ------------------------------------------------------------
# Host Information
# ------------------------------------------------------------

{
    section "HOST INFORMATION"

    echo "Hostname:"
    hostname

    echo ""
    echo "Hostnamectl:"
    if command -v hostnamectl >/dev/null 2>&1; then
        hostnamectl
    else
        echo "hostnamectl not available"
    fi

    echo ""
    echo "Architecture:"
    uname -m
} >> "$REPORT"

# ------------------------------------------------------------
# CPU Information
# ------------------------------------------------------------

{
    section "CPU INFORMATION"

    if [ -f /proc/cpuinfo ]; then
        echo "CPU Model:"
        awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo

        echo ""
        echo "Logical CPU Count:"
        nproc 2>/dev/null

        echo ""
        echo "CPU Details:"
        lscpu 2>/dev/null || cat /proc/cpuinfo
    else
        echo "/proc/cpuinfo not available."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Memory Information
# ------------------------------------------------------------

{
    section "MEMORY INFORMATION"

    if command -v free >/dev/null 2>&1; then
        free -h
    else
        cat /proc/meminfo
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Disk Information
# ------------------------------------------------------------

{
    section "DISK INFORMATION"

    echo "Filesystem Usage:"
    df -hT

    echo ""
    echo "Block Devices:"
    if command -v lsblk >/dev/null 2>&1; then
        lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
    else
        echo "lsblk not available."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Mounted Filesystems
# ------------------------------------------------------------

{
    section "MOUNTED FILESYSTEMS"

    mount
} >> "$REPORT"

# ------------------------------------------------------------
# Current User
# ------------------------------------------------------------

{
    section "CURRENT USER"

    echo "User:"
    id

    echo ""
    echo "Groups:"
    groups

    echo ""
    echo "Home Directory:"
    echo "$HOME"
} >> "$REPORT"

# ------------------------------------------------------------
# Local Users
# ------------------------------------------------------------

{
    section "LOCAL USERS"

    if [ -f /etc/passwd ]; then
        awk -F: '{printf "%-25s UID=%-8s GID=%-8s HOME=%s\n",
            $1,$3,$4,$6}' /etc/passwd
    else
        echo "/etc/passwd unavailable."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Groups
# ------------------------------------------------------------

{
    section "LOCAL GROUPS"

    if [ -f /etc/group ]; then
        cat /etc/group
    else
        echo "/etc/group unavailable."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Logged-In Users
# ------------------------------------------------------------

{
    section "LOGGED-IN USERS"

    if command -v who >/dev/null 2>&1; then
        who
    fi

    echo ""
    if command -v w >/dev/null 2>&1; then
        w
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Network Interfaces
# ------------------------------------------------------------

{
    section "NETWORK INTERFACES"

    if command -v ip >/dev/null 2>&1; then
        ip addr show
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig -a
    else
        echo "Network interface command unavailable."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Routing Table
# ------------------------------------------------------------

{
    section "ROUTING TABLE"

    if command -v ip >/dev/null 2>&1; then
        ip route show
    elif command -v route >/dev/null 2>&1; then
        route -n
    else
        echo "Routing command unavailable."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# DNS Configuration
# ------------------------------------------------------------

{
    section "DNS CONFIGURATION"

    if [ -f /etc/resolv.conf ]; then
        cat /etc/resolv.conf
    else
        echo "/etc/resolv.conf unavailable."
    fi

    echo ""
    echo "Resolved DNS:"
    if command -v resolvectl >/dev/null 2>&1; then
        resolvectl status
    else
        echo "resolvectl not available."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Listening Ports
# ------------------------------------------------------------

{
    section "LISTENING PORTS"

    if command -v ss >/dev/null 2>&1; then
        ss -tulnp
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tulnp
    else
        echo "Neither ss nor netstat is available."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Active Network Connections
# ------------------------------------------------------------

{
    section "ACTIVE NETWORK CONNECTIONS"

    if command -v ss >/dev/null 2>&1; then
        ss -tunap
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tunap
    else
        echo "Network connection command unavailable."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Running Processes
# ------------------------------------------------------------

{
    section "RUNNING PROCESSES"

    if command -v ps >/dev/null 2>&1; then
        ps auxww
    else
        echo "ps command unavailable."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Services
# ------------------------------------------------------------

{
    section "SYSTEM SERVICES"

    if command -v systemctl >/dev/null 2>&1; then

        echo "Service Status:"
        systemctl list-units --type=service --all --no-pager

        echo ""
        echo "Enabled Services:"
        systemctl list-unit-files --type=service --state=enabled --no-pager

    elif command -v service >/dev/null 2>&1; then
        service --status-all 2>&1

    else
        echo "Service management command unavailable."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Installed Packages
# ------------------------------------------------------------

{
    section "INSTALLED SOFTWARE / PACKAGES"

    if command -v dpkg >/dev/null 2>&1; then

        echo "Debian/Ubuntu Packages:"
        dpkg-query -W -f='${Package}\t${Version}\n' 2>/dev/null

    elif command -v rpm >/dev/null 2>&1; then

        echo "RPM Packages:"
        rpm -qa 2>/dev/null

    elif command -v pacman >/dev/null 2>&1; then

        echo "Pacman Packages:"
        pacman -Q 2>/dev/null

    else
        echo "Supported package manager not detected."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

{
    section "ENVIRONMENT INFORMATION"

    echo "Shell:"
    echo "$SHELL"

    echo ""
    echo "PATH:"
    echo "$PATH"

    echo ""
    echo "Environment Variables:"
    env | sort
} >> "$REPORT"

# ------------------------------------------------------------
# Kernel Modules
# ------------------------------------------------------------

{
    section "KERNEL MODULES"

    if command -v lsmod >/dev/null 2>&1; then
        lsmod
    else
        echo "lsmod not available."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Security / Firewall Information
# ------------------------------------------------------------

{
    section "FIREWALL / SECURITY INFORMATION"

    echo "UFW:"
    if command -v ufw >/dev/null 2>&1; then
        ufw status verbose 2>&1
    else
        echo "UFW not installed."
    fi

    echo ""
    echo "Firewalld:"
    if command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --state 2>&1
        firewall-cmd --list-all 2>&1
    else
        echo "firewalld not installed."
    fi

    echo ""
    echo "SELinux:"
    if command -v getenforce >/dev/null 2>&1; then
        getenforce 2>&1
    else
        echo "SELinux tools not available."
    fi

    echo ""
    echo "AppArmor:"
    if command -v aa-status >/dev/null 2>&1; then
        aa-status 2>&1
    else
        echo "AppArmor tools not available."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Scheduled Tasks / Cron
# ------------------------------------------------------------

{
    section "CRON CONFIGURATION"

    echo "System Cron Directories:"
    for dir in /etc/cron.d /etc/cron.daily /etc/cron.hourly \
               /etc/cron.weekly /etc/cron.monthly; do

        if [ -d "$dir" ]; then
            echo ""
            echo "[$dir]"
            ls -la "$dir"
        fi
    done

    echo ""
    echo "Current User Crontab:"
    if command -v crontab >/dev/null 2>&1; then
        crontab -l 2>&1
    else
        echo "crontab command unavailable."
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# System Limits
# ------------------------------------------------------------

{
    section "SYSTEM LIMITS"

    if command -v ulimit >/dev/null 2>&1; then
        ulimit -a
    fi
} >> "$REPORT"

# ------------------------------------------------------------
# Important System Information
# ------------------------------------------------------------

{
    section "SYSTEM INFORMATION"

    echo "Kernel:"
    uname -a

    echo ""
    echo "Uptime:"
    uptime

    echo ""
    echo "Date:"
    date

    echo ""
    echo "Current Working Directory:"
    pwd
} >> "$REPORT"

# ------------------------------------------------------------
# Collection Complete
# ------------------------------------------------------------

{
    section "COLLECTION COMPLETE"

    echo "Report generated successfully."
    echo "Report location: $REPORT"
    echo "Collection completed at: $(date)"
} >> "$REPORT"

echo ""
echo "============================================================"
echo " System information collection completed."
echo "============================================================"
echo ""
echo "Report saved to:"
echo "$REPORT"
echo ""
```
