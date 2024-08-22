
# Windows VM Optimization Script for unRAID

## Quick Start: How to Run the Script

To quickly optimize your Windows VM on unRAID, run the following command in PowerShell with Administrator privileges:

```powershell
irm https://raw.githubusercontent.com/KenGrinder/OptimizeVMunRAID/main/optimize-vm.ps1 | iex
```

This command will download and execute the script directly in PowerShell.

## Disclaimer

**Please Note:** This script is provided as-is, and running it is at your own risk. It is strongly recommended that you back up your VM and any important data before proceeding. The script makes significant changes to system settings that could impact your VM's performance or behavior.

## Overview

This script is designed to optimize a Windows Virtual Machine (VM) running on unRAID. The script automates several steps to improve performance, streamline power management, and ensure that the VM runs efficiently.

## What the Script Does

The script performs the following tasks:

1. **Download and Install Windows Guest Tools**: 
   - Downloads and installs the latest Windows guest tools from the Fedora project. This ensures that the VM has the latest drivers and tools necessary for optimal performance.

2. **Disable Hibernation and Remove hiberfil.sys**: 
   - Hibernation is completely disabled, and the `hiberfil.sys` file is removed to free up disk space and avoid potential issues.

3. **Disable Fast Startup**: 
   - Disables the Fast Startup feature to ensure clean shutdowns and startups, which is critical for VMs to avoid hardware initialization issues.

4. **Disable Windows Indexing Service**: 
   - The Windows Indexing service is disabled to reduce unnecessary disk activity, which can improve overall VM performance.

5. **Disable Automatic Disk Defragmenting**: 
   - Disables the automatic disk defragmentation task, which is unnecessary in modern VM environments and can cause unnecessary wear on virtual disks.

6. **Enable High Performance Power Mode**: 
   - The VM is set to use the High Performance power plan to ensure maximum performance.

7. **Restart Prompt**: 
   - After completing all optimizations, the script prompts the user to restart the VM to apply all changes.

## Additional Information and Resources

For more details on optimizing Windows VMs in unRAID, visit the unRAID Wiki:

- [unRAID VM Support](https://docs.unraid.net/unraid-os/manual/vm/vm-support/)

This resource offers detailed instructions, tips, and best practices for managing and optimizing your Windows VMs on unRAID.

## Compatibility

The script is compatible with the following Windows versions running as VMs on unRAID:

- Windows 7, 8.1, 10, 11
- Windows Server 2008 R2, 2012 R2, 2016, 2019, 2022

Please note that specific optimizations may vary depending on the Windows version and your specific VM configuration.

## License

This script is provided under the MIT License. You are free to use, modify, and distribute it as needed.
