<#
.SYNOPSIS

Securely shred and delete a file.

.DESCRIPTION

Securely shreds a file by overwriting the file several times
with a cryptographically strong sequence of random byte values.
Each iteration uses a different value of bytes which are
obtained from the static method 'GetBytes' of the
System.Security.Cryptography.RandomNumberGenerator class.

After the file has been overwritten, it's then deleted using the
PowerShell cmdlet 'Remove-Item'.

I have heard it mentioned that due to technological advances,
one overwrite pass is often enough, reducing the time and energy
needed for effective data sanitization. Nevertheless, I've
decided to stick with multiple overwrites of the file with
random data just to make sure.

This program is designed to prevent data from being recovered
by commercially available processes.

The path to the file can be passed to the parameter as a string
or a 'System.IO.FileInfo' object.

.PARAMETER Path

The file which will be overwritten and then deleted

.EXAMPLE

./Secure-Delete.ps1

As no parameter has been supplied, an internal function will
be invoked to prompt the user to select a file to shred and
delete.

.EXAMPLE

./Secure-Delete.ps1 'C:\Gash\speak.ps1'

An absolute path to the file that will be shredded and deleted.
The string containing the path is passed as a positional parameter.

.EXAMPLE

./Secure-Delete.ps1 -Path 'C:\Gash\speak.ps1'

Using a named parameter to pass the path of the file that will
be shredded and deleted.

.EXAMPLE

./Secure-Delete.ps1 $file

The path to the file is passed as a positional parameter via
the contents of variable 'file'. Variable file can be of type
string or a System.IO.FileInfo object. This can be achieved
with the following assignments:

$file = 'C:\Gash\myfile.txt'
or
$file = Get-Item 'myfile.txt'

.EXAMPLE

./Secure-Delete.ps1 -Path $file

The path to the file is passed as a named parameter via
the contents of variable 'file'. Variable file can be of type
string or a System.IO.FileInfo object. This can be achieved
with the following assignments:

$file = 'C:\Gash\myfile.ps1'
or
$file = Get-Item 'myfile.ps1'

.INPUTS

Optional: System.IO.FileInfo | System.String | <no user input>

.OUTPUTS

None. No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Secure-Delete.ps1
Author       : Ian Molloy
Last updated : 2023-09-21T21:53:57
Keywords     : yes no yesno secure shred delete random

See also
NIST SP 800-88 R1, Guidelines for Media Sanitization

DoD 5220.22-M National Industrial Security Program
Operating Manual (NISPOM)


Overwrite deleted data using Cipher.exe /w
WARNING, THIS PROCESS CAN TAKE A VERY LONG TIME!

To overwrite already deleted data, one can use the /w switch.
Due to the very nature of this tool, you're safe using it to
securely delete data, as it will never overwrite your active
files; it will only overwrite data (files) that have already
been deleted by you.

Cipher creates a temporary folder called EFSTMPWP (ie,
C:\EFSTMPWP) on the volume. Then, it creates one or more
temporary files in that folder, and writes data to those files.
First it writes zeros, then it writes ones, and finally, it
writes random numbers. After running this to completion, one
can be certain any previously deleted data can not be recovered
off the disk. If you cancel the operation, you may need to
delete the temporary folder manually.

By the time a file has taken up all of the drive's empty space,
it's effectively forced the file system to overwrite all data
held in its free space with the file's newly-written data,
rendering any data previously held there permanently irrecoverable.

Microsoft SysInternals also has a powerful tool that lets you
delete files permanently. With the SDelete tool, which you can
download for free, you can overwrite the contents of free space
on your disk to prevent deleted or encrypted files from being
recovered.

running CIPHER /W.
Writing 0x00

.LINK

ErrorRecord Class
Namespace: System.Management.Automation
https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.errorrecord?view=powershellsdk-7.0.0


RandomNumberGenerator Class
https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.randomnumbergenerator?view=net-6.0


RNGCryptoServiceProvider Class
Implements a cryptographic Random Number Generator (RNG) using the
implementation provided by the cryptographic service provider (CSP).
From the documentation:
"RNGCryptoServiceProvider is obsolete. To generate a random number,
use one of the RandomNumberGenerator static methods instead."
https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.rngcryptoserviceprovider?view=netframework-4.7.2


