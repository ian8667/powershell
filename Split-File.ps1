[CmdletBinding()]
Param ()

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# Emulates the Unix split command and splits a file into
# pieces (chunks).
#
# Modified from: http://stackoverflow.com/a/11010158/215200
# web_info.html
# C:\Family\Ian
#
# Split-Path C:\temp\Untitled1.ps1 -leaf
# Split-Path C:\temp\Untitled1.ps1 -Parent
#
# See also:
# System.IO Namespace
# http://msdn.microsoft.com/en-us/library/System.IO.aspx
#
# [IO.Path]::GetFileNameWithoutExtension($ff)
#
# See also:
# File.OpenRead Method
# http://msdn.microsoft.com/en-us/library/system.io.file.openread.aspx
# FileStream.Read Method
# http://msdn.microsoft.com/en-us/library/system.io.filestream.read.aspx
# File.OpenWrite Method
# http://msdn.microsoft.com/en-us/library/system.io.file.openwrite.aspx
# FileStream.Write Method
# http://msdn.microsoft.com/en-us/library/system.io.filestream.write.aspx
# FileStream.Flush Method
# http://msdn.microsoft.com/en-us/library/2bw4h516.aspx
# Stream.Close Method
# http://msdn.microsoft.com/en-us/library/system.io.stream.close.aspx
#
$inputfile = "C:\junk\gashinputfile.txt";
# Opens an existing file for reading.
$sourceFile = [System.IO.File]::OpenRead($inputfile);
Write-Host "Reading from input file $inputfile";

$chunkSize = 1kb;
$buff = New-Object -TypeName byte[] $chunkSize;

$bytesRead = 0;
$idx = 0; # Used to help identify chunk files and forms part of the filename.
$eof = 0; # Signifies the end of the stream has been reached.

# Create the chunk file template in the format of, for example:
#   C:\junk\ian.{0}.csv
# where the place holder will be used to insert an integer
# number thus making the file name unqiue each time around.
$pos = $inputfile.LastIndexOf([System.IO.Path]::GetExtension($inputfile));
$template = $inputfile.Insert($pos, ".{0}");
Write-Verbose -Message "Chunk file template used is $template";
#($template -f 7);

Write-Host "Splitting file $inputfile using $chunkSize byte chunks per file.";
try {

    do {
        # $bytesRead - the total number of bytes read into the buffer. This
        # might be less than the number of bytes requested if that number
        # of bytes are not currently available, or zero (EOF) if the end of
        # the stream is reached.
        $bytesRead = $sourceFile.Read($buff, 0, $buff.Length);
        if ($bytesRead -gt $eof) {

            # Increment counter ready for the next filename to be used.
            $idx++;

            # Create a filename for the next chunk file to be written to.
            # The number portion of filename will have leading zeros.
            $to = ($template -f ($idx.ToString('000')));

            # Open the next chunk file to write to.
            $dest = [System.IO.File]::OpenWrite($to);

            try {
                Write-Host "Writing to chunk file $to";
                $dest.Write($buff, 0, $bytesRead);
            } finally {
                # Close the chunk file just used. We don't need it anymore.
                $dest.Flush($true);
                $dest.Close();
            }
        
        } #end of IF statement.


    } while ($bytesRead -gt $eof)
}
finally {
    # Close the input file.
    $sourceFile.Close();
}

if ($PSBoundParameters['Verbose']) {
     Write-Host "doing some verbose things";
     Write-Host "this is mighty fun";
     Write-Host "to is now $to";
     
     $p1 = [System.IO.Path]::GetDirectoryName($ff);
     $p2 = [System.IO.Path]::GetFileNameWithoutExtension($ff) + '*';
     #$newfiles.append([System.IO.Path]::GetDirectoryName($ff));
     ls -Path $p1 -Filter $p2;
}

Write-Host "";
Write-Host ("{0} chunk files created" -f $idx);
Write-Host "All done now!";

##=============================================
## END OF SCRIPT: Split-File.ps1
##=============================================
