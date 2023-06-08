<#
.SYNOPSIS

Downloads a copy of Microsoft file msert.exe

.DESCRIPTION

Downloads the latest copy of Microsoft file msert.exe. The
msert.exe process is also known as Microsoft Support
Emergency Response Tool (MSERT) and is a part of Microsoft
Anti-Malware Signature Package. This software is produced
by Microsoft (www.microsoft.com). This is also known as
'Microsoft Safety Scanner' and is a scan tool designed to
find and remove malware from Windows computers.

Microsoft Safety scanner is a portable executable and does
not appear in the Windows Start menu or as an icon on the
desktop. Remember where you saved this download when you
want to use it.

Uses the .NET System.Net.WebClient Class to download the
file as an asynchronous operation.

For more detailed information on what files were removed
(if any), and detailed detection results, you can consult
the log file $Env:SYSTEMROOT\debug\msert.log.

.EXAMPLE

./Get-MsertExe.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

None, no .NET Framework types of objects are output from this script.

.NOTES

File Name    : Get-MsertExe.ps1
Author       : Ian Molloy
Last updated : 2023-06-08T19:11:16
Keywords     : msert scan malware

$Event
System.Management.Automation.PSEventArgs Class

Contains a PSEventArgs object that represents the event
that is being processed. This variable is populated only
within the Action block of an event registration command,
such as Register-ObjectEvent. The value of this variable
is the same object that the Get-Event cmdlet returns.
Therefore, you can use the properties of the Event variable,
such as $Event.TimeGenerated, in an Action script block.


$EventArgs
System.Management.Automation.PSEventArgs Class

Contains an object that represents the first event argument
that derives from EventArgs of the event that is being
processed. This variable is populated only within the Action
block of an event registration command. The value of this
variable can also be found in the SourceEventArgs property of
the PSEventArgs object that Get-Event returns.


$EventSubscriber
System.Management.Automation.PSEventSubscriber Class

Contains a PSEventSubscriber object that represents the event
subscriber of the event that is being processed. This variable
is populated only within the Action block of an event
registration command. The value of this variable is the same
object that the Get-EventSubscriber cmdlet returns.


$Sender
System.Management.Automation.PSEventArgs.Sender Property

Contains the object that generated this event. This variable
is populated only within the Action block of an event
registration command. The value of this variable can also
be found in the Sender property of the PSEventArgs object
that Get-Event returns.


System.Management.Automation.Job Class
Represents a command running in background. A job object can internally contain many child job objects.


System.Management.Automation.JobState Enum
Enumeration for background job status values. Indicates the status of the result object.

.LINK

Microsoft Safety Scanner
https://docs.microsoft.com/en-us/windows/security/threat-protection/intelligence/safety-scanner-download

Disable MSRT from sending Telemetry Report to Microsoft
https://www.winhelponline.com/blog/scan-using-malicious-software-removal-tool-msrt-mss/

Remove specific prevalent malware with Windows Malicious Software Removal Tool
https://support.microsoft.com/en-us/help/890830/remove-specific-prevalent-malware-with-windows-malicious-software-remo

Downloading Windows Malicious Software Removal Tool 64-bit
https://www.microsoft.com/en-us/download/confirmation.aspx?id=9905

https://www.windowscentral.com/how-clean-windows-10-setup-using-malicious-software-removal-tool
How to clean Windows 10 setup using the Malicious Software Removal Tool

Is this how you handle these events?
Handling and raising events
https://docs.microsoft.com/en-us/dotnet/standard/events/?view=netcore-3.1

WebClient.DownloadFileCompleted Event
Occurs when an asynchronous file download operation completes.
https://docs.microsoft.com/en-us/dotnet/api/system.net.webclient.downloadfilecompleted?view=net-5.0

Gavsto-Public-Scripts/Find-MicrosoftSecurityScannerViolations.ps1
https://github.com/gavsto/Gavsto-Public-Scripts/blob/master/Find-MicrosoftSecurityScannerViolations.ps1

Handle and raising events
https://docs.microsoft.com/en-us/dotnet/standard/events/?view=netcore-3.1

There's two .NET class you can use in PowerShell to download files;
System.Net.WebClient Class
System.Net.Http.HttpClient Class

Download a File with an Alternative PowerShell wget Command
A nice blog tutorial showing  how to download files, among other
ways, with System.Net.WebClient Class and
System.Net.Http.HttpClient Class.
https://adamtheautomator.com/powershell-download-file/

Enumerating key-value pairs "$($Event.MessageData)"
Try this out sometime to see if I can list the contents
of $($Event.MessageData),
foreach ($kvp in $var.GetEnumerator()) {
    $key = $kvp.Key
    $val = $kvp.Value
}
$myhashtable.GetEnumerator();
https://stackoverflow.com/questions/37635820/how-can-i-enumerate-a-hashtable-as-key-value-pairs-filter-a-hashtable-by-a-col/37635938

