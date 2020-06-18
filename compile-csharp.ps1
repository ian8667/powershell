<#
.SYNOPSIS

Compile a C# file

.DESCRIPTION

Invoke the Microsoft supplied C# compiler 'csc.exe' to compile a
C# program. The '.exe' output file created will be placed in the
same directory as the '.cs' file. Only one C# will be compiled at
a time. Compiling multiple '.cs' files is not supported.

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
Last updated : 2020-06-16T13:51:03
Keywords     : csharp c#

ScriptBlock which can be used to find the location of the C# compiler.

$sb = {
$compilerName = 'csc.exe';
ls -file -Recurse -Filter $compilerName -path 'C:/' -ErrorAction SilentlyContinue;
}

.LINK

Command-line build with csc.exe
https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/command-line-building-with-csc-exe

OpenFileDialog Class
https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=netcore-3.1

C# Compiler (csc.exe)
https://www.oreilly.com/library/view/net-framework-essentials/0596001657/apds06.html

C# Compiler Options Listed by Category
https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/listed-by-category

C# Compiler Options Listed Alphabetically
https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/listed-alphabetically
#>

[CmdletBinding()]
Param()

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
#endregion ***** End of function Get-Filename *****

#region ***** Function Get-OutputFilename *****
function Get-OutputFilename {
<#
.SYNOPSIS

Get the output filename

.DESCRIPTION

Get the absolute path of the output filename. This is derived
from the input filename and ensures the '.exe' file created
will be in the same directory as the '.cs' file compiled

.PARAMETER Path

The C# input filename from which to obtain the output filename

#>
    
[CmdletBinding()]
Param (
   [parameter(Mandatory=$true,
              HelpMessage="Input filename")]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [String]$Path
) #end param
    
Begin {}
    
Process {
  $baseDir = Split-Path -Path $Path -Parent #ie C:\Gash
  $file = Split-Path -Path $Path -LeafBase  #ie csharp_001
  $outputfile = Join-Path -Path $baseDir -ChildPath $file;
  $outputfile = ('{0}.exe' -f $outputfile);
}
    
End {
  return $outputfile;
}
}
#endregion ***** End of function Get-OutputFilename *****


##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Write-Output 'Start of compile';
$inputfile = Get-Filename -Title 'C# file to compile';
$outputfile = Get-OutputFilename -Path $inputfile; # C# .exe filename
$compile = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe';
$cmdArgs = @("-out:$outputfile", "-nologo", "-optimize+");
$mask = 'dddd, dd MMMM yyyy';
$basedir = Split-Path -Path $inputfile;
Set-Variable -Name 'inputfile','outputfile','compile','cmdArgs','mask','basedir' -Option ReadOnly;
Write-Output '';

Write-Output ('Compiling C# file "{0}"' -f (Split-Path -Path $inputfile -Leaf));
[System.Linq.Enumerable]::Repeat("", 2); #blanklines
#& $compile $inputfile -nologo;
#& $compile $inputfile;
& $compile @cmdArgs $inputfile;
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
