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
Last updated : 2020-08-05T12:54:29

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

$inrec="";
$counter=0;
$infile="C:\junk\gashinputfile.txt";
$outfile="C:\junk\gashoutputfile.txt";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Demonstration program using .NET objects to achieve file input/output';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

$input = New-Object -TypeName System.IO.StreamReader($infile);
$outStream = New-Object -TypeName System.IO.FileStream(
                        $outfile,
                        [System.IO.FileMode]::Create,
                        [System.IO.FileAccess]::Write);
$output = New-Object -TypeName System.IO.StreamWriter(
              $outStream,
              [System.Text.Encoding]::ASCII);

$inrec = $input.ReadLine();
while ($inrec -ne $null) {
   $output.WriteLine($inrec);
   $counter++;

   $inrec = $input.ReadLine();
}

$input.Close();
$input.Dispose();
$output.Flush();
$output.Close();
$output.Dispose();


$filelen = New-Object -TypeName System.IO.FileInfo($outfile);
Write-Output "File $($outfile.ToString()) has length $($filelen.length) bytes";

Write-Output "Lines written: $counter";
Write-Output "Files used:";
Write-Output ("Input file: {0}`nOutput file: {1}" -f $infile, $outfile);
Write-Output "All done now";
##=============================================
## END OF SCRIPT: StreamInputOutput.ps1
##=============================================
