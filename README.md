# Windows Recovery Toolkit Enterprise (WRTE)

> Enterprise-grade Windows diagnostics, maintenance, recovery, reporting, and support toolkit built with PowerShell.

![Version](https://img.shields.io/badge/version-0.6.0-blue)
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

### v0.6.0 — Repair Safety & Enhanced Reporting

Version 0.6.0 strengthens WRTE's repair safety model and expands its diagnostic reporting capabilities.

Key improvements include:

- Controlled live Windows Repair execution
- Global Dry Run safety control
- Per-feature Windows Repair live-mode safety gates
- Administrator privilege validation for live repairs
- User confirmation before destructive or system-changing actions
- System File Repair using SFC
- Windows Image Repair using DISM
- Network Stack Reset
- Windows Update Repair with service-state restoration
- Professional HTML diagnostic reports
- Structured JSON diagnostic reports
- Human-readable TXT diagnostic reports
- Companion TXT, JSON, and HTML report export
- Shared timestamp handling for exported report sets
- Improved report presentation and offline viewing
- Expanded automated Pester coverage
- 200 automated tests passing

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
- Network Stack Reset
- Windows Update Repair
- Advanced Recovery Tools

Windows Repair supports controlled live execution with:

- Global Dry Run protection
- Per-feature live execution controls
- Administrator privilege checks
- User confirmation prompts
- Repair result verification
- Activity logging
- Windows Update service-state restoration

> Windows Repair uses a layered safety model. A global Dry Run setting can prevent all live repair execution, while individual repair features must also be explicitly enabled before live actions are permitted. Administrator privileges and user confirmation are required before supported live repairs are executed.

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
- Human-readable TXT Diagnostic Report
- Structured JSON Diagnostic Report
- Professional HTML Diagnostic Report
- Companion Report Export

Diagnostic reports can be generated as a matching report set in:

- TXT format for human-readable troubleshooting
- JSON format for structured data processing
- HTML format for professional offline viewing and presentation

The Export Latest Report feature detects matching companion files and exports TXT, JSON, and HTML reports together.

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

Diagnostic reports are generated as matching companion files:

```text
WRTE-DiagnosticReport-ComputerName-Timestamp.txt
WRTE-DiagnosticReport-ComputerName-Timestamp.json
WRTE-DiagnosticReport-ComputerName-Timestamp.html
```
The TXT report provides a human-readable troubleshooting summary.

The JSON report provides structured diagnostic data suitable for automation, parsing, integration, and future tooling.

The HTML report provides a professional, self-contained offline diagnostic view with formatted sections and tables.

When exporting the latest diagnostic report, WRTE automatically detects available companion files and exports the TXT, JSON, and HTML report set together.

If an exported filename already exists, WRTE applies a shared timestamp suffix to the entire report set to prevent accidental overwriting.

---

## 🧪 Automated Testing

WRTE uses Pester for automated testing.

The current test suite covers:

- Core bootstrap behavior
- Configuration loading and validation
- Logger initialization and output
- Module loading
- Function availability
- Module structure and PowerShell parser integrity
- Windows Repair safety gates
- System File Repair
- Windows Image Repair
- Network Stack Reset
- Windows Update Repair
- Windows Update service-state restoration
- Report companion export behavior
