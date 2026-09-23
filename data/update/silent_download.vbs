' silent_download.vbs <url> <path> <timeout>
' Windows 完全静默后台下载脚本：零窗口、零黑框
On Error Resume Next
Dim args, url, path, timeout, sh, ret, curl_cmd, http, stream, ps_cmd, fso
Set args = WScript.Arguments
If args.Count < 2 Then WScript.Quit 1
url = args(0)
path = args(1)
timeout = 8
If args.Count >= 3 Then timeout = CInt(args(2))

Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
ret = -1

' Tier 1: curl.exe (hidden with 0, wait with True)
curl_cmd = "curl.exe -s --max-time " & timeout & " -A ""Mozilla/5.0"" """ & url & """ -o """ & path & """"
ret = sh.Run(curl_cmd, 0, True)

If ret = 0 Then
    If Not fso.FileExists(path) Then
        ret = -1
    ElseIf fso.GetFile(path).Size = 0 Then
        fso.DeleteFile path, True
        ret = -1
    End If
End If

' Tier 2: MSXML2.ServerXMLHTTP.6.0 (in-process COM)
If ret <> 0 Then
    Err.Clear
    Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    If Err.Number = 0 And Not http Is Nothing Then
        http.open "GET", url, False
        http.setTimeouts 3000, 3000, timeout * 1000, timeout * 1000
        http.setRequestHeader "User-Agent", "Mozilla/5.0"
        http.send
        If Err.Number = 0 And http.status = 200 Then
            Set stream = CreateObject("ADODB.Stream")
            stream.Open
            stream.Type = 1
            stream.Write http.responseBody
            stream.SaveToFile path, 2
            stream.Close
            If fso.FileExists(path) And fso.GetFile(path).Size > 0 Then
                ret = 0
            End If
        End If
    End If
End If

' Tier 3: PowerShell fallback (hidden with 0, wait with True)
If ret <> 0 Then
    Err.Clear
    ps_cmd = "powershell -NoProfile -NonInteractive -Command ""$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -TimeoutSec " & timeout & " -Uri '" & Replace(url, "'", "''") & "' -OutFile '" & Replace(path, "'", "''") & "'"""
    sh.Run ps_cmd, 0, True
End If
