<#
.SYNOPSIS

Securely delete a file.

.NOTES

File Name    : List-Zipfile.ps1
Author       : Ian Molloy
Last updated : 2020-08-04T21:08:47
Keywords     : zipfile zip contents

#>

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

function Get-FriendlySize {
[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="File length in bytes to convert")]
        [ValidateNotNullOrEmpty()]
        [System.Double]$num
      ) #end param

Begin {
  $suffix = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB");
  $index = 0;
  [System.Double]$n = $num;
}

Process {
  while ($n -gt 1kb) {
       $n = $n / 1024;
       $index++;
  } 

}

End {
  return ("{0:N4} {1}" -f $n, $suffix[$index]);
}

}

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
   Write-Output 'Listing contents of a zip file';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

Add-Type -AssemblyName 'System.IO.Compression.FileSystem';

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
$zipFile = 'C:\gash\myZipfile.zip';
$myread = [System.IO.Compression.ZipArchiveMode]::Read;
$fred = [System.IO.Compression.ZipFile]::Open($zipFile, $myread);
[System.UInt16]$entryCount = 0;
[System.Int64]$komplength = 0; # Compressed size of the entry in the zip archive.
$flength = "";

foreach ($entry in $fred.Entries) {
# Variable entry is of type:
# TypeName: System.IO.Compression.ZipArchiveEntry
   $entryCount++;
   Write-Output ('{0} compressed length = {1} bytes' -f $entry.Name, $entry.CompressedLength);
   $flength = Get-FriendlySize $entry.CompressedLength;
   Write-Output ('({0}) {1} {2}' -f $entryCount, $entry, $flength);
   Write-Output '';
}

Write-Output ("`n{0} entries in zipfile {1}" -f $entryCount, $zipFile);
$fred.Dispose();

# Clean up
Remove-Variable fred;
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: List-Zipfile.ps1
##=============================================
