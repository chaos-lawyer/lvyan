# tools/update_lpr.ps1
# 静默拉取最新 LPR 数据至 legal_data/lpr.tmp
[CmdletBinding()]
param(
    [string]$TargetFile = "",
    [string]$LogFile = ""
)

$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

# 自动推导路径
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir

if (-not $TargetFile) {
    $TargetFile = Join-Path $BaseDir "legal_data\lpr.tmp"
}
if (-not $LogFile) {
    $LogFile = Join-Path $BaseDir "legal_data\lpr_update.log"
}

function Write-LprLog([string]$msg) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $entry = "[$timestamp] $msg"
    try {
        if (Test-Path $LogFile) {
            $len = (Get-Item $LogFile).Length
            if ($len -gt 50KB) {
                # 保持日志文件小巧
                Clear-Content $LogFile
            }
        }
        Add-Content -Path $LogFile -Value $entry -Encoding UTF8
    } catch {}
}

$url = "https://www.chinamoney.com.cn/r/cms/www/chinamoney/data/currency/bk-lpr.json"
$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

try {
    # 强制使用 TLS 1.2+
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $req = [System.Net.HttpWebRequest]::Create($url)
    $req.Method = "GET"
    $req.Timeout = 6000 # 6秒超时
    $req.ReadWriteTimeout = 6000
    $req.UserAgent = $userAgent

    $resp = $req.GetResponse()
    $stream = $resp.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
    $content = $reader.ReadToEnd()
    $reader.Close()
    $stream.Close()
    $resp.Close()

    if ($content -and $content.Length -gt 10 -and $content.Contains("showDateCN")) {
        $dir = Split-Path -Parent $TargetFile
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        [System.IO.File]::WriteAllText($TargetFile, $content, [System.Text.Encoding]::UTF8)
        Write-LprLog "SUCCESS: downloaded latest LPR json ($( $content.Length ) bytes)"
    } else {
        Write-LprLog "FAILED: empty or unexpected content from server"
    }
} catch {
    Write-LprLog "FAILED: $($_.Exception.Message)"
}
