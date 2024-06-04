<#
.SYNOPSIS

Shows whether any newer module versions are available

.DESCRIPTION

Looks at currently installed module version numbers and whether
there are any newer versions are available for updating. The
program will indicate which modules need updating

.EXAMPLE

./Get-ModuleInfo.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Get-ModuleInfo.ps1
Author       : Ian Molloy
Last updated : 2024-04-17T00:38:23
Keywords     : module version numbers

.LINK

Keeping Your Modules Up-To-Date
https://stackoverflow.com/questions/58040991/


Yes, it is possible to determine if a Windows computer has any outstanding or failed updates using Microsoft PowerShell. Here is a concise answer:

You can use the `Get-WindowsUpdate` cmdlet from the `PSWindowsUpdate` module to retrieve a list of all available updates, including those that have not yet been installed. To get the list of updates that are not yet installed, you can use the `-IsInstalled $false` parameter:

```powershell
Get-WindowsUpdate -IsInstalled $false
```

This will return a list of all updates that are available but have not been installed on the system. You can further filter the results to only show important or security updates by adding the `-Mandatory $true` parameter:

```powershell
Get-WindowsUpdate -IsInstalled $false -Mandatory $true
```

To check for any failed updates, you can use the `Get-WindowsUpdateLog` cmdlet, which will show you the history of Windows Update activity, including any failed updates:

```powershell
Get-WindowsUpdateLog
```

This will provide a detailed log of all Windows Update activity, including any errors or failures that have occurred.

By using these PowerShell cmdlets, you can easily determine if a Windows computer has any outstanding or failed updates, and take the necessary actions to address them. [1][2][3][4]

Citations:
[1] https://www.reddit.com/r/PowerShell/comments/fu8zu6/get_list_of_windows_updates_that_have_yet_to_be/
[2] https://www.action1.com/check-missing-windows-updates-script/
[3] https://gist.github.com/Grimthorr/44727ea8cf5d3df11cf7
[4] https://superuser.com/questions/1107692/list-pending-windows-updates-from-command-line
[5] https://community.spiceworks.com/t/server-2016-v1607-stopped-getting-windows-updates-from-wsus/746679

Perplexity. ( 17 April 2024 ). Information from a conversation with Perplexity. perplexity.ai. https://www.perplexity.ai/
#>

[CmdletBinding()]
Param () #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

    Write-Output '';
    Write-Output 'Checking module version numbers';
    $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
    Write-Output ('Today is {0}' -f $dateMask);

    $script = $MyInvocation.MyCommand.Name;
    $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
    Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

  }

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'Current and available module versions';
Get-InstalledModule | & {
    begin {
        #$module - this data comes from cmdlet Find-Module
        #$_ - this data comes from cmdlet Get-InstalledModule

        class MyData
        {
            # Optionally, add attributes to prevent invalid values
            [ValidateNotNullOrEmpty()][String]$Name; #module name
            [ValidateNotNullOrEmpty()][boolean]$NeedsUpdating; #whether the module needs updating
            [ValidateNotNullOrEmpty()][String]$CurrVersion; #existing (current) version
            [ValidateNotNullOrEmpty()][String]$VersionAvailable; #newer version (if available)
        }
        $moduleInfo = [MyData]::new();
    }
    process {
        try {
            $fmodule = Find-Module -Name $_.Name -ErrorAction Stop;

            $moduleInfo.Name = $_.Name;
            $moduleInfo.NeedsUpdating = ($_.Version -lt $fmodule.Version);
            $moduleInfo.CurrVersion = $_.Version; #current version
            $moduleInfo.VersionAvailable = $fmodule.Version; #newer version
        }
        catch {

            $moduleInfo.VersionAvailable = 'No longer available';
            $moduleInfo.NeedsUpdating = $true;
        }

        Write-Output $moduleInfo;
    }
    end {}
} | #end all blocks
Format-Table -Property Name, NeedsUpdating, CurrVersion, VersionAvailable -AutoSize;

Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Get-ModuleInfo.ps1
##=============================================
