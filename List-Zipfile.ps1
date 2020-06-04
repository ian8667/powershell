function Get-FriendlySize() {
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

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Add-Type -AssemblyName System.IO.Compression.FileSystem;

$ff = 'C:\Family\powershell\NewZip.zip';
$myread = [System.IO.Compression.ZipArchiveMode]::Read;
$fred = [System.IO.Compression.ZipFile]::Open($ff, $myread);
[System.UInt16]$entryCount = 0;
[System.Int64]$komplength = 0; # Compressed size of the entry in the zip archive.
$flength = "";

foreach ($entry in $fred.Entries) {
# Variable entry is of type:
# TypeName: System.IO.Compression.ZipArchiveEntry
   $entryCount++;
   Write-Host ('{0} compressed length= {1}' -f $entry.Name, $entry.CompressedLength);
   $flength = Get-FriendlySize $entry.CompressedLength;
   $flength
   Write-Host ('({0}) {1} {2}' -f $entryCount, $entry, $flength);
   Write-Host '';
}

Write-Host ("`n{0} entries in zipfile {1}" -f $entryCount, $ff);
$fred.Dispose();

# Clean up
Remove-Variable fred;
Write-Host 'End of test';
