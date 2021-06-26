<#
.SYNOPSIS

Prefixes lines in a text file with an integer (incrementing) number

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

0000000001 | the
0000000002 | quick
0000000003 | brown
0000000004 | fox
0000000005 | jumps
0000000006 | over
0000000007 | the
0000000008 | lazy
0000000009 | dog
0000000010 | 012345
0000000011 | last line of text

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : File-LineNumbers.ps1
Author       : Ian Molloy
Last updated : 2021-05-23T16:29:43

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
   Write-Output 'Adding numbers to lines';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   if ($MyInvocation.OffsetInLine -ne 0) {
       #I think the script was run from the command line
       $script = $MyInvocation.MyCommand.Name;
       $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
       Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
   }

} #end of Invoke-Command -ScriptBlock

# The New-TemporaryFile cmdlet creates an empty file that
# has the .tmp file name extension. This cmdlet names the
# file tmpNNNN.tmp, where NNNN is a random hexadecimal
# number. The cmdlet creates the file in your
# $Env:Temp folder. To find out what this directory is:
# PS> Write-Output $Env:TEMP;
$TempFile = New-TemporaryFile;

$config = @{
   Inputfile   = 'C:\Gash\gash02.txt';  # <-- Change accordingly
   Outputfile  = $TempFile.FullName;              # <-- Change accordingly
}

# If we've used the New-TemporaryFile cmdlet to create a
# file then it will be empty anyway so in theory, we don't
# need this step. But we'll leave it in anyway just in
# case we're using an existing file for some reason and
# not creating a new temporary file and would like it
# to be empty.
if (Test-Path -Path $config.Outputfile) {
   Clear-Content -Path $config.Outputfile;
}

$splat = @{
    # Splat data for use with New-Variable cmdlet.
    Name        = 'BUFFSIZE'
    Value       = 8KB
    Option      = 'Constant'
    Description = 'Buffer size used with file I/O'
}
New-Variable @splat;

$separator = ' | ';
$myAscii = New-Object -TypeName 'System.Text.ASCIIEncoding';
Set-Variable -Name 'config', 'separator', 'myAscii' -Option ReadOnly;

#
# The input stream (splat example)
#
$myargs = @(
    #Constructor arguments - input stream
    $config.Inputfile  #The complete file path to be read.
    $myAscii  #The character encoding to use.
    $false  #whether to look for byte order marks at the beginning of the file.
    $BUFFSIZE  #minimum buffer size, in number of 16-bit characters
)
$parameters = @{
    #General parameters
    TypeName = 'System.IO.StreamReader'
    ArgumentList = $myargs
}
$reader = New-Object @parameters;

#
# The output stream (splat example)
#
$myargs = @(
    #Constructor arguments - output stream
    $config.Outputfile  #The complete file path to write to.
    $false  #true to append data to the file; false to overwrite
            #the file. If the specified file does not exist, this
            #parameter has no effect, and the constructor creates
            #a new file.
    $myAscii  #The character encoding to use.
    $BUFFSIZE  #The buffer size, in bytes.
)
$parameters = @{
    #General parameters
    TypeName = 'System.IO.StreamWriter'
    ArgumentList = $myargs
}
$writer = New-Object @parameters;

$writer.AutoFlush = $false;
$sb = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList 100;
[System.UInt64][ValidateRange(0, 9999999999)]$counter = 0;
$sw = New-Object -typeName 'System.Diagnostics.Stopwatch';
$sw.Start();

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output "Line numbering file $($config.Inputfile)";
Write-Output ("Input file length is {0:N0} bytes" -f  $($reader.BaseStream.Length));

try {

   do {
      $counter++;
      $null = $sb.Append($counter.ToString('0000000000'));
      $null = $sb.Append($separator);
      $null = $sb.Append($reader.ReadLine());
      $writer.WriteLine($sb.ToString());
      $null = $sb.Clear();
  } until ($reader.EndOfStream)

} catch [Exception] {
    $Error[0].Exception.Message;
    # As we've hit an error, the output file is no use
    # to us now.
    Remove-Item -Path $TempFile -Force;
} finally {
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

#Write-Output "`n$($counter) lines processed from input file";
Write-Output ("`n{0:N0} lines processed from input file" -f $counter);

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output ("`nFiles used`nInput: {0}`nOutput: {1}" -f `
      $config.Inputfile, $config.Outputfile);
Get-ChildItem $config.Inputfile, $config.Outputfile;
Write-Output "`nAll done now";

##=============================================
## END OF SCRIPT: File-LineNumbers.ps1
##=============================================
