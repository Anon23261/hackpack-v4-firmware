<div align="center">

# 🛡️ Hackpack v4 Firmware

*Your IoT Security and Development Platform powered by Raspberry Pi!*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi-brightgreen.svg)](https://www.raspberrypi.com/)
[![OS](https://img.shields.io/badge/OS-Raspberry%20Pi%20OS-blue.svg)](https://www.raspberrypi.com/software/)

<img src="bin/root/opt/splash.png" alt="Hackpack Logo" width="400"/>

</div>

## 🚀 What is Hackpack?

Hackpack v4 is your comprehensive Python development platform! Built for the Raspberry Pi Zero W and Zero 2W, it transforms your device into a powerful portable Python workstation with integrated development tools, visual feedback, and USB payload capabilities.

### 💻 Development Features

- 🐍 Interactive Python Development
  * IPython shell (A Button)
  * Jupyter Notebook server (Start Button)
  * Quick file execution (B Button)
  * Code quality checks (X Button)

- 🎨 Visual Feedback System
  * RGB LED status indicators
  * Process state monitoring
  * Real-time execution feedback

- 🔧 Development Tools
  * Black code formatter
  * Pylint code analyzer
  * Pytest testing framework
  * MyPy type checker

- 🌐 Web Development
  * FastAPI for modern APIs
  * Uvicorn ASGI server
  * WebSocket support

- 🎮 USB Payload Development
  * HID device emulation
  * Payload generator (Y Button)
  * Quick deployment tools

## 🔧 Installation

### Step 1: Choose Your Hardware

#### 🔵 Raspberry Pi Zero W
```markdown
📥 Use 32-bit Raspberry Pi OS
🔗 Download: raspberrypi.com/software
📦 Select: "Raspberry Pi OS with desktop"
```

#### 🔴 Raspberry Pi Zero 2W (Recommended)
```markdown
🚀 Better performance for data processing
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
└── projects/          # Your Python workspace
    └── payloads/      # USB payload scripts
```

### Quick Access Buttons

#### Development Tools
- A Button: Launch IPython shell
- B Button: Run current Python file
- X Button: Run code quality checks
  * Black formatting
  * Pylint analysis
  * Pytest execution
- Y Button: USB payload generator
- Start Button: Launch Jupyter Notebook
- Select Button: Stop current process

#### Visual Feedback
- Cyan blinking: Process running
- Purple solid: Process stalled
- Green: Success
- Red: Error/Stop
- Blue: Processing

#### Development Packages
- Interactive: IPython, Jupyter
- Quality: Black, Pylint, MyPy, Pytest
- Web: FastAPI, Uvicorn, WebSockets
- Data: NumPy, Pandas, Matplotlib
- Utils: Rich, Tqdm, Python-dotenv

### Development Workflow

```bash
# Activate environment
source ~/venv/bin/activate

# Create new Python file
touch ~/projects/my_script.py

# Edit and run (B Button)
vim ~/projects/my_script.py

# Check code quality (X Button)
black .
pylint *.py
pytest

# Interactive development (A Button)
ipython

# Create USB payload (Y Button)
cd ~/projects/payloads
python3 generate_payload.py
```
