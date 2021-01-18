<#
.SYNOPSIS

Securely delete a file.

.DESCRIPTION

Securely deletes a file by overwriting the file several times with a
cryptographically strong sequence of random byte values. Each iteration
uses a different value of bytes which are obtained from the method
RNGCryptoServiceProvider.GetBytes.

After the file has been overwritten, it's then deleted using the
PowerShell cmdlet Remove-Item.

.EXAMPLE

./Secure-Delete.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

None, no .NET Framework types of objects are output from this script.

.NOTES

File Name    : Secure-Delete.ps1
Author       : Ian Molloy
Last updated : 2021-01-18T12:54:47
Keywords     : yes no yesno

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
Param() #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** Function Get-Filename *****
function Get-Filename {
  <#
  .SYNOPSIS

  Display the OpenFileDialog dialog box

  .DESCRIPTION

  Display the .NET class OpenFileDialog dialog box that prompts
  the user to open a file to which will be securely deleted

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

#------------------------------------------------------------------------------

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
"@ #end of message variable
        # Create a 'Collection' object of type
        # 'System.Management.Automation.Host.ChoiceDescription'
        # with the generic type of
        # 'System.Management.Automation.Host.ChoiceDescription'
        $choices = New-Object -typeName "System.Collections.ObjectModel.Collection[$cDescription]";
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

#------------------------------------------------------------------------------

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
      $ShredFile.IsReadOnly = $false;

      $fos = New-Object -TypeName System.IO.FileStream($ShredFile, 'OPEN', 'Write', 'None');
      $rng = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider';
      Set-Variable -Name 'BufferSize', 'BufferLen', 'ShredFile', 'rng' -Option ReadOnly;

      [Long]$FileLength = $ShredFile.Length;
      [Long]$BytesWritten = 0L;
      [Long]$RemainingBytes = 0L;
      Set-Variable -Name 'FileLength' -Option ReadOnly;
      Write-Verbose -Message "Length of file to be overwritten: $FileLength bytes";

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
            $fos.Position = 0;
            $PassCounter++;
            Write-Output "`nFile overwrite pass# $PassCounter";

            # Inner loop to write, buffer by buffer, to the output stream
            while ($BytesWritten -lt $FileLength) {
                #
                $RemainingBytes = $FileLength - $BytesWritten;
                $rng.GetBytes($DataBuffer);
                Write-Verbose  'Random data refreshed. First four bytes...';
                $VerboseMsg = ($DataBuffer[0..3] | ForEach-Object {Write-Output ("{0:X2}" -f $_)}) -join ' ';
                Write-Verbose -Message $VerboseMsg

                if ($RemainingBytes -gt $BufferLen) {
                    # Write a full buffer worth of data to the stream
                    $fos.Write($DataBuffer, 0, $BufferLen);
                    $BytesWritten += $DataBuffer.LongLength;
                } else {
                    # Write a partial buffer to the stream because
                    # this is all we have left
                    $fos.Write($DataBuffer, 0, $RemainingBytes);
                    $BytesWritten += $RemainingBytes;
                }

                $fos.Flush();

            } #end while loop

            $BytesWritten = 0L;
        } #end foreach loop

     } catch {
       Write-Host $_.Exception.Message -ForegroundColor Green
     } finally {
       $fos.Flush();
       $fos.Close();
       $rng.Dispose();

       # Now we've overwritten the file, delete it
       Remove-Item -Path $FileName -Force -Verbose;

       # Confirm to the user whether the file has been deleted as intended
       if (Test-Path -Path $FileName) {
         Write-Warning -Message "Shredded file $($FileName) not deleted";
       } else {
         Write-Output "Shredded file $($FileName) deleted as intended";
       }
     } #end try/catch/finally block

    }

    End {
      Remove-Variable -Name 'DataBuffer' -Force;
    }
}
#endregion ***** End of function Delete-File *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

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

# Get the filename to shred and delete
[String]$MyFile = Get-Filename -Title 'Filename to shred/delete';
Write-Verbose -Message "File selected for shred/delete is |$MyFile|";
if (Confirm-Delete -FileName $MyFile) {
   Delete-File -FileName $MyFile;
} else {
   Write-Warning -Message "File $($MyFile) not deleted at user request";
}

##=============================================
## END OF SCRIPT: Secure-Delete.ps1
##=============================================
