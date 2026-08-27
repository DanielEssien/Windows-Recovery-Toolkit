# Windows Recovery Toolkit Enterprise (WRTE)

> Enterprise-grade Windows diagnostics, maintenance, recovery, reporting, and support toolkit built with PowerShell.

![Version](https://img.shields.io/badge/version-0.5.0-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE)
![Platform](https://img.shields.io/badge/platform-Windows-success)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 📖 Overview

Windows Recovery Toolkit Enterprise (WRTE) is an open-source PowerShell application designed to help IT professionals diagnose, repair, maintain, secure, and document Windows systems.

Rather than being a collection of disconnected scripts, WRTE is built around a structured, modular architecture with centralized configuration, logging, reporting, diagnostics, validation, automated testing, and reusable support tools.

WRTE is intended for IT support engineers, system administrators, desktop support teams, technical support personnel, and other Windows professionals who need a consistent troubleshooting and recovery toolkit.

---

## ✨ Vision

Build one of the most comprehensive open-source Windows IT support toolkits available.

---

## 🎯 Objectives

WRTE aims to:

- Diagnose common Windows problems
- Repair Windows system components
- Automate maintenance activities
- Troubleshoot hardware and network issues
- Review endpoint security configuration
- Support Microsoft 365 and OneDrive troubleshooting
- Generate professional diagnostic reports
- Reduce troubleshooting time
- Provide reusable enterprise IT support utilities
- Maintain a modular and extensible PowerShell architecture

---

## 🚀 Current Version

### v0.5.0 — Quality, Testing & Packaging

Version 0.5.0 focuses on improving WRTE reliability, maintainability, reporting, testing, and distribution.

Key improvements include:

- Automated Pester testing
- Configuration validation
- Hardened application startup
- Hardened module loader
- Improved error handling
- Structured JSON diagnostic reports
- Paired TXT and JSON report export
- PowerShell 7 launcher validation
- Windows batch launcher
- Automated release package generation

---

## 🧩 Modules

WRTE currently includes the following modules:

### Dashboard

Provides the main WRTE navigation interface and system overview.

### Diagnostics

Includes:

- Quick Health Check
- System File Checker
- DISM diagnostics and repair
- Disk Check
- Windows Memory Diagnostic
- Recovery Information
- Event Log Diagnostics
- Crash / BSOD Diagnostics
- Startup Diagnostics

### Hardware

Includes:

- Hardware Overview
- Storage Information
- Battery Information
- BIOS Information
- Driver and Device Health

### Network

Includes:

- Network Overview
- Adapter Information
- Connectivity Diagnostics
- DNS Diagnostics

### Maintenance

Includes:

- Temporary File Cleanup
- Windows Update Maintenance
- Disk Cleanup
- System Uptime Information

### Windows Repair

Includes:

- System File Repair
- Windows Image Repair
- Network Reset
- Windows Update Repair
- Advanced Recovery Tools

> Windows Repair currently supports Dry Run mode to help prevent unintended system changes during development and testing.

### Security

Includes:

- Security Overview
- Microsoft Defender Status
- Windows Firewall Status
- BitLocker Status
- Secure Boot Status
- Disk Encryption Detection
- TPM Status

### Microsoft 365

Includes:

- Microsoft 365 Overview
- Office Installation Detection
- Activation Information
- Outlook Diagnostics
- Microsoft Teams Detection
- Update Channel Information

### OneDrive

Includes:

- OneDrive Overview
- Sync Status
- Known Folder Backup
- Account Detection
- OneDrive Repair
- OneDrive Settings

### Reports

Includes:

- System Report
- Diagnostic Health Report
- Structured JSON Diagnostic Report
- Report Export

Diagnostic reports can be generated in both human-readable TXT format and structured JSON format.

### Utilities

Includes:

- Environment Information
- Process Lookup
- Service Lookup
- Device Manager
- Event Viewer
- Windows Administrative Tools

---

## 📊 Diagnostic Reporting

WRTE can generate detailed diagnostic reports covering:

- Operating system information
- System uptime
- Memory utilization
- Storage health
- Network configuration
- Windows Firewall
- Microsoft Defender
- Microsoft 365
- Windows event log health
- Crash and BSOD activity
- Startup load
- Driver and device health
- TPM status
- Overall system assessment

Reports are generated as:

```text
WRTE-DiagnosticReport-ComputerName-Timestamp.txt
WRTE-DiagnosticReport-ComputerName-Timestamp.json