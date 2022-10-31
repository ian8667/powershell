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
Last updated : 2022-01-23T21:52:10
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

20 Unnecessary Background Services to Disable on Windows 10
https://www.freshtechtips.com/2019/04/disable-unnecessary-services-in-windows.html

What Windows 10 Services Can I Disable
https://www.briteccomputers.co.uk/posts/what-windows-10-services-can-i-disable/

See also
What's new in Windows 10? (worth reading?)
https://support.microsoft.com/en-us/windows?ui=en-US&rs=en-US&ad=US

* -----
Next run the commands below (cmd) in an elevated command prompt:
sc delete DiagTrack
sc delete dmwappushservice

o Makre sure this directory is empty
DiagTrack Log
C:\ProgramData\Microsoft\Diagnosis\ETLLogs\Autologger(?)
Concentrate on file 'AutoLogger-DiagTrack-Listener.etl'?

o Services
You can delete or disable the 2 services below:
DiagTrack - (aka. Connected User Experiences and Telemetry) Diagnostics Tracking Service
dmwappushsvc - WAP Push Message Routing Service

o HOSTS
Append known tracking domains to the HOSTS file located
in C:\Windows\System32\drivers\etc

o IP Blocking
Block known tracking IPs with the Windows Firewall. The
rules are named TrackingIPX, replacing X with the IP numbers.

o Windows Defender
Disable the following:
Automatic Sample Submission
Delivery Optimization Download Mode

o WifiSense (not sure what this is)
Disables the following:
Credential Share
Open-ness

o Office 365 telemetry
The English version of the report is available as a PDF document
that you can download.
https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Publikationen/Studien/Office_Telemetrie/Office_Telemetrie.pdf?__blob=publicationFile&v=5

o Microsoft Edge
C:\Users\ianm7\AppData\Local\Microsoft\Edge\User Data
Why do I have recent files in the above directory when I don't use Edge?

o Services
what are these services? Have a look in more detail.
get-Service -Name RetailDemo ==
get-Service -Name wercplsupport
get-Service -Name TapiSrv
get-Service -Name WbioSrvc
get-Service -Name wcncsvc
get-Service -Name winrm ==
get-Service -Name XblAuthManager
get-Service -Name XblGameSave
get-Service -Name XboxNetApiSvc

o Scheduled tasks
Do I need to disable the following tasks?

"Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem",
# Initializes Family Safety monitoring and enforcement.
"Microsoft\Windows\Shell\FamilySafetyMonitor",
# Synchronizes the latest settings with the Microsoft family features service.
"Microsoft\Windows\Shell\FamilySafetyMonitorToastTask",
# Synchronizes the latest settings with the Microsoft family features service.
"Microsoft\Windows\Shell\FamilySafetyRefreshTask",
# Collects program telemetry information if opted-in to the Microsoft Customer Experience Improvement Program.
"Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
"Microsoft\Windows\Application Experience\AitAgent",
# Collects program telemetry information if opted-in to the Microsoft Customer Experience Improvement Program
"Microsoft\Windows\Application Experience\ProgramDataUpdater",
"Microsoft\Windows\Application Experience\Uploader",
# This task collects and uploads autochk SQM data if opted-in to the Microsoft Customer Experience Improvement Program.
"Microsoft\Windows\Autochk\Proxy",
# The Windows Disk Diagnostic reports general disk and system information to Microsoft for users participating in the Customer Experience Program.
"Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
# "Microsoft\Windows\Maintenance\WinSAT",
"Microsoft\Office\OfficeTelemetryAgentFallBack2016",
"Microsoft\Office\OfficeTelemetryAgentLogOn2016",
"Microsoft\Office\Office ClickToRun Service Monitor",
"Microsoft\Office\OfficeTelemetry\AgentFallBack2016",
"Microsoft\Office\OfficeTelemetry\OfficeTelemetryAgentLogOn2016",
"Microsoft\Windows\Media Center\ActivateWindowsSearch",
"Microsoft\Windows\Media Center\ConfigureInternetTimeService",
"Microsoft\Windows\Media Center\DispatchRecoveryTasks",
"Microsoft\Windows\Media Center\ehDRMInit",
"Microsoft\Windows\Media Center\InstallPlayReady",
"Microsoft\Windows\Media Center\mcupdate",
"Microsoft\Windows\Media Center\MediaCenterRecoveryTask",
"Microsoft\Windows\Media Center\ObjectStoreRecoveryTask",
"Microsoft\Windows\Media Center\OCURActivate",
"Microsoft\Windows\Media Center\OCURDiscovery",
"Microsoft\Windows\Media Center\PBDADiscovery",
"Microsoft\Windows\Media Center\PBDADiscoveryW1",
"Microsoft\Windows\Media Center\PBDADiscoveryW2",
"Microsoft\Windows\Media Center\PvrRecoveryTask",
"Microsoft\Windows\Media Center\PvrScheduleTask",
"Microsoft\Windows\Media Center\RegisterSearch",
"Microsoft\Windows\Media Center\ReindexSearchRoot",
"Microsoft\Windows\Media Center\SqlLiteRecoveryTask",
"Microsoft\Windows\Media Center\UpdateRecordPath"

\Microsoft\Windows\Diagnosis

o OneDrive logs - check the number of logs in this directory
C:\Users\ianm7\AppData\Local\Microsoft\OneDrive\setup\logs

o Privacy Dashboard
https://account.microsoft.com/privacy/

o Example of code - shall I do something like this?
Function DisableDiagTrack {
  Write-Output "Stopping and disabling Diagnostics Tracking Service..."
  Stop-Service "DiagTrack" -WarningAction SilentlyContinue
  Set-Service "DiagTrack" -StartupType Disabled
}

