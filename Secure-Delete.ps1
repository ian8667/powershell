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
Last updated : 2020-06-18T22:05:27
Keywords     : yes no yesno

.LINK

RNGCryptoServiceProvider Class
Implements a cryptographic Random Number Generator (RNG) using the
implementation provided by the cryptographic service provider (CSP).
https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.rngcryptoserviceprovider?view=netframework-4.7.2

#>

[CmdletBinding()]
Param() #end param

#region ***** Function Get-Filename *****
function Get-Filename {
  <#
  .SYNOPSIS

  Display the OpenFileDialog dialog box

  .DESCRIPTION

  Display the .NET class OpenFileDialog dialog box that prompts
  the user to open a C# file to compile

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
    Write-Verbose -Message "Invoking function to obtain the C# filename to compile";

    Add-Type -AssemblyName "System.Windows.Forms";
    # Displays a standard dialog box that prompts the user
    # to open (select) a file.
    [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

    # The dialog box return value is OK (usually sent
    # from a button labeled OK). This indicates the
    # user has selected a file.
    $myok = [System.Windows.Forms.DialogResult]::OK;
    $retFilename = "";
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
    return $retFilename;
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
               HelpMessage="Filename about to be deleted")]
    [ValidateNotNullOrEmpty()]
    [String]$FileName
) #end param

  Begin {
   $retval = $false;
   $title = "Remove file";
   $yes = New-Object -TypeName 'System.Management.Automation.Host.ChoiceDescription' "&Yes", `
          "Remove file";
   $no = New-Object -TypeName 'System.Management.Automation.Host.ChoiceDescription' "&No", `
         "Ignore file";

   $msg = @"
Confirm
Are you sure you want to perform this action?

Performing the operation 'Remove File' on target $($FileName).

This action cannot be undone! Please make sure
"@
  }

  Process {

   $options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes);

   $result = $host.ui.PromptForChoice($title, $msg, $options, 0);

  }

  End {

   switch ($result) {
      0 {$retval = $false; break}  # Response no
      1 {$retval = $true; break}   # Response yes
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
               HelpMessage="Filename to delete")]
    [ValidateNotNullOrEmpty()]
    [String]$FileName
) #end param

    Begin {
      Write-Output "Deleting file $($FileName)";
      $objectFile = Get-Item -Path $FileName;
      $fileLen = $objectFile.Length;
      $objectFile.IsReadOnly = $false;
      $byteArray = New-Object -TypeName Byte[] -ArgumentList $fileLen;
      $rng = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider';

    }

    Process {
     try {

       foreach ($num in 1..3) {

          $rng.GetBytes($byteArray);
          [System.IO.File]::WriteAllBytes($FileName, $byteArray);

       } #end foreach loop

       # Now we've overwritten the file, delete it
       Remove-Item -Path $FileName -Force;

     } catch {
       Write-Host $_.Exception.Message -ForegroundColor Green
     } finally {
       $rng.Dispose();

       # Confirm to the user whether the file has been deleted as intended
       if (Test-Path -Path $FileName) {
         Write-Warning -Message "File $($FileName) not deleted";
       } else {
         Write-Output "File $($FileName) deleted as intended";
       }
     } #end try/catch/finally block

    }

    End {
      Remove-Variable -Name fileLen, byteArray -Force;
    }
}
#endregion ***** End of function Delete-File *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output ('Today is {0:dddd, dd MMMM yyyy}' -f (Get-Date));
   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script, $scriptPath);

}

# Get the filename to delete
$Path = Get-Filename -Title 'Filename to delete';
if (Confirm-Delete $Path) {
   Delete-File $Path;
} else {
   Write-Warning -Message "`nFile $($Path) not deleted at user request";
}

##=============================================
## END OF SCRIPT: Secure-Delete.ps1
##=============================================
