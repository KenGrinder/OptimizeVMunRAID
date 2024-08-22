# Function to safely execute a command and handle errors
function Safe-Execute {
    param (
        [string]$Command,
        [string]$ErrorMessage
    )
    try {
        Invoke-Expression $Command
    } catch {
        Write-Error "$ErrorMessage: $_"
    }
}

# Backup Registry Key Function
function Backup-RegistryKey {
    param (
        [string]$KeyPath,
        [string]$BackupPath
    )
    try {
        if (Test-Path $KeyPath) {
            Export-RegistryKey -Path $KeyPath -LiteralPath $BackupPath -ErrorAction Stop
            Write-Host "Backup of $KeyPath saved to $BackupPath."
        } else {
            Write-Host "Registry key $KeyPath does not exist. No backup needed."
        }
    } catch {
        Write-Error "Failed to backup $KeyPath: $_"
    }
}

# Step 1: Enable Hibernation (if needed)
Write-Host "Enabling Hibernation..."
Safe-Execute -Command "powercfg /hibernate on" -ErrorMessage "Failed to enable hibernation"

# Step 2: Configure Power Options for Hibernation
Write-Host "Configuring Power Options for Hibernation..."
$hibernateSettingsCmd = @"
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
"@
Safe-Execute -Command $hibernateSettingsCmd -ErrorMessage "Failed to configure power options for hibernation"

# Step 3: Disable Fast Startup with Registry Backup
Write-Host "Disabling Fast Startup..."
$fastStartupRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$backupPath = "$env:TEMP\FastStartupRegBackup.reg"

Backup-RegistryKey -KeyPath $fastStartupRegPath -BackupPath $backupPath
Safe-Execute -Command "Set-ItemProperty -Path $fastStartupRegPath -Name 'HiberbootEnabled' -Value 0" -ErrorMessage "Failed to disable Fast Startup"

# Step 4: Disable Hibernation (and remove hiberfil.sys)
Write-Host "Disabling Hibernation to remove hiberfil.sys..."
Safe-Execute -Command "powercfg /hibernate off" -ErrorMessage "Failed to disable hibernation"

# Step 5: Disable Windows Indexing Service with Error Handling
Write-Host "Disabling Windows Indexing..."
try {
    $windowsSearchService = Get-Service "WSearch"
    if ($windowsSearchService.Status -eq "Running") {
        Stop-Service "WSearch" -Force -ErrorAction Stop
        Write-Host "Windows Search service stopped."
    }
    Set-Service "WSearch" -StartupType Disabled -ErrorAction Stop
    Write-Host "Windows Search service disabled."
} catch {
    Write-Error "Failed to disable Windows Indexing service: $_"
}

# Step 6: Disable Automatic Disk Defragmenting
Write-Host "Disabling Automatic Disk Defragmenting..."
$defragTaskName = "\Microsoft\Windows\Defrag\ScheduledDefrag"
Safe-Execute -Command "schtasks /Change /TN $defragTaskName /DISABLE" -ErrorMessage "Failed to disable automatic disk defragmenting"

# Step 7: Enable High Performance Power Mode with Error Handling
Write-Host "Enabling High Performance Power Mode..."
try {
    $highPerformanceSchemeGuid = (powercfg /list | Select-String -Pattern "High performance" | ForEach-Object { $_ -replace '.*\((.+)\)', '$1' }).Trim()
    if ($highPerformanceSchemeGuid) {
        powercfg /setactive $highPerformanceSchemeGuid
        Write-Host "High Performance Power Mode activated."
    } else {
        Write-Error "High Performance Power Mode not found."
    }
} catch {
    Write-Error "Failed to enable High Performance Power Mode: $_"
}

Write-Host "VM Optimization Complete!"
