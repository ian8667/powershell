<#

.SYNOPSIS

Blocks a file via a 'Zone.Identifier' Alternate Data Stream

.DESCRIPTION

'Blocks' files by setting a 'Zone.Identifier' Alternate Data Stream,
(ADS) with a value of "3" which indicates as if it was downloaded
from the Internet. This means the Windows operating system will consider
the file to have been downloaded from the Internet Zone and results
in the "Unblock" check box being displayed in the properties of the file.

Effectively this is the reverse of the Microsoft provided 'Unblock-File'
cmdlet which removes the Zone.Identifier alternate data stream.

The NTFS file system includes support for Alternate Data Streams (ADS).
This is not a well known feature and was included, primarily, to provide
compatibility with files in the Macintosh file system. Alternate data
streams allow files to contain more than one stream of data. Every file
has at least one data stream. In Windows, this default data stream is
called :$DATA. A common use of ADS is to indicate that a file downloaded
by Internet Explorer came from the Internet Zone.

By using the PowerShell cmdlet's 'Set-Content' and 'Add-Content', you
are able to read and write to alternate data streams. Note that
directories can also have alternate data streams

Any such stream associated with a file/folder is not visible when viewed
through conventional utilities such as Windows Explorer or PowerShell
Get-ChildItem command or any other file browser tools. It is used
legitimately by Windows and other applications to store additional
information (for example summary information) for the file. Even 'Internet
Explorer' adds the stream named 'Zone.Identifier' to every file downloaded
from the internet.

.PARAMETER Path

The file on which a 'Zone.Identifier' Alternate Data Stream
(ADS) will be created.

.EXAMPLE

./Block-File.ps1

As a parameter has not been supplied, an internal function is invoked
to obtain the file to block.

.EXAMPLE

./Block-File.ps1 'filename.txt'

The file supplied as a positional parameter will be blocked.

.EXAMPLE

./Block-File.ps1 -Path 'filename.txt'

The file supplied as a named parameter will be blocked.

.EXAMPLE

./Block-File.ps1 $file

The path to the file is passed as a positional parameter via
the contents of variable 'file'. Variable file can be of type
string or a System.IO.FileInfo object. This can be achieved
with the following assignments:

$file = 'C:\Gash\myfile.ps1'
or
$file = Get-Item 'myfile.ps1'

.EXAMPLE

./Secure-Delete.ps1 -Path $file

The path to the file is passed as a named parameter via
the contents of variable 'file'. Variable file can be of type
string or a System.IO.FileInfo object. This can be achieved
with the following assignments:

$file = 'C:\Gash\myfile.ps1'
or
$file = Get-Item 'myfile.ps1'

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Block-File.ps1
Author       : Ian Molloy
Last updated : 2023-03-06T17:47:02

For a carriage return and a new line, use `r`n.
Special Characters
`r    Carriage return
`n    New line
or
$crlf = [string]::new(([char]0x0d, [char]0x0a));
write-host ('hello{0}world{0}how{0}you' -f $crlf);

PS> Set-Content -Path 'myfile.txt' -Stream 'Zone.Identifier' -Value "[ZoneTransfer]`r`nZoneId=3"

Set-Content -Path 'myfile.txt' -Stream 'Zone.Identifier' -Value '[ZoneTransfer]'
Add-Content -Path 'myfile.txt' -Stream 'Zone.Identifier' -Value 'ZoneId=3'
Get-Content -Path 'myfile.txt' -Stream zone.identifier
Get-Item -Path 'myfile.txt' -Stream zone *

.LINK

AlternateStreamData Class
Represents alternate stream data retrieved from a file
https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.internal.alternatestreamdata?view=powershellsdk-1.1.0

How NTFS Works
https://technet.microsoft.com/en-us/library/cc781134(v=ws.10).aspx

Alternate Data Streams in NTFS
https://blogs.technet.microsoft.com/askcore/2013/03/24/alternate-data-streams-in-ntfs/

