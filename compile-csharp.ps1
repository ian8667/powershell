<#
.SYNOPSIS

Compile a C# file

.DESCRIPTION

Invoke the Microsoft supplied C# compiler 'csc.exe' to compile a
C# program. The '.exe' output file created will be placed in the
same directory as the '.cs' file. Only one C# will be compiled at
a time, compiling multiple '.cs' files is not supported.

An internal function is invoked to obtain the name of the C#
program to compile

.EXAMPLE

PS> ./compile-csharp.ps1

The .NET class 'System.Windows.Forms.OpenFileDialog' is invoked to
obtain the C# filename to compile

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : compile-csharp.ps1
Author       : Ian Molloy
Last updated : 2020-06-11T19:09:43
Keywords     : csharp c#

.LINK

Command-line build with csc.exe
https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/command-line-building-with-csc-exe

OpenFileDialog Class
https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=netcore-3.1

C# Compiler (csc.exe)
https://www.oreilly.com/library/view/net-framework-essentials/0596001657/apds06.html

#>

[CmdletBinding()]
Param()

#region ***** Function Get-Filename *****
#* Function: Get-Filename
#* Last modified: 2017-02-11
#* Author: Ian Molloy
#*
#* Arguments:
#* Title - the title displayed on the dialog box window.
#*
#* See also:
#* OpenFileDialog Class.
#* http://msdn.microsoft.com/en-us/library/system.windows.forms.openfiledialog.aspx
#* =============================================
#* Purpose:
#* Displays a standard dialog box that prompts
#* the user to open a file. This will be the
#* C# file to compile.
#* =============================================
function Get-Filename {
[CmdletBinding()]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="ShowDialog box title")]
        [ValidateNotNullOrEmpty()]
        [String]$Title
      ) #end param

  #trap { "An error: $_"; exit 1;}

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
  $ofd.Filter = "C# files (*.cs)|*.cs|All files (*.*)|*.*";
  $ofd.FilterIndex = 1;
  $ofd.InitialDirectory = "C:\Family\powershell";
  $ofd.Multiselect = $false;
  $ofd.RestoreDirectory = $false;
  $ofd.Title = $Title; # sets the file dialog box title
  $ofd.DefaultExt = "cs";

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
#endregion ***** End of function getFilename *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Write-Output 'Start of compile';
$file = Get-Filename -Title 'C# file to compile';
$compile = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe';
$cmdArgs = @('-nologo', '-optimize+');
$mask = 'dddd, dd MMMM yyyy';
$basedir = Split-Path -Path $file;
Set-Variable -Name 'file','compile','cmdArgs','mask','basedir' -Option ReadOnly;
Write-Output '';

Write-Output ('Compiling C# file "{0}"' -f (Split-Path -Path $file -Leaf));
[System.Linq.Enumerable]::Repeat("", 2); #blanklines
#& $compile $file -nologo;
#& $compile $file;
& $compile $file @cmdArgs;
$rc = $LastExitCode;
Write-Output "Return code = $rc";

if ($rc -eq 0) {
    #List any files created within the last few minutes
    #as a result of this compile
    Write-Output 'Files created within the last few minutes'
    Get-ChildItem -File -Path $basedir |
       Where-Object {$_.LastWriteTime -ge (Get-Date).AddMinutes(-5)} |
       Sort-Object -Property LastWriteTime;
} else {
    Write-Error -Message 'C# sharp compile failed. Please fix the above errors';
}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'End of compile';

##=============================================
## END OF SCRIPT: compile-csharp.ps1
##=============================================