File and Stream I/O
A very interesting  Microsoft article on the subject of files
and stream I/O.
File and stream I/O (input/output) refers to the transfer of data
either to or from a storage medium. In .NET, the System.IO
namespaces contain types that enable reading and writing, both
synchronously and asynchronously, on data streams and files.
These namespaces also contain types that perform compression and
decompression on files, and types that enable communication
through pipes and serial ports.
https://learn.microsoft.com/en-us/dotnet/standard/io/


7 Effective Algorithms to Remove Files and Folders Permanently
https://www.stellarinfo.com/article/7-algorithms-to-wipe-files-folders-permanently.php


The management of modern storage devices is addressed by using
a scheme called Logical Block Addressing (LBA). It's the
arrangement of the logical sectors that constitute the media.
The partitioning scheme that is used by most modern Windows-based
computers is MBR (master boot record). This scheme sets a limit
of 32 for the number of bits that are available to represent the
number of logical sectors.


File IO improvements in .NET 6
A Microsoft article on the improvements made to the FileStream
class. This article is of relevance to this program and well
worth a read.
https://devblogs.microsoft.com/dotnet/file-io-improvements-in-dotnet-6/

#>

<#
new work (24 August 2023)
need to think on how I can effect performance improvements as
the script runs very slowly on files a couple of megabytes
in size.

foreach ($num in 1..10) {write-host '.' -NoNewline}

Write-Host $(Get-Date -Format 'dd-MMM-yyyy HH:mm:ss');
Get-Date -DisplayHint time

Custom date and time format strings
https://learn.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings?view=netframework-4.8

function Log-Message
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$LogMessage
    )

    Write-Output ("{0} - {1}" -f (Get-Date), $LogMessage)
}


$tyme = ('[{0:HH:mm:ss}]' -f (Get-Date))

#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false,
              HelpMessage='File to shred and delete')]
   [Object]
   $Path
) #end param

#-----------------------------------------------------
# Start of delegates
#-----------------------------------------------------

$Get_FileStream = [Func[System.IO.FileInfo,System.IO.FileStream]]{
param($FilePath)
<#
Get the input file stream based upon the file passed as
a parameter
#>
   Set-Variable -Name 'buffersize' -Value (1024 * 8) -Option Constant;

   #Specifies whether to use asynchronous I/O or synchronous I/O.
   Set-Variable -Name 'useAsync' -Value $true -Option Constant;

   $optionFlags = [System.IO.FileOptions]::Asynchronous + [System.IO.FileOptions]::WriteThrough;

   $myargs = @(
       #Constructor arguments
       $FilePath.FullName #path to the file in question
       [System.IO.FileMode]::Open #mode - FileMode
       [System.IO.FileAccess]::Write #access - FileAccess
       [System.IO.FileShare]::None #share - FileShare
       $buffersize
       $optionFlags
   )
   $parameters = @{
       #General parameters
       TypeName = 'System.IO.FileStream'
       ArgumentList = $myargs
   }
   $mystream = New-Object @parameters;  #splat example

   return $mystream;
} #end inStreamFunc

#------------------------------------------------------

[Predicate[System.IO.FileInfo]]$IsRubbishFile = {
<#
Determines whether the file supplied as a parameter is suitable
for us to work with. A terminating error is thrown is the file
is not fit for purpose.

Returns true if the file is not fit for purpose (ie a rubbish file);
otherwise, false.
#>
param($f)

$ErrorActionPreference = 'SilentlyContinue';

Set-Variable -Name 'retval' -Value $false -Option Constant;

$f.Refresh();

if (-not (Test-Path -Path $f -PathType 'Leaf')) {
    return $true;
}

if ($f.Length -eq 0) {
    return $true;
}

#If we get here, we're returning the default value
#of false indicating this is not a rubbish file.
return $retval;

} #returns true or false

#-----------------------------------------------------
# End of delegates
#-----------------------------------------------------

#-----------------------------------------------------
# Start of functions
#-----------------------------------------------------

