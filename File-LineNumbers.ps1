<#
Keywords: text file line number
#>

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

$config = @{
   Inputfile   = 'C:\test\small_sampledata.txt';
   Outputfile  = 'C:\Test\gashoutput.txt';
}

if (Test-Path -Path $config.Outputfile) {
   Clear-Content -Path $config.Outputfile;
}

New-Variable -Name BUFFSIZE -Value 4KB -Option Constant `
             -Description 'Buffer size used with file I/O';

$separator = ' | ';
Set-Variable -Name 'config', 'separator' -Option ReadOnly;

$myAscii = New-Object -TypeName 'System.Text.ASCIIEncoding';
$reader = New-Object -TypeName 'System.IO.StreamReader' `
          -ArgumentList $config.Inputfile, $myAscii, $false, $BUFFSIZE;
$writer = New-Object -TypeName 'System.IO.StreamWriter' `
          -ArgumentList $config.Outputfile, $false, $myAscii, $BUFFSIZE;
$writer.AutoFlush = $false;
$sb = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList 100;
[System.UInt32][ValidateRange(0, 999999)]$counter = 0;
$sw = New-Object -typeName 'System.Diagnostics.Stopwatch';
$sw.Start();

$dateMask = Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss";
Write-Output "Running program on $dateMask";

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
}
finally
{
   Write-Host "`nCleaning up ..."
   # clean-up things
   $reader.Close();
   $reader.Dispose();
   $writer.Flush();
   $writer.Close();
   $writer.Dispose();

   $sw.Stop();

}

Write-Output "`nElapsed time:";
$elapsed = $sw.Elapsed.Duration();
$elapsed | Format-Table Days, Hours, Minutes, Seconds, Milliseconds -AutoSize

Write-Output "`n$($counter) lines processed";

Write-Output 'Files used:';
Get-ChildItem $config.Inputfile, $config.Outputfile;
Write-Output "`nAll done now";
