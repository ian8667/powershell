<#
.SYNOPSIS

Compiles a JavaFX program.

.DESCRIPTION

Note the distinction between Java and JavaFX.

Compiles a JavaFX program with the aid of JavaFX runtime
libraries. The variable 'PATH_TO_FX' points to wherever these
runtime libraries have been installed. The variable is a
CONSTANT declared in the 'Variable/constant declarations'
section and may have to be changed whenever the JavaFX runtime
libraries are updated.

.PARAMETER JavaFilename

(optional) the JavaFX program to compile in the format of
<programname>.java. If a parameter is not supplied, an internal
function is invoked to obtain the JavaFX filename.

.EXAMPLE

./compile.ps1

As a parameter has not been supplied, an internal function is invoked
to obtain the JavaFX filename.

.EXAMPLE

./compile.ps1 'myfile.java'

The JavaFX program to compile is supplied as a parameter. Error message:

Error: file myfile.java not found to compile

is displayed if, for example, file 'myfile.java' cannot be found or
doesn't exist.

.EXAMPLE

./compile.ps1 -JavaFilename 'myfile.java'

Using a named parameter to supply the Java program
to compile.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

Java CLASS files created withing the last few minutes are listed
if the compile is successful. In the event of an unsuccessful
compile, Java errors are shown in the usual way.

.NOTES

File Name    : compileFX.ps1
Author       : Ian Molloy
Last updated : 2023-03-27T18:36:43

.LINK

JavaFX
https://openjfx.io/

JavaFX API docs
https://openjfx.io/javadoc/20/

JavaFX Documentation Project
https://fxdocs.github.io/docs/html5/

javac - Java programming language compiler
http://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html

JavaFX Introduction
https://www.ntu.edu.sg/home/ehchua/programming/java/Javafx1_intro.html

Getting Started with JavaFX
https://openjfx.io/openjfx-docs/#install-javafx

JavaFX Documentation
A wealth of information is available to help you learn and use the JavaFX technology.
https://www.oracle.com/java/technologies/javase/javafx-docs.html

Release Notes for JavaFX 20
The following notes describe important changes and information
about this release. In some cases, the descriptions provide links
to additional detailed information about an issue or a change.
These release notes cover the standalone JavaFX 20 release.
JavaFX 20 requires JDK 17 or later.
https://github.com/openjdk/jfx/blob/master/doc-files/release-notes-20.md

Getting Started with JavaFX
This collection of (Oracle( tutorials is designed to get you started
with common JavaFX tasks, including working with layouts, controls,
style sheets, and visual effects.
https://docs.oracle.com/javafx/2/get_started/jfxpub-get_started.htm

Java JDK 20 Documentation home
https://docs.oracle.com/en/java/javase/20/index.html

Java SE Version 20 API docs
https://docs.oracle.com/en/java/javase/20/docs/api/index.html

#>

[CmdletBinding()]
Param(
   [parameter(Position=0,
              Mandatory=$false,
              HelpMessage='JavaFX file to compile')]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $JavaFilename
) #end param

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
the user to open a JavaFX file to compile

.PARAMETER Title

The title displayed on the dialog box window

.LINK

OpenFileDialog Class.
https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=netcore-3.1
#>

[CmdletBinding()]
Param(
   [parameter(Position=0,
              Mandatory=$true,
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

#---------------------------------------------------------------

#region ********** Variable/constant declarations **********
Write-Verbose -Message "Declaring variables and constants";
# Variable/constant declarations.
#New-Variable -Name APACHE_HOME -Option Constant -Value 'C:\Program Files\Java\commons-io-2.4';
#New-Variable -Name "CPATH" -Option Constant -Value '.;C:\Program Files\Java\javafx-sdk-19\lib\*';
New-Variable -Name "PATH_TO_FX" -Option Constant -Value 'C:\Program Files\Java\javafx-sdk-19\lib';
New-Variable -Name "JAVA_TOP" -Option Constant -Value 'C:\Program Files\Java\jdk-19';
New-Variable -Name "JAVAEXE" -Option Constant -Value "$JAVA_TOP\bin\javac.exe";
$ProgramName = '';
[String]$aLine = ('=' * 45);
Set-Variable -Name 'aLine' -Option ReadOnly;
Write-Verbose -Message "Java CLASSPATH used is:`n$PATH_TO_FX";
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
Set-StrictMode -Version Latest;

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Compile JavaFX file';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

# The location of JAVA_TOP changes due to Java updates to new
# versions. Check the location really exists and that we've
# not forgotten to change it to the most recent Java update.
if (-not (Test-Path -Path $JAVA_TOP)) {
    throw [System.IO.DirectoryNotFoundException] "JAVA_TOP $JAVA_TOP not found";
}

# The location of the JavaFX runtime location changes due
# to updates to new versions. Check the location really
# exists and that we've not forgotten to change it to the
# most recent update.
if (-not (Test-Path -Path $PATH_TO_FX)) {
    throw [System.IO.DirectoryNotFoundException] "JavaFX runtime location $($PATH_TO_FX) not found";
}

if ($PSBoundParameters.ContainsKey('JavaFilename')) {
   $ProgramName = $JavaFilename;
   Write-Output "Program name supplied is $ProgramName";
} else {
   # JavaFX file to compile has not been supplied. Get the filename.
   $ProgramName = Get-Filename -Title "Get JavaFX file to compile";
}

Set-Variable -Name ProgramName -Option ReadOnly;

  [System.Linq.Enumerable]::Repeat("", 2); #blanklines
  Write-Output $aLine;

  $dateMask = Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss";
  Write-Output "Compiling program $ProgramName on $dateMask";

  try {
    #& $JAVAEXE -Xlint:all -Xmaxerrs 10 -Xmaxwarns 10 -Xdiags:verbose -classpath $CPATH $ProgramName;
    & $JAVAEXE --module-path $PATH_TO_FX --add-modules javafx.controls $ProgramName;
  } catch {
    Write-Error -Message $Error[0].Exception;
  }

  $rc = $LastExitCode;

  Write-Output "`nFile $ProgramName compiled";

  if ($rc -eq 0) {
     Write-Output "Exit code = $rc";
     [System.Linq.Enumerable]::Repeat("", 2); #blanklines
     Write-Output $aLine;

     # Show the resultant class files recently compiled.
     Write-Output "Java CLASS files created within the last few minutes";

     Get-ChildItem -Filter '*.class' -File |
         Where-Object {$_.LastWriteTime -ge (Get-Date).AddMinutes(-5)} |
         Sort-Object -Property LastWriteTime;
     [System.Linq.Enumerable]::Repeat("", 2); #blanklines
     $dateMask = Get-Date -Format "HH:mm:ss";
     Write-Output "Current time is: $dateMask";

  } else {
    Write-Warning -Message "Process exited with exit code $rc";
  }

  Write-Output $aLine;
  [System.Linq.Enumerable]::Repeat("", 2); #blanklines

exit $rc;

##=============================================
## END OF SCRIPT: compileFX.ps1
##=============================================