#>

[CmdletBinding()]
Param()

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** Function Get-MsertFile *****
function Get-MsertFile {
[CmdletBinding()]
  #[OutputType([System.Collections.Hashtable])]
  Param (
      [parameter(Mandatory=$true,
                 Position=0)]
      [ValidateNotNullOrEmpty()]
      [System.String]
      $InputFile,

      [parameter(Mandatory=$true,
                 Position=1)]
      [ValidateNotNullOrEmpty()]
      [System.String]
      $OutputFile
  ) #end param

  $uri = New-Object -TypeName 'System.Uri' -ArgumentList $InputFile;
  $wc = New-Object -TypeName 'System.Net.WebClient';
  Set-Variable -Name 'uri', 'wc' -Option ReadOnly;

  $sourceIdent = 'msertdownload';
  $msertLogfile = 'C:\Windows\Debug\msert.log';
  Set-Variable -Name 'sourceIdent', 'msertLogfile' -Option ReadOnly;

  if (Test-Path -Path $OutputFile) {
      Clear-Content -Path $OutputFile;
  }

  if (Test-Path -Path $msertLogfile) {
      Clear-Content -Path $msertLogfile;
  }

  $ActionBlock = {
    # ScriptBlock which is passed to parameter 'Action' of
    # cmdlet Register-ObjectEvent.
    #
    Write-Host ('(action block) message data is:');
    [String]$OutputFile = $Event.MessageData.OutFile;
    [String]$JobName = $Event.MessageData.JobName;
    [String]$LogFile = $Event.MessageData.LogFile;
    Write-Host "Output file: $($Event.MessageData.OutFile)";
    Write-Host "Job name: $($Event.MessageData.JobName)";
    Write-Host "Msert log file: $($Event.MessageData.LogFile)";
    Write-Host "";

    $timestamp = ('time is {0}' -f (Get-Date -Format 's'));
    $downloaddir = Split-Path -Path $OutputFile -Parent;
    Write-Host "File download should be complete`nin directory $downloaddir - $timestamp";
    Get-ChildItem -File -Path $OutputFile, $LogFile;

    Write-Host "Cleaning up unwanted jobs and events";
    $EventSubscriber | Unregister-Event -Force;
    #Remove-Job -Name $Event.MessageData.JobName;
    Remove-Job -Name $JobName;
    Write-Host "Cleanup done";

  } #end of scriptblock $ActionBlock

  # Ensure we don't have this SourceIdentifier left over
  # from any previous sessions. Otherwise we get a
  # "Cannot subscribe to the specified event" exception.
  #
  # Get-EventSubscriber
  # Unregister-Event -SourceIdentifier 'msertfile' -Force;
  #Unregister-Event -SourceIdentifier $sourceIdent -ErrorAction SilentlyContinue;

  $MsgData = [PSObject]@{
      OutFile  = $OutputFile
      JobName  = $sourceIdent
      LogFile  = $msertLogfile;
  }
  Set-Variable -Name 'MsgData' -Option ReadOnly;

  $splat = @{
    #splat data for Register-ObjectEvent cmdlet
    InputObject = $wc
    EventName = 'DownloadFileCompleted'
    SourceIdentifier = $sourceIdent # user friendly name to use
    Action = $ActionBlock
    MessageData = $MsgData
  }
  $reg = Register-ObjectEvent @splat;
  #$reg | Format-List -Property *;

  try {
    $wc.DownloadFileAsync($uri, $OutputFile);
  } catch {
    $_.Exception.Message;
  } finally {
    $wc.Dispose();
  }

} #end of function
#endregion ***** End of function Get-MsertFile *****

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
   Write-Output 'Get Microsoft Safety Scanner scan tool msert.exe';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
# URL of the resource to download (source file).
$Filename = 'msert.exe';
$inputFile = "http://definitionupdates.microsoft.com/download/definitionupdates/safetyscanner/amd64/$Filename";

# The name of the file to be placed on the local computer.
# i.e., the destination of the file which is downloaded.
$outputFile = Join-Path -Path $Env:Temp -ChildPath $Filename;

$msg = @"
Background job submitted to download the required file.

The file will be downloaded asynchronously and an event
will notify you when the download is complete.

Please be patient ...
"@
Set-Variable -Name 'inputFile', 'outputFile', 'msg' -Option ReadOnly;

Get-MsertFile -InputFile $inputFile -OutputFile $outputFile;
Write-Output $msg;

##=============================================
## END OF SCRIPT: Get-MsertExe.ps1
##=============================================
