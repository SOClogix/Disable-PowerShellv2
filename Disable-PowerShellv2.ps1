<# 
.SYNOPSIS

This script will disable the PowerShell v2 Engine on Windows 10/Server 2012/16/19/22, if any other version is detected no changes are made.

.DESCRIPTION

This script will disable the PowerShell v2 Engine on Windows 10/11 and Server 12/16/19/22, if any other version is detected no changes are made.

Disable-WindowsOptionalFeature does not work correctly when used as a startup script, so instead dism.exe is called directly in this
script.

Script flow:
- Check the current OS version.
    - If Windows 10/11 or Server 12/16/19/22, PowerShell v2 will be disabled.
        - If PowerShell v2 is already disabled, no changes will be made.
    - Any other OS, no changes will be made.

Script log data saved to: C:\Windows\Logs\Disable-PowerShellv2-Log.txt

This script is designed to be deployed as a Group Policy Startup Script.
Policy: Computer Configuration > Policies > Windows Settings > Scripts (Startup/Shutdown)
Script Name: Disable-PSv2.ps1
Parameters: -ExecutionPolicy Bypass -NonInteractive -NoProfile

Original Author - Rob Willis
Blog post - http://robwillis.info/2020/01/disabling-powershell-v2-with-group-policy/

Author - William Johnson
Company - SOClogix, Inc.
Source - https://github.com/SOClogix/Disable-PowerShellv2

.EXAMPLE

C:\PS> powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -WindowsStyle Hidden .\Disable-PSv2.ps1

#>

# Start logging
$DefaultLogLocation = "C:\Windows\Logs\Disable-PowerShellv2-Log.txt"
Start-Transcript -Path $DefaultLogLocation

# Get the current OS version
$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
# Disable PowerShell v2 based off the OS version
switch -regex ($OSVersion) {  
    "(?i)10|2012|2016|2019|2022" {
        Write-Host "Windows 10/11 or Server 12/16/19/22 detected."
        Write-Host "Checking to see if PowerShell v2 is currently enabled..."
        $PSv2PreCheck = dism.exe /Online /Get-Featureinfo /FeatureName:"MicrosoftWindowsPowerShellv2" | findstr "State"
        If ( $PSv2PreCheck -like "State : Enabled" ) {
            Write-Host "PowerShell v2 appears to be enabled, disabling via dism..." 
            dism.exe /Online /Disable-Feature /FeatureName:"MicrosoftWindowsPowerShellv2" /NoRestart
            $PSv2PostCheck = dism.exe /Online /Get-Featureinfo /FeatureName:"MicrosoftWindowsPowerShellv2" | findstr "State"
            If ( $PSv2PostCheck -like "State : Enabled" ) {
                Write-Host "PowerShell v2 still seems to be enabled, check the log for errors: $DefaultLogLocation"
            } Else {
                Write-Host "PowerShell v2 disabled successfully."
            }
        } Else {
            Write-Host "PowerShell v2 is already disabled, no changes will be made."
        }
    }   
    "(?i)7|Vista|2008" {
        Write-Host "Detected Windows 7/Vista/Server 2008, no changes will be made."
    }
    default {"Unable to match the OS, no changes will be made."}
}

#Stop logging
Stop-Transcript