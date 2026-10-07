# System Information Collector

A lightweight **cross-platform system information and security auditing tool** for Windows and Linux.

The project automates collection of endpoint information and writes the results to timestamped text reports. It is intended for **authorized security assessments, defensive reconnaissance, incident triage, troubleshooting, and system administration**.

## Features

### Windows

- Operating system and build information
- Host, domain, and BIOS information
- CPU and memory information
- Disk and filesystem information
- Local users and groups
- Network adapters and IP configuration
- Routing table and DNS configuration
- Active TCP connections and listening ports
- Running processes
- Windows services
- Installed software
- Windows Firewall profile status
- Windows Defender status where available
- Environment variables
- PowerShell and system information

### Linux

- Distribution and kernel information
- Hostname and architecture
- CPU and memory information
- Disk, block-device, and mount information
- Current user, local users, and groups
- Logged-in users
- Network interfaces and routes
- DNS configuration
- Listening ports and active connections
- Running processes
- System services
- Installed packages
- Environment information
- Kernel modules
- UFW/firewalld status
- SELinux/AppArmor status
- Cron configuration
- System limits

## Project Structure

```text
system-information-collector/
├── windows/
│   └── system_info_collector.ps1
├── linux/
│   └── system_info_collector.sh
├── reports/
│   └── .gitkeep
├── README.md
├── LICENSE
└── .gitignore
```

## Requirements

### Windows

- Windows 10/11 or Windows Server
- PowerShell 5.1+
- Administrator privileges are recommended for more complete results

### Linux

- Bash
- Standard Linux utilities
- `sudo` may be required for some information depending on the host

The Linux collector checks for common utilities and reports when optional commands are unavailable.

## Usage

### Windows

```powershell
cd windows
.\system_info_collector.ps1
```

If your local PowerShell execution policy blocks the script for the current session:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\system_info_collector.ps1
```

The script creates a timestamped report in the current directory:

```text
system_info_YYYY-MM-DD_HHMMSS.txt
```

### Linux

```bash
cd linux
chmod +x system_info_collector.sh
./system_info_collector.sh
```

The script creates:

```text
system_info_YYYY-MM-DD_HHMMSS.txt
```

## Security and Privacy

This project is designed for **authorized systems only**.

The collectors are intended to perform read-only system enumeration. They do not intentionally collect:

- Passwords
- Password hashes
- Private SSH keys
- Browser credentials
- Authentication tokens
- Personal document contents

However, reports can contain sensitive infrastructure information such as usernames, hostnames, IP addresses, installed software, services, and network connections.

**Do not commit generated reports to a public GitHub repository.**

The repository `.gitignore` excludes generated text reports.

## Use Cases

### Security Operations

Quick endpoint visibility during initial incident triage.

### Vulnerability Assessment

Identify operating-system versions, installed applications, exposed services, and listening ports.

### Incident Response

Collect baseline host information before deeper investigation.

### System Administration

Generate a quick inventory of system configuration and resources.

### Cybersecurity Labs

Practice Windows PowerShell and Linux Bash automation in authorized lab environments.

## Architecture

```text
                    ┌──────────────────────────┐
                    │ System Information       │
                    │ Collector                │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────┴─────────────┐
                    │                          │
             ┌──────▼──────┐           ┌──────▼──────┐
             │   Windows   │           │    Linux    │
             │ PowerShell  │           │    Bash     │
             └──────┬──────┘           └──────┬──────┘
                    │                          │
                    └────────────┬─────────────┘
                                 │
                         ┌───────▼────────┐
                         │ System Data    │
                         │ Collection     │
                         └───────┬────────┘
                                 │
                         ┌───────▼────────┐
                         │ Timestamped    │
                         │ TXT Report     │
                         └────────────────┘
```

## Example Output

```text
======================================================================
              SYSTEM INFORMATION COLLECTOR
======================================================================

Collection Time : 2026-10-07 23:00:00
Hostname        : workstation
Current User    : analyst
Kernel          : 6.x.x

======================================================================
 OPERATING SYSTEM
======================================================================

...

======================================================================
 NETWORK INTERFACES
======================================================================

...

======================================================================
 LISTENING PORTS
======================================================================

...

======================================================================
 RUNNING PROCESSES
======================================================================

...

======================================================================
 COLLECTION COMPLETE
======================================================================
```

## Design Principles

- Read-only collection
- No credential harvesting
- Cross-platform coverage
- Timestamped output
- Graceful handling of unavailable commands
- Human-readable reports
- Minimal external dependencies
- Suitable for defensive security workflows

## Roadmap

Future versions can add:

- JSON and CSV output
- HTML reports
- SHA-256 report integrity hashes
- Configurable collection modules
- Security findings and risk scoring
- Detection of potentially exposed services
- Software/version assessment
- CVE enrichment
- SIEM-friendly output
- Centralized endpoint collection
- Automated unit tests
- CI/CD validation

## Skills Demonstrated

- PowerShell
- Bash
- Windows administration
- Linux administration
- Endpoint security
- System enumeration
- Network enumeration
- Security automation
- Incident response fundamentals
- Defensive reconnaissance
- Cross-platform scripting
- Git/GitHub

## Disclaimer

This project is intended for **authorized security assessments, system administration, cybersecurity education, and defensive security purposes**.

Do not use this tool to collect information from systems without appropriate authorization.

## License

MIT License. See [LICENSE](LICENSE).

---

**Author:** Your Name  
**Focus:** Cybersecurity | Penetration Testing | Security Automation
