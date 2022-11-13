<#
.SYNOPSIS

Lists the last N bytes of a file.

.DESCRIPTION

Uses the FileStream method 'Seek' in order to move the current position
of the stream to a given value towards the end of the stream in order
to read the last N bytes of a file. The last N bytes is written to a
file of the users choosing.

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
Last updated : 2022-11-13T00:14:15
Keywords     : pscustomobject pstypename

.LINK

FileStream Class
https://docs.microsoft.com/en-us/dotnet/api/system.io.filestream?view=netframework-4.7.2

Microsoft.PowerShell.Core help topic 'about'
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/?view=powershell-6

Get-Content (parameter -Tail)
Specifies the number of lines from the end of a file to list.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-content?view=powershell-7.1#parameters

Custom objects and PSTypeName
https://powershellstation.com/2016/05/22/custom-objects-and-pstypename/

#>

[CmdletBinding()]
Param () #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Get-Parameters *****
function Get-Parameters {
  [CmdletBinding()]
  [OutputType([System.Management.Automation.PSCustomObject])]
  param ()

  Begin {
    # Change the values in this PSCustomObject object accordingly.
    $object = [PSCustomObject]@{
    PSTypeName = 'Widget';

        # Input filename. A 'FileNotFoundException' exception is thrown
        # if the file does not exist.
        path              = 'C:\test/small_sampledata.txt';

        # Output filename. The file will be overwritten if it exists.
        pathout           = 'C:\Test\gashoutput.txt';

        # Int32 Struct. This variable determines the bufferSize
        # used by the System.IO.Stream object.
        buffersize        = 8192;

        # Int64 Struct. Seek position pointer. Sets the current
        # position of this stream to the given value. ie, the
        # total number of bytes from the end of the file. Adjust
        # this figure accordingly depending upon the amount of
        # data from the end of the file you wish to look at.
        #
        # So if you're interested in the last 15 Kb of the file,
        # for example, set this variable as:
        # seekPos           = [System.Convert]::ToInt64(15KB);
        seekPos           = [System.Convert]::ToInt64(10KB);

    }

  }

  Process {}

  End {

    return $object;

  }
}
#endregion ***** end of function Get-Parameters *****

#----------------------------------------------------------

