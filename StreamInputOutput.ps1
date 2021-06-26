<#
.SYNOPSIS

Demonstrates the basic use of file input and output

.DESCRIPTION

Demonstration program to show the basic use of file input
and output using .NET objects. As this is a Demonstration
program, it merely executes a WHILE loop to read data in
from an input file and write that same data to an output
file.

It doesn't aim to do anything else.

.EXAMPLE

./StreamInputOutput.ps1

No parameters are required or used. The files used for input
and output are hard coded within the program. Change accordingly.

.INPUTS

System.IO.StreamReader
System.IO.FileStream
System.IO.StreamWriter
System.IO.FileInfo

.NOTES

File Name    : StreamInputOutput.ps1
Author       : Ian Molloy
Last updated : 2021-06-24T23:08:45
Keywords     : delegate

Encoder - converts a set of characters into a sequence of bytes.
Decoder - converts a sequence of encoded bytes into a set of characters.

For information regarding this subject (comment-based help),
execute the command:
PS> Get-Help about_comment_based_help

.LINK

System.IO.StreamReader
http://msdn.microsoft.com/en-us/library/system.io.streamreader.aspx

System.IO.FileStream
http://msdn.microsoft.com/en-us/library/system.io.filestream.aspx

System.IO.StreamWriter
http://msdn.microsoft.com/en-us/library/system.io.streamwriter.aspx

FileInfo Class
http://msdn.microsoft.com/en-us/library/system.io.fileinfo.aspx
#>

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------

$inStreamReader = [Func[String,System.IO.StreamReader]]{
   param($InputData)
   <#
   Get input stream reader
   #>
      $buffersize = 8KB;
      $myargs = @(
          #Constructor arguments - input stream
          $InputData #path
          [System.Text.Encoding]::ASCII #encoding
          $false #detectEncodingFromByteOrderMarks
          $buffersize #bufferSize
      )
      $parameters = @{
          #General parameters
          TypeName = 'System.IO.StreamReader'
          ArgumentList = $myargs
      }
      $fis = New-Object @parameters;  #splat example
      return $fis;
} #end inStreamReader

#----------------------------------------------------------

$outStreamWriter = [Func[String,System.IO.StreamWriter]]{
   param($OutputData)
   <#
   Get output stream writer
   #>
      $buffersize = 8KB;
      $myargs = @(
          #Constructor arguments - output stream
          $OutputData #path
          $false #true to append data to the file; false to overwrite
                 #the file. If the specified file does not exist,
                 #this parameter has no effect, and the constructor
                 #creates a new file.
          [System.Text.Encoding]::ASCII #encoding
          $buffersize #bufferSize
      )
      $parameters = @{
          #General parameters
          TypeName = 'System.IO.StreamWriter'
          ArgumentList = $myargs
      }

      $fos = New-Object @parameters;  #splat example
      return $fos;
} #end outStreamWriter

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
     Write-Output 'Demonstration program using .NET objects to achieve file input/output';
     $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
     Write-Output ('Today is {0}' -f $dateMask);

     if ($MyInvocation.OffsetInLine -ne 0) {
         #I think the script was run from the command line
         $script = $MyInvocation.MyCommand.Name;
         $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
         Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
     }

} #end of Invoke-Command -ScriptBlock

$inrec = '';
$counter = 0;
$inputFile = "C:\Gash\gashinput.txt";
$outputFile = "C:\Gash\gashoutput.txt";
Set-Variable -Name 'inputFile', 'outputFile' -Option ReadOnly;

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
$inStream = $inStreamReader.Invoke($inputFile);
Write-Output ('Input file length: {0:N0} bytes' -f $inStream.BaseStream.Length);
$outStream = $outStreamWriter.Invoke($outputFile);

$inrec =  Get-Date | Out-String;
$outStream.WriteLine($inrec);
$inrec = $inStream.ReadLine();
while ($null -ne $inrec) {
    $outStream.WriteLine($inrec);
    $counter++;

    $inrec = $inStream.ReadLine();
}

$inStream.Close();
$inStream.Dispose();
$outStream.Flush();
$outStream.Close();
$outStream.Dispose();

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output "Lines written: $counter";
Write-Output "Files used:";
Write-Output ("Input file: {0}`nOutput file: {1}" -f $inputFile, $outputFile);
Write-Output "All done now";
##=============================================
## END OF SCRIPT: StreamInputOutput.ps1
##=============================================