What you need to know about alternate data streams in windows?
Is your Data secure? Can you restore that?
https://www.symantec.com/connect/articles/what-you-need-know-about-alternate-data-streams-windows-your-data-secure-can-you-restore

Fork (file system)
https://en.wikipedia.org/wiki/Fork_(file_system)

Reading And Writing Alternate Data Streams
http://www.powertheshell.com/ntfsstreams/

System.Security.SecurityZone Enum
Defines the integer values corresponding to security zones used by security policy.

System.Security.Policy.Zone Class
Provides the security zone of a code assembly as evidence for policy evaluation.

DataObject Class
Namespace:   System.Windows.Forms
https://msdn.microsoft.com/en-us/library/system.windows.forms.dataobject(v=vs.110).aspx

The Unblock-File cmdlet
Unblocks files that were downloaded from the Internet.
https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/Unblock-File?view=powershell-7.1

Alternate Data Streams in NTFS(2)
https://docs.microsoft.com/en-us/archive/blogs/askcore/alternate-data-streams-in-ntfs

Sysinternals utility 'Streams' currently at version 1.6
https://learn.microsoft.com/en-us/sysinternals/downloads/streams


How to write a cmdlet
This article shows how to write a cmdlet. The Send-Greeting
cmdlet takes a single user name as input and then writes a
greeting to that user. Although the cmdlet does not do much
work, this example demonstrates the major sections of a cmdlet.
https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/how-to-write-a-simple-cmdlet?view=powershell-7.1

System.Management.Automation.ScriptBlock
Search for files with an alternate data stream (ADS)
$sb = {

Begin {
  $path = 'c:/gash';
}

Process {
  Get-ChildItem -File -Path $path |
      ForEach-Object {Get-Item -Path $_.FullName -Stream *;} |
      Where-Object -Property 'Stream' -ne -Value ':$DATA' |
      Format-List FileName, Stream, Length;
}

End {
  Write-Output 'Alternate data stream (ADS) search complete';
}

} #end of ScriptBlock
Submit the scriptblock above as a background job in one of two ways:
1.
$job = Start-ThreadJob -ScriptBlock $sb -Name 'adssearch';
or
2.
$job = Start-Job -ScriptBlock $sb -Name 'adssearch';
#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [Object]
   $Path
) #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** Function Get-Filename *****
function Get-Filename {
  <#
  .SYNOPSIS

  Display the OpenFileDialog dialog box

  .DESCRIPTION

  Display the .NET class OpenFileDialog dialog box that prompts
  the user to open a file

  .PARAMETER Title

  The title displayed on the dialog box window

  .LINK

  OpenFileDialog Class.
  https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=netcore-3.1
  #>

  [CmdletBinding()]
  Param (
     [parameter(Mandatory=$true,
                HelpMessage="ShowDialog box title")]
     [ValidateNotNullOrEmpty()]
     [String]$Title
  ) #end param

  Begin {
    Write-Verbose -Message "Invoking function to obtain the filename to block";

    Add-Type -AssemblyName "System.Windows.Forms";
    # Displays a standard dialog box that prompts the user
    # to open (select) a file.
    #[System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;
    [System.Windows.Forms.OpenFileDialog]$ofd = [System.Windows.Forms.OpenFileDialog]::new();

    # The dialog box return value is OK (usually sent
    # from a button labeled OK). This indicates the
    # user has selected a file.
    $myok = [System.Windows.Forms.DialogResult]::OK;
    [String[]]$retFilename = "";
    $ofd.CheckFileExists = $true;
    $ofd.CheckPathExists = $true;
    $ofd.ShowHelp = $false;
    $ofd.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*";
    $ofd.FilterIndex = 1;
    $ofd.InitialDirectory = "C:\Family\powershell";
    $ofd.Multiselect = $true;
    $ofd.RestoreDirectory = $false;
    $ofd.Title = $Title; # sets the file dialog box title
    $ofd.DefaultExt = "txt";

  }

  Process {
    if ($ofd.ShowDialog() -eq $myok) {
       $retFilename = $ofd.FileNames;
    } else {
       Throw "No file chosen or selected";
    }
  }

  End {
    $ofd.Dispose();
    return $retFilename;
  }
  }
  #endregion ***** End of function Get-Filename *****

