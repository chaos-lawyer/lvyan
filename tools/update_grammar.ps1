# tools/update_grammar.ps1
# 下载/更新 RIME-LMDG 万象语法模型 (wanxiang-lts-zh-hans.gram / wanxiang-lts-zh-hant.gram)
# 项目地址: https://github.com/amzxyz/RIME-LMDG
[CmdletBinding()]
param(
    [ValidateSet("zh-hans", "zh-hant")]
    [string]$Model = "zh-hans",
    [switch]$UseProxy = $false
)

$ErrorActionPreference = "Stop"

# 定位 Rime 用户根目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RimeDir = Split-Path -Parent $ScriptDir

$FileName = "wanxiang-lts-$Model.gram"
$TargetFile = Join-Path $RimeDir $FileName
$TempFile = Join-Path $RimeDir "$FileName.download.tmp"

# 官方 GitHub Releases 最新下载地址
$RawUrl = "https://github.com/amzxyz/RIME-LMDG/releases/latest/download/$FileName"

# 下载源列表（如果指定 -UseProxy 或直连失败则尝试镜像）
$Urls = @()
if ($UseProxy) {
    $Urls += "https://ghproxy.net/$RawUrl"
    $Urls += "https://ghfast.top/$RawUrl"
    $Urls += $RawUrl
} else {
    $Urls += $RawUrl
    $Urls += "https://ghproxy.net/$RawUrl"
    $Urls += "https://ghfast.top/$RawUrl"
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " RIME-LMDG 万象语法模型下载/更新工具" -ForegroundColor Cyan
Write-Host " 目标模型: $FileName" -ForegroundColor Yellow
Write-Host " 目标路径: $TargetFile" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

# 强制 TLS 1.2+
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$Success = $false

foreach ($url in $Urls) {
    Write-Host "`n[尝试下载] $url" -ForegroundColor Green
    try {
        if (Test-Path $TempFile) {
            Remove-Item -Force $TempFile -ErrorAction SilentlyContinue
        }

        # 使用 WebClient 或 Invoke-WebRequest 进行下载
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        
        # 显示下载状态
        Write-Host "正在下载模型文件（约 100MB~300MB，请耐心等待）..." -ForegroundColor Gray
        $webClient.DownloadFile($url, $TempFile)

        # 检查下载文件大小，确保不是 404/错误页面
        if (Test-Path $TempFile) {
            $fileSize = (Get-Item $TempFile).Length
            # .gram 语法模型通常至少几十兆（> 10MB）
            if ($fileSize -gt 10MB) {
                Write-Host "下载成功！文件大小: $([math]::Round($fileSize / 1MB, 2)) MB" -ForegroundColor Green
                
                # 移动/覆盖目标文件
                if (Test-Path $TargetFile) {
                    Remove-Item -Force $TargetFile
                }
                Move-Item -Path $TempFile -Destination $TargetFile -Force
                $Success = $true
                break
            } else {
                Write-Warning "下载的文件体积异常小 ($fileSize 字节)，可能是下载页面或网络拦截，尝试下一个源..."
                Remove-Item -Force $TempFile -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Write-Warning "当前下载源失败: $($_.Exception.Message)"
        if (Test-Path $TempFile) {
            Remove-Item -Force $TempFile -ErrorAction SilentlyContinue
        }
    }
}

if ($Success) {
    Write-Host "`n==================================================" -ForegroundColor Green
    Write-Host " [OK] 语法模型已成功部署到 Rime 目录！" -ForegroundColor Green
    Write-Host " 文件名: $FileName" -ForegroundColor White
    Write-Host "`n【下一步提示】" -ForegroundColor Yellow
    Write-Host "请右键点击任务栏小狼毫（Weasel）托盘图标，点击【重新部署】(Deploy) 即可生效！" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Green
} else {
    Write-Host "`n==================================================" -ForegroundColor Red
    Write-Host " [错误] 自动下载失败，可能因网络环境受限无法访问 GitHub。" -ForegroundColor Red
    Write-Host " 您也可以手动下载该文件：" -ForegroundColor Yellow
    Write-Host " 1. 访问 https://github.com/amzxyz/RIME-LMDG/releases" -ForegroundColor White
    Write-Host " 2. 下载 $FileName" -ForegroundColor White
    Write-Host " 3. 复制到目录: $RimeDir" -ForegroundColor White
    Write-Host " 4. 在小狼毫菜单中点击【重新部署】" -ForegroundColor White
    Write-Host "==================================================" -ForegroundColor Red
    exit 1
}