#region ***** Function Get-Filename *****
function Get-Filename {
<#
.SYNOPSIS

Display the OpenFileDialog dialog box

.DESCRIPTION

Display the .NET class OpenFileDialog dialog box that prompts
the user to open a file which will eventually be securely
deleted

.PARAMETER Title

The title displayed on the dialog box window

.LINK

OpenFileDialog Class.
https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=netcore-3.1
#>

[CmdletBinding()]
Param(
   [parameter(Mandatory=$true,
              HelpMessage='ShowDialog box title')]
   [ValidateNotNullOrEmpty()]
   [String]$Title
) #end param

    begin {

      Add-Type -AssemblyName 'System.Windows.Forms';
      # Displays a standard dialog box that prompts the user
      # to open (select) a file that will eventually be
      # shredded.
      $ofd = [System.Windows.Forms.OpenFileDialog]::new();

      # The dialog box return value is OK (usually sent
      # from a button labeled OK). This indicates the
      # user has selected a file.
      $myok = [System.Windows.Forms.DialogResult]::OK;
      Set-Variable -Name 'myok' -Option ReadOnly;

      [String]$retFilename = '';

      $ofd.CheckFileExists = $true;
      $ofd.CheckPathExists = $true;
      $ofd.ShowHelp = $false;
      $ofd.Filter = 'Text files (*.txt)|*.txt|All files (*.*)|*.*';
      $ofd.FilterIndex = 1;
      $ofd.InitialDirectory = 'C:\gash';
      $ofd.Multiselect = $false;
      $ofd.RestoreDirectory = $false;
      $ofd.Title = $Title; # sets the file dialog box title
      $ofd.DefaultExt = 'txt';
      Set-Variable -Name 'ofd' -Option ReadOnly;

    }

    process {
      if ($ofd.ShowDialog() -eq $myok) {
         $retFilename = $ofd.FileName;
      } else {
         Throw 'No file chosen or selected';
      }
    }

    end {
      $ofd.Dispose();
      return $retFilename.Trim();
    }
}
#endregion ***** End of function Get-Filename *****

#-----------------------------------------------------

#region ***** Function Get-ErrorRecord *****
function Get-ErrorRecord {
<#
.SYNOPSIS

Create a type of ErrorRecord Class

.DESCRIPTION

Create an error record for the situation of when
the number of bytes written to the output stream
is not the number expected. Of course, this will
only be used if there is an I/O (write) error

.LINK

ErrorRecord Class
An ErrorRecord describes an error.
https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.errorrecord?view=powershellsdk-7.0.0
#>

  [CmdletBinding()]
  Param() #end param

  begin {
     $message = 'Invalid write error to FileStream';
     $myargs = @(
         #Constructor arguments
         'System.InvalidOperationException'::new($message); #exception
         'FileError'; #errorId
         [System.Management.Automation.ErrorCategory]::WriteError; #errorCategory
         'Output FileStream'; #targetObject
     )
     $parameters = @{
         #General parameters
         TypeName = 'System.Management.Automation.ErrorRecord'
         ArgumentList = $myargs
     }
     $errorRecord = New-Object @parameters;  #splat example
  }

  process {}

  end {
     return $errorRecord;
  }
}
#endregion ***** End of function Get-ErrorRecord *****

#-----------------------------------------------------

#region ***** function Confirm-Delete *****
function Confirm-Delete {
[CmdletBinding()]
[OutputType([System.Boolean])]
Param(
    [parameter(Mandatory=$true,
               HelpMessage='Confirm file deletion')]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]$FileName
) #end param

      begin {

        $retval = $false;
        # cDescription is an abbreviation for
        # 'System.Management.Automation.Host.ChoiceDescription'
        $cDescription = 'System.Management.Automation.Host.ChoiceDescription' -as [type];
        $caption = 'Remove file';
        $message = @"
Confirm
Are you sure you want to perform this action?
Performing the operation remove file on target $($FileName.FullName).
This action cannot be undone! Please make sure
"@ #end of 'message' variable
        Set-Variable -Name 'cDescription', 'caption', 'message' -Option ReadOnly;

        # Create a 'Collection' object of type
        # 'System.Management.Automation.Host.ChoiceDescription'
        # with the generic type of
        # 'System.Management.Automation.Host.ChoiceDescription'
        $choices = New-Object -TypeName "System.Collections.ObjectModel.Collection[$cDescription]";
        Set-Variable -Name 'defaultChoice' -Value 1 -Option Constant;

        $yes = $cDescription::new("&Yes"); # Label value
        $yes.HelpMessage = "Remove file";
        $choices.Add($yes);

        $no = $cDescription::new("&No"); # Label value
        $no.HelpMessage = "Ignore file";
        $choices.Add($no);

        $exit = $cDescription::new("&Exit"); # Label value
        $exit.HelpMessage = "Exit and do nothing";
        $choices.Add($exit);
      } #end of Begin block

      process {
        # https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshostuserinterface.promptforchoice?view=powershellsdk-7.0.0
        # Returns an 'Int32' value which is the index of the choices
        # element that corresponds to the option selected by the
        # user.
        $result = $Host.UI.PromptForChoice($caption, $message, $choices, $defaultChoice);

      }

      end {

       switch ($result) {
          0 {$retval = $true; break}  # Response yes
          1 {$retval = $false; break} # Response no
          2 {$retval = $false; break} # Response exit
          default {$retval = $false; break} # Default the response to no
       }

        return $retval;
      }
}
#endregion ***** end of function Confirm-Delete *****

#-----------------------------------------------------

#region ***** Function Delete-File *****
function Delete-File {

<#
.SYNOPSIS

Overwrite and delete the selected file

.DESCRIPTION

Overwrites the selected file with cryptographically strong
random numbers and delete the file with the PowerShell
cmdlet 'Remove-Item'. The file is overwritten a number of
times as determined by an outer 'foreach' loop.

The 'System.Security.Cryptography.RandomNumberGenerator'
class is used to generate the random numbers. Originally,
I was using the statement '$rng.GetBytes($ByteBuffer)'
to collect (generate) the random numbers. For some unknown
reason though, this failed to fill variable 'ByteBuffer'
with any data so this is why I'm now using the statement
$ByteBuffer = [System.Security.Cryptography.RandomNumberGenerator]::GetBytes($BufferLen);
I can only surmise that statement '$rng.GetBytes($ByteBuffer)'
was not happy at being executed in a 'Switch' statement.

.PARAMETER DeleteFile

The file which will be overwritten and deleted

.LINK

RandomNumberGenerator Class
https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.randomnumbergenerator?view=net-6.0
#>

[CmdletBinding()]
Param(
    [parameter(Mandatory=$true,
               HelpMessage='Filename to shred and delete')]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [System.IO.FileInfo]$DeleteFile
) #end param

    begin {

      $sw = [System.Diagnostics.Stopwatch]::new();
      Set-Variable -Name 'sw' -Option ReadOnly;
      $sw.Start();

      $DeleteFile.Refresh();

      [Byte]$PassCounter = 0;

      Set-Variable -Name 'BufferSize' -Value (1024 * 8) -Option Constant;

      # Clears buffers for this stream and causes any buffered data
      # to be written to the file, and also clears all intermediate
      # file buffers when using the 'Flush (bool flushToDisk)' method
      # with a boolean value of true.
      Set-Variable -Name 'flushToDisk' -Value $true -Option Constant;

      # Ensure the file is not read only before we attempt to
      # overwrite it.
      $DeleteFile.IsReadOnly = $false;

      $ByteBuffer = [System.Byte[]]::new($BufferSize);

      # Get the length in bytes of the stream we want to shred
      # and then delete
      [Long]$FileLength = $DeleteFile.Length;
      Set-Variable -Name 'FileLength' -Option ReadOnly;

      $deleteStream = $Get_FileStream.Invoke($DeleteFile);
      Write-Output "FileStream was opened asynchronously: $($deleteStream.IsAsync)";

      $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create();
      Set-Variable -Name 'rng' -Option ReadOnly;

      Write-Output ("Length of file to be overwritten: {0:N0} bytes" -f $FileLength);
      Write-Output ("Using a buffer size of: {0:N0} bytes" -f $BufferSize);

      # Keeps track of how many bytes have been written so far
      [Long]$BytesWritten = 0L;

      # Tells us how many bytes of the file stream we have left to overwrite
      [Long]$RemainingBytes = 0L;

      # Reminds us how many bytes should be written for each
      # execution of the 'FileStream.WriteAsync' Method. From this, we
      # can check that the correct number of bytes have been written.
      [Long]$ExpectedBytes = 0L;

      $FilePosition = [PSCustomObject]@{
        OldPos = 0L
        NewPos = 0L
      }

      $loopIndex = [PSCustomObject]@{
        Min = 1
        Max = 7
      }
      Set-Variable -Name 'loopIndex' -Option ReadOnly;

      # Indicates the task completed execution successfully.
      $ranOK = [System.Threading.Tasks.TaskStatus]::RanToCompletion;
      Set-Variable -Name 'ranOK' -Option ReadOnly;

      [System.Linq.Enumerable]::Repeat("", 2); #blanklines
      Write-Output 'This may take a while depending upon the file size. Please be patient...';
    } #end 'begin' block

    process {
     try {
        # Outer loop which determines how many times the file is
        # overwritten.
        foreach ($num in $loopIndex.Min..$loopIndex.Max) {

            # Set the current position of the stream to the beginning
            # of the stream before overwriting the file. Otherwise,
            # we'll end up extending the size of the file which we
            # don't want to do.
            $deleteStream.Position = 0;
            $PassCounter++;
           [System.Linq.Enumerable]::Repeat("", 2); #blanklines
           $tyme = '[{0:HH:mm:ss}]' -f (Get-Date)
           Write-Output ("{0} File overwrite pass #{1} / {2}" -f $tyme,$PassCounter,$loopIndex.Max);
           if ($PassCounter -eq $loopIndex.Max) {
             Write-Output 'Final pass';
           }

            $ByteBuffer.Clear()

            # Assign the content of 'ByteBuffer' for loop pass 1
            # (one) and loop pass 2 (two). The contents of 'ByteBuffer'
            # don't change for the first two loop passes once assigned,
            # so that's why we're assigning values at this point. The
            # whole file will be overwritten with either zeros or ones.
            # Loop pass #1: 'ByteBuffer' filled with zeros (0)
            # Loop pass #2: 'ByteBuffer' filled with ones (1)
            if ($PassCounter -eq 1) {
              [byte]$fillValue = 0;
            } elseif ($PassCounter -eq 2) {
              [byte]$fillValue = 1;
            }
            $ByteBuffer = for ($m = 0; $m -lt $BufferSize; $m++) { $fillValue }


            # Inner loop to write, buffer by buffer, to the output stream
            # and thus overwrite the file concerned.
            while ($BytesWritten -lt $FileLength) {
                #
                # Writes to the console to reassure the
                # user that the script is still running
                # as intended. This is especially
                # important when overwriting large files
                # as the process can take a long time.
                Write-Host '.' -NoNewline;
                $RemainingBytes = $FileLength - $BytesWritten;

                $FilePosition.OldPos = $deleteStream.Position;

                # On loop pass three and greater, 'ByteBuffer' is
                # filled with random bytes from class
                # System.Security.Cryptography.RandomNumberGenerator
                if ($PassCounter -ge 3) {
                  $ByteBuffer.Clear();
                  $ByteBuffer = $rng::GetBytes($BufferSize);
                }


                Write-Verbose -Message 'Random data refreshed. First eight bytes...';
                $VerboseMsg = ($ByteBuffer[0..7] |
                    ForEach-Object {Write-Output ("{0:X2}" -f $_)}) -join ' ';
                Write-Verbose -Message $VerboseMsg;

                if ($RemainingBytes -gt $BufferSize) {
                    # Write a full data buffer worth of data to the stream

                    $myTask = $deleteStream.WriteAsync($ByteBuffer, 0, $BufferSize);
                    $BytesWritten += $ByteBuffer.LongLength;
                    $ExpectedBytes = $BufferSize;
                } else {
                    # Write a partial data buffer to the stream because
                    # this is all we have left to write

                    $myTask = $deleteStream.WriteAsync($ByteBuffer, 0, $RemainingBytes);
                    $BytesWritten += $RemainingBytes;
                    $ExpectedBytes = $RemainingBytes;
                }

                # Wait here until the task finishes.
                # A call to the task Wait method blocks
                # the calling thread until the single
                # class instance has completed execution.
                $myTask.Wait();
                if ($myTask.Status -ne $ranOK) {
                   # throw an error
                   $splat = @{
                       # Splat data for use with Write-Error cmdlet.
                       Category = [System.Management.Automation.ErrorCategory]::InvalidResult;
                       CategoryActivity = 'Executing method <filestream>.WriteAsync';
                       CategoryReason = 'Unexpected result from WriteAsync Task';
                       Message = 'Unexpected TaskStatus from WriteAsync Task';
                   }
                   Write-Error @splat;

                } #end if statement

                $deleteStream.Flush($flushToDisk);
                Start-Sleep -Milliseconds 600;
                $FilePosition.NewPos = $deleteStream.Position;

                # Check the number of bytes is what we expected to write.
                # If not, throw a terminating error
                if ( ($FilePosition.NewPos - $FilePosition.OldPos) -ne $ExpectedBytes ) {
                     # I'd like to get the line number of the error
                     # statement and be able to write that to the
                     # screen so people will know which line the
                     # error was written from. Still working on
                     # this idea

                     $splat = @{
                         # Splat data for use with Write-Error cmdlet.
                         Category = [System.Management.Automation.ErrorCategory]::WriteError
                         CategoryActivity = 'Writing data to output file'
                         CategoryReason = 'Unexpected number of bytes written to output file'
                         Message = 'Unexpected number of bytes written'
                     }
                     Write-Error @splat;
                } #end if statement

                # If the write operation is successful, the position
                # within the file stream advances by the number of
                # bytes written. If an exception occurs, the
                # position within the file stream remains unchanged
                # and from this, we know there is a problem.
                $movement = $FilePosition.NewPos - $FilePosition.OldPos;
                $VerboseMsg = ('File position advanced by {0} bytes' -f $movement);
                Write-Verbose -Message $VerboseMsg;

            } #end inner while loop

            # Get ready for the next loop iteration
            $BytesWritten = 0L;
        } #end foreach outer loop

     } catch {
       Write-Error $_.Exception.Message;

     } finally {
       $deleteStream.Close();
       $deleteStream.Dispose();
       $rng.Dispose();

     } #end try/catch/finally block

    } #end 'process' block

    end {
       # Now we've overwritten the file with random bytes,
       # we can delete it
       Start-Sleep -Seconds 1;
       Remove-Item -Path $DeleteFile;
       $sw.Stop();

       # Confirm whether the file has been deleted as intended
       if (Test-Path -Path $DeleteFile -PathType 'Leaf') {
           Write-Warning -Message "Shredded file [$($DeleteFile)] not deleted";
       } else {
           [System.Linq.Enumerable]::Repeat('', 2); #blanklines
           Write-Output "Shredded file [$($DeleteFile)] deleted as intended";
           Write-Output 'Elapsed time:'
           $sw.Elapsed | Format-Table -Property Hours, Minutes, Seconds -AutoSize;

       }

       Remove-Variable -Name 'ByteBuffer' -Force;
    } #end 'end' block
}
#endregion ***** End of function Delete-File *****

