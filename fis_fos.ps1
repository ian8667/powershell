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
Last updated : 2021-05-29T19:19:01

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
Param() #end param

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------

$inStreamFunc = [Func[String,System.IO.FileStream]]{
param($InputData)
<#
Get input stream
#>
   $buffersize = 8KB;
   $myargs = @(
       #Constructor arguments - input stream
       $InputData #path
       [System.IO.FileMode]::Open #mode - FileMode
       [System.IO.FileAccess]::Read #access - FileAccess
       [System.IO.FileShare]::Read #share - FileShare
       $buffersize #bufferSize - Int32
       [System.IO.FileOptions]::SequentialScan #options - FileOptions
   )
   $parameters = @{
       #General parameters
       TypeName = 'System.IO.FileStream'
       ArgumentList = $myargs
   }
   $fis = New-Object @parameters;  #splat example
   return $fis;
} #end inStreamFunc

#----------------------------------------------------------

$outStreamFunc = [Func[String,System.IO.FileStream]]{
param($OutputData)
<#
Get output stream
#>
   $buffersize = 8KB;
   $myargs = @(
       #Constructor arguments - output stream
       $OutputData #path
       [System.IO.FileMode]::Create #mode - FileMode
       [System.IO.FileAccess]::Write #access - FileAccess
       [System.IO.FileShare]::None #share - FileShare
       $buffersize #bufferSize - Int32
       [System.IO.FileOptions]::None #options - FileOptions
   )
   $parameters = @{
       #General parameters
       TypeName = 'System.IO.FileStream'
       ArgumentList = $myargs
   }

   $fos = New-Object @parameters;  #splat example
   return $fos;
} #end outStreamFunc

#----------------------------------------------------------
# End of delegates
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

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
     Write-Output 'fis/fos example copy file';
     $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
     Write-Output ('Today is {0}' -f $dateMask);

     if ($MyInvocation.OffsetInLine -ne 0) {
         #I think the script was run from the command line
         $script = $MyInvocation.MyCommand.Name;
         $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
         Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
     }

} #end of Invoke-Command -ScriptBlock


$sw = [System.Diagnostics.Stopwatch]::new();
$sw.Start();
$buffersize = 8KB;
#The cmdlet creates an empty file in the TEMP ($env:temp) folder.
$TempFile = New-TemporaryFile;
$config = @{
   Inputfile   = 'C:\gash\Screenshot 2020-12-14 233306.png';  # <-- Change accordingly
   Outputfile  = $TempFile.FullName;              # <-- Change accordingly
}
$inStream = $inStreamFunc.Invoke($config.Inputfile);
$outStream = $outStreamFunc.Invoke($config.Outputfile);

try {

  $inStream.CopyTo($outStream, $buffersize);

} catch {
  Write-Error -Message $error[0].Exception.Message;
} finally {

  $inStream.Dispose();
  $outStream.Dispose();
  $sw.Stop();
}

#Get-ChildItem -File $optIn.path, $optOut.path;
Get-ChildItem -File $config.Inputfile, $config.Outputfile;

Write-Output "`nElapsed time for File copy:";
$elapsed = $sw.Elapsed.Duration();
$elapsed | Format-Table Days, Hours, Minutes, Seconds, Milliseconds -AutoSize

# Ensure both files have the same MD5 hash
$hashInfo = Get-FileHash -Path $config.Inputfile, $config.Outputfile -Algorithm MD5;
$hashInfo | Format-List Path, Hash;

if ($hashInfo[0].Hash -ne $hashInfo[1].Hash) {
  Write-Error -Message 'File hashes are not consistent';
}

Write-Output "`nEnd of test";

##=============================================
## END OF SCRIPT: fis_fos.ps1
##=============================================
