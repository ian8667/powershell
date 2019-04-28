<#
#>

[CmdletBinding()]
Param () #end param

#region ***** function Compress-Gzip *****
function Compress-Gzip {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param () #end param

BEGIN {
$bufSize = 4KB;

$file = [PSCustomObject]@{
    # Input and output files used
    Input     = 'C:\test\gashInput.txt';
    Output    = 'C:\test\gashOutput.gz';
}

$optIn = [PSCustomObject]@{
    # Input file
    path        = $file.Input;
    mode        = [System.IO.FileMode]::Open;
    access      = [System.IO.FileAccess]::Read;
    share       = [System.IO.FileShare]::Read;
    bufferSize  = $bufSize;
    options     = [System.IO.FileOptions]::SequentialScan;
}

$optOut = [PSCustomObject]@{
    # Output file
    path        = $file.Output;
    mode        = [System.IO.FileMode]::Create;
    access      = [System.IO.FileAccess]::Write;
    share       = [System.IO.FileShare]::None;
    bufferSize  = $bufSize;
    options     = [System.IO.FileOptions]::None;
}

} #end BEGIN block

PROCESS {
try {
    $fis = New-Object -typeName 'System.IO.FileStream' -ArgumentList `
      $optIn.path, $optIn.mode, $optIn.access, $optIn.share, $optIn.bufferSize, $optIn.options;

    $fos = New-Object -typeName 'System.IO.FileStream' -ArgumentList `
      $optOut.path, $optOut.mode, $optOut.access, $optOut.share, $optOut.bufferSize, $optOut.options;

    $gzipOut = [PSCustomObject]@{
        stream    = $fos;
        mode      = [System.IO.Compression.CompressionMode]::Compress;
        leaveOpen = $false;
    }
    $gzipStream = New-Object 'System.IO.Compression.GzipStream' -ArgumentList `
      $gzipOut.stream, $gzipOut.mode, $gzipOut.leaveOpen;

    $fis.CopyTo($gzipStream, $bufSize);

} catch {
    Write-Error -Message $Error[0].Exception;
} finally {
    Write-Output 'Tidyup section';
    $gzipStream.Close();
    $gzipStream.Dispose();
    $fos.Close();
    $fos.Dispose();
    $fis.Close();
    $fis.Dispose();
}

} #end PROCESS block

END {
    Write-Output "Files used`n$($file)";
    Write-Output 'All done now';
}

}
#endregion ***** end of function Compress-Gzip *****

#region ***** function Compress-Zip *****
function Compress-Zip {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param () #end param

BEGIN {
write-output 'this is a pretend Compress-Zip;'
} #end BEGIN block

PROCESS {
} #end PROCESS block

END {
    Write-Output 'All done now';
}

}
#endregion ***** end of function Compress-Zip *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Write-Output 'test for Compress-File.ps1';

enum CompressFormat 
{
   Gzip;
   Zip;
}

[CompressFormat]$Choice = [CompressFormat]::Gzip;

switch ($Choice)
{
  "Gzip"   {Compress-Gzip; break;} 
  "Zip"    {Compress-Zip; break;} 
}

Write-Output 'test for Compress-File.ps1 done';

##=============================================
## END OF SCRIPT: Compress-File.ps1
##=============================================
