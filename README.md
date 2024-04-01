# Disable-PowerShellv2
Disabling PowerShell v2 with Group Policy

This repo is an update to the original author's repo. The script has been updated to run on Windows Server 2022.
The original script's Author is Rob Willis. See sources below.

This script will disable the PowerShell v2 Engine on Windows 10/Server 2012/16/19/22, if any other version is detected no changes are made.

Disable-WindowsOptionalFeature does not work correctly when used as a startup script, so instead dism.exe is called directly in this
script.

Script flow:
- Check the current OS version.
    - If Windows 10/Server 12/16/19, PowerShell v2 will be disabled.
        - If PowerShell v2 is already disabled, no changes will be made.
    - Any other OS, no changes will be made.

Script log data saved to: C:\Windows\Logs\Disable-PSv2-Log.txt

This script is designed to be deployed as a Group Policy Startup Script.

## Group Policy Instructions:
Policy: Computer Configuration > Policies > Windows Settings > Scripts (Startup/Shutdown)\
Script Name: Disable-PSv2.ps1\
Parameters: -ExecutionPolicy Bypass -NonInteractive -NoProfile


### Example usage from PowerShell:
C:\PS> powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -WindowsStyle Hidden .\Disable-PSv2.ps1

### Sources:
https://devblogs.microsoft.com/powershell/windows-powershell-2-0-deprecation/
https://www.robwillis.info/2020/01/disabling-powershell-v2-with-group-policy/
https://github.com/robwillisinfo/Disable-PSv2