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
Last updated : 2013-08-11

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

[cmdletbinding()]
Param ()

$inrec="";
$counter=0;
$infile="C:\junk\gashinputfile.txt";
$outfile="C:\junk\gashoutputfile.txt";

Write-Host "Demonstration program using .NET objects to achieve file input/output";

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
Write-Host "File $($outfile.ToString()) has length $($filelen.length) bytes";


Write-Host "Lines written: $counter";
Write-Host "Files used:";
Write-Host ("Input file: {0}`nOutput file: {1}" -f $infile, $outfile);
Write-Host "All done now";
##=============================================
## END OF SCRIPT: StreamInputOutput.ps1
##=============================================
