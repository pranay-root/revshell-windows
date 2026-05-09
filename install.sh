#!/bin/bash

# ==========================================
# PHASE 1: SYSTEM PREPARATION & WINE INSTALL
# ==========================================
echo "[+] Configuring 32-bit architecture..."
dpkg --add-architecture i386

echo "[+] Updating package lists..."
apt update

echo "[+] Installing Wine, Wine32, and Wget..."
# The -y flag ensures it doesn't prompt you during installation
apt install -y wine wine32:i386 wget

# ==========================================
# PHASE 2: WINE ENVIRONMENT SETUP
# ==========================================
echo "[+] Terminating old Wine processes and cleaning up..."
wineserver -k
rm -rf /root/.wine
sleep 2

# Force a pure 32-bit environment
export WINEARCH=win32
export WINEPREFIX=/root/.wine

echo "[+] Initializing 32-bit Wine prefix (Windows 10 mode)..."
winecfg /v win10 &
sleep 5
pkill -9 winecfg

# Registry hacks to bypass Python installer OS checks
wine reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild /t REG_SZ /d 19041 /f
wine reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ProductName /t REG_SZ /d "Windows 10 Pro" /f

# ==========================================
# PHASE 3: PYTHON & TOOL INSTALLATION
# ==========================================
if [ ! -f "python-3.11.9.exe" ]; then
    echo "[+] Downloading 32-bit Windows Python installer..."
    wget https://www.python.org/ftp/python/3.11.9/python-3.11.9.exe
fi

echo -e "\n\033[1;31m[!] IMPORTANT: In the popup window:\033[0m"
echo "    1. Check 'Add Python to PATH'"
echo "    2. Click 'Install Now'"
echo "    3. Click 'Close' when finished to continue the script."
wine python-3.11.9.exe

# The 32-bit installation path
PY_PATH="/root/.wine/drive_c/users/root/AppData/Local/Programs/Python/Python311-32/python.exe"

echo "[+] Installing PyInstaller..."
wine "$PY_PATH" -m pip install pyinstaller

echo -e "\n\033[1;31m[!] Requirements completed proceed with running start.sh \033[0m"
