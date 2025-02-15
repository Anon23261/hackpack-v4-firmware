<div align="center">

# 🛡️ Hackpack v4 Firmware

*Your IoT Security and Development Platform powered by Raspberry Pi!*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi-brightgreen.svg)](https://www.raspberrypi.com/)
[![OS](https://img.shields.io/badge/OS-Raspberry%20Pi%20OS-blue.svg)](https://www.raspberrypi.com/software/)

<img src="bin/root/opt/splash.png" alt="Hackpack Logo" width="400"/>

</div>

## 🚀 What is Hackpack?

Hackpack v4 is your comprehensive IoT security and development platform! Originally a gaming device, it has been transformed into a powerful tool for IoT security testing, API development, and network analysis. Supporting both Raspberry Pi Zero W and Zero 2W, it's perfect for portable security testing and development.

### 🛠️ Security Features

- 🔍 Network Analysis Tools (nmap, wireshark, tcpdump)
- 🛡️ Security Testing Framework (pwntools, scapy)
- 🔐 Cryptography Tools
- 📡 Network Scanner
- 🕵️ Packet Analysis

### 💻 Development Features

- 🌐 API Development (FastAPI, Flask)
- 🐍 Python Virtual Environment
- 🧪 Testing Framework (pytest)
- 📊 Code Quality Tools (black, pylint)
- 🗄️ Database Support (SQLite, SQLAlchemy)

## 🔧 Installation

### Step 1: Choose Your Hardware

#### 🔵 Raspberry Pi Zero W
```markdown
✨ Perfect for Classic Gaming
📥 Use 32-bit Raspberry Pi OS
🔗 Download: raspberrypi.com/software
📦 Select: "Raspberry Pi OS with desktop"
```

#### 🔴 Raspberry Pi Zero 2W (Recommended)
```markdown
🚀 Enhanced Performance
📥 Use 64-bit Raspberry Pi OS
🔗 Download: raspberrypi.com/software
📦 Select: "Raspberry Pi OS (64-bit) with desktop"
```

### Step 2: Install the Firmware

1. Clone this repository:
```bash
git clone https://github.com/YourUsername/hackpack-v4-firmware.git /home/pi/firmware
```

2. Run the installer:
```bash
sudo bash /home/pi/firmware/bin/install.sh
```

🎯 The firmware will automatically detect your Pi model and apply the optimal configuration!

## 🔧 Features

### 🔍 Security Tools
- Network Scanning & Analysis
  - Discover devices on your network
  - Analyze network traffic
  - Monitor IoT device communications
- Security Testing
  - Automated security assessments
  - Protocol analysis
  - Vulnerability scanning

### 🌐 Development Environment
- API Development
  - FastAPI with automatic OpenAPI docs
  - RESTful API templates
  - API testing tools
- Code Quality
  - Automated formatting with black
  - Linting with pylint
  - Unit testing with pytest

### 📊 Data Analysis
- SQLite database support
- Jupyter notebooks
- Data visualization tools

## 🛠️ Development

### Prerequisites
- Raspberry Pi Zero W or Zero 2W
- Raspberry Pi OS (32/64-bit)
- Basic Linux knowledge

### Quick Start Guide
```bash
# Install the platform
git clone https://github.com/Anon23261/hackpack-v4-firmware.git /home/pi/firmware
sudo bash /home/pi/firmware/bin/install.sh

# Start using the tools
source ~/venv/bin/activate  # Activate Python environment

# Network scanning
sudo python3 ~/projects/scan_network.py

# Start the API server
cd ~/projects/api
python3 example_server.py
```

## 🤝 Contributing

We welcome contributions! Feel free to:
- 🔍 Add new security tools
- 🌐 Improve API templates
- 📊 Enhance analysis features
- 🐛 Fix bugs
- 📚 Improve documentation

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

<div align="center">

### 🛡️ Secure Development & Analysis! 💻

</div>

## 📚 Detailed Documentation

### Project Structure

```
/home/pi/
├── firmware/          # Core system files
├── venv/              # Python virtual environment
└── projects/          # Your development workspace
    ├── iot/           # IoT-related projects
    ├── api/           # API development
    └── security/      # Security tools
```

### Available Tools

#### Network Analysis
- `scan_network.py`: Discover devices on your network
- Wireshark: GUI-based packet analysis
- tcpdump: Command-line packet capture
- nmap: Network mapping and security scanning

#### Development Tools
- FastAPI: Modern API development
- Flask: Lightweight web applications
- SQLAlchemy: Database ORM
- pytest: Testing framework
- black: Code formatter
- pylint: Code linter

#### Security Testing
- pwntools: CTF framework and exploit development
- scapy: Packet manipulation
- cryptography: Cryptographic recipes

### Command-Line Interface

```bash
# Network scanning
sudo python3 ~/projects/scan_network.py 192.168.1.0/24

# Start API server
python3 ~/projects/api/example_server.py

# Code quality
black ~/projects/
pylint ~/projects/
pytest ~/projects/
```
