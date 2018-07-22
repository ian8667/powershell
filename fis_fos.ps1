<#
.SYNOPSIS

Copy a file using the FileStream class

.DESCRIPTION

Demonstration program using System.IO.FileStream class to copy a file
to an output FileStream. In this example I'm using my own buffer size
instead of accepting the default. The documentation tells us the
default buffer size is 81920 bytes.

In terms of efficiency, it may be worthwhile thinking about wrapping
a System.IO.BufferedStream class around each of the input and output
FileStream objects.

The input and output filenames are hardcoded within the code.

.EXAMPLE

PS> ./fis_fos.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

A Better View of PowerShell Help
But in PowerShell 3 we can display help in a pop-up window using the
-ShowWindow parameter:

PS C:\> help Get-EventLog -ShowWindow


File Name    : fis_fos.ps1
Author       : Ian Molloy
Last updated : 2018-07-22

.LINK

BufferedStream Class
Adds a buffering layer to read and write operations on another stream.
https://docs.microsoft.com/en-us/dotnet/api/system.io.bufferedstream?view=netframework-4.7.1

FileStream Class
Provides a Stream for a file, supporting both synchronous and
asynchronous read and write operations.
https://docs.microsoft.com/en-us/dotnet/api/system.io.filestream?view=netframework-4.7.1

About Comment Based Help
Describes how to write comment-based help topics for functions and scripts.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-6

#>

[CmdletBinding()]
Param () #end param

$bufSize = 10KB;
$optIn = [PSCustomObject]@{
    path        = 'C:\test\gashInput01.txt';
    mode        = [System.IO.FileMode]::Open;
    access      = [System.IO.FileAccess]::Read;
    share       = [System.IO.FileShare]::Read;
    bufferSize  = $bufSize;
    options     = [System.IO.FileOptions]::SequentialScan;
}

$optOut = [PSCustomObject]@{
    path        = 'C:\test\gashOutput.txt';
    mode        = [System.IO.FileMode]::OpenOrCreate;
    access      = [System.IO.FileAccess]::Write;
    share       = [System.IO.FileShare]::None;
    bufferSize  = $bufSize;
    options     = [System.IO.FileOptions]::None;
}

$sw = New-Object -typeName 'System.Diagnostics.Stopwatch';
$sw.Start();

try {

  $fis = New-Object -typeName System.IO.FileStream -ArgumentList `
         $optIn.path, $optIn.mode, $optIn.access, $optIn.share, $optIn.bufferSize, $optIn.options;
  $fos = New-Object -typeName System.IO.FileStream -ArgumentList `
         $optOut.path, $optOut.mode, $optOut.access, $optOut.share, $optOut.bufferSize, $optOut.options;

  $fis.CopyTo($fos, $bufSize);

} catch {
  Write-Error -Message $error[0].Exception.Message;
} finally {
  $fos.Flush();
  $fis.Dispose();
  $fos.Dispose();
  $sw.Stop();
}

ls $optIn.path, $optOut.path;

Write-Output "`nElapsed time for File copy:";
$elapsed = $sw.Elapsed.Duration();
$elapsed | Format-Table Days, Hours, Minutes, Seconds -AutoSize
<#
In terms of elapsed, one could also use the ideas from the
following web sites:

Use PowerShell and Conditional Formatting to Format Time Spans
https://blogs.technet.microsoft.com/heyscriptingguy/2013/03/15/use-powershell-and-conditional-formatting-to-format-time-spans/

Custom TimeSpan Format Strings
https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-timespan-format-strings
#>

# Ensure both files have the same MD5 hash
$hashInfo = Get-FileHash -Path $optIn.path, $optOut.path -Algorithm MD5;
$hashInfo | Format-List Path, Hash;

if ($hashInfo[0].Hash -ne $hashInfo[1].Hash) {
  Write-Error -Message 'File hashes are not consistent';
}

Write-Output "`nEnd of test";

##=============================================
## END OF SCRIPT: fis_fos.ps1
##=============================================
