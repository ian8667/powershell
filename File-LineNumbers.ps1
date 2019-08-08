<<<<<<< HEAD
<#
.SYNOPSIS

Prefixes lines in a text file with an incrementing number

.DESCRIPTION

Prefixes lines in a text file with an incrementing number for the
purpose of being able to illustrate and refer to the file. For
example, one can refer to lines 5-10 of a PowerShell script if
need be.

The input file will not be amended. The line number and original
line of text from the input file are written to a temporary file.

All file names used are hard coded within the program.

.EXAMPLE

./File-LineNumbers.ps1

No parameters are used

Sample output

000001 | the
000002 | quick
000003 | brown
000004 | fox
000005 | jumps
000006 | over
000007 | the
000008 | lazy
000009 | dog
000010 | 012345
000011 | last line of text

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : File-LineNumbers.ps1
Author       : Ian Molloy
Last updated : 2019-08-08

.LINK

StreamReader Class
https://docs.microsoft.com/en-us/dotnet/api/system.io.streamreader?view=netframework-4.8

About Comment Based Help
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-6

#>

[CmdletBinding()]
Param (
) #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# The New-TemporaryFile cmdlet creates an empty file that
# has the .tmp file name extension. This cmdlet names the
# file tmpNNNN.tmp, where NNNN is a random hexadecimal
# number. The cmdlet creates the file in your
# $Env:Temp folder.
$TempFile = New-TemporaryFile;

$config = @{
   Inputfile   = 'C:\Family\powershell\gash.ian';
   Outputfile  = $TempFile.FullName;
}

# If we've used the New-TemporaryFile cmdlet to create a
# file then it will be empty anyway so in theory, we don't
# need this step. But we'll leave it in anyway just in
# case we're using an existing file for some reason.
if (Test-Path -Path $config.Outputfile) {
   Clear-Content -Path $config.Outputfile;
}

New-Variable -Name BUFFSIZE -Value 4KB -Option Constant `
             -Description 'Buffer size used with file I/O';

$separator = ' | ';
$myAscii = New-Object -TypeName 'System.Text.ASCIIEncoding';
Set-Variable -Name 'config', 'separator', 'myAscii' -Option ReadOnly;

# Input file
$reader = New-Object -TypeName 'System.IO.StreamReader' `
          -ArgumentList $config.Inputfile, $myAscii, $false, $BUFFSIZE;
# Output file
$writer = New-Object -TypeName 'System.IO.StreamWriter' `
          -ArgumentList $config.Outputfile, $false, $myAscii, $BUFFSIZE;
$writer.AutoFlush = $false;
$sb = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList 100;
[System.UInt32][ValidateRange(0, 999999)]$counter = 0;
$sw = New-Object -typeName 'System.Diagnostics.Stopwatch';
$sw.Start();

$dateMask = Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss";
Write-Output "Running program on $dateMask";
Write-Output "Input file length is $($reader.BaseStream.Length) bytes";
try
{

   do {
       $counter++;
       $sb.Append($counter.ToString('000000')) | Out-Null;
       $sb.Append($separator) | Out-Null;
       $sb.Append($reader.ReadLine()) | Out-Null;
       $writer.WriteLine($sb.ToString());
       $sb.Clear() | Out-Null;
   } until ($reader.EndOfStream)

}
catch [Exception]
{
    $Error[0].Exception.Message;
    # As we've hit an error, the output file is no use
    # to us now.
    Remove-Item -Path $TempFile -Force;
}
finally
{
   Write-Output "`nCleaning up ..."
   # clean-up things
   $reader.Close();
   $reader.Dispose();
   $writer.Flush();
   $writer.Close();
   $writer.Dispose();

   $sw.Stop();

}

Write-Output "`nElapsed time:";
# Returns a read-only TimeSpan object representing the total
# elapsed time to process the input file.
$elapsed = $sw.Elapsed.Duration();
$elapsed | Format-Table Days, Hours, Minutes, Seconds, Milliseconds -AutoSize;

Write-Output "`n$($counter) lines processed from input file";

