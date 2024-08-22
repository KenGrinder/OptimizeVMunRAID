
# Windows VM Optimization Script for unRAID

## Overview

This script is designed to optimize a Windows Virtual Machine (VM) running on unRAID. The script automates several steps to improve performance, streamline power management, and ensure that the VM runs efficiently.

## What the Script Does

The script performs the following tasks:

1. **Download and Install Windows Guest Tools**: 
   - Downloads and installs the latest Windows guest tools from the Fedora project. This ensures that the VM has the latest drivers and tools necessary for optimal performance.

2. **Enable Hibernation**: 
   - Hibernation is enabled to allow the VM to save its state and power down without losing the current session.

3. **Configure Hibernation Settings**: 
   - Adjusts power settings to ensure that the VM doesn't enter hibernation when connected to AC power, preventing unwanted interruptions.

4. **Disable Fast Startup**: 
   - Disables the Fast Startup feature to ensure clean shutdowns and startups, which is critical for VMs to avoid hardware initialization issues.

5. **Disable Hibernation and Remove hiberfil.sys**: 
   - Hibernation is disabled again, and the `hiberfil.sys` file is removed to free up disk space.

6. **Disable Windows Indexing Service**: 
   - The Windows Indexing service is disabled to reduce unnecessary disk activity, which can improve overall VM performance.

7. **Disable Automatic Disk Defragmenting**: 
   - Disables the automatic disk defragmentation task, which is unnecessary in modern VM environments and can cause unnecessary wear on virtual disks.

8. **Enable High Performance Power Mode**: 
   - The VM is set to use the High Performance power plan to ensure maximum performance.

9. **Restart Prompt**: 
   - After completing all optimizations, the script prompts the user to restart the VM to apply all changes.

## How to Run the Script

### Prerequisites

- **Administrator Rights**: The script must be run with Administrator privileges to make the necessary system changes.
- **PowerShell**: Ensure you are running the script in a PowerShell environment.

### Running the Script

To run the script, open PowerShell with Administrator privileges and execute the following command:

```powershell
irm https://raw.githubusercontent.com/KenGrinder/OptimizeVMunRAID/main/optimize-vm.ps1 | iex
```

This command will download and execute the script directly in PowerShell.

### Post-Execution

After the script has completed its tasks, you will be prompted to restart the VM. It is recommended to restart immediately to apply all changes. If you choose not to restart right away, please remember to do so later.

## Additional Information and Resources

For more details on optimizing Windows VMs in unRAID, including troubleshooting, advanced configuration options, and a comprehensive guide on virtual machine support, visit the unRAID Wiki:

- [unRAID VM Support](https://docs.unraid.net/unraid-os/manual/vm/vm-support/)
- [VirtIO Drivers and Windows VM Setup](https://docs.unraid.net/unraid-os/manual/vm/virtio-drivers/)
- [Performance Tuning for Windows VMs](https://docs.unraid.net/unraid-os/manual/vm/performance-tuning/)

These resources offer detailed instructions, tips, and best practices for managing and optimizing your Windows VMs on unRAID.

## Compatibility

The script is compatible with the following Windows versions running as VMs on unRAID:

- Windows 7, 8.1, 10, 11
- Windows Server 2008 R2, 2012 R2, 2016, 2019, 2022

Please note that specific optimizations may vary depending on the Windows version and your specific VM configuration.

## License

This script is provided under the MIT License. You are free to use, modify, and distribute it as needed.
