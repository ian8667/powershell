<#
.SYNOPSIS

Securely delete a file.

.DESCRIPTION

Securely deletes a file by overwriting the file several times with a
cryptographically strong sequence of random byte values. Each iteration
uses a different value of bytes which are obtained from the method
RNGCryptoServiceProvider.GetBytes.

After the file has been overwritten, it's then deleted using the
PowerShell Remove-Variable cmdlet.

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
Last updated : 2018-12-25

.LINK

RNGCryptoServiceProvider Class
Implements a cryptographic Random Number Generator (RNG) using the
implementation provided by the cryptographic service provider (CSP).
https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.rngcryptoserviceprovider?view=netframework-4.7.2

#>

[CmdletBinding()]
Param () #end param

#region ********** Function Get-Filename **********
function Get-Filename() {
    [CmdletBinding()]
    Param (
            [parameter(Mandatory=$true,
                       HelpMessage="ShowDialog box title")]
            [ValidateNotNullOrEmpty()]
            [String]$Title
          ) #end param

    BEGIN {
      Write-Verbose -Message "Invoking function to obtain the filename to delete";

      Add-Type -AssemblyName "System.Windows.Forms";
      [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog';

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

    PROCESS {
       if ($ofd.ShowDialog() -eq $myok) {
          $retFilename = $ofd.FileName;
       } else {
          Throw "No file chosen or selected";
       }
    }

    END {
      $ofd.Dispose();
      return $retFilename;
    }
}
#endregion ********** End of function Get-Filename **********

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

  BEGIN {
   Add-Type -AssemblyName "System.Windows.Forms";

   $msg = @"
    Confirm
    Are you sure you want to perform this action?

    Performing the operation 'Remove File' on target $($FileName).

    This action cannot be undone!
"@

   $yesnocancel = [System.Windows.Forms.MessageBoxButtons]::YesNoCancel;
   $warning = [System.Windows.Forms.MessageBoxIcon]::Warning;
   $default = [System.Windows.Forms.MessageBoxDefaultButton]::Button3
   $retval = $false;
  }

  PROCESS {

   $result = [System.Windows.Forms.MessageBox]::Show($msg, `
                 'Delete file', `
                 $YesNoCancel, `
                 $warning, `
                 $default);
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
       $retval = $true;
    }

  }

  END {

    return $retval;

  }
  }
  #endregion ***** end of function Confirm-Delete *****

  #region ********** Function Delete-File **********
function Delete-File {
    [CmdletBinding()]
    Param (
            [parameter(Mandatory=$true,
                       HelpMessage="Filename to delete")]
            [ValidateNotNullOrEmpty()]
            [String]$FileName
          ) #end param

    BEGIN {
      $fileLen = (Get-ChildItem -Path $FileName).Length;
      $byteArray = New-Object -TypeName Byte[] -ArgumentList $fileLen;
      $rng = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider';

    }

    PROCESS {
     try {

       foreach ($num in 1..3) {

          $rng.GetBytes($byteArray);
          [System.IO.File]::WriteAllBytes($FileName, $byteArray);

       } #end foreach loop

       Remove-Item -Path $FileName -Force;
       #[System.IO.File]::Delete($FileName);

     } catch {
       Write-Host $_.Exception.Message -ForegroundColor Green
     } finally {
       $rng.Dispose();

     }

    }

    END {
      Remove-Variable -Name fileLen, byteArray -Force;
    }
}
#endregion ********** End of function Delete-File **********

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

$Path = Get-Filename 'Filename to delete';
if (Confirm-Delete $Path) {
  Delete-File $Path;
} else {
  Write-Warning -Message "File $($Path) not deleted at user request";
}

##=============================================
## END OF SCRIPT: Secure-Delete.ps1
##=============================================
