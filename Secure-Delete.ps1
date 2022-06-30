<#
.SYNOPSIS

Securely delete a file.

.DESCRIPTION

Securely deletes a file by overwriting the file several times
with a cryptographically strong sequence of random byte values.
Each iteration uses a different value of bytes which are
obtained from the method 'RNGCryptoServiceProvider.GetBytes'.

After the file has been overwritten, it's then deleted using the
PowerShell cmdlet Remove-Item.

The path to the file can be passed to the parameter as a string
or a 'System.IO.FileInfo' object.

.PARAMETER Path
The file which will be overwritten and then deleted

.EXAMPLE

./Secure-Delete.ps1

As no parameter has been supplied, an internal function will
invoke the 'System.Windows.Forms.OpenFileDialog' class which
prompts the user to select a file to shred and delete.

.EXAMPLE

./Secure-Delete.ps1 'C:\Gash\speak.ps1'

The string containing the path to the file is passed as a
positional parameter.

.EXAMPLE

./Secure-Delete.ps1 -Path 'C:\Gash\speak.ps1'

Using a named parameter to pass the path of the file concerned.

.EXAMPLE

./Secure-Delete.ps1 $file

The path to the file is passed as a positional parameter via
the contents of variable 'file'. Variable file can be of type
string or a System.IO.FileInfo object. This can be achieved
with the following assignments:

$file = 'C:\Gash\myfile.ps1'
or
$file = Get-Item 'myfile.ps1'

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

None, no .NET Framework types of objects are used as input.

.OUTPUTS

None, no .NET Framework types of objects are output from this script.

.NOTES

File Name    : Secure-Delete.ps1
Author       : Ian Molloy
Last updated : 2022-06-30T11:10:33
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

7 Effective Algorithms to Remove Files and Folders Permanently
https://www.stellarinfo.com/article/7-algorithms-to-wipe-files-folders-permanently.php
#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false,
              HelpMessage="File to shred and delete")]
   [Object]
   $Path
) #end param

#-----------------------------------------------------
# Start of delegates
#-----------------------------------------------------