Write-Output ("`nFiles used`nInput: {0}`nOutput: {1}" -f `
      $config.Inputfile, $config.Outputfile);
Get-ChildItem $config.Inputfile, $config.Outputfile;
Write-Output "`nAll done now";

##=============================================
## END OF SCRIPT: File-LineNumbers.ps1
##=============================================
=======
<#
.SYNOPSIS

Prefixes lines in a text file with an incrementing number

.DESCRIPTION

Prefixes lines in a text file with an incrementing number for the
purpose of being able to illustrate and refer to the file. For
example, one can refer to lines 5-10 of a PowerShell script if
need be.

The input file will not be amended. The line number and original
line of text from the input file are written to a temporary file.

All file names used are hard coded within the program.

.EXAMPLE

./File-LineNumbers.ps1

No parameters are used

Sample output

000001 | the
000002 | quick
000003 | brown
000004 | fox
000005 | jumps
000006 | over
000007 | the
000008 | lazy
000009 | dog
000010 | 012345
000011 | last line of text

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : File-LineNumbers.ps1
Author       : Ian Molloy
Last updated : 2019-08-08

.LINK

StreamReader Class
https://docs.microsoft.com/en-us/dotnet/api/system.io.streamreader?view=netframework-4.8

About Comment Based Help
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-6

#>

[CmdletBinding()]
Param (
) #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# The New-TemporaryFile cmdlet creates an empty file that
# has the .tmp file name extension. This cmdlet names the
# file tmpNNNN.tmp, where NNNN is a random hexadecimal
# number. The cmdlet creates the file in your
# $Env:Temp folder.
$TempFile = New-TemporaryFile;

$config = @{
   Inputfile   = 'C:\Family\powershell\gash.ian';
   Outputfile  = $TempFile.FullName;
}

# If we've used the New-TemporaryFile cmdlet to create a
# file then it will be empty anyway so in theory, we don't
# need this step. But we'll leave it in anyway just in
# case we're using an existing file for some reason.
if (Test-Path -Path $config.Outputfile) {
   Clear-Content -Path $config.Outputfile;
}

New-Variable -Name BUFFSIZE -Value 4KB -Option Constant `
             -Description 'Buffer size used with file I/O';

$separator = ' | ';
$myAscii = New-Object -TypeName 'System.Text.ASCIIEncoding';
Set-Variable -Name 'config', 'separator', 'myAscii' -Option ReadOnly;

# Input file
$reader = New-Object -TypeName 'System.IO.StreamReader' `
          -ArgumentList $config.Inputfile, $myAscii, $false, $BUFFSIZE;
# Output file
$writer = New-Object -TypeName 'System.IO.StreamWriter' `
          -ArgumentList $config.Outputfile, $false, $myAscii, $BUFFSIZE;
$writer.AutoFlush = $false;
$sb = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList 100;
[System.UInt32][ValidateRange(0, 999999)]$counter = 0;
$sw = New-Object -typeName 'System.Diagnostics.Stopwatch';
$sw.Start();

$dateMask = Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss";
Write-Output "Running program on $dateMask";
Write-Output "Input file length is $($reader.BaseStream.Length) bytes";
try
{

   do {
       $counter++;
       $sb.Append($counter.ToString('000000')) | Out-Null;
       $sb.Append($separator) | Out-Null;
       $sb.Append($reader.ReadLine()) | Out-Null;
       $writer.WriteLine($sb.ToString());
       $sb.Clear() | Out-Null;
   } until ($reader.EndOfStream)

}
catch [Exception]
{
    $Error[0].Exception.Message;
    # As we've hit an error, the output file is no use
    # to us now.
    Remove-Item -Path $TempFile -Force;
}
finally
{
   Write-Output "`nCleaning up ..."
   # clean-up things
   $reader.Close();
   $reader.Dispose();
   $writer.Flush();
   $writer.Close();
   $writer.Dispose();

   $sw.Stop();

}

Write-Output "`nElapsed time:";
# Returns a read-only TimeSpan object representing the total
# elapsed time to process the input file.
$elapsed = $sw.Elapsed.Duration();
$elapsed | Format-Table Days, Hours, Minutes, Seconds, Milliseconds -AutoSize;

Write-Output "`n$($counter) lines processed from input file";

Write-Output ("`nFiles used`nInput: {0}`nOutput: {1}" -f `
      $config.Inputfile, $config.Outputfile);
Get-ChildItem $config.Inputfile, $config.Outputfile;
Write-Output "`nAll done now";

##=============================================
## END OF SCRIPT: File-LineNumbers.ps1
##=============================================
>>>>>>> e9e98d3d65ef754aaaa512d0b6c91805ea3bb72d