#------------------------------------------------

#region ***** function Start-MainRoutine *****
function Start-MainRoutine {
  <#
  .SYNOPSIS

  Process the file selected

  .DESCRIPTION

  Set the Zone.Identifier Alternate Data Stream of the
  file selected to a value of "3" which indicate that it
  was downloaded from the Internet. Even if the file
  wasn't downloaded, setting the Zone.Identifier like
  this has the same effect.

  .PARAMETER BlockFile

  File which will be blocked
  #>

[CmdletBinding()]
[OutputType([System.Void])]
Param (
   [parameter(Position=0,
              Mandatory=$true)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $BlockFile
) #end param

Begin {}

Process {

  Write-Verbose -Message "Setting Zone.Identifier for file $BlockFile";


  $ReadOnlyStatus = (Get-Item $BlockFile).IsReadOnly
  (Get-Item $BlockFile).IsReadOnly = $false;

  # Remove the 'Zone.Identifier' stream if it exists. Not all
  # files have an Alternate Data Stream of course, so the
  # Remove-Item cmdlet will generate an error which will be
  # silently ignored.
  #
  # I've taken the decision to do this, as some files when downloaded
  # from the Internet have other data in this stream such as:
  #   [ZoneTransfer]
  #   ZoneId=3
  #   ReferrerUrl=<some URL>
  #   HostUrl=<some URL>
  # I'm removing the stream altogether and recreating it with my
  # own content of:
  #   [ZoneTransfer]
  #   ZoneId=3
  #
  Remove-Item -Path $BlockFile -Stream 'Zone.Identifier' -ErrorAction Ignore;

  [System.Linq.Enumerable]::Repeat("", 2); #blanklines

  Set-Content -Path $BlockFile -Stream 'Zone.Identifier' -Value '[ZoneTransfer]';
  Add-Content -Path $BlockFile -Stream 'Zone.Identifier' -Value 'ZoneId=3';

  #Set the read only property back to it's original value
  (Get-Item $BlockFile).IsReadOnly = $ReadOnlyStatus;

  #List all streams on the file just modified
  Write-Output "Streams now on file [$BlockFile]";
  Get-Item -Path $BlockFile -Stream * | Format-Table Stream,Length;

} #end process block

End {}

}
#endregion ***** end of function Start-MainRoutine *****

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
<#
$MyInvocation
TypeName: System.Management.Automation.InvocationInfo
This automatic variable contains information about the current
command, such as the name, parameters, parameter values, and
information about how the command was started, called, or
invoked, such as the name of the script that called the current
command.

$MyInvocation is populated differently depending upon whether
the script was run from the command line or submitted as a
background job. This means that $MyInvocation may not be able
to return the path and file name of the script concerned as
intended.
#>
   Write-Output '';
   Write-Output "Blocking file(s) using the Alternate Data Stream 'Zone.Identifier'";
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   if ($MyInvocation.OffsetInLine -ne 0) {
       #I think the script was run from the command line
       $script = $MyInvocation.MyCommand.Name;
       $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
       Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
   }

} #end of Invoke-Command -ScriptBlock

#Extract the filename to work with from the parameter
if ($Path -is [String]) {
    Write-Verbose 'The main parameter is a string';
    $MyFile = Resolve-Path -Path $Path;

} elseif ($Path -is [System.IO.FileInfo]) {
    Write-Verbose 'The main parameter is FileInfo';
    $MyFile = $Path.FullName;

} else {
    #No value has been supplied
    Write-Verbose 'Not sure what the type of the main parameter is';
    $MyFile = Get-Filename -Title 'File to block';
}

Start-MainRoutine -BlockFile $MyFile;

Write-Output '';
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Block-File.ps1
##=============================================
