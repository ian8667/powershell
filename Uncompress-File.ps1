<#
#>

[CmdletBinding()]
Param () #end param


#region ***** function Check-Gzipfiles *****
function Check-Gzipfiles {
[CmdletBinding()]
[OutputType([System.Double])]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateScript({Test-Path -Path $_})]
        [System.String]
        $InputFile,

        [parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OutputFile
      ) #end param

  if ($InputFile -eq $OutputFile)
  {
      $msg = ("Input file {0} cannot be the same as the output file {1}" -f $InputFile, $OutputFile);
      throw $msg;
  }
}
#endregion ***** end of function Check-Gzipfiles *****


#region ***** function Uncompress-Gzip *****
function Uncompress-Gzip {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param () #end param

BEGIN {

# change accordingly
$file = [PSCustomObject]@{
    # Input and output files used
    'Input'     = 'C:\test\gashInput.gz';
    'Output'    = 'C:\test\gashOutput.txt';
}

Check-Gzipfiles -InputFile $file.Input -OutputFile $file.Output;

$bufSize = 4KB;

$optIn = [PSCustomObject]@{
    # Input file options
    path        = $file.Input;
    mode        = [System.IO.FileMode]::Open;
    access      = [System.IO.FileAccess]::Read;
    share       = [System.IO.FileShare]::Read;
    bufferSize  = $bufSize;
    options     = [System.IO.FileOptions]::SequentialScan;
}

$optOut = [PSCustomObject]@{
    # Output file options
    path        = $file.Output;
    mode        = [System.IO.FileMode]::Create;
    access      = [System.IO.FileAccess]::Write;
    share       = [System.IO.FileShare]::None;
    bufferSize  = $bufSize;
    options     = [System.IO.FileOptions]::None;
}

$CompressStart = Get-Date;
Write-Output ('Gzip uncompress file start: {0}' -f $CompressStart.ToString("yyyy-MM-ddTHH-mm-ss"))
} #end BEGIN block

PROCESS {
try {

    # The stream to Uncompress.
    $fis = New-Object -typeName 'System.IO.FileStream' -ArgumentList `
      $optIn.path, $optIn.mode, $optIn.access, $optIn.share, $optIn.bufferSize, $optIn.options;


    $fos = New-Object -typeName 'System.IO.FileStream' -ArgumentList `
      $optOut.path, $optOut.mode, $optOut.access, $optOut.share, $optOut.bufferSize, $optOut.options;


    $gzipIn = [PSCustomObject]@{
        stream    = $fis;
        mode      = [System.IO.Compression.CompressionMode]::Decompress;
        leaveOpen = $false;
    }
    $gzipStream = New-Object 'System.IO.Compression.GzipStream' -ArgumentList `
      $gzipIn.stream, $gzipIn.mode, $gzipIn.leaveOpen;


    $gzipStream.CopyTo($fos, $bufSize);

} catch {
    Write-Error -Message $Error[0].Exception;
} finally {
    $gzipStream.Close();
    $gzipStream.Dispose();
    $fos.Close();
    $fos.Dispose();
    $fis.Close();
    $fis.Dispose();
}

} #end PROCESS block

END {
    $CompressFinish = Get-Date;
    Write-Output ('uncompress finish: {0}' -f $CompressFinish.ToString("yyyy-MM-ddTHH-mm-ss"))
    $tspan = $CompressFinish - $CompressStart;
    Write-Output "`nElapsed time:";
    $tspan | Format-Table Days, Hours, Minutes, Seconds
    Write-Output "Files used:";
    Write-Output ("Input - {0}" -f $file.Input);
    Write-Output ("Output - {0}" -f $file.Output);
    Get-ChildItem $file.Input, $file.Output;
    Write-Output "`nAll done now";
}

}
#endregion ***** end of function Uncompress-Gzip *****


##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Uncompress-Gzip;

##=============================================
## END OF SCRIPT: Uncompress-File.ps1
##=============================================
