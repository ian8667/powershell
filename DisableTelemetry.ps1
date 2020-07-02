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
Last updated : 2020-07-02T13:29:26
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
    Write-Verbose "Disabling task $($key)";
    Disable-ScheduledTask -TaskName $key -TaskPath $value |
        Format-List TaskName, State;
}
Stop-Service -Force -DisplayName 'Adobe Acrobat Update Service';

Write-Output 'All done now';
##=============================================
## END OF SCRIPT: DisableTelemetry.ps1
##=============================================