#-----------------------------------------------------
# End of functions
#-----------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Secure deletion of file';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}


#'MyFile' will be of type 'System.IO.FileInfo' when we exit
#this if/elseif/else block.
if ($Path -is [String]) {
    Write-Verbose 'The main parameter is of type string';
    $MyFile = Get-Item (Resolve-Path -Path $Path);

} elseif ($Path -is [System.IO.FileInfo]) {
    Write-Verbose 'The main parameter is of type FileInfo';
    $MyFile = $Path;

} else {
    #No value has been supplied. Invoke an internal function
    #to get the filename to shred
    Write-Verbose 'Nothing passed in';
    $m = Get-Filename -Title 'Filename to shred/delete';
    $MyFile = Get-Item $m;
}

#Ensure the object (file) to work with is fit for purpose. If
#not, throw a terminating error
if ($IsRubbishFile.Invoke($MyFile)) {
  $splat = @{
      # Splat data for use with Write-Error cmdlet.
      Message = 'File not found or empty file'
      Category = 'InvalidResult'
      ErrorId = 'ERR-0001'
      CategoryActivity = "Checking input file [$($MyFile)]"
      CategoryTargetName = "File: $MyFile"
      CategoryTargetType = 'File'
      RecommendedAction = 'Ensure input file exists and is not empty'
      ErrorAction = 'Stop'
  }
  Write-Error @splat;

}


Write-Verbose -Message "File selected for shred/delete is |$MyFile|";
if (Confirm-Delete -FileName $MyFile) {


# As part of the obfuscation process, rename the file in
# question with a random file name obtained from the
# method [System.Io.Path]::GetRandomFileName.
$randomFilename = [System.Io.Path]::GetRandomFileName();
$shredFilename = Join-Path -Path $MyFile.DirectoryName -ChildPath $randomFilename;
Set-Variable -Name 'shredFilename' -Option ReadOnly;

$message = @"

Renaming original file:
[$($MyFile)]
to:
[$($shredFilename)]
"@
Write-Output $message;
Rename-Item -Path $MyFile -NewName $shredFilename;

   Delete-File -DeleteFile $shredFilename;

} else {

    Write-Warning -Message "File $($MyFile) not deleted at user request";

}
Write-Output 'All done now';
##=============================================
## END OF SCRIPT: Secure-Delete.ps1
##=============================================
