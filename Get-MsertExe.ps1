<#
Source: https://codealoud.blogspot.com/2011/12/downloading-files-with-powershell.html

Pass variable to Register-ObjectEvent action block.
try(?):
You can use the -MessageData parameter to pass info to
the scriptblock:
$pso = new-object psobject -property @{foo = $foo; bar = $bar}
Register-ObjectEvent ... -MessageData $pso;

After that you should be able to access it inside the Scriptblock
like this:

  $Event.MessageData.foo;


MessageData - Specifies any additional data to be associated
with this event subscription. The value of this parameter
appears in the MessageData property of all events associated
with this subscription.

Microsoft Safety Scanner
https://docs.microsoft.com/en-us/windows/security/threat-protection/intelligence/safety-scanner-download

Disable MSRT from sending Telemetry Report to Microsoft
https://www.winhelponline.com/blog/scan-using-malicious-software-removal-tool-msrt-mss/

Remove specific prevalent malware with Windows Malicious Software Removal Tool
https://support.microsoft.com/en-us/help/890830/remove-specific-prevalent-malware-with-windows-malicious-software-remo

Downloading Windows Malicious Software Removal Tool 64-bit
https://www.microsoft.com/en-us/download/confirmation.aspx?id=9905

Is this how you handle these events?
Handling and raising events
https://docs.microsoft.com/en-us/dotnet/standard/events/?view=netcore-3.1

Handling events:
AsyncCompletedEventHandler Delegate
Represents the method that will handle the MethodNameCompleted event of an asynchronous operation.
https://docs.microsoft.com/en-us/dotnet/api/system.componentmodel.asynccompletedeventhandler?view=netcore-3.1
Is this how I should do it?

Last updated : 2020-05-20T18:04:59
#>

[CmdletBinding()]
Param()

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

  if (Test-Path -Path $outputFile) {
    Clear-Content -Path $OutputFile;
  }

  $uri = New-Object -TypeName 'System.Uri' -ArgumentList $InputFile;
  $wc = New-Object -TypeName 'System.Net.WebClient';
  $sourceIdent = 'msertfile';
  Set-Variable -Name 'sourceIdent', 'uri' -Option ReadOnly;

  $ActionBlock = {
    # ScriptBlock passed to parameter 'Action' of cmdlet
    # Register-ObjectEvent.
    #
    $timestamp = ('time is {0}' -f (Get-Date -Format 's'));
    $downloaddir = Split-Path -Path $Event.MessageData -Parent;

    Write-Host "File download should be complete`nin directory $downloaddir - $timestamp";

    Write-Host "Cleaning up unwanted jobs and events";
    $EventSubscriber | Unregister-Event -Force;
    Write-Host "Cleanup done";

  } #end $ActionBlock

  # Ensure we don't have this SourceIdentifier left over
  # from any previous sessions. Otherwise we get a
  # "Cannot subscribe to the specified event" exception.
  #
  # Get-EventSubscriber
  # Unregister-Event -SourceIdentifier 'msertfile' -Force;
  #Unregister-Event -SourceIdentifier $sourceIdent -ErrorAction SilentlyContinue;

  $splat = @{
    InputObject = $wc
    EventName = 'DownloadFileCompleted'
    SourceIdentifier = $sourceIdent # user friendly name to use
    Action = $ActionBlock
    MessageData = $OutputFile;
  }
  $reg = Register-ObjectEvent @splat;
  #$reg | Format-List -Property *;

  try {
    $wc.DownloadFileAsync($uri, $OutputFile);
  }
  catch {
    $_.Exception.Message;
  }
  finally {
    $wc.Dispose();
  }

} #end of function
#endregion ***** End of function Get-MsertFile *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# URL of the resource to download.
$inputFile = 'http://definitionupdates.microsoft.com/download/definitionupdates/safetyscanner/amd64/msert.exe';

# The name of the file to be placed on the local computer.
# i.e., the destination of the file.
$outputFile = 'C:\Temp\msert.exe';

$msg = @"
Job submitted to download the file.

The file will be downloaded asynchronously and an event
will notify you when the download is complete.

Please be patient
"@

Get-MsertFile -InputFile $inputFile -OutputFile $outputFile;
Write-Output $msg;

##=============================================
## END OF SCRIPT: Get-MsertExe.ps1
##=============================================
