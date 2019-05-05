<#

.SYNOPSIS

Compress file objects using either Zip or Gzip compression methods.

.DESCRIPTION

Enables compression of a file using gzip data format (an
industry-standard algorithm for lossless file compression and
decompression) or zip data format which allows for the compression
of the contents of a directory into one zip file.

.EXAMPLE

./Compress-File.ps1

No parameters are used

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Compress-File.ps1
Author       : Ian Molloy
Last updated : 2019-05-04

.LINK

System.IO.Compression.GZipStream class
https://docs.microsoft.com/en-us/dotnet/api/system.io.compression.gzipstream?view=netframework-4.8

System.IO.Compression.ZipFile class
System.IO.Compression.ZipFile.CreateFromDirectory Method
Creates a zip archive that contains the files and directories
from the specified directory.
https://docs.microsoft.com/en-us/dotnet/api/system.io.compression.zipfile.createfromdirectory?view=netframework-4.8

GZIP file format specification version 4.3
Request for Comments (RFC) : 1952
https://tools.ietf.org/html/rfc1952

How to: Compress and extract files
https://docs.microsoft.com/en-us/dotnet/standard/io/how-to-compress-and-extract-files

#>


[CmdletBinding()]
Param () #end param

#region ***** function Check-Zipfiles *****
function Check-Zipfiles {
[CmdletBinding()]
[OutputType([System.Double])]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $InputDirectory,

        [parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OutputFile
      ) #end param

  if ((Get-Item $InputDirectory).PSIsContainer -ne $true)
  {
      throw "Input directory $($InputDirectory) has to be a directory";
  }

  if ($InputDirectory -eq $OutputFile)
  {
      $msg = ("Input directory {0} cannot be the same as the output file {1}" -f $InputDirectory, $OutputFile);
      throw $msg;
  }

  $FileCount = Get-ChildItem -Path $InputDirectory;
  if (($FileCount | Measure-Object).Count -eq 0)
  {
     throw "No files to compress in directory $($InputDirectory)";
  }

  if (Test-Path -Path $OutputFile)
  {
     $mask = 'yyyy-MM-ddTHH-mm-ss';
     $dateTime = (Get-Date).ToString($mask);

     $pos = $OutputFile.LastIndexOf([System.IO.Path]::GetExtension($OutputFile));
     $template = $OutputFile.Insert($pos, "_{0}");

     $newFilename = ($template -f $dateTime);
     Rename-Item -Path $OutputFile -NewName $newFilename;
  }

}
#endregion ***** end of function Check-Zipfiles *****


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


#region ***** function Compress-Gzip *****
function Compress-Gzip {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param () #end param

BEGIN {

# change accordingly
$file = [PSCustomObject]@{
    # Input and output files used
    'Input'     = 'C:\test\gashInput_02.txt';
    'Output'    = 'C:\test\gashOutput.gz';
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
Write-Output ('Gzip compress file start: {0}' -f $CompressStart.ToString("yyyy-MM-ddTHH-mm-ss"))
} #end BEGIN block

PROCESS {
try {

    # The stream to compress.
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
    Write-Output ('Compress finish: {0}' -f $CompressFinish.ToString("yyyy-MM-ddTHH-mm-ss"))
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
#endregion ***** end of function Compress-Gzip *****

#region ***** function Compress-Zip *****
function Compress-Zip {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param () #end param

BEGIN {

# change accordingly
$file = [PSCustomObject]@{
    # Input and output objects used
    'Input'     = 'C:\test\Blankdir'; # Has to be a directory
    'Output'    = 'C:\test\gashOutput.zip';
}

Check-Zipfiles -InputDirectory $file.Input -OutputFile $file.Output;


Add-Type -AssemblyName "System.IO.Compression.FileSystem";

$opt = [System.IO.Compression.CompressionLevel]::Optimal;
$includeBaseDirectory = $false;

$CompressStart = Get-Date;
Write-Output ("`nZip compress directory start: {0}" -f $CompressStart.ToString("yyyy-MM-ddTHH-mm-ss"))
} #end BEGIN block

PROCESS {

[System.IO.Compression.ZipFile]::CreateFromDirectory( `
            $file.Input, `
            $file.Output, `
            $opt, `
            $includeBaseDirectory);

} #end PROCESS block

END {
    $CompressFinish = Get-Date;
    Write-Output ('Compress finish: {0}' -f $CompressFinish.ToString("yyyy-MM-ddTHH-mm-ss"))
    $tspan = $CompressFinish - $CompressStart;
    Write-Output "`nElapsed time:";
    $tspan | Format-Table Days, Hours, Minutes, Seconds
    Write-Output "Directory and output file used:";
    Write-Output ("Input - {0}" -f $file.Input);
    Write-Output ("Output - {0}" -f $file.Output);
    Get-ChildItem $file.Output;
    Write-Output "`nAll done now";
}

}
#endregion ***** end of function Compress-Zip *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

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

##=============================================
## END OF SCRIPT: Compress-File.ps1
##=============================================
