# Function to safely execute a command and handle errors, with debugging
function Safe-Execute {
    param (
        [string]$Command,
        [string]$ErrorMessage
    )
    Write-Host "Executing Command: $Command"
    try {
        Invoke-Expression $Command
    } catch {
        Write-Error "${ErrorMessage}: $($_)"
        Write-Host "Moving on to the next step..."
    }
}

# Ensure script is running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator rights. Please rerun as Administrator."
    exit
}

# Step 0: Download and Install Latest Windows Guest Tools
# Download and install the latest Windows Guest Tools to ensure your VM has the best drivers and tools available.
Write-Host "Downloading and installing Windows Guest Tools..."
$guestToolsUrl = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win-guest-tools.exe"
$guestToolsPath = "$env:TEMP\virtio-win-guest-tools.exe"

Safe-Execute -Command "Invoke-WebRequest -Uri $guestToolsUrl -OutFile $guestToolsPath" -ErrorMessage "Failed to download Windows Guest Tools."
Safe-Execute -Command "Start-Process -FilePath $guestToolsPath -ArgumentList '/quiet' -Wait" -ErrorMessage "Failed to install Windows Guest Tools."

# Step 1: Disable Hibernation and Remove hiberfil.sys
# Completely disable hibernation to free up disk space and avoid potential issues.
Write-Host "Disabling hibernation and removing hiberfil.sys..."
Safe-Execute -Command "powercfg /hibernate off" -ErrorMessage "Failed to disable hibernation."

# Step 2: Disable Fast Startup
# Fast Startup is disabled to ensure clean shutdowns and startups, which is critical for VMs to avoid hardware initialization issues.
Write-Host "Disabling Fast Startup..."
$fastStartupRegPath = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
Safe-Execute -Command "reg add `"$fastStartupRegPath`" /v HiberbootEnabled /t REG_DWORD /d 0 /f" -ErrorMessage "Failed to disable Fast Startup."

# Step 3: Disable Windows Indexing Service with Error Handling
# The Windows Indexing service is disabled to reduce unnecessary disk activity inside the VM.
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
    Write-Error "Failed to disable Windows Indexing service."
}

# Step 4: Disable Automatic Disk Defragmenting
# Disabling the automatic disk defragmenting task as it’s unnecessary in most modern VM environments.
Write-Host "Disabling automatic disk defragmenting..."
$defragTaskName = "\Microsoft\Windows\Defrag\ScheduledDefrag"
Safe-Execute -Command "schtasks /Change /TN $defragTaskName /DISABLE" -ErrorMessage "Failed to disable automatic disk defragmenting."

# Step 5: Enable High Performance Power Mode
# The VM is set to use the High Performance power plan for better performance.
Write-Host "Enabling High Performance power mode..."
try {
    $powerSchemes = powercfg /list
    $highPerformanceSchemeGuid = ($powerSchemes | Select-String -Pattern "High performance").ToString().Split(' ')[3].Trim()
    Write-Host "High Performance power mode activated."
    Safe-Execute -Command "powercfg /setactive $highPerformanceSchemeGuid" -ErrorMessage "Failed to enable High Performance power mode."
} catch {
    Write-Error "Failed to enable High Performance power mode."
}

# Final Note and Restart Prompt
# The script has finished optimizing the VM. The user is prompted to restart the computer for changes to take effect.
Write-Host "`nVM optimization complete."
Write-Host "For more details, visit the unRAID Wiki: https://docs.unraid.net/unraid-os/manual/vm/vm-support/"

$restart = Read-Host "Restart required. Do you want to restart now? (Y/N)"
if ($restart -match "^[Yy]") {
    Write-Host "Restarting now..."
    Restart-Computer
} else {
    Write-Host "Remember to restart later to apply changes."
}
