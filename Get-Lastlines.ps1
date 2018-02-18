# Read the last N bytes of a file.
#
[CmdletBinding()]
Param () #end param

#region ***** function Get-InputFilestream *****
function Get-InputFilestream {
  [CmdletBinding()]
  [OutputType([System.IO.FileStream])]
  param ()

  BEGIN {
    $opts1 = [PSCustomObject]@{
        path        = 'C:\test\gashInput.txt';
        mode        = [System.IO.FileMode]::Open;
        access      = [System.IO.FileAccess]::Read;
        share       = [System.IO.FileShare]::Read;
        bufferSize  = 16KB;
        options     = [System.IO.FileOptions]::None;
    }

    $inStream = New-Object -typeName System.IO.FileStream -ArgumentList `
        $opts1.path, $opts1.mode, $opts1.access, $opts1.share, $opts1.bufferSize, $opts1.options;

  }

  PROCESS {}

  END {

    # Return a filestream object
    return $inStream;

  }
}
#endregion ***** end of function Get-InputFilestream *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

# Total number of bytes from the end of the file we wish to look at.
# Adjust this figure accordingly depending upon the amount of data
# at the end of the file you wish to look at.
$numBytes = 10KB;

# Specifies the end of the stream as a reference point to seek from.
$theEnd = [System.IO.SeekOrigin]::End;

# Total number of bytes read into the data buffer.
$bytesRead = 0;

$utf8 = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false, $true;

$numBytes = [System.Math]::Abs($numBytes);
$dataBuffer = New-Object byte[] $numBytes;

try {
  $fis = Get-InputFilestream;
  Write-Host ('Length of stream: {0} bytes' -f $fis.Length);
  
  # Find out which is the smallest value. This ensures we don't
  # attempt to move the file pointer before the beginning of the
  # file if the data buffer is larger than the file. Failure to
  # do this results in the error:
  # "An attempt was made to move the file pointer before the beginning of the file."
  $lookBytes = [System.Math]::Min($fis.Length, $numBytes);


  # In order to seek to a new position backwards from the end of the
  # stream, the first parameter of method 'Seek' HAS to be a
  # negative number. This then allows us to read the last few N
  # bytes when we read from the stream.
  $lookBytes = [System.Math]::Abs($lookBytes) * -1;
  $fis.Seek($lookBytes, $theEnd) | Out-Null;

  $lookBytes = [System.Math]::Abs($lookBytes)
  $bytesRead = $fis.Read($dataBuffer, 0, $lookBytes);
  Write-Host ('Number of bytes read into the buffer: {0}' -f $bytesRead);

  # Write some blank lines
  foreach ($num in 1..3) {Write-Host ''}

  $str = $utf8.GetString($dataBuffer);
  Write-Host $str;

} catch {
  Write-Error -Message $Error[0];
  Write-Error -Message $error[0].InvocationInfo;
} finally {
  $fis.Close();
}

Write-Host 'End of test';
##=============================================
## END OF SCRIPT: Get-Lastlines.ps1
##=============================================
