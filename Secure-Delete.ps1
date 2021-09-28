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

./Secure-Delete.ps1 -ShredFile 'C:\Gash\speak.ps1'

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

./Secure-Delete.ps1 -ShredFile $file

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
Last updated : 2021-09-28T22:38:30
Keywords     : yes no yesno secure shred delete

See also
NIST SP 800-88 R1, Guidelines for Media Sanitization

DoD 5220.22-M National Industrial Security Program
Operating Manual (NISPOM)

.LINK

RNGCryptoServiceProvider Class
Implements a cryptographic Random Number Generator (RNG) using the
implementation provided by the cryptographic service provider (CSP).
https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.rngcryptoserviceprovider?view=netframework-4.7.2

#>

#Search term: how to download a file with powershell from the web
#How to Download a File with PowerShell from the Web
#https://adamtheautomator.com/powershell-download-file/

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [Object]
   $ShredFile
) #end param

#-----------------------------------------------------
# Start of delegates
#-----------------------------------------------------

$Get_FileStream = [Func[System.IO.FileInfo,System.IO.FileStream]]{
param($FilePath)
<#
Get the input file stream which will be overwritten and then deleted.
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
  the user to open a file which will be securely deleted

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

  Begin {

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

  Process {
    if ($ofd.ShowDialog() -eq $myok) {
       $retFilename = $ofd.FileName;
    } else {
       Throw "No file chosen or selected";
    }
  }

  End {
    $ofd.Dispose();
    return $retFilename.Trim();
  }
}
#endregion ***** End of function Get-Filename *****

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

      Begin {

        $retval = $false;
        $cDescription = 'System.Management.Automation.Host.ChoiceDescription' -as [type];
        $caption = "Remove file";
        $message = @"
Confirm
Are you sure you want to perform this action?
Performing the operation remove file on target $($FileName).
This action cannot be undone! Please make sure
"@ #end of 'message' variable
        Set-Variable -Name 'cDescription', 'caption', 'message' -Option ReadOnly

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

      Process {
        # https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshostuserinterface.promptforchoice?view=powershellsdk-7.0.0
        # Returns an 'Int32' value which is the index of the choices
        # element that corresponds to the option selected by the
        # user.
        $result = $host.ui.PromptForChoice($caption, $message, $choices, $defaultChoice)

      }

      End {

       switch ($result) {
          0 {$retval = $true; break}  # Response yes
          1 {$retval = $false; break} # Response no
          2 {$retval = $false; break} # Response exit
       }

        return $retval;
      }
}
#endregion ***** end of function Confirm-Delete *****

#-----------------------------------------------------

#region ***** Function Delete-File *****
function Delete-File {
[CmdletBinding()]
Param (
    [parameter(Mandatory=$true,
               HelpMessage="Filename to shred and delete")]
    [ValidateNotNullOrEmpty()]
    [String]$FileName
) #end param

    Begin {
      [Byte]$PassCounter = 0;
      $BufferSize = 8KB;
      $DataBuffer = [System.Byte[]]::new($BufferSize);
      $BufferLen = $DataBuffer.Length;
      $ShredFile = Get-Item -Path $FileName;
      # Ensure the file is not read only before we attempt to
      # overwrite it.
      $ShredFile.IsReadOnly = $false;

      $deleteStream = $Get_FileStream.Invoke($ShredFile);
      $rng = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider';
      Set-Variable -Name 'BufferSize', 'BufferLen', 'ShredFile', 'rng' -Option ReadOnly;

      [Long]$FileLength = $ShredFile.Length;
      [Long]$BytesWritten = 0L;
      [Long]$RemainingBytes = 0L;
      Set-Variable -Name 'FileLength' -Option ReadOnly;
      Write-Output ("Length of file to be overwritten: {0:N0} bytes" -f $FileLength);

    }

    Process {
     try {

        # Outer loop which determines how many times the file is
        # overwritten.
        foreach ($num in 1..5) {
            # Set the current position of the stream to the beginning
            # of the stream before overwriting the file. Otherwise,
            # we'll end up extending the size of the file which we
            # don't want to do.
            $deleteStream.Position = 0;
            $PassCounter++;
            Write-Output ("`nFile overwrite pass #{0}" -f $PassCounter);

            # Inner loop to write, buffer by buffer, to the output stream
            # and thus overwrite the file.
            while ($BytesWritten -lt $FileLength) {
                #
                $RemainingBytes = $FileLength - $BytesWritten;
                $rng.GetBytes($DataBuffer);
                Write-Verbose -Message 'Random data refreshed. First four bytes...';
                $VerboseMsg = ($DataBuffer[0..3] | ForEach-Object {Write-Output ("{0:X2}" -f $_)}) -join ' ';
                Write-Verbose -Message $VerboseMsg

                if ($RemainingBytes -gt $BufferLen) {
                    # Write a full buffer worth of data to the stream
                    $deleteStream.Write($DataBuffer, 0, $BufferLen);
                    $BytesWritten += $DataBuffer.LongLength;
                } else {
                    # Write a partial buffer to the stream because
                    # this is all we have left
                    $deleteStream.Write($DataBuffer, 0, $RemainingBytes);
                    $BytesWritten += $RemainingBytes;
                }

                $deleteStream.Flush();

            } #end inner while loop

            $BytesWritten = 0L;
        } #end foreach outer loop

     } catch {
       Write-Host $_.Exception.Message -ForegroundColor Green;
     } finally {
       $deleteStream.Flush();
       $deleteStream.Close();
       $deleteStream.Dispose();
       $rng.Dispose();

       # Now we've overwritten the file, delete it
       Remove-Item -Path $FileName -Force;

       # Confirm to the user whether the file has been deleted as intended
       if (Test-Path -Path $FileName) {
         Write-Warning -Message "Shredded file [$($FileName)] not deleted";
       } else {
         Write-Output "Shredded file [$($FileName)] deleted as intended";
       }
     } #end try/catch/finally block

    }

    End {
      Remove-Variable -Name 'DataBuffer' -Force;
    }
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

#Extract the filename to shred from the parameter
if ($ShredFile -is [String]) {
    Write-Verbose 'The main parameter is a string';
    $MyFile = Resolve-Path -Path $ShredFile;

} elseif ($ShredFile -is [System.IO.FileInfo]) {
    Write-Verbose 'The main parameter is FileInfo';
    $MyFile = $ShredFile.FullName;

} else {
    #No value has been supplied
    Write-Verbose 'Not sure what the type of the main parameter is';
    $MyFile = Get-Filename -Title 'Filename to shred/delete';
}

Write-Verbose -Message "File selected for shred/delete is |$MyFile|";
if (Confirm-Delete -FileName $MyFile) {
   Delete-File -FileName $MyFile;
} else {
   Write-Warning -Message "File $($MyFile) not deleted at user request";
}

##=============================================
## END OF SCRIPT: Secure-Delete.ps1
##=============================================
