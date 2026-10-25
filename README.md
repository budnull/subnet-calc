# SubnetCalc

> **SubnetCalc** is a fast, modern, and native macOS network calculator and diagnostic utility built with Swift and SwiftUI.

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-blue?logo=apple)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift)
![License MIT](https://img.shields.io/badge/License-MIT-green)
![Tests Passing](https://img.shields.io/badge/Tests-62%2F62%20passed-brightgreen)

---

## 🚀 Features

- **IPv4 Subnet Calculator**:
  - CIDR notation and dotted-decimal mask support (`192.168.1.10/24` or `10.0.0.1 255.255.0.0`).
  - Network, broadcast, usable host range, host counts, address class (A/B/C/D/E), and address types (RFC 1918 Private, Public, Loopback, Link-Local).
  - Highlighting of network (blue) and host (orange) bits in binary.

- **IPv6 Subnet Calculator**:
  - Full 128-bit address and prefix calculation (/0 to /128).
  - Canonical RFC 5952 zero-compression (`::`) and full expansion.
  - Exact total address calculation without precision loss.

- **Subnetting (Equal Division & VLSM)**:
  - **Equal Division**: Split networks into $N$ equal-sized subnets.
  - **VLSM (Variable Length Subnet Masking)**: Optimal allocation based on custom host demands.

- **Supernetting (Route Aggregation)**:
  - Summarize multiple subnets into the most specific single CIDR route.

- **Network Tools & Diagnostics**:
  - **Check IP in Subnet**: Test if an address falls within a designated CIDR block.
  - **CIDR / Mask Converter**: Bidirectional conversion between CIDR `/n`, decimal mask, and wildcard.
  - **DNS & Reverse DNS (PTR) Lookup**: Resolve domains to IPs or IPs to hostnames.
  - **Ping Sweep / Network Scanner**: Scan subnets with live latency and hostname detection.

- **Menu Bar Mode (`MenuBarExtra`)**:
  - Quick popup in the macOS Menu Bar with one-click copy/paste buttons.

- **History & Export**:
  - Persistent history across sessions.
  - Export to Text, CSV, or save to disk.

- **100% Bilingual**:
  - Native support for both **Italian** and **English** with system-language detection.

---

## 🛠️ Requirements & Installation

- **macOS**: 13.0 (Ventura) or later.
- **Xcode / Command Line Tools**: 15.0+ or later.

### Install from DMG

Download `SubnetCalc.dmg` from the [Releases](https://github.com/) page and drag **SubnetCalc** into your `/Applications` folder.

---

## 💻 Building from Source

Clone the repository:
```bash
git clone https://github.com/<your-username>/subnet-calc.git
cd subnet-calc
```

### Run Tests
```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

### Build & Run
```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run
```

### Create the `.app` Bundle
```bash
./build_app.sh
```

### Create the `.dmg` Installer
```bash
./create_dmg.sh
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