#region ***** function Check-parameters *****
function Check-parameters {
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param (
      [parameter(Position=0,
                 Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [PSTypeName('Widget')]$Params
    ) #end param

    Begin {
        $check1 = {
          # Exception thrown if the input file does not exist.
          param($File)

          $msg = "Cannot find input file '$File' because it does not exist";
          $notfound = New-Object -TypeName 'System.IO.FileNotFoundException' -ArgumentList $msg;

          throw $notfound;
        } #end scriptblock check1

        $check2 = {
            # Exception thrown if input file length is zero bytes.
            param($File)

            $msg = "File '$File' must be greater than zero bytes length"
            $errcat = [System.Management.Automation.ErrorCategory]::InvalidData;
            $exception = New-Object -TypeName 'System.IO.InvalidDataException' -ArgumentList $msg;

            $msg2 = "A whole lot more details here from err details";
            $errDetails = New-Object -TypeName 'System.Management.Automation.ErrorDetails' -ArgumentList $msg2;

            $zerobytes = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList `
                 $exception, 'file has zero bytes length', $errcat, $File;
            #$zerobytes.ErrorDetails = $errDetails;

            throw $zerobytes;
        } #end scriptblock check2

        $check3 = {
            # Exception thrown if input and output filenames have the same name
            param($File1, $File2)

            $msg = "Input and output filenames cannot be the same";
            $errcat = [System.Management.Automation.ErrorCategory]::InvalidData;
            $exception = New-Object -TypeName 'System.ArgumentException' -ArgumentList $msg;

            $same = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList `
                 $exception, $msg, $errcat, $null;
            #$zerobytes.ErrorDetails = $errDetails;

            throw $same;
        } #end scriptblock check3

    } #end BEGIN block

    Process {
        # 1. Check the input file exists
        if (-not (Test-Path -Path $Params.path) ) {
            Invoke-Command -ScriptBlock $check1 -ArgumentList $Params.path;
        }

        # 2. Check the input file is greater than zero bytes in length
        if ((Get-Item -Path $Params.path).length -eq 0kb) {
            Invoke-Command -ScriptBlock $check2 -ArgumentList $Params.path;
        }

        # 3. Check the input and output file are not the same
        if ($Params.path -eq $Params.pathout) {
            Invoke-Command -ScriptBlock $check3 -ArgumentList $Params.path, $Params.pathout;
        }

        # 4. If the output file exists, ensure we can write to it.
        # A simple test to see if we can write to the file is to
        # open the file in write mode. We don’t really want to do
        # any writing, just checking we can do so. An exception
        # will occur if we cannot open the file as we wish.
        if (Test-Path -Path $Params.pathout) {
            $tfile = [ref]'Undefined';
            $filemode = [System.IO.FileMode]::Open;
            $fileaccess = [System.IO.FileAccess]::Write;
            $local:fileOK = $true;

            try {
                $tfile = [System.IO.File]::Open($Params.pathout, $filemode, $fileaccess);
            } catch [System.Management.Automation.MethodInvocationException] {
              # We can't open the file in write mode.
              $fred = $Error[0];
              $local:fileOK = $false;

              Write-Output $fred.FullyQualifiedErrorId;
              Write-Output $fred.Exception.Message;
              Write-Output "At script linenumber $($fred.InvocationInfo.ScriptLineNumber)";
              Write-Output $fred.InvocationInfo.Line;
              Write-Output "Line in error--> $($fred.InvocationInfo.Line)";

              Write-Error -Category 'WriteError' `
                          -CategoryReason 'Checking we can write to output file' `
                          -CategoryTargetType 'Output file' `
                          -ErrorId '101' `
                          -Message 'Check the output file is not readonly' `
                          -RecommendedAction 'Check file is not reaonly';

              #throw "$($fred.Exception.Message)";
            } catch [System.Exception] {
              # Some other error has occurred.
              Write-Error -Message $_.Exception.Message `
                          -ErrorId '102';

            } finally {
              if ($local:fileOK) {
                   $tfile.Close();
                   $tfile.Dispose();
              }

              Remove-Variable -Name 'tfile', 'fileOK';
              [System.GC]::Collect();
            }

        } #end IF statement
    }

    End {}
}
#endregion ***** end of function Check-parameters *****

#----------------------------------------------------------

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

  Begin {

    #
    # The input stream
    #
    $myargs = @(
        #Constructor arguments - input stream
        $Filename #path
        [System.IO.FileMode]::Open #mode - FileMode
        [System.IO.FileAccess]::Read #access - FileAccess
        [System.IO.FileShare]::Read #share - FileShare
        $Buffsize #bufferSize - Int32
        [System.IO.FileOptions]::SequentialScan #options - FileOptions
    )
    $parameters = @{
        #General parameters (splat example)
        TypeName = 'System.IO.FileStream'
        ArgumentList = $myargs
    }
    $inStream = New-Object @parameters;

  }

  Process {}

  End {

    return $inStream;

  }
}
#endregion ***** end of function Get-InputFilestream *****

#----------------------------------------------------------

#region ***** function Get-OutputFilestream *****
function Get-OutputFilestream {
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

  Begin {

    #
    # The output stream
    #
    $myargs = @(
        #Constructor arguments - output stream
        $Filename #path
        [System.IO.FileMode]::Create #mode - FileMode
        [System.IO.FileAccess]::Write #access - FileAccess
        [System.IO.FileShare]::None #share - FileShare
        $Buffsize #bufferSize - Int32
        [System.IO.FileOptions]::None #options - FileOptions
    )
    $parameters = @{
        #General parameters (splat example)
        TypeName = 'System.IO.FileStream'
        ArgumentList = $myargs
    }

    # It's important to note that by specifying "Open", it does
    # not actually overwrite the entire file, it only starts at
    # the beginning of the file and overwrites the text up to the
    # point that the new text ends. To make this a true overwriting
    # of the file, I will call the SetLength() method and specify
    # a 0 (zero) to tell the file to be 0 bytes and clear the file
    # prior to adding new text. This is analogous to using the
    # 'Clear-Content' cmdlet.
    $outStream = New-Object @parameters;
    $outStream.SetLength(0);
  }

  Process {}

  End {

    return $outStream;

  }
}
#endregion ***** end of function Get-OutputFilestream *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Continue';

Invoke-Command -ScriptBlock {
    <#
    $MyInvocation
    TypeName: System.Management.Automation.InvocationInfo
    This automatic variable contains information about the current
    command, such as the name, parameters, parameter values, and
    information about how the command was started, called, or
    invoked, such as the name of the script that called the current
    command.

    $MyInvocation is populated differently depending upon whether
    the script was run from the command line or submitted as a
    background job. This means that $MyInvocation may not be able
    to return the path and file name of the script concerned as
    intended.
    #>
       Write-Output '';
       Write-Output 'Getting last few bytes (lines) of a file';
       $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
       Write-Output ('Today is {0}' -f $dateMask);

       if ($MyInvocation.OffsetInLine -ne 0) {
           #I think the script was run from the command line
           $script = $MyInvocation.MyCommand.Name;
           $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
           Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
       }

} #end of Invoke-Command -ScriptBlock

$param = Get-Parameters;
Set-Variable -Name "param" -Option ReadOnly -Description "Contains program parameters";

# Check the parameters supplied. A terminating error will be thrown
# if any checks fail.
Check-parameters -Params $param;

# Specifies the end of the stream as a reference point to seek from.
# We do this because we're interested in the end of the file not the
# beginning. In other words, we're going backwards from the end of
# the file towards the beginning.
$theEnd = [System.IO.SeekOrigin]::End;

[Int64]$FileStreamPosition = 0;

try {
  $fis = Get-InputFilestream -Filename $param.path -Buffsize $param.buffersize;
  Write-Verbose -Message "Input stream $($param.path) open";
  Write-Output ("Length of input stream {0:N0} bytes" -f $($fis.Length));

  $fos = Get-OutputFilestream -Filename $param.pathout -Buffsize $param.buffersize;
  Write-Verbose -Message "Output stream open";

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
  $FileStreamPosition = $fis.Position;
  Write-Verbose -Message "FileStream position of input stream moved to $($FileStreamPosition)";

  # Copying begins at the current position in the current stream, and
  # does not reset the position of the destination stream after the
  # copy operation is complete.
  $fis.CopyTo($fos, $param.buffersize);

} catch {
  Write-Error -Message $error[0].Exception.Message;
} finally {
  Write-Verbose -Message 'Closing input and output files';
  $fis.Close();
  $fis.Dispose();

  $fos.Flush();
  $fos.Close();
  $fos.Dispose();

  Remove-Variable -Name 'fis', 'fos' -Force;
  [System.GC]::Collect();
  [System.GC]::WaitForPendingFinalizers();
}

Write-Output "`nFiles used";
Write-Output "Input file: $($param.path)";
Write-Output "Output file: $($param.pathout)";

Write-Output "`nEnd of copy last few bytes";
##=============================================
## END OF SCRIPT: Get-Lastlines.ps1
##=============================================
