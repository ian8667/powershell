<#
.SYNOPSIS

Runs a JavaFX program.

.DESCRIPTION

Note the distinction between Java and JavaFX.

Runs a JavaFX program that has already been compiled. The
variable 'PATH_TO_FX' points to wherever the JavaFX runtime
libraries have been installed. The variable is a CONSTANT
declared in the 'Variable/constant declarations' section and
may have to be changed whenever the JavaFX runtime libraries
are updated.

.PARAMETER JavaFilename

(optional) the JavaFX program to run in the format of
<programname>.java. If a parameter is not supplied, an internal
function is invoked to obtain the JavaFX filename.

.EXAMPLE

./run_javaFX.ps1

As a parameter has not been supplied, an internal function is invoked
to obtain the JavaFX filename.

.EXAMPLE

./run_javaFX.ps1 'myfile.java'

The Java program to execute is supplied as a parameter. Error message:

Error: file myfile.java not found to run

is displayed if, for example, file 'myfile.java' cannot be found or
doesn't exist.

.EXAMPLE

./run_javaFX.ps1 -JavaFilename 'myfile.java'

Using a named parameter to supply the Java program to execute.

.INPUTS

None. No .NET Framework types of objects are used as input.

.OUTPUTS

None. No .NET Framework types of objects are output from this script.

.NOTES

File Name    : run_javaFX.ps1
Author       : Ian Molloy
Last updated : 2021-06-19T17:25:20

.LINK


JavaFX
https://openjfx.io/

JavaFX API docs
https://openjfx.io/javadoc/15/

JavaFX Documentation Project
https://fxdocs.github.io/docs/html5/

javac - Java programming language compiler
http://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html

JavaFX Introduction
https://www.ntu.edu.sg/home/ehchua/programming/java/Javafx1_intro.html

Getting Started with JavaFX 12
https://openjfx.io/openjfx-docs/#install-javafx

JDK 16 Documentation
https://docs.oracle.com/en/java/javase/16/index.html

Java SE Version 16 API docs
https://docs.oracle.com/en/java/javase/16/docs/api/index.html
#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [String]
   $JavaFilename
) #end param

  trap { "An error: $_"; exit 1;}

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
    Write-Verbose -Message "Invoking function to obtain the filename to compile";

    Add-Type -AssemblyName "System.Windows.Forms";
    # Displays a standard dialog box that prompts the user
    # to open (select) a file.
    [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog';

    # The dialog box return value is OK (usually sent
    # from a button labeled OK). This indicates the
    # user has selected a file.
    $myok = [System.Windows.Forms.DialogResult]::OK;
    $retFilename = "";
    $ofd.CheckFileExists = $true;
    $ofd.CheckPathExists = $true;
    $ofd.ShowHelp = $false;
    $ofd.Filter = "JavaFX files (*.java)|*.java|All files (*.*)|*.*";
    $ofd.FilterIndex = 1;
    $ofd.InitialDirectory = "C:\Family\javaFX";
    $ofd.Multiselect = $false;
    $ofd.RestoreDirectory = $false;
    $ofd.Title = $Title; # sets the file dialog box title
    $ofd.DefaultExt = "java";

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

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

#region ********** Variable/constant declarations **********
Write-Verbose -Message "Declaring variables and constants";

#New-Variable -Name APACHE_HOME -Option Constant -Value 'C:\Program Files\Java\commons-io-2.4';
#New-Variable -Name "CPATH" -Option Constant -Value '.;C:\Program Files\Java\javafx-sdk-12.0.1\lib\*;C:\Program Files\Java\javafx-sdk-12.0.1\bin\*';
New-Variable -Name "PATH_TO_FX" -Option Constant -Value 'C:\Program Files\Java\javafx-sdk-15.0.1\lib';
New-Variable -Name "JAVA_TOP" -Option Constant -Value "C:\Program Files\Java\jdk-15";
New-Variable -Name "JAVAEXE" -Option Constant -Value "$JAVA_TOP\bin\java.exe";
New-Variable -Name "CLASSPATH" -Option Constant -Value "C:\Family\javaFX";
$ProgramName = "";
[String]$aLine = ('=' * 45);
Set-Variable -Name 'aLine' -Option ReadOnly;
Write-Verbose -Message "JavaFX CLASSPATH used is:`n$($PATH_TO_FX)";
$rc = -1;
#endregion ********** End of Variable/constant declarations **********

# *****
# The Call Operator "&"
# The little call operator "&" gives you great discretionary power
# over the execution of PowerShell commands. If you place this
# operator in front of a string (or a string variable), the string
# will be interpreted as a command and executed just as if you had
# input it directly into the console.
# http://powershell.com/cs/blogs/ebook/archive/2009/03/30/chapter-12-command-discovery-and-scriptblocks.aspx#building-scriptblocks
# *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Invoke-Command -ScriptBlock {

  Write-Output '';
  Write-Output 'Running JavaFX file';
  $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
  Write-Output ('Today is {0}' -f $dateMask);

  $script = $MyInvocation.MyCommand.Name;
  $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
  Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
# The location of JAVA_TOP changes due to Java updates to new
# versions. Check the location really exists and that we've
# not forgotten to change it to the most recent Java version.
if (-not (Test-Path -Path $JAVA_TOP))
{
    throw [System.IO.DirectoryNotFoundException] "JAVA_TOP $JAVA_TOP not found";
}

# The location of the JavaFX runtime location changes due
# to updates to new versions. Check the location really
# exists and that we've not forgotten to change it to the
# most recent update.
if (-not (Test-Path -Path $PATH_TO_FX))
{
    throw [System.IO.DirectoryNotFoundException] "JavaFX runtime location $($PATH_TO_FX) not found";
}

if ($PSBoundParameters.ContainsKey('JavaFilename')) {
   $ProgramName = $JavaFilename;
   Write-Output "Program name supplied is $ProgramName";
} else {
   # Java file to run has not been supplied. Get the filename.
   $ProgramName = Get-Filename "Get JavaFX file to run";
}

Set-Variable -Name 'ProgramName' -Option ReadOnly;

  $dd = Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss";
  Write-Output "Running program $ProgramName on $dd";

  # The absolute path returned will be, for example,
  # 'C:\progs\test\coreJava.java'. In orer to run the
  # program, we will replace 'java' with 'class' so
  # that it becomes 'C:\progs\test\coreJava.class'.
  $Prog = $ProgramName.Replace('java$', 'class');

  [System.Linq.Enumerable]::Repeat("", 2); #blanklines
  Write-Output $aLine;
  & $JAVAEXE --module-path $PATH_TO_FX --add-modules javafx.controls -classpath $CLASSPATH $Prog
  $rc = $LastExitCode;

  Write-Output $aLine;
  [System.Linq.Enumerable]::Repeat("", 2); #blanklines
  $dd = Get-Date -Format "HH:mm:ss";
  Write-Output "Process exited at $dd with exit code $rc"
  Write-Output "JavaFX $ProgramName completed"


exit $rc;
##=============================================
## END OF SCRIPT: run_javaFX.ps1
##=============================================
