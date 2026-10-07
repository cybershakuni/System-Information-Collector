```powershell
#requires -Version 5.1

<#
.SYNOPSIS
    Cross-platform project companion: Windows system information collector.

.DESCRIPTION
    Collects general Windows system, hardware, network, process, service,
    software, firewall, and security information and writes it to a
    timestamped text report.

    This script is intended for authorized defensive security assessments,
    system administration, troubleshooting, and incident-response triage.

.NOTES
    Author: Your Name
    Project: System Information Collector
    Platform: Windows
#>

$ErrorActionPreference = "SilentlyContinue"

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$ReportFile = Join-Path (Get-Location) "system_info_$Timestamp.txt"

# ------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------

function Write-Section {
    param (
        [string]$Title
    )

    Add-Content -Path $ReportFile -Value ""
    Add-Content -Path $ReportFile -Value ("=" * 70)
    Add-Content -Path $ReportFile -Value " $Title"
    Add-Content -Path $ReportFile -Value ("=" * 70)
}

function Write-CommandOutput {
    param (
        [string]$Command
    )

    try {
        $Output = Invoke-Expression $Command 2>&1

        if ($null -ne $Output) {
            $Output | Out-String | Add-Content -Path $ReportFile
        }
    }
    catch {
        Add-Content -Path $ReportFile -Value "Unable to collect information."
    }
}

function Write-ObjectOutput {
    param (
        $Object
    )

    if ($null -ne $Object) {
        $Object | Format-List * | Out-String -Width 220 |
            Add-Content -Path $ReportFile
    }
}

# ------------------------------------------------------------
# Report Header
# ------------------------------------------------------------

@"
======================================================================
              SYSTEM INFORMATION COLLECTOR
======================================================================

Collection Time : $(Get-Date)
Hostname        : $env:COMPUTERNAME
Current User    : $env:USERNAME
PowerShell      : $($PSVersionTable.PSVersion)
Report File     : $ReportFile

Purpose:
Defensive system inventory, endpoint assessment, troubleshooting,
and authorized security/incident-response triage.

======================================================================
"@ | Set-Content -Path $ReportFile

# ------------------------------------------------------------
# Operating System
# ------------------------------------------------------------

Write-Section "OPERATING SYSTEM"

Get-CimInstance Win32_OperatingSystem |
    Select-Object Caption, Version, BuildNumber, OSArchitecture,
        InstallDate, LastBootUpTime, SerialNumber |
    Format-List |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Computer / BIOS Information
# ------------------------------------------------------------

Write-Section "COMPUTER INFORMATION"

Get-CimInstance Win32_ComputerSystem |
    Select-Object Manufacturer, Model, SystemType,
        Domain, PartOfDomain, TotalPhysicalMemory |
    Format-List |
    Out-String -Width 220 |
    Add-Content $ReportFile

Write-Section "BIOS INFORMATION"

Get-CimInstance Win32_BIOS |
    Select-Object Manufacturer, SMBIOSBIOSVersion,
        ReleaseDate, SerialNumber |
    Format-List |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# CPU
# ------------------------------------------------------------

Write-Section "CPU INFORMATION"

Get-CimInstance Win32_Processor |
    Select-Object Name, Manufacturer, NumberOfCores,
        NumberOfLogicalProcessors, MaxClockSpeed |
    Format-List |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Memory
# ------------------------------------------------------------

Write-Section "MEMORY INFORMATION"

$Memory = Get-CimInstance Win32_ComputerSystem

[PSCustomObject]@{
    Total_RAM_GB = [math]::Round(
        $Memory.TotalPhysicalMemory / 1GB, 2
    )
} |
    Format-List |
    Out-String |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Disk Information
# ------------------------------------------------------------

Write-Section "DISK INFORMATION"

Get-CimInstance Win32_LogicalDisk |
    Select-Object DeviceID, VolumeName, FileSystem,
        DriveType,
        @{Name="SizeGB";Expression={
            if ($_.Size) {
                [math]::Round($_.Size / 1GB, 2)
            }
        }},
        @{Name="FreeGB";Expression={
            if ($_.FreeSpace) {
                [math]::Round($_.FreeSpace / 1GB, 2)
            }
        }} |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Local Users
# ------------------------------------------------------------

Write-Section "LOCAL USERS"

Get-LocalUser |
    Select-Object Name, Enabled, LastLogon, PasswordRequired,
        PasswordExpires |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Local Groups
# ------------------------------------------------------------

Write-Section "LOCAL GROUPS"

Get-LocalGroup |
    Select-Object Name, Description |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Network Adapters
# ------------------------------------------------------------

Write-Section "NETWORK ADAPTERS"

Get-NetAdapter |
    Select-Object Name, InterfaceDescription,
        Status, MacAddress, LinkSpeed |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# IP Configuration
# ------------------------------------------------------------

Write-Section "IP CONFIGURATION"

Get-NetIPConfiguration |
    Format-List |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Routing Table
# ------------------------------------------------------------

Write-Section "ROUTING TABLE"

Get-NetRoute |
    Select-Object DestinationPrefix, NextHop,
        InterfaceAlias, RouteMetric |
    Sort-Object DestinationPrefix |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# DNS Configuration
# ------------------------------------------------------------

Write-Section "DNS CONFIGURATION"

Get-DnsClientServerAddress |
    Select-Object InterfaceAlias, AddressFamily,
        ServerAddresses |
    Format-List |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Active Connections
# ------------------------------------------------------------

Write-Section "ACTIVE NETWORK CONNECTIONS"

Get-NetTCPConnection |
    Select-Object LocalAddress, LocalPort,
        RemoteAddress, RemotePort, State, OwningProcess |
    Sort-Object LocalPort |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Listening Ports
# ------------------------------------------------------------

Write-Section "LISTENING TCP PORTS"

Get-NetTCPConnection -State Listen |
    Select-Object LocalAddress, LocalPort,
        OwningProcess |
    Sort-Object LocalPort |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Processes
# ------------------------------------------------------------

Write-Section "RUNNING PROCESSES"

Get-Process |
    Select-Object Id, ProcessName,
        @{Name="CPU(s)";Expression={
            try {
                [math]::Round($_.CPU, 2)
            }
            catch {
                0
            }
        }},
        @{Name="MemoryMB";Expression={
            [math]::Round($_.WorkingSet64 / 1MB, 2)
        }} |
    Sort-Object ProcessName |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Services
# ------------------------------------------------------------

Write-Section "WINDOWS SERVICES"

Get-Service |
    Select-Object Name, DisplayName, Status, StartType |
    Sort-Object Status, Name |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Installed Software
# ------------------------------------------------------------

Write-Section "INSTALLED SOFTWARE"

$SoftwarePaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($Path in $SoftwarePaths) {

    Get-ItemProperty $Path |
        Where-Object {
            $_.DisplayName
        } |
        Select-Object DisplayName, DisplayVersion,
            Publisher, InstallDate |
        Sort-Object DisplayName |
        Format-Table -AutoSize |
        Out-String -Width 220 |
        Add-Content $ReportFile
}

# ------------------------------------------------------------
# Windows Firewall
# ------------------------------------------------------------

Write-Section "WINDOWS FIREWALL"

Get-NetFirewallProfile |
    Select-Object Name, Enabled, DefaultInboundAction,
        DefaultOutboundAction |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Windows Defender
# ------------------------------------------------------------

Write-Section "WINDOWS DEFENDER STATUS"

try {
    Get-MpComputerStatus |
        Select-Object AMServiceEnabled,
            AntivirusEnabled,
            AntispywareEnabled,
            BehaviorMonitorEnabled,
            IoavProtectionEnabled,
            RealTimeProtectionEnabled,
            NISEnabled,
            AntivirusSignatureVersion,
            AntivirusSignatureLastUpdated |
        Format-List |
        Out-String -Width 220 |
        Add-Content $ReportFile
}
catch {
    Add-Content $ReportFile "Windows Defender information unavailable."
}

# ------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------

Write-Section "ENVIRONMENT VARIABLES"

Get-ChildItem Env: |
    Sort-Object Name |
    Format-Table -AutoSize |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# PowerShell Information
# ------------------------------------------------------------

Write-Section "POWERSHELL INFORMATION"

$PSVersionTable |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# System Information
# ------------------------------------------------------------

Write-Section "WINDOWS SYSTEM INFORMATION"

systeminfo |
    Out-String -Width 220 |
    Add-Content $ReportFile

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

Write-Section "COLLECTION COMPLETE"

Add-Content $ReportFile "Report generated successfully."
Add-Content $ReportFile "Location: $ReportFile"

Write-Host ""
Write-Host "System information collection completed."
Write-Host "Report saved to:"
Write-Host $ReportFile
```
