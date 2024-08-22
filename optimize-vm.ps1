# Step 1: Enable Hibernation in Windows
Write-Host "Enabling Hibernation..."
powercfg /hibernate on

# Step 2: Enable Hibernate option in Power Options
Write-Host "Configuring Power Options for Hibernation..."
$powerOptionsCmd = @"
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
"@
Invoke-Expression $powerOptionsCmd

# Step 3: Disable Fast Startup
Write-Host "Disabling Fast Startup..."
$fastStartupCmd = "powercfg -h off"
Invoke-Expression $fastStartupCmd

# Step 4: Disable Hibernation (if necessary)
Write-Host "Disabling Hibernation entirely to remove hiberfil.sys..."
$disableHibernationCmd = "powercfg -h off"
Invoke-Expression $disableHibernationCmd

# Step 5: Disable Windows Indexing
Write-Host "Disabling Windows Indexing..."
$windowsSearchService = Get-Service "WSearch"
if ($windowsSearchService.Status -eq "Running") {
    Stop-Service "WSearch"
}
Set-Service "WSearch" -StartupType Disabled

# Step 6: Disable Automatic Disk Defragmenting
Write-Host "Disabling Automatic Disk Defragmenting..."
$defragCmd = @"
schtasks /Change /TN `"\Microsoft\Windows\Defrag\ScheduledDefrag`" /DISABLE
"@
Invoke-Expression $defragCmd

# Step 7: Enable High Performance Power Mode
Write-Host "Enabling High Performance Power Mode..."
$highPerformanceScheme = powercfg /list | Select-String -Pattern "High performance"
if ($highPerformanceScheme) {
    $schemeGuid = $highPerformanceScheme -replace "^.*\s\{(.*)\}.*$", '$1'
    powercfg /setactive $schemeGuid
    Write-Host "High Performance Power Mode activated."
} else {
    Write-Host "High Performance Power Mode not found."
}

Write-Host "VM Optimization Complete!"
