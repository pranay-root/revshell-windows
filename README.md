<div align="center">

<img src="https://github.com/user-attachments/assets/910dbba7-d046-4c39-a13c-a1c5d1c9e6bc" alt="REVPDF Logo" width="400">

### Weaponized PDF Framework

![Kali](https://img.shields.io/badge/Kali_Linux-268BCC?style=for-the-badge&logo=kalilinux&logoColor=white)
![Python](https://img.shields.io/badge/Python_3-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Windows](https://img.shields.io/badge/Windows_Targets-0078D6?style=for-the-badge&logo=windows&logoColor=white)

*Advanced Red Team Payload Wrapper & Deployment Framework*

</div>


## ⚡ What is REVPDF?

**REVPDF** is an automated, stealth-focused deployment framework designed specifically for Ethical Hacking labs and Red Team operations.

It solves the classic "delivery problem" by bridging the gap between a raw reverse shell payload and a social engineering pretext. By leveraging Wine, Python, and native Windows scripting, REVPDF instantly compiles a **Zero-Click Wrapper**—a single executable that perfectly mimics a standard PDF document while silently executing a PowerShell reverse shell in the background.

### ⚠️ Ethical Disclaimer

> **REVPDF is developed strictly for educational purposes, authorized penetration testing, and cybersecurity research.** The creator assumes no liability and is not responsible for any misuse or damage caused by this program. Never deploy this against systems without explicit, written consent.

---

## 🔥 Arsenal Features

* **🎭 The Phantom Frontend:** Employs the "Double-Extension Trick" (e.g., `invoice.pdf.exe`) paired with high-res Adobe icons to bypass visual suspicion.
* **⚙️ Cross-Compilation Engine:** Automatically provisions a pure 32-bit (x86) Windows environment inside Kali Linux for maximum target compatibility.
* **💉 Dynamic Injection:** Modifies the payload's `LHOST` on-the-fly via stream editing (`sed`), allowing seamless transitions between local testing and remote Ngrok/VPS deployments.
* **🐙 Multi-Shell Orchestration:** Integrates directly with Metasploit Framework (`exploit/multi/handler`) to catch, background, and manage multiple simultaneous victim connections seamlessly.
* **🚀 Rapid Redeployment:** Built-in interactive menu allows operators to rebuild payloads, spin up temporary HTTP hosting, or launch listeners in seconds.

---

## 🏗️ Architecture & Execution Flow

Understanding how **REVPDF** operates under the hood is critical for evasion and payload modification.

### Phase 1: The Build (Kali Linux)

1. **Source:** Takes your legitimate `file.pdf` and raw `payload.ps1`.
2. **Bind:** PyInstaller (running via Wine) packages these assets alongside a Python bootloader (`wrapper.py`).
3. **Output:** A standalone, 32-bit Windows Executable disguised as a document.

### Phase 2: The Execution (Target Windows Machine)

When the target double-clicks the file, the execution forks instantly:

```text
[ Target Clicks invoice.pdf.exe ]
       │
       ├──► 📂 Extracts assets to hidden %TEMP% directory.
       │
       ├──► 📄 FRONTEND THREAD: 
       │    Calls OS Default API -> Opens 'invoice.pdf' in Chrome/Edge/Adobe.
       │    (Target is reading the document within milliseconds)
       │
       └──► 🥷 BACKEND THREAD: 
            Calls wscript.exe -> Runs VBScript -> Executes PowerShell Payload.
            (Runs entirely hidden from the taskbar and UI)

```

### Phase 3: The Catch

The payload reaches out to the specified `LHOST`, where REVPDF's automated Metasploit listener catches the incoming TCP stream and drops it into a background session.

---

## 🛠️ Quick Start Guide

**1. Clone & Prep**
Ensure you are running as `root` on Kali Linux.

```bash
git clone https://github.com/pranay-root/revpdf.git
cd revpdf
chmod +x install.sh start.sh

```

**2. Initialize the Framework**
Run the setup script to build the Wine environment. *(Remember to check "Add to PATH" when the Python installer pops up).*

```bash
./install.sh

```

**3. Launch the Operator Menu**

```bash
./start.sh

```

Follow the interactive prompts to inject your IP, name your payload, and launch the listener.

---

