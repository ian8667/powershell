<#
.SYNOPSIS

Copy a file to the original PowerShell directory

.DESCRIPTION

Copy a file from a local Git respository to the original
PowerShell directory. I don't keep all files from my
Github repository in my original PowerShell directory,
so this script checks first to see whether this is the
case. If so, the file is not copied from the local Git
respository.

The directory paths used are hard coded withing the program

.EXAMPLE

./Kopy-2Orig.ps1

A filename to copy has not been supplied so the user
will be prompted to supply the filename.

.EXAMPLE

PS> ./Kopy-2Orig.ps1 'myfile.ps1'

The filename supplied will be copied to the original
PowerShell directory.

.EXAMPLE

PS> ./Kopy-2Orig.ps1 -Filename 'myfile.ps1'

The filename supplied will be copied to the original
PowerShell directory.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Kopy-2Orig.ps1
Author       : Ian Molloy
Last updated : 2020-08-05T23:15:06
Keywords     : git github repository copy

#>

[CmdletBinding()]
param (
    [Parameter(Position=0,
               Mandatory=$true,
               HelpMessage="Enter filename to copy to orig PowerShell dir")]
    [ValidateNotNullOrEmpty()]
    [String]$Filename
) #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Copy file from gitrepos to original PowerShell directory';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
#Directories
$sourceDir = 'C:\IanmTools\GitRepos\powershell';
$destDir = 'C:\Family\powershell';

#Filenames with absolute paths
$kopyFile = Join-Path -Path $sourceDir -ChildPath $Filename;
$destFile = Join-Path -Path $destDir -ChildPath $Filename;
Set-Variable -Name 'sourceDir', 'destDir', 'kopyFile', 'destFile' -Option ReadOnly;

#Not all of the programs in the local Git repository will be
#in the original PowerShell directory. If this is the case,
#there is nothing to do.
if (-not (Test-Path -Path $destFile)) {
$msg = @"
File $Filename does not exist in the original PowerShell directory.
So this file will not be copied
"@

  Write-Warning -Message $msg;
  return;
}

Write-Output ('Copying file {0} to {1}' -f $Filename, $destFile);
Start-Sleep -Seconds 2.0;
Copy-Item -Path $kopyFile -Destination $destDir;

#Ensure the file copy was OK. Algorithm MD5 is being used for simple
#change validation only. We can also use hash values to determine if
#two different files have exactly the same content. If the hash values
#of the files are identical, the contents of the files are also
#identical and thus the copy of the file was OK.
$fileHash = Get-FileHash -Path $kopyFile, $destFile -Algorithm 'MD5';
[System.Linq.Enumerable]::Repeat("", 2); #blanklines
if ($fileHash.Hash[0] -eq $fileHash.Hash[1]) {
   Write-Output ('File {0} seems to have copied OK ' -f $Filename);
} else {
   Write-Warning -Message 'File hash for the two files are not the same';
}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Kopy-2Orig.ps1
##=============================================
