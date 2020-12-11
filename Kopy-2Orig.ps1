<#
.SYNOPSIS

Copy a file to the original PowerShell directory

.DESCRIPTION

Copy a file from a local Git respository to the original
local PowerShell directory. I don't keep all files from
my Github repository in my original PowerShell directory,
so this script checks first to see whether this is the
case. If so, the file is not copied from the local Git
respository.

The directory paths used are hard coded within the program

.EXAMPLE

./Kopy-2Orig.ps1

No parameters used

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Kopy-2Orig.ps1
Author       : Ian Molloy
Last updated : 2020-12-07T19:07:33
Keywords     : git github repository copy

#>

[CmdletBinding()]
param () #end param

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
   the user to select a file to copy from the local Git repository
   to the main PowerShell directory

   .PARAMETER Title

   The title displayed on the OpenFileDialog dialog box window

   .PARAMETER GitRepository

   The initial directory displayed by the file dialog box.
   This value is used by the OpenFileDialog class
   'InitialDirectory' property

   .LINK

   OpenFileDialog Class.
   https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=netcore-3.1
   #>

   [CmdletBinding()]
   Param (
      [parameter(Mandatory=$true,
                 HelpMessage="File to copy to the main PowerShell directory")]
      [ValidateNotNullOrEmpty()]
      [String]$Title,

      [parameter(Mandatory=$true,
                 HelpMessage="Local Git repository where we will find the file to copy")]
      [ValidateNotNullOrEmpty()]
      [String]$GitRepository
   ) #end param

   Begin {

     Add-Type -AssemblyName "System.Windows.Forms";
     # Displays a standard dialog box that prompts the user
     # to open (select) a file.
     [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog';

     # The dialog box return value is OK (usually sent
     # from a button labeled OK). This indicates the
     # user has selected a file.
     $myok = [System.Windows.Forms.DialogResult]::OK;
     $retFilename = "";
     $ofd.CheckFileExists = $true;
     $ofd.CheckPathExists = $true;
     $ofd.ShowHelp = $false;
     $ofd.Filter = "PowerShell files (*.ps1)|*.ps1|All files (*.*)|*.*";
     $ofd.FilterIndex = 1;
     $ofd.InitialDirectory = $GitRepository;
     $ofd.Multiselect = $false;
     $ofd.RestoreDirectory = $false;
     $ofd.Title = $Title; # sets the file dialog box title
     $ofd.DefaultExt = "ps1";

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

#-------------------------------------------------
# End of functions
#-------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Copy file from local Git repository to original PowerShell directory';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
#Directories involved
$ConfigData = [PSCustomObject]@{
   #Local Git repository directory
   SourceDirectory = 'C:\IanmTools\GitRepos\powershell';

   #Local main (master) PowerShell directory
   DestinationDirectory = 'C:\Family\powershell';
}
Set-Variable -Name 'ConfigData' -Option ReadOnly;

#This will be the modified file to copy from the local Git repository
#to the main (master) PowerShell directory. Once the file is copied to
#the main PowerShell directory, we are free to overwrite the local Git
#repository. If we didn't do this copy, we would lose the updates to
#the file when the local Git repository is deleted in the process of
#being cloned from the online repository.
$SourceFile = Get-Filename -Title 'File to cppy' -GitRepository $ConfigData.SourceDirectory;

$SourceFileLeaf = Split-Path -Path $SourceFile -Leaf;
$DestinationFile = Join-Path -Path $ConfigData.DestinationDirectory -ChildPath $SourceFileLeaf;
Set-Variable -Name 'SourceFile', 'SourceFileLeaf', 'DestinationFile' -Option ReadOnly;

#Not all of the programs in the local Git repository will be
#in the original local PowerShell directory. If this is the
#case, there is nothing to do.
if (-not (Test-Path -Path $DestinationFile)) {
$msg = @"
File $SourceFileLeaf does not exist in the original (master) PowerShell directory.
So this file will not be copied
"@

  Write-Warning -Message $msg;
  return;
}

Write-Output ('Copying file {0} to {1}' -f $SourceFile, $DestinationFile);
Start-Sleep -Seconds 2.0;
Copy-Item -Path $SourceFile -Destination $DestinationFile;

#Ensure the file copy was OK. Algorithm MD5 is being used for simple
#change validation only. We can also use hash values to determine if
#two different files have exactly the same content. If the hash values
#of the files are identical, the contents of the files are also
#identical and thus the copy of the file was OK.
$fileHash = Get-FileHash -Path $SourceFile, $DestinationFile -Algorithm 'MD5';
[System.Linq.Enumerable]::Repeat("", 2); #blanklines
if ($fileHash.Hash[0] -eq $fileHash.Hash[1]) {
   Write-Output ('File {0} seems to have copied OK ' -f $SourceFile);
} else {
   Write-Warning -Message 'File hash for the two files are not the same';
}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Kopy-2Orig.ps1
##=============================================
