# C:\Family\ian
# illegalChars.txt
#

[CmdletBinding()]
Param () #end param

$ErrorActionPreference = 'Stop';

$validBytes = New-Object -TypeName System.Collections.Generic.List[Int32](150);
foreach ($num in 1..127) {
    $validBytes.Add($num);
}
# End-of-line characters
$validBytes.Add(0X0D); # Carriage Return (CR)
$validBytes.Add(0X0A); # Line Feed (LF)
$validBytes.TrimExcess();
Set-Variable -Name 'validBytes' -Option ReadOnly;

New-Variable -Name "BUFSIZE" -Value 4KB -Option Constant;
New-Variable -Name "EOF" -Value 0 -Option Constant;
New-Variable -Name "INF" -Value 'C:\Family\powershell\ian.ian' -Option Constant;
$bytesRead = 0;
[UInt16]$illCount = 0; # count of illegal characters found

if (-not (Test-Path -Path $INF)) {
    throw [System.IO.FileNotFoundException] "Input file not found", $INF;
}

$opts1 = [PSCustomObject]@{
    path        = $INF;
    mode        = [System.IO.FileMode]::Open;
    access      = [System.IO.FileAccess]::Read;
    share       = [System.IO.FileShare]::Read;
    bufferSize  = $BUFSIZE;
    options     = [System.IO.FileOptions]::SequentialScan
}
$databuffer = New-Object Byte[] $BUFSIZE;

try {
    $fis = New-Object -typeName System.IO.FileStream -ArgumentList `
    $opts1.path, $opts1.mode, $opts1.access, $opts1.share, $opts1.bufferSize, $opts1.options;

    $bytesRead = $fis.Read($databuffer, 0, $databuffer.Length);
    :outerloop while ($bytesRead -ne $EOF) {

        # Check the data buffer for any dodgy characters.
        :innerloop for ($i=0; $i -lt $bytesRead; $i++) {
            if (-not $validBytes.Contains($databuffer[$i])) {
                Write-Host ("this is a wrong character {0:X2}" -f $databuffer[$i]);
                $illCount++;
            }
        }# end for loop

        $bytesRead = $fis.Read($databuffer, 0, $databuffer.Length);
    }# end WHILE loop
}
catch {
    $_.Exception.Message;
    $_.Exception.ItemName;
}
finally {
    $fis.Close();
    $fis.Dispose();
}
Write-Host "`nIllegal characters found in file $($opts1.path): $($illCount)";
Write-Host 'End of test';
