<#
.SYNOPSIS

Lists the last N bytes of a file.

.DESCRIPTION

Uses the FileStream method 'Seek' in order to move the current position
of the stream to a given value towards the end of the stream in order
to read (list) the last N bytes of a file.

The user defined variables 'path', 'buffersize' and 'seekPos' can be
modified in function Get-Parameters as appropriate. These variables
should be modified by the user prior to running the script.

.EXAMPLE

./Get-Lastlines.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Get-Lastlines.ps1
Author       : Ian Molloy
Last updated : 2018-04-06

.LINK

Online notepad
http://www.rapidtables.com/tools/notepad.htm

Microsoft.PowerShell.Core help topic 'about'
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/?view=powershell-6
#>

[CmdletBinding()]
Param () #end param

#region ***** function Get-Parameters *****
function Get-Parameters {
  [CmdletBinding()]
  [OutputType([System.Management.Automation.PSCustomObject])]
  param ()

  BEGIN {
    $object = [PSCustomObject]@{
        # Input filename. A 'FileNotFoundException' exception is thrown
        # if the file does not exist.
        path              = 'C:\test\gashInput.txt';

        # Int32 Struct. This variable serves a dual purpose as:
        #   1. The buffer size used by the stream.
        #   2. Data buffer size when reading a block of bytes by
        #      the filestream 'Read' method.
        buffersize        = 4096;

        # Int64 Struct. Sets the current position of this stream to
        # the given value. ie, the total number of bytes from the end
        # of the file. Adjust this figure accordingly depending upon
        # the amount of data from the end of the file you wish to look
        # at.
        #
        # So if you're interested in the last 15Kb of the file, for
        # example, set this variable as:
        # seekPos           = [System.Convert]::ToInt64(15Kb);
        seekPos           = [System.Convert]::ToInt64(2kb);

    }

  }

  PROCESS {}

  END {

    return $object;

  }
}
#endregion ***** end of function Get-Parameters *****

#region ***** function Get-InputFilestream *****
function Get-InputFilestream {
  [CmdletBinding()]
  [OutputType([System.IO.FileStream])]
  Param (
    [parameter(Position=0,
               Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$Filename,

    [parameter(Position=1,
               Mandatory=$true)]
    [Int32]$Buffsize
  ) #end param

  BEGIN {
    $opts1 = [PSCustomObject]@{
        path        = $Filename;
        mode        = [System.IO.FileMode]::Open;
        access      = [System.IO.FileAccess]::Read;
        share       = [System.IO.FileShare]::Read;
        bufferSize  = $Buffsize;
        options     = [System.IO.FileOptions]::None;
    }

    $inStream = New-Object -typeName System.IO.FileStream -ArgumentList `
        $opts1.path, $opts1.mode, $opts1.access, $opts1.share, $opts1.bufferSize, $opts1.options;

  }

  PROCESS {}

  END {

    return $inStream;

  }
}
#endregion ***** end of function Get-InputFilestream *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

$param = Get-Parameters;
Set-Variable -Name "param" -Option ReadOnly -Description "Contains program parameters";

# Specifies the end of the stream as a reference point to seek from.
# We do this because we're interested in the end of the file not the
# beginning. In other words, we're going backwards not forwards.
$theEnd = [System.IO.SeekOrigin]::End;

# Total number of bytes read into the data buffer or zero if the end
# of the stream (EOF) is reached.
$bytesRead = 0;

$utf8 = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false, $true;

New-Variable -Name "EOF" -Value 0 -Description "End of file marker" -Option Constant;

$param.buffersize = [System.Math]::Abs($param.buffersize);
$dataBuffer = New-Object byte[] $param.buffersize;

try {
  $fis = Get-InputFilestream -Filename $param.path -Buffsize $param.buffersize;

  # Find out which is the smallest value. This ensures we don't
  # attempt to move the file position (pointer) before the
  # beginning of the file if the data buffer is larger than the
  # file. Failure to do so results in the error:
  #   "An attempt was made to move the file pointer before the beginning of the file."
  $lookBytes = [System.Math]::Min($fis.Length, $param.seekPos);


  # In order to seek to a new position backwards from the end of the
  # stream, the first parameter of method 'Seek' HAS to be a
  # negative number. This moves the current position towards the end
  # of the stream and thus allows us to read the last few N bytes
  # when we start reading from that position to the end the stream.
  $lookBytes = [System.Math]::Abs($lookBytes) * -1;
  $fis.Seek($lookBytes, $theEnd) | Out-Null;

  $bytesRead = $fis.Read($dataBuffer, 0, $dataBuffer.Length);
  while ($bytesRead -ne $EOF) {
    $str = $utf8.GetString($dataBuffer);
    Write-Output $str;

    $bytesRead = $fis.Read($dataBuffer, 0, $dataBuffer.Length);
  }

} catch {
  Write-Error -Message $Error[0];
  Write-Error -Message $error[0].InvocationInfo;
} finally {
  $fis.Close();
}

Write-Host 'End of run';
##=============================================
## END OF SCRIPT: Get-Lastlines.ps1
##=============================================
