<#

.SYNOPSIS

Creates a zip archive that contains the files and directories from
the specified directory

.DESCRIPTION

Creates a zip file that containing the files and directories from the
specified directory. Uses a compression level of "Optimal" meaning
the compression operation should be optimally compressed, even if the
operation takes a longer time to complete.

The parameter "includeBaseDirectory" is set to false to include only
the contents of the directory.

The destination archive filename will be deleted if it exists to avoid
the exception "Exception calling "CreateFromDirectory" with "4" argument(s)"

.EXAMPLE

./ZipMyDirectory.ps1

No parameters are used

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : ZipMyDirectory.ps1
Author       : Ian Molloy
Last updated : 2020-08-05T13:46:14

.LINK

ZipFile.CreateFromDirectory Method
https://docs.microsoft.com/en-us/dotnet/api/system.io.compression.zipfile?view=netframework-4.7.1

Compress-Archive
Creates an archive, or zipped file, from specified files and folders.
https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Archive/Compress-Archive?view=powershell-5.1

#>

[CmdletBinding()]
Param () #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Zip files in a directory';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

#
# Change the next two constants accordingly.
#
New-Variable -Name 'sourceDir' -Value 'C:\IanmTools\GitRepos\powershell' -Option Constant `
             -Description 'The path of the directory to be archived';
New-Variable -Name 'destinationFile' -Value 'C:\Test\gashfile.zip'  -Option Constant `
             -Description 'The path of the archive (ZIP file) to be created';

If (Test-Path -Path $destinationFile) {
    # By removing the file if it exists, we avoid the error:
    # Exception calling "CreateFromDirectory" with "4" argument(s): "The file 'C:\Test\gashfile.zip' already exists."
    Remove-Item -Path $destinationFile;
}

Add-Type -AssemblyName "System.IO.Compression.FileSystem";

$opt = [System.IO.Compression.CompressionLevel]::Optimal;
$includeBaseDirectory = $false;
Write-Output ('Zipping directory {0} to ZIP file {1}' -f $sourceDir, $destinationFile);
[System.IO.Compression.ZipFile]::CreateFromDirectory( `
            $sourceDir, `
            $destinationFile, `
            $opt, `
            $includeBaseDirectory);
Get-ChildItem -File $destinationFile;

Write-Output '';
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: ZipMyDirectory.ps1
##=============================================