$Get_FileStream = [Func[System.IO.FileInfo,System.IO.FileStream]]{
param($FilePath)
<#
Get the input file stream which will be overwritten and then
eventually deleted.
#>
   $buffersize = 8KB;
   $myargs = @(
       #Constructor arguments
       $FilePath.FullName.ToString() #path
       [System.IO.FileMode]::Open #mode - FileMode
       [System.IO.FileAccess]::Write #access - FileAccess
       [System.IO.FileShare]::None #share - FileShare
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

Returns true if the file is not fit for purpose (a rubbish file);
otherwise, false.
#>
param($f)

$ErrorActionPreference = 'SilentlyContinue';
$retval = $false;
Set-Variable -Name 'retval' -Option ReadOnly;

$m = [String]::IsNullOrWhiteSpace($f);
if ($m) {
    return $true;
}

if (-not (Test-Path -Path $f -PathType 'Leaf')) {
    return $true;
}

$item = Get-Item -Path $f;
if ($item.Length -eq 0) {
    return $true;
}

return $retval
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
  Param (
     [parameter(Mandatory=$true,
                HelpMessage="ShowDialog box title")]
     [ValidateNotNullOrEmpty()]
     [String]$Title
  ) #end param

  begin {

    Add-Type -AssemblyName "System.Windows.Forms";
    # Displays a standard dialog box that prompts the user
    # to open (select) a file that will eventually be
    # shredded.
    [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog';

    # The dialog box return value is OK (usually sent
    # from a button labeled OK). This indicates the
    # user has selected a file.
    $myok = [System.Windows.Forms.DialogResult]::OK;
    [String]$retFilename = "";

    $ofd.CheckFileExists = $true;
    $ofd.CheckPathExists = $true;
    $ofd.ShowHelp = $false;
    $ofd.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*";
    $ofd.FilterIndex = 1;
    $ofd.InitialDirectory = "C:\Family\Ian";
    $ofd.Multiselect = $false;
    $ofd.RestoreDirectory = $false;
    $ofd.Title = $Title; # sets the file dialog box title
    $ofd.DefaultExt = "txt";
    Set-Variable -Name 'myok', 'ofd' -Option ReadOnly;

  }

  process {
    if ($ofd.ShowDialog() -eq $myok) {
       $retFilename = $ofd.FileName;
    } else {
       Throw "No file chosen or selected";
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
     $message = "Invalid write error to FileStream";
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
Param (
    [parameter(Mandatory=$true,
               HelpMessage="Confirm file deletion")]
    [ValidateNotNullOrEmpty()]
    [String]$FileName
) #end param

      begin {

        $retval = $false;
        # cDescription is an abbreviation for
        # 'System.Management.Automation.Host.ChoiceDescription'
        $cDescription = 'System.Management.Automation.Host.ChoiceDescription' -as [type];
        $caption = "Remove file";
        $message = @"
Confirm
Are you sure you want to perform this action?
Performing the operation remove file on target $($FileName).
This action cannot be undone! Please make sure
"@ #end of 'message' variable
        Set-Variable -Name 'cDescription', 'caption', 'message' -Option ReadOnly;

        # Create a 'Collection' object of type
        # 'System.Management.Automation.Host.ChoiceDescription'
        # with the generic type of
        # 'System.Management.Automation.Host.ChoiceDescription'
        $choices = New-Object -TypeName "System.Collections.ObjectModel.Collection[$cDescription]";
        $defaultChoice = 1;

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
        $result = $host.ui.PromptForChoice($caption, $message, $choices, $defaultChoice);

      }

      end {

       switch ($result) {
          0 {$retval = $true; break}  # Response yes
          1 {$retval = $false; break} # Response no
          2 {$retval = $false; break} # Response exit
          default {$retval = $false; break} # Default to no
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

  .PARAMETER FileName

  The file which will be overwritten and deleted

  .LINK

  RandomNumberGenerator Class
  https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.randomnumbergenerator?view=net-6.0
  #>

[CmdletBinding()]
Param (
    [parameter(Mandatory=$true,
               HelpMessage="Filename to shred and delete")]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [String]$FileName
) #end param

    begin {
      [Byte]$PassCounter = 0;
      $BufferSize = 8KB;
      $ByteBuffer = [System.Byte[]]::new($BufferSize);
      $BufferLen = $ByteBuffer.Length;
      $ShredFile = Get-Item -Path $FileName;
      # Ensure the file is not read only before we attempt to
      # overwrite it.
      $ShredFile.IsReadOnly = $false;

      $deleteStream = $Get_FileStream.Invoke($ShredFile);
      $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create();
      Set-Variable -Name 'BufferSize', 'BufferLen', 'ShredFile', 'rng' -Option ReadOnly;

      # Get the length in bytes of the stream we want to shred
      # and then delete
      [Long]$FileLength = $ShredFile.Length;
      # Keeps track of how many bytes have been written so far
      [Long]$BytesWritten = 0L;
      # Tells us how many bytes of the file stream we have left to overwrite
      [Long]$RemainingBytes = 0L;
      Set-Variable -Name 'FileLength' -Option ReadOnly;
      Write-Output ("Length of file to be overwritten: {0:N0} bytes" -f $FileLength);
      # Reminds us how many bytes should be written for each
      # execution of the FileStream.Write Method. From this, we
      # can check that the correct number of bytes have been written.
      [Long]$ExpectedBytes = 0L;

      $FilePosition = [PSCustomObject]@{
        OldPos = 0L
        NewPos = 0L
      }

    } #end 'begin' block

    process {
     try {
        # Outer loop which determines how many times the file is
        # overwritten.
        foreach ($num in 1..7) {
            # Set the current position of the stream to the beginning
            # of the stream before overwriting the file. Otherwise,
            # we'll end up extending the size of the file which we
            # don't want to do.
            $deleteStream.Position = 0;
            $PassCounter++;
            Write-Output ("`nFile overwrite pass #{0}" -f $PassCounter);

            # Inner loop to write, buffer by buffer, to the output stream
            # and thus overwrite the file concerned.
            while ($BytesWritten -lt $FileLength) {
                #
                $RemainingBytes = $FileLength - $BytesWritten;
                $ByteBuffer.Clear();

                $FilePosition.OldPos = $deleteStream.Position;

                Switch ( $PassCounter ) {
                  1 { Write-Verbose 'option 1';
                      $ByteBuffer = ,0 * $BufferLen;
                      break; }
                  2 { Write-Verbose 'option 2';
                      $ByteBuffer = ,1 * $BufferLen;
                      break; }
                  default { Write-Verbose 'option default';
  $ByteBuffer = [System.Security.Cryptography.RandomNumberGenerator]::GetBytes($BufferLen);
                            break; }
                  } #end switch

                Write-Verbose -Message 'Random data refreshed. First four bytes...';
                $VerboseMsg = ($ByteBuffer[0..3] |
                    ForEach-Object {Write-Output ("{0:X2}" -f $_)}) -join ' ';
                Write-Verbose -Message $VerboseMsg;

                if ($RemainingBytes -gt $BufferLen) {
                    # Write a full data buffer worth of data to the stream
                    $deleteStream.Write($ByteBuffer, 0, $BufferLen);
                    $BytesWritten += $ByteBuffer.LongLength;
                    $ExpectedBytes = $BufferLen;
                } else {
                    # Write a partial data buffer to the stream because
                    # this is all we have left to write
                    $deleteStream.Write($ByteBuffer, 0, $RemainingBytes);
                    $BytesWritten += $RemainingBytes;
                    $ExpectedBytes = $RemainingBytes;
                }

                $deleteStream.Flush();
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
                # position within the file stream remains unchanged.
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
       $deleteStream.Flush();
       $deleteStream.Close();
       $deleteStream.Dispose();
       $rng.Dispose();

     } #end try/catch/finally block

    } #end 'process' block

    end {
       # Now we've overwritten the file with random bytes,
       # we can delete it
       Remove-Item -Path $ShredFile -Force;

       # Confirm to the user whether the file has been deleted as intended
       if (Test-Path -Path $ShredFile -PathType 'Leaf') {
         Write-Warning -Message "Shredded file [$($ShredFile)] not deleted";
       } else {
         Write-Output "Shredded file [$($ShredFile)] deleted as intended";
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
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Secure deletion of file';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}


#Extract the filename to shred from the parameter (if supplied)
if ($Path -is [String]) {
    Write-Verbose 'The main parameter is a string';
    $MyFile = Resolve-Path -Path $Path;

} elseif ($Path -is [System.IO.FileInfo]) {
    Write-Verbose 'The main parameter is FileInfo';
    $MyFile = $Path.FullName;

} else {
    #No value has been supplied. Invoke an internal function
    #to get the filename
    Write-Verbose 'Not sure what the type of the main parameter is';
    $MyFile = Get-Filename -Title 'Filename to shred/delete';
}


#Ensure the object (file) to work with is fit for purpose. If
#not, throw a terminating error
if ($IsRubbishFile.Invoke($MyFile)) {
  $splat = @{
      # Splat data for use with Write-Error cmdlet.
      Message = 'File not found or empty file'
      Category = 'InvalidResult'
      ErrorId = 'ERR-0001'
      CategoryActivity = 'Checking input file'
      CategoryTargetName = "File: $MyFile"
      CategoryTargetType = 'File'
      RecommendedAction = 'Ensure input file exists and is not empty'
      ErrorAction = 'Stop'
  }
  Write-Error @splat;

}


Write-Verbose -Message "File selected for shred/delete is |$MyFile|";
if (Confirm-Delete -FileName $MyFile) {
# -----
$newFilename = [System.Io.Path]::GetRandomFileName();
$dest = Join-Path -Path $Env:Temp -ChildPath $newFilename;

# As part of the obfuscation process, move and rename the file
# in question to the temporary folder defined by the environment
# variable $Env:Temp with a random file name obtained from the
# method [System.Io.Path]::GetRandomFileName.
#
# about_Environment_Variables
# Describes how to access and manage environment variables
# in PowerShell.
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.2
$msg = @"

New derived filename: [$($newFilename)]

Renaming original file:
[$($MyFile)]
to:
[$($dest)]
"@
Write-Output $msg;
Move-Item -Path $MyFile -Destination $dest;

   Delete-File -FileName $dest;
} else {
   Write-Warning -Message "File $($MyFile) not deleted at user request";
}
Write-Output 'Script complete';
##=============================================
## END OF SCRIPT: Secure-Delete.ps1
##=============================================
