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
Last updated : 2020-12-22T18:14:35
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

Windows 10: Powershell Script to protect your privacy
https://michlstechblog.info/blog/windows-10-powershell-script-to-protect-your-privacy/

#>

#requires -RunAsAdministrator

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Disable-ScheduledTasks *****
function Disable-ScheduledTasks {
[CmdletBinding()]
param ()

    begin {
        [Byte]$Counter = 0;
        #List of scheduled tasks we want to disable
        #TypeName: System.Collections.Hashtable
        #
        #TaskPath - To specify a full TaskPath you need to include the
        #leading and trailing \. If you do not specify a path, the
        #cmdlet uses the root folder.
        #
        #Think about disabling tasks in \Microsoft\Office ?
        #
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
          'CCleaner Update' = '\'
          'GoogleUpdateTaskMachineCore' = '\'
          'GoogleUpdateTaskMachineUA' = '\'
          'OneDrive Standalone Update Task-S-1-5-21-619814707-1675325165-3821842880-1001' = '\'
          'MicrosoftEdgeUpdateTaskMachineCore' = '\'
          'MicrosoftEdgeUpdateTaskMachineUA' = '\'
          'PcaPatchDbTask' = '\Microsoft\Windows\Application Experience\'
          'Office ClickToRun Service Monitor' = '\Microsoft\Office\'
        } #end of Hashtable
        Set-Variable -Name 'tasklist' -Option ReadOnly;

    }

    process {
        # Loop to disable scheduled tasks
        # Within this loop:
        #   kvp.Name - the scheduled task name.
        #   kvp.Value - the scheduled task path.
        Write-Output 'Disabling unwanted scheduled tasks';
        foreach ($kvp in $tasklist.GetEnumerator()) {
            $key = $kvp.Name;    #TaskName
            $value = $kvp.Value; #TaskPath
            $Counter++;

            Write-Verbose -Message ('Scheduled task number#({0})' -f $Counter);
            #Ensure the scheduled task exists even though it may exist
            #in our Hashtable variable. It could be we've forgotten to
            #remove it from the Hashtable although we've removed the
            #scheduled task from within the operating system
            $fred = Get-ScheduledTask -TaskName $key -TaskPath $value -ErrorAction SilentlyContinue;
            if ([String]::IsNullOrWhiteSpace($fred)) {
              #Scheduled task not found
              Write-Warning -Message ('Scheduled task {0} not found to disable' -f $key);
            } else {
              #Write-Output 'disabling a task';
              Write-Verbose -Message "Disabling scheduledtask $($key)";
              Disable-ScheduledTask -TaskName $key -TaskPath $value | Out-Null;
            }

        } #end foreach loop

    }

    end {}
}
#endregion ***** end of function Disable-ScheduledTasks *****

#----------------------------------------------------------

#region ***** function Disable-Services *****
function Disable-Services {
[CmdletBinding()]
param ()

    begin {
        #Unwanted services
        Write-Output 'Stopping some unwanted services';
        $services = @(
          'AdobeARMservice' # Adobe Acrobat Update Service
          'DiagTrack'       # Connected User Experiences and Telemetry
          'ClickToRunSvc'   # Microsoft Office Click-to-Run Service
          'WinRM'           # Windows Remote Management (WS-Management)
        )
        Set-Variable -Name 'services' -Option ReadOnly;

    }

    process {
        # Loop to disable scheduled tasks
        foreach ($service in $services) {
            Stop-Service -Force -Name $service;
          }

    }

    end {}
}
#endregion ***** end of function Disable-Services *****

#----------------------------------------------------------

#region ***** function Disable-PSRemoteing *****
function Disable-PSRemoteing {
[CmdletBinding()]
param ()
#C:\Family\powershell\Disable-PSRemoting.txt
code to put in from the above text file
    begin {
        #Unwanted services
        Write-Output 'Stopping some unwanted services';
        $services = @(
          'AdobeARMservice' # Adobe Acrobat Update Service
          'DiagTrack'       # Connected User Experiences and Telemetry
          'ClickToRunSvc'   # Microsoft Office Click-to-Run Service
          'WinRM'           # Windows Remote Management (WS-Management)
        )
        Set-Variable -Name 'services' -Option ReadOnly;

    }

    process {
        # Loop to disable scheduled tasks
        foreach ($service in $services) {
            Stop-Service -Force -Name $service;
          }

    }

    end {}
}
#endregion ***** end of function Disable-PSRemoteing *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

  Write-Output '';
  Write-Output 'Disable telemetry and unwanted things';
  $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
  Write-Output ('Today is {0}' -f $dateMask);

  $script = $MyInvocation.MyCommand.Name;
  $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
  Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
  Write-Output '';

}

Disable-ScheduledTasks;

Disable-Services;

#Not yet developed/completed
#Disable-PSRemoteing;

Write-Output '';
Write-Output 'All done now';
Write-Output '';

##=============================================
## END OF SCRIPT: DisableTelemetry.ps1
##=============================================
