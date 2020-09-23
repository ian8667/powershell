<#
.SYNOPSIS

Disable unwanted MS Windows services and scheduled tasks

.DESCRIPTION

Disable unwanted MS Windows services and scheduled tasks that
I don't want running or scheduled.

This program came about as I realised there were scheduled
tasks and MS Windows services that I don't want running and
I was disabling them by hand. So this program saves me the
job.

.EXAMPLE

./DisableTelemetry.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : DisableTelemetry.ps1
Author       : Ian Molloy
Last updated : 2020-08-19T21:58:16
Keywords     : scheduled task service windows disable admin

To run a specific script from an elevated (admin) window.
PS> $myArgs = @('-NoProfile','-File','C:\Family\powershell\DisableTelemetry.ps1');
PS> Start-Process -FilePath 'pwsh.exe' -ArgumentList $myArgs -Verb RunAs;

To create and run an elevated (admin) session.
PS> Start-Process -FilePath 'pwsh.exe' -Verb RunAs;

To run a single PowerShell command in an elevated (admin) window.
In this example we're going to run the 'Remove-Item' cmdlet.
PS> $argList = "-Command Remove-Item -Path 'C:\\IanmTools\\GitRepos\\powershell' -Recurse -Force";
PS> Start-Process -FilePath 'pwsh' -ArgumentList $argList -Verb RunAs

.LINK

About Requires
#Requires -RunAsAdministrator
When this switch parameter is added to your #Requires statement,
it specifies that the PowerShell session in which you're running
the script must be started with elevated user rights.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_requires?view=powershell-7

About Comment Based Help
Describes how to write comment-based help topics for functions
and scripts.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7

Start-Process
Starts one or more processes on the local computer.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7

How To Disable Telemetry and Data Collection in Windows 10 and Regain Your Privacy
https://www.tecklyfe.com/how-to-disable-telemetry-and-data-collection-in-windows-10-regain-your-privacy/

#>

#requires -RunAsAdministrator

[CmdletBinding()]
Param() #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

[Byte]$Counter = 0;
#List of scheduled tasks we want to disable
#TypeName: System.Collections.Hashtable
$tasklist = @{
  'CCleanerSkipUAC' = '\'
  'Proxy' = '\Microsoft\Windows\Autochk\'
  'Microsoft Compatibility Appraiser' = '\Microsoft\Windows\Application Experience\'
  'ProgramDataUpdater' = '\Microsoft\Windows\Application Experience\'
  'StartupAppTask' = '\Microsoft\Windows\Application Experience\'
  'Consolidator' = '\Microsoft\Windows\Customer Experience Improvement Program\'
  'UsbCeip' = '\Microsoft\Windows\Customer Experience Improvement Program\'
  'OfficeTelemetryAgentLogOn2016' = '\Microsoft\Office\'
  'OfficeTelemetryAgentFallBack2016' = '\Microsoft\Office\'
  'Adobe Acrobat Update Task' = '\'
  'Avast Emergency Update' = '\'
  'CCleaner Update' = '\'
  'GoogleUpdateTaskMachineCore' = '\'
  'GoogleUpdateTaskMachineUA' = '\'
  'OneDrive Standalone Update Task-S-1-5-21-619814707-1675325165-3821842880-1001' = '\'
  'Overseer' = '\Avast Software\'
  'MicrosoftEdgeUpdateTaskMachineCore' = '\'
  'MicrosoftEdgeUpdateTaskMachineUA' = '\'
  'PcaPatchDbTask' = '\Microsoft\Windows\Application Experience'
}
Set-Variable -Name 'tasklist' -Option ReadOnly;
[System.Linq.Enumerable]::Repeat("", 2); #blanklines

# Loop to disable scheduled tasks
# Within this loop:
#   kvp.Name - the scheduled task name.
#   kvp.Value - the scheduled task path.
foreach ($kvp in $tasklist.GetEnumerator()) {
    $key = $kvp.Name;    #TaskName
    $value = $kvp.Value; #TaskPath
    $Counter++;

    Write-Output ('Task number#({0})' -f $Counter);
    Write-Verbose -Message "Disabling task $($key)";
    Disable-ScheduledTask -TaskName $key -TaskPath $value |
        Format-List TaskName, State;
}

#Unwanted services
Write-Output 'Stopping some unwanted services';
$services = @(
  'AdobeARMservice' # Adobe Acrobat Update Service
  'DiagTrack'       # Connected User Experiences and Telemetry
  'ClickToRunSvc'   # Microsoft Office Click-to-Run Service
  'WinRM'           # Windows Remote Management (WS-Management)
 
)

foreach ($service in $services) {
  Stop-Service -Force -Name $service;
}

Write-Output 'All done now';
##=============================================
## END OF SCRIPT: DisableTelemetry.ps1
##=============================================
