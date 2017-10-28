<#
.SYNOPSIS

Copies a file and inserts the current date/time partway through
the name of the copied file.

.DESCRIPTION

By copying a file and inserting the current date/time partway through
the name of the copied file, a 'backup copy' is made of the original
file. This means we can make amendments to the original file and have
a backup copy should we have the need to revert to it. The date and
time show when the file was copied and by having a time component, we
can make more than one copy per day.

.EXAMPLE

./DateCopy-File.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : DateCopy-File.ps1
Author       : Ian Molloy
Last updated : 2017-10-28

.LINK

Date and time format - ISO 8601
https://www.iso.org/iso-8601-date-and-time-format.html

ISO 8601 Data elements and interchange formats
https://en.wikipedia.org/wiki/ISO_8601

Namespace:   System.IO.Path Class
https://msdn.microsoft.com/en-us/library/system.io.path(v=vs.110).aspx

Microsoft.PowerShell.Management
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/?view=powershell-5.1

Online notepad
http://www.rapidtables.com/tools/notepad.htm

#>

[CmdletBinding()]
Param () #end param

#region ********** Function Get-NewFilename **********
#* Function: Get-NewFilename
#* Last modified: 2017-10-22
#* Author: Ian Molloy
#*
#* Arguments:
#* title - the title displayed on the dialog box window.
#*
#* See also:
#* OpenFileDialog Class.
#* http://msdn.microsoft.com/en-us/library/system.windows.forms.openfiledialog.aspx
#* =============================================
#* Purpose:
#* Displays a standard dialog box that prompts
#* the user to select a filename.
#* =============================================
function Get-NewFilename() {
[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="ShowDialog box title")]
        [ValidateNotNullOrEmpty()]
        [String]$title
      ) #end param

BEGIN {
  Write-Verbose -Message "Invoking function to obtain the to date copy";

  Add-Type -AssemblyName "System.Windows.Forms";
  [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

  $myok = [System.Windows.Forms.DialogResult]::OK;
  $retFilename = "";
  $ofd.AddExtension = $false;
  $ofd.CheckFileExists = $true;
  $ofd.CheckPathExists = $true;
  $ofd.ShowHelp = $false;
  $ofd.InitialDirectory = "C:\Family\powershell";
  $ofd.Multiselect = $false;
  $ofd.RestoreDirectory = $false;
  $ofd.Title = $title; # sets the file dialog box title
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
#endregion ********** End of function getFilename **********

#region ********** Function Get-NewFilename **********
#* Function: Get-NewFilename
#* Last modified: 2017-10-22
#* Author: Ian Molloy
#*
#* Arguments:
#* filename - the filename from which to create the new
#* filename.
#*
#* See also:
#* OpenFileDialog Class.
#* http://msdn.microsoft.com/en-us/library/system.windows.forms.openfiledialog.aspx
#* =============================================
#* Purpose:
#* Creates the new filename from the filename supplied.
#* =============================================
function Get-NewFilename() {
[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="The filename to rename")]
        [ValidateNotNullOrEmpty()]
        [String]$filename
      ) #end param

BEGIN {
  $a = [System.IO.Path]::GetDirectoryName($filename); # file path only
  $b = [System.IO.Path]::GetFileNameWithoutExtension($filename); # filename minus extension
  $c = [System.IO.Path]::GetExtension($filename); # extension

  $dd=("{0:s}" -f (Get-Date))
  $dd = $dd -replace ':', '-';

  $sep = [System.IO.Path]::DirectorySeparatorChar;
}

PROCESS {
  $tempPath = ("{0}{1}{2}" -f $a, $sep, $b);
  $newFilename = ("{0}_{1}{2}" -f $tempPath, $dd, $c);

}

END {
  return $newFilename;
}

}
#endregion ********** End of function Get-NewFilename **********

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Invoke-Command -ScriptBlock {

   Write-Host '';
   Write-Host ('Today is {0:dddd, dd MMMM yyyy}' -f (Get-Date));

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Host ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

$oldFilename = Get-NewFilename 'File to copy';
$newFilename = Get-NewFilename $oldFilename;

Write-Host ("`nFile we want to copy: {0}" -f $oldFilename);
Write-Host ("New filename = {0}" -f $newFilename);
Copy-Item -Path $oldFilename -Destination $newFilename -Confirm;

##=============================================
## END OF SCRIPT: DateCopy-File.ps1
##=============================================
