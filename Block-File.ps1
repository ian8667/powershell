<#

.SYNOPSIS

Blocks a file via a 'Zone.Identifier' Alternate Data Stream

.DESCRIPTION

'Blocks' files by setting the Zone.Identifier alternate data stream,
which has a value of "3" to indicate as if it was downloaded from the
Internet. Effectively this is the reverse of the 'Unblock-File' cmdlet
which removes the Zone.Identifier alternate data stream.

The NTFS file system includes support for Alternate Data Streams (ADS).
This is not a well known feature and was included, primarily, to provide
compatibility with files in the Macintosh file system. Alternate data
streams allow files to contain more than one stream of data. Every file
has at least one data stream. In Windows, this default data stream is
called :$DATA. A common use of ADS is to indicate that a file downloaded
by Internet Explorer came from the Internet Zone.

Any such stream associated with a file/folder is not visible when viewed
through conventional utilities such as Windows Explorer or PowerShell
Get-ChildItem command or any other file browser tools. It is used
legitimately by Windows and other applications to store additional
information (for example summary information) for the file. Even 'Internet
Explorer' adds the stream named 'Zone.Identifier' to every file downloaded
from the internet.

.EXAMPLE

./Block-File.ps1

As a parameter has not been supplied, an internal function is invoked
to obtain the file(s) to block.

.EXAMPLE

./Block-File.ps1 'file1.txt', 'file2.txt'

The file(s) supplied as parameters will be blocked.

.EXAMPLE

./Block-File.ps1 -Path 'filename.txt'

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Block-File.ps1
Author       : Ian Molloy
Last updated : 2020-07-08T13:59:20

For a carriage return and a new line, use `r`n.
Special Characters
`r    Carriage return
`n    New line
PS> Set-Content -Path 'fred.txt' -Stream 'Zone.Identifier' -Value "[ZoneTransfer]`r`nZoneId=3"

Set-Content -Path 'ian.ian' -Stream 'Zone.Identifier' -Value '[ZoneTransfer]'
Add-Content -Path 'ian.ian' -Stream 'Zone.Identifier' -Value 'ZoneId=3'
Get-Content –Path 'fred.txt' -Stream zone.identifier
Get-Item -Path fred.txt -Stream zone*

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

System.Management.Automation.ScriptBlock
Search for files with an alternate data stream (ADS)
$sb = {

Begin {
  $path = 'c:/gash';
}

Process {
  Get-ChildItem -file -Path $path |
  foreach {Get-Item -Path $_.FullName -Stream *;} |
    Where-Object -property stream -ne -value ':$DATA' |
    Format-List filename, stream, length;
}

End {
  Write-Output 'alternate data stream search complete';
}

} #end of ScriptBlock
Submit as a background job:
$job = Start-ThreadJob -ScriptBlock $sb -Name 'adssearch';
or
$job = Start-Job -ScriptBlock $sb -Name 'adssearch';
#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String[]]
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
    Write-Verbose -Message "Invoking function to obtain the C# filename to compile";

    Add-Type -AssemblyName "System.Windows.Forms";
    # Displays a standard dialog box that prompts the user
    # to open (select) a file.
    [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

    # The dialog box return value is OK (usually sent
    # from a button labeled OK). This indicates the
    # user has selected a file.
    $myok = [System.Windows.Forms.DialogResult]::OK;
    $retFilename = "";
    $ofd.CheckFileExists = $true;
    $ofd.CheckPathExists = $true;
    $ofd.ShowHelp = $false;
    $ofd.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*";
    $ofd.FilterIndex = 1;
    $ofd.InitialDirectory = "C:\Family\powershell";
    $ofd.Multiselect = $false;
    $ofd.RestoreDirectory = $false;
    $ofd.Title = $Title; # sets the file dialog box title
    $ofd.DefaultExt = "txt";

  }

  Process {
    if ($ofd.ShowDialog() -eq $myok) {
       $retFilename = $ofd.FileName;
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

#------------------------------------------------------------------------------

#region ***** function Start-MainRoutine *****
function Start-MainRoutine {
  <#
  .SYNOPSIS

  Process files selected

  .DESCRIPTION

  Loop through each of the files in the array supplied as
  a parameter and set the 'Zone.Identifier' alternate data
  stream. No action is taken if the file concerned alrady
  has a 'Zone.Identifier' alternate data stream except to
  write a warning to the console to this effect.
  
  .PARAMETER fList

  List of file(s) to process
  #>

[CmdletBinding()]
[OutputType([System.Void])]
Param (
   [parameter(Position=0,
              Mandatory=$true)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String[]]
   $fList
) #end param

Begin {
  [String[]]$zones = '';
}

Process {
  # Loop round the array of files and set the Zone.Identifier accordingly.
  foreach ($file in $fList) {
    Write-Verbose -Message "Setting Zone.Identifier for file $file";

    #Make sure the file does not already have a Zone.Identifier. Returns an
    #object of the type:
    #TypeName: System.Management.Automation.Internal.AlternateStreamData
    $zones = (Get-Item $file -Stream *).Stream;

    if ($zones -contains 'Zone.Identifier') {
      Write-Warning -Message "File $file already has a Zone.Identifier.`nNo further action taken";
    } else {
      Set-Content -Path $file -Stream 'Zone.Identifier' -Value '[ZoneTransfer]';
      Add-Content -Path $file -Stream 'Zone.Identifier' -Value 'ZoneId=3';
    }

  }

}

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

Write-Output '';
Write-Output "Blocking file(s) using the Alternate Data Stream 'Zone.Identifier'";
Write-Output ('Today is {0:dddd, dd MMMM yyyy}' -f (Get-Date));
[System.String[]]$files = $null;
Invoke-Command -ScriptBlock {

   Write-Output '';
   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

if ($PSBoundParameters.ContainsKey('Path')) {
   # Files have been supplied as a parameter.
   $files = $Path;
} else {
  # No files supplied to the program. Get some to work with.
  $files = Get-Filename -Title 'File(s) to block';
}

Start-MainRoutine -fList $files;

Write-Output '';
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Block-File.ps1
##=============================================
