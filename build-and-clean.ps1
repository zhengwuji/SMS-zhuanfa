# ============================================================
#  SmsForwarder 编译 + 自动清理内存
#  用途：编译 APK，完成后立即回收 Gradle/Kotlin 守护进程占用的内存
#  用法：
#     powershell -ExecutionPolicy Bypass -File build-and-clean.ps1
#     powershell -ExecutionPolicy Bypass -File build-and-clean.ps1 -Task assembleDebug
#     powershell -ExecutionPolicy Bypass -File build-and-clean.ps1 -KeepDaemon
# ============================================================

param(
    # 要执行的 Gradle 任务，默认打 release 包
    [string]$Task = "assembleRelease",
    # 保留守护进程（下次编译更快，但内存持续占用）
    [switch]$KeepDaemon,
    # 编译产物输出目录（复制 APK 到这里）
    [string]$OutputDir = ".."
)

$ErrorActionPreference = "Continue"

# ---------- 环境配置 ----------
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$JdkHome     = "C:\Users\Administrator\.jdks\jdk-17.0.19+10"
$SdkRoot     = "G:\Personal\Desktop\SMS\android-sdk"

function Write-Step($msg) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  $msg" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
}

function Get-MemoryInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $totMB  = [math]::Round($os.TotalVisibleMemorySize / 1KB, 0)
    $freeMB = [math]::Round($os.FreePhysicalMemory / 1KB, 0)
    $usedMB = $totMB - $freeMB
    return [PSCustomObject]@{
        Total   = $totMB
        Free    = $freeMB
        Used    = $usedMB
        Percent = [math]::Round($usedMB / $totMB * 100, 1)
    }
}

function Get-JavaMemory {
    $procs = @(Get-Process -Name "java", "javaw" -ErrorAction SilentlyContinue)
    if ($procs.Count -eq 0) { return 0 }
    return [math]::Round((($procs | Measure-Object WorkingSet64 -Sum).Sum) / 1MB, 0)
}

function Show-Memory($label) {
    $m = Get-MemoryInfo
    $javaMB = Get-JavaMemory
    Write-Host ("  {0,-10} 系统内存: {1}% 已用 ({2} MB 可用) | Java 进程占用: {3} MB" -f `
        $label, $m.Percent, $m.Free, $javaMB) -ForegroundColor Gray
}

# ---------- 开始 ----------
Write-Step "SmsForwarder 编译"
Write-Host "  项目目录: $ProjectRoot"
Write-Host "  Gradle 任务: $Task"

Show-Memory "编译前"

# ---------- 配置环境变量 ----------
$env:JAVA_HOME        = $JdkHome
$env:ANDROID_HOME     = $SdkRoot
$env:ANDROID_SDK_ROOT = $SdkRoot
$env:PATH             = "$JdkHome\bin;$SdkRoot\platform-tools;$env:PATH"

if (-not (Test-Path "$JdkHome\bin\java.exe")) {
    Write-Host "  [错误] 未找到 JDK: $JdkHome" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $SdkRoot)) {
    Write-Host "  [错误] 未找到 Android SDK: $SdkRoot" -ForegroundColor Red
    exit 1
}

# ---------- 执行编译 ----------
Write-Step "开始编译"
$startTime = Get-Date
Push-Location $ProjectRoot

$gradleArgs = @($Task, "--no-daemon", "--stacktrace")
& cmd.exe /c "gradlew.bat $($gradleArgs -join ' ') 2>&1"
$exitCode = $LASTEXITCODE

Pop-Location
$elapsed = (Get-Date) - $startTime

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "  编译成功  耗时: $([math]::Round($elapsed.TotalMinutes,1)) 分钟" -ForegroundColor Green
} else {
    Write-Host "  编译失败  退出码: $exitCode  耗时: $([math]::Round($elapsed.TotalMinutes,1)) 分钟" -ForegroundColor Red
}

# ---------- 收集 APK ----------
if ($exitCode -eq 0) {
    Write-Step "收集编译产物"
    $apkDir = Join-Path $ProjectRoot "build\app\outputs\apk\release"
    if ($Task -match "Debug") {
        $apkDir = Join-Path $ProjectRoot "build\app\outputs\apk\debug"
    }

    $apks = @(Get-ChildItem $apkDir -Filter "*.apk" -ErrorAction SilentlyContinue)
    if ($apks.Count -gt 0) {
        $dest = Resolve-Path (Join-Path $ProjectRoot $OutputDir) -ErrorAction SilentlyContinue
        if ($dest) {
            foreach ($apk in $apks) {
                Copy-Item $apk.FullName -Destination $dest -Force
                Write-Host ("  {0,-52} {1,7} MB" -f $apk.Name, [math]::Round($apk.Length / 1MB, 2)) -ForegroundColor Green
            }
            Write-Host "  已复制到: $dest"
        }
    } else {
        Write-Host "  未找到 APK 产物" -ForegroundColor Yellow
    }
}

# ---------- 清理内存 ----------
Write-Step "清理内存"

if ($KeepDaemon) {
    Write-Host "  已指定 -KeepDaemon，保留守护进程（下次编译更快）" -ForegroundColor Yellow
    Write-Host "  提示：守护进程闲置后会自动退出，也可随时运行 gradlew --stop" -ForegroundColor DarkGray
} else {
    Show-Memory "清理前"

    # 1. 用 Gradle 官方方式停止守护进程（干净退出，不留锁文件）
    Write-Host "  [1/3] 停止 Gradle 守护进程..."
    Push-Location $ProjectRoot
    & cmd.exe /c "gradlew.bat --stop 2>&1" | Out-Null
    Pop-Location
    Start-Sleep -Seconds 2

    # 2. 终止残留的 Java/Kotlin 编译进程
    Write-Host "  [2/3] 清理残留 Java 进程..."
    $remain = @(Get-Process -Name "java", "javaw" -ErrorAction SilentlyContinue)
    if ($remain.Count -gt 0) {
        foreach ($p in $remain) {
            $ci = Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)" -ErrorAction SilentlyContinue
            $cl = if ($ci.CommandLine) { $ci.CommandLine } else { "" }
            # 只清理与本项目/Gradle/Kotlin 相关的进程，避免误杀其他 Java 程序
            if ($cl -match "gradle|GradleDaemon|kotlin|SmsForwarder") {
                try {
                    Stop-Process -Id $p.Id -Force -ErrorAction Stop
                    Write-Host ("    已终止 PID {0} ({1} MB)" -f $p.Id, [math]::Round($p.WorkingSet64 / 1MB, 0)) -ForegroundColor DarkGray
                } catch {
                    Write-Host ("    PID {0} 终止失败" -f $p.Id) -ForegroundColor DarkGray
                }
            } else {
                Write-Host ("    跳过 PID {0}（非本项目进程）" -f $p.Id) -ForegroundColor DarkGray
            }
        }
    } else {
        Write-Host "    无残留 Java 进程" -ForegroundColor DarkGray
    }

    Start-Sleep -Seconds 2

    # 3. 报告结果
    Write-Host "  [3/3] 完成"
    Show-Memory "清理后"
}

Write-Host ""
$m = Get-MemoryInfo
Write-Host ("  当前系统内存占用: {0}%  可用: {1} MB" -f $m.Percent, $m.Free) -ForegroundColor Cyan
Write-Host ""

exit $exitCode
