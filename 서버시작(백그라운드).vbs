Set fso = CreateObject("Scripting.FileSystemObject")
Set WshShell = CreateObject("WScript.Shell")
ScriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

PythonExe = "C:\Users\QC\AppData\Local\Programs\Python\Python314\python.exe"
ServerScript = ScriptDir & "\scripts\start-local-server.py"

' Prevent duplicate instances on port 8787
WshShell.Run "cmd /c wmic process where ""name='python.exe' and commandline like '%start-local-server.py%'"" call terminate >nul 2>nul", 0, True

Cmd = """" & PythonExe & """ """ & ServerScript & """ --host 0.0.0.0 --port 8787 --root """ & ScriptDir & """ --allow-public-clients"
WshShell.Run Cmd, 0, False

MsgBox "Server started in background." & vbCrLf & vbCrLf & _
       "URL: http://127.0.0.1:8787/index.html" & vbCrLf & vbCrLf & _
       "Run server-stop.vbs to stop.", _
       vbInformation, "Shinsung NCP Server"