o Example program (contains LOTS of enable/disables)
mughuara/windows10_debloat_OneDrive.txt
https://gist.github.com/mughuara/fd71e3b297bc6f20b07327f131f265dc

o Search the Registry Using PowerShell
PowerShell allows you to search registry. The next script searches
the HKCU:\Control Panel\Desktop the parameters, whose names contain
the *dpi* key.

$Path = (Get-ItemProperty 'HKCU:\Control Panel\Desktop');
$Path.PSObject.Properties | ForEach-Object {
   If ($_.Name -like '*dpi*') {
      Write-Host $_.Name ' = ' $_.Value
   }
} #end ForEach-Object
http://woshub.com/how-to-access-and-manage-windows-registry-with-powershell/

* -----
-- Do I need this section in my code?
-- o Deletes most of one's own passwords and other cached
-- secrets from Credential Manager in Control Panel.
-- Does not delete other users' saved credentials.
-- Does not require administrative privileges.
-- Cannot delete all the credentials stored here for
-- some unknown reason, e.g., a cred may be seen in
-- Credential Manager in Control Panel but not be
-- listed by cmdkey.exe (???).

cmdkey.exe /list |
select-string -pattern ':target=(.+)' |
foreach { $_.matches.groups[1].value } |
foreach { cmdkey.exe /delete:$_ }

-- Delete Remote Access Server (RAS) creds:
cmdkey.exe /delete /ras

* -----

#>

#requires -RunAsAdministrator

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------

[Action]$CheckClickToRun = {
<#
ClickToRunSvc - if this service is disabled, we get the
following error when starting MS Word:
  Something went wrong
  We couldn't start, try repairing Office from 'Programs and Features' in the Control Panel.
  Error Code: 0x426-0x0
Enable this service if you need to use MS Word.
#>
    $InformationPreference = 'Continue';
    Write-Information -MessageData '';

    $StartType = (Get-Service -name 'ClickToRunSvc').StartType;
    $Disabled = [System.ServiceProcess.ServiceStartMode]::Disabled;
    $Code = "Set-Service -Name 'ClickToRunSvc' -StartupType Manual;";

    if ($StartType -eq $Disabled) {
        Write-Information -MessageData 'Service <ClickToRunSvc> is disabled';
        Write-Information -MessageData 'If you wish to run MS Word, run the following code in elevated mode first:';
        Write-Information -MessageData $Code;
    }

}

#----------------------------------------------------------
# End of delegates
#----------------------------------------------------------

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
        #cmdlet uses the root folder which may not be what you want.
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
<#
o 'DiagTrack' service has been deleted. Just make sure it
doesn't come back.

o Services to think about disabling
Name: TrkWks
DisplayName: Distributed Link Tracking Client

o Notes
Name: PcaSvc
DisplayName: Program Compatibility Assistant Service
If you love to run legacy or poorly maintained applications
on your Windows 10 PC, you may need this service. This
service checks for compatibility problems while installing
an application.

o Notes
MS Windows Services - registry 'start' values
Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services
Use following values of your choice
0 = Boot. Loaded by kernel loader.
1 = System
2 = Automatic
3 = Manual
4 = Disabled
5 = Delayed start

o Notes
'start' key for the following services has been set to '4' (Disabled).
Computer\HKLM\SYSTEM\CurrentControlSet\Services\OneSyncSvc
Computer\HKLM\SYSTEM\CurrentControlSet\Services\OneSyncSvc_5c6c1

o Notes
See also
System.ServiceProcess.ServiceController Class

o Notes
ClickToRunSvc - if this service is disabled, we get the
following error when starting MS Word:
  Something went wrong
  We couldn't start, try repairing Office from 'Programs and Features' in the Control Panel.
  Error Code: 0x426-0x0
Enable this service if you need to use MS Word.

* -----
Currently working on:
What Windows 10 Services Can I Disable
https://www.briteccomputers.co.uk/posts/what-windows-10-services-can-i-disable/
#>
[CmdletBinding()]
param ()

# dmwappushservice
# sc delete dmwappushservice
    begin {
        #Unwanted services. The values used in the array
        #are the 'service name' for the service concerned.
        #The 'display name' can be seen in the comments.
        Write-Output 'Stopping some unwanted services';
        $services = @(
          #'AdobeARMservice'     # Adobe Acrobat Update Service
          'ClickToRunSvc'       # Microsoft Office Click-to-Run Service
          'WinRM'               # Windows Remote Management (WS-Management)
          'AJRouter'            # AllJoyn Router Service
          'MapsBroker'          # Downloaded Maps Manager
          'Fax'                 # Fax
          'WpcMonSvc'           # Parental Controls
          'PcaSvc'              # Program Compatibility Assistant Service. See note above
          'RemoteRegistry'      # Remote Registry
          'RetailDemo'          # Retail Demo Service
          'seclogon'            # Secondary Log-on
          'lmhosts'             # TCP/IP NetBIOS Helper
          'WerSvc'              # Windows Error Reporting Service
          'wisvc'               # Windows Insider Service
          'XblAuthManager'      # Xbox Live Auth Manager
          'XblGameSave'         # Xbox Live Game Save
          'XboxGipSvc'          # Xbox Accessory Management Service
          'XboxNetApiSvc'       # Xbox Live Networking Service
          #Can't seem to stop this service. It gives an error
          #'TabletInputService'  # Touch Keyboard and Handwriting Panel Service
        )
        Set-Variable -Name 'services' -Option ReadOnly;

    }

    process {
        # Loop to disable unnecessary startup entries
        foreach ($service in $services) {
            Stop-Service -Force -Name $service;
            Set-Service -Name $service -StartupType Disabled;

        }

    }

    end {
        $CheckClickToRun.Invoke();
    }
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
