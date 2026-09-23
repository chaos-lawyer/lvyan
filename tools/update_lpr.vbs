' tools/update_lpr.vbs
' Windows 下通过 WScript.Shell 彻底隐藏运行 PowerShell 脚本，绝无任何控制台黑框或蓝框弹出
Option Explicit

Dim ws, fso, scriptDir, baseDir, psScript, cmd

Set ws = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
baseDir = fso.GetParentFolderName(scriptDir)
psScript = fso.BuildPath(scriptDir, "update_lpr.ps1")

If fso.FileExists(psScript) Then
    cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & psScript & """"
    ' 参数 0 表示隐藏窗口 (vbHide)，False 表示异步非阻塞执行
    ws.Run cmd, 0, False
End If
