<#
If you must ensure that your entire code block is executed in
one, embed it into curly brackets and execute this script
block with the '&' operator.
& {
"Starting!"
$a = Read-Host -Prompt 'Enter something'
"Entered: $a"
"Completed"
}

https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/keeping-your-modules-up-to-date

https://blogs.oracle.com/connect/post/nasa-deep-space-network?source=:em:nw:mt::::RC_WWMK200429P00044C0109:NSL400244549&elq_mid=228207&sh=182613141215151202312825271316&cmid=WWMK200429P00044C0109

"terminal.integrated.shellIntegration.enabled": true

TypeName: Microsoft.PowerShell.Commands.PSRepositoryItemInfo

; -----
$lat = 53.626428;
$long = -2.346529;
$Daylight = (Invoke-RestMethod "https://api.sunrise-sunset.org/json?lat=53.626428&lng=-2.346529&formatted=0").results;
$Sunrise  = ($Daylight.Sunrise | Get-Date -Format "HH:mm");
$Sunset   = ($Daylight.Sunset | Get-Date -Format "HH:mm");

Met office
sunrise: 0605
sunset: 2016

https://www.google.co.uk/maps/@
53.4901394
-2.23842

Get-Date -Format yyyy/MM/dd
HH-mm-ss
25/08/2022 06:04:20

Get-Date -Format 'dd/MM/yyyy HH:mm:ss'
$datemask = 'dd/MM/yyyy HH:mm:ss';
$d1 = [DateTime]::ParseExact("25/08/2022 06:04:20", $datemask, $null);
$d2 = [DateTime]::ParseExact('25/08/2022 20:17:45', $datemask, $null);

;----------------------------------------------------------
File Name    : test001.ps1
Author       : Ian Molloy
Last updated : 2022-10-29T00:14:53

#>

<#
New work:
o add advanced comments to the header of the file
o finish off and upload to github
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
