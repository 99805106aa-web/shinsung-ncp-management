Set WshShell = CreateObject("WScript.Shell")

WshShell.Run "cmd /c wmic process where ""name='python.exe' and commandline like '%start-local-server.py%'"" call terminate >nul 2>nul", 0, True

MsgBox "Server stopped.", vbInformation, "Shinsung NCP Server"
