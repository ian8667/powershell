<#
.SYNOPSIS

Splits a file into multiple smaller files (chunks).

.DESCRIPTION

Splits a text file into smaller files based on a chunk size of 8 Mb.
Each of these smaller files are equal in size, with the exception of
the last one created. It is the remainder of the original. Your
original file is not changed by split. You may find the split command
helpful in dividing large data files into smaller, more manageable
files. The original file can be recreated from the chunks created
using cat command (Get-Content).

As byte buffers are used to copy data, it's not possible to do anything
about (or correct) trailining spaces or end-of-line sequence (i.e.,
Unix or MS Windows). The data is copied as-is.

.EXAMPLE

PS> ./Split-File.ps1

The file to split up is hardcoded within the program.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Split-File.ps1
Author       : Ian Molloy
Last updated : 2019-02-23

.LINK

Online notepad
http://www.rapidtables.com/tools/notepad.htm

File.OpenRead Method
http://msdn.microsoft.com/en-us/library/system.io.file.openread.aspx

FileStream.Read Method
http://msdn.microsoft.com/en-us/library/system.io.filestream.read.aspx

File.OpenWrite Method
http://msdn.microsoft.com/en-us/library/system.io.file.openwrite.aspx

FileStream.Write Method
http://msdn.microsoft.com/en-us/library/system.io.filestream.write.aspx

FileStream.Flush Method
http://msdn.microsoft.com/en-us/library/2bw4h516.aspx

Stream.Close Method
http://msdn.microsoft.com/en-us/library/system.io.stream.close.aspx

#>

[CmdletBinding()]
Param ()

#region ***** function DisplayInBytes *****
function DisplayInBytes($num)
{
   $suffix = @("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB");
   $index = 0
   [Double]$d = $num

   while ($d -gt 1kb)
   {
      $d = $d / 1kb
      $index++
   }

   return "{0:N4} {1}" -f $d, $suffix[$index];
}
#endregion ***** end of function DisplayInBytes *****


##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

New-Variable -Name INPUTFILE -Value "C:\test\large_sampledata.dat" -Option Constant `
             -Description 'Input text file to be split up into smaller files';

New-Variable -Name CHUNKSIZE -Value 5MB -Option Constant `
             -Description 'The original file will be split up into smaller files of this size';

New-Variable -Name BUFFSIZE -Value 4KB -Option Constant `
             -Description 'Buffer size used with file I/O';

New-Variable -Name EOF -Value 0 -Option Constant `
             -Description 'Signifies the end of the stream has been reached';

# Opens an existing file for reading.
# Returns: FileStream, A read-only FileStream on the specified path.
$sourceFile = [System.IO.File]::OpenRead($INPUTFILE);
Write-Host "`nReading from input file $INPUTFILE";
$len = DisplayInBytes  (get-item $INPUTFILE).length
Write-Output ("Input file length {0}" -f $len);

$dataBuffer = New-Object -TypeName byte[] $BUFFSIZE;

# The total number of bytes read into the buffer. This can be less
# than the number of bytes requested if that many bytes are not
# currently available, or zero (0) if the end of the stream has been
# reached.
$bytesRead = 0;

# Keeps track of the number of bytes written to the current chunk.
# When the number of bytes written is greater than or equal to
# the value of 'CHUNKSIZE', we know we've completed the current
# chunk and can consider creating another chunk if necessary.
$bytesWritten = 0;

# Used to help identify chunk files and forms part of the filename.
$idx = 0;

# Create the chunk file template in the format of, for example:
#   C:\junk\filename.{0}.csv
# where the place holder will be used to insert an integer
# number thus making the file name unqiue each time around.
$pos = $inputfile.LastIndexOf([System.IO.Path]::GetExtension($inputfile));
$template = $inputfile.Insert($pos, ".{0}");
Write-Verbose -Message "Chunk file template used is $template";

Write-Output "`nSplitting input file using $CHUNKSIZE byte chunks per file.";
$startTime = Get-Date;
Write-Output ($startTime.ToString('F') );
$parent = Split-Path $INPUTFILE -Parent;

try {

     # $bytesRead - the total number of bytes read into the buffer. This
     # might be less than the number of bytes requested if that number
     # of bytes are not currently available, or zero (EOF) if the end of
     # the stream is reached.
     $bytesRead = $sourceFile.Read($dataBuffer, 0, $dataBuffer.Length);

     :outerloop while ($bytesRead -gt $EOF) {

         # Increment counter ready for the next filename to be used.
         $idx++;

         $bytesWritten = 0;

         # Create a filename for the next chunk file to be written to.
         # The number portion of filename will have leading zeros. So
         # the number 7 will be written into the filename as 007.
         $fout = ($template -f ($idx.ToString('000')));
         Write-Verbose -Message "creating chunk file  $($fout)";

         # Open the next chunk file to write to.
         # Returns FileStream, An unshared FileStream object on
         # the specified path with Write access.
         $chunkPiece = [System.IO.File]::OpenWrite($fout);

         :innerloop while (($bytesWritten -le $CHUNKSIZE) -and ($bytesRead -gt $EOF)) {
              # Keep track of how many bytes we've written to
              # the current chunk.
              $bytesWritten += $bytesRead;

              $chunkPiece.Write($dataBuffer, 0, $bytesRead);

              $bytesRead = $sourceFile.Read($dataBuffer, 0, $dataBuffer.Length);

         } #end WHILE (inner) loop

         # Close the chunk file just written to. We don't need it anymore.
         $chunkPiece.Flush($true);
         $chunkPiece.Dispose();

     } #end WHILE (outer) loop

} finally {
    # Close the input file.
    $sourceFile.Close();
    $sourceFile.Dispose();
}

$endTime = Get-Date;
$tspan = New-TimeSpan -Start $startTime -End $endTime;

Write-Output "";
Write-Output ("{0} chunk files created`nin directory {1}" -f $idx, $parent);
Write-Output "`nElapsed time for split:";
Write-Output $tspan | Select-Object Hours, Minutes, Seconds;
Write-Output "`nAll done now!";

##=============================================
## END OF SCRIPT: Split-File.ps1
##=============================================
