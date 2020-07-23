<#

.SYNOPSIS

Compress file objects using either Zip or Gzip compression methods.

.DESCRIPTION

Enables compression of a file using gzip data format (an
industry-standard algorithm for lossless file compression and
decompression) or zip data format which allows for the compression
of the contents of a directory into one zip file.

The file objects required are hard coded in the hashtable
'$ConfigData' in the main body of the program.

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
Last updated : 2020-07-23T17:14:22

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

Compress-Archive
The Compress-Archive cmdlet creates a compressed, or zipped, archive
file from one or more specified files or directories

Expand-Archive
The Expand-Archive cmdlet extracts files from a specified zipped
archive file to a specified destination folder.

#>

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Compress-Gzip *****
function Compress-Gzip {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param(
      [Parameter(Position=0,
                 Mandatory=$true,
                 HelpMessage="Input object name")]
      [ValidateNotNullOrEmpty()]
      [String]$InputData,

      [Parameter(Position=1,
                 Mandatory=$true,
                 HelpMessage="Output object name")]
      [ValidateNotNullOrEmpty()]
      [String]$OutputData
) #end param

Begin {

$bufSize = 4KB;

$CompressStart = Get-Date;
Write-Output ('Gzip compress file start: {0}' -f $CompressStart.ToString("yyyy-MM-ddTHH-mm-ss"))
} #end BEGIN block

Process {
try {

    #
    # The stream to compress.
    #
    $myargs = @(
        #Constructor arguments - input stream
        $InputData #path
        [System.IO.FileMode]::Open #mode - FileMode
        [System.IO.FileAccess]::Read #access - FileAccess
        [System.IO.FileShare]::Read #share - FileShare
        $bufSize #bufferSize - Int32
        [System.IO.FileOptions]::SequentialScan #options - FileOptions
    )
    $parameters = @{
        #General parameters
        TypeName = 'System.IO.FileStream'
        ArgumentList = $myargs
    }
    $fis = New-Object @parameters;

    #
    # The output stream
    #
    $myargs = @(
        #Constructor arguments - output stream
        $OutputData #path
        [System.IO.FileMode]::Create #mode - FileMode
        [System.IO.FileAccess]::Write #access - FileAccess
        [System.IO.FileShare]::None #share - FileShare
        $bufSize #bufferSize - Int32
        [System.IO.FileOptions]::None #options - FileOptions
    )
    $parameters = @{
        #General parameters
        TypeName = 'System.IO.FileStream'
        ArgumentList = $myargs
    }
    $fos = New-Object @parameters;

    #
    #Create the Gzip stream
    #
    $myargs = @(
        #Constructor arguments
        $fos #stream
        [System.IO.Compression.CompressionMode]::Compress #mode - compression mode
        $false #leaveOpen
    )
    $parameters = @{
        #General parameters
        TypeName = 'System.IO.Compression.GzipStream'
        ArgumentList = $myargs
    }
    $gzipStream = New-Object @parameters;

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

End {
    $CompressFinish = Get-Date;
    Write-Output ('Gzip compress finish: {0}' -f $CompressFinish.ToString("yyyy-MM-ddTHH-mm-ss"))
    $tspan = $CompressFinish - $CompressStart;
    Write-Output "`nElapsed time:";
    $tspan | Format-Table Days, Hours, Minutes, Seconds
    Write-Output "Files used:";
    Write-Output ("Input - {0}" -f $InputData);
    Write-Output ("Output - {0}" -f $OutputData);
    Get-ChildItem $InputData, $OutputData;
    Write-Output "`nAll done now";
}

}
#endregion ***** end of function Compress-Gzip *****

#----------------------------------------------------------

#region ***** function Compress-Zip *****
function Compress-Zip {
[CmdletBinding()]
#[OutputType([System.Collections.Hashtable])]
Param(
      [Parameter(Position=0,
                 Mandatory=$true,
                 HelpMessage="Input object name")]
      [ValidateNotNullOrEmpty()]
      [String]$InputData,

      [Parameter(Position=1,
                 Mandatory=$true,
                 HelpMessage="Output object name")]
      [ValidateNotNullOrEmpty()]
      [String]$OutputData
) #end param

Begin {

Add-Type -AssemblyName "System.IO.Compression.FileSystem";

$opt = [System.IO.Compression.CompressionLevel]::Optimal;
$includeBaseDirectory = $true;

$CompressStart = Get-Date;
Write-Output ("`nZip compress directory start: {0}" -f $CompressStart.ToString("yyyy-MM-ddTHH-mm-ss"))
} #end BEGIN block

Process {

   [System.IO.Compression.ZipFile]::CreateFromDirectory( `
            $InputData, `
            $OutputData, `
            $opt, `
            $includeBaseDirectory);

} #end PROCESS block

End {
    $CompressFinish = Get-Date;
    Write-Output ('Zip compress finish: {0}' -f $CompressFinish.ToString("yyyy-MM-ddTHH-mm-ss"))
    $tspan = $CompressFinish - $CompressStart;
    Write-Output "`nElapsed time:";
    $tspan | Format-Table Days, Hours, Minutes, Seconds
    Write-Output "Directory and output file used:";
    Write-Output ("Input - {0}" -f $InputData);
    Write-Output ("Output - {0}" -f $OutputData);
    Get-ChildItem $OutputData;
    Write-Output "`nAll done now";
}

}
#endregion ***** end of function Compress-Zip *****

#----------------------------------------------------------

#region ***** function Check-Parameters *****
function Check-Parameters {
[CmdletBinding()]
#[OutputType([System.Double])]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $Config
) #end param

# Check the input is not the same as the output, ignoring
# the case of the strings being compared.
$myenum = [System.StringComparison]::CurrentCultureIgnoreCase;
$kompare = [System.String]::Compare($Config.Input, $Config.Output, $myenum);
if ($kompare -eq 0) {
    throw "Input $($Config.Input) cannot be the same as output $($Config.Output)";
}

# See whether the input object is a file or a directory.
# true if object is a directory, false otherwise.
$isDir = (Get-Item $Config.Input).PSIsContainer;

# Get the extension (including the period "."), or empty
# if variable 'OldFilename' does not contain an extension.
$ext = [System.io.Path]::GetExtension($Config.Output);


if ($Config.Format -eq 'Gzip') {
    # Carry out Gzip related checks.

    Write-Verbose -Message 'Carrying out Gzip checks';
    if ($isDir) {
        # The input object appears to be a directory which we
        # don't really want
        throw "For Gzip compression, input object must be a file";
    }

    # Check whether the output filename has a 'gz' or 'gzip'
    # file extension. If not, throw a terminating error.
    $isGzip = $ext -match 'gz|gzip';
    if (-not $isGzip) {
        throw "Convention has it that Gzip output files have an extension of 'gz' or 'gzip'";
    }

    # Check the input file is not an empty file.
    $len = (Get-Item $Config.Input).Length;
    if ($len -eq 0) {
        throw "Input file $($Config.Input) cannot be empty";
    }

} else {
    # Carry out Zip related checks.
    Write-Verbose -Message 'Carrying out Zip checks';

    if (-not $isDir) {
        # This input object appears to be a file which we don't really want.
        # The input object has to be a directory.
        throw "For Zip compression, input object $($Config.Input) must be a directory";
    }

    # Check whether the output filename has a 'zip' file
    # extension. If not, throw a terminating error.
    $isZip = $ext -match 'zip';
    if (-not $isZip) {
        throw "Convention has it that Zip output files should have an extension of 'zip'";
    }

    # Check the input directory has objects to zip. If not,
    # throw a terminating error.
    $count = (Get-ChildItem -Recurse -Path $Config.Input | Measure-Object).Count;
    if ($count -eq 0) {
        throw "Input directory $($Config.Input) does not appear to have any object to zip";
    }
}

} #end function
#endregion ***** end of function Check-Parameters *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

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

# change accordingly
# TypeName: System.Collections.Hashtable
$ConfigData = @{

    # Input object.
    # For zip files - The path to the directory to be archived,
    # (zipped) specified as an absolute path.
    #
    # For gzip files - the (usually text) file to compress
    # specified as an absolute path.
    Input   = 'C:\temp'

    # Output object.
    # For zip files - the path of the archive (zip file) to be
    # created, specified as an absolute path.
    #
    # For gzip files - the path of the archive (gzip file) to be
    # created, specified as an absolute path. By convention, gzip
    # files have a file extension of either 'gz' or 'gzip'.
    Output  = 'C:\Gash\TestZiped.zip'

    # Compression format to use. Uses one of the values in
    # enumerated type 'CompressFormat' to do the compression.
    Format  = [CompressFormat]::Zip;
}
Set-Variable -Name 'ConfigData' -Option ReadOnly;

# Check the values in hashtable 'ConfigData' are OK.
Check-Parameters -Config $ConfigData;

$splat = @{
  # Splat data for use with functions Compress-Gzip and Compress-Zip.
  InputData = $ConfigData.Input
  OutputData = $ConfigData.Output
}

switch ($ConfigData.Format)
{
  "Gzip"   {Compress-Gzip @splat; break;}
  "Zip"    {Compress-Zip @splat; break;}
}

##=============================================
## END OF SCRIPT: Compress-File.ps1
##=============================================
