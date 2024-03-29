<#
.SYNOPSIS

Runs a Java program.

.DESCRIPTION

Runs a Java program that has already been compiled. The CLASSPATH used
is a CONSTANT declared in the 'Variable/constant declarations' section.
This may have to be updated depending upon the program being run.

.PARAMETER Path

(optional) the Java program to run in the format of
<programname>.java. If a parameter is not supplied, an internal
function is invoked to obtain the Java program.

.EXAMPLE

./run_java.ps1

As a parameter has not been supplied, an internal function is invoked
to obtain the Java filename.

.EXAMPLE

./run_java.ps1 'myfile.java'

The Java program to execute is supplied as a parameter. Error message:

Error: file myfile.java not found to run

is displayed if, for example, file 'myfile.java' cannot be found or
doesn't exist.

.EXAMPLE

./run_java.ps1 Path 'myfile.java'

Using a named parameter to supply the Java program to execute.
Error message:

Error: file myfile.java not found to compile

is displayed if, for example, file 'myfile.java' cannot be found or
doesn't exist.

.INPUTS

None. No .NET Framework types of objects are used as input.

.OUTPUTS

None. No .NET Framework types of objects are output from this script.

.NOTES

File Name    : run_java.ps1
Author       : Ian Molloy
Last updated : 2023-12-27T18:29:45


.LINK

JDK 21 Documentation
https://docs.oracle.com/en/java/javase/21/

Java SE Version 21 API docs
https://docs.oracle.com/en/java/javase/21/docs/api/index.html

JSR 394: Java SE 19: Annex 3
Final Release Specification JLS & JVMS
https://cr.openjdk.java.net/~iris/se/19/latestSpec/java-se-19-annex-3.html

The Java Tutorials
https://docs.oracle.com/javase/tutorial/

The Destination for Java Developers
https://dev.java/

iText Core/Community 7.2.3
Newer versions of iText
https://github.com/itext/itext7/releases/tag/7.2.3

Learn Java
https://dev.java/learn/

#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [Object]
   $Path
) #end param

  #trap { "An error: $_"; exit 1;}

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
  the user to open a Java class file to run

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
    Write-Verbose -Message "Invoking function to obtain the Java class file to run";

    Add-Type -AssemblyName "System.Windows.Forms";
    # Displays a standard dialog box that prompts the user
    # to open (select) a file.
    $ofd = [System.Windows.Forms.OpenFileDialog]::new();

    # The dialog box return value is OK (usually sent
    # from a button labeled OK). This indicates the
    # user has selected a file.
    $myok = [System.Windows.Forms.DialogResult]::OK;
    [String]$retFilename = "";
    $ofd.CheckFileExists = $true;
    $ofd.CheckPathExists = $true;
    $ofd.ShowHelp = $false;
    $ofd.Filter = "Java files (*.java)|*.java|All files (*.*)|*.*";
    $ofd.FilterIndex = 1;
    $ofd.InitialDirectory = "C:\Family\Ian";
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

#----------------------------------------------------------
# SCRIPT BODY
# Main routine starts here
#----------------------------------------------------------
Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Run Java file';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}


#$Path = $JavaFilename;
#'MyFile' will be of type 'System.IO.FileInfo' when we exit
#this if/elseif/else block.
if ($Path -is [String]) {
    Write-Verbose 'The main parameter is of type string';
    $MyFile = Get-Item (Resolve-Path -Path $Path);

} elseif ($Path -is [System.IO.FileInfo]) {
    Write-Verbose 'The main parameter is of type FileInfo';
    $MyFile = $Path;

} else {
    #No value has been supplied. Invoke an internal function
    #to get the filename to shred
    Write-Verbose 'Nothing passed in';
    $m = Get-Filename -Title 'Java file to run';
    $MyFile = Get-Item $m;
}


#region ***** Variable/constant declarations *****
Write-Verbose -Message "Declaring variables and constants";

#New-Variable -Name 'JAR1' -Option Constant -Value 'C:/Program Files/Java/iText7/*';

#Set the Java CLASSPATH
New-Variable -Name "CPATH" -Option Constant -Value "C:\Family\Ian;C:\Program Files\Java\iText723\*";
#'Java_Top' is the root directory of the currently
#installed Java SDK
New-Variable -Name "JAVA_TOP" -Option Constant -Value 'C:\Program Files\Java\jdk-21';
New-Variable -Name "JAVAEXE" -Option Constant -Value "$JAVA_TOP\bin\java.exe";
[String]$aLine = ('=' * 45);
Write-Verbose -Message "Java CLASSPATH used is:`n$CPATH";
Set-Variable -Name 'aLine' -Option ReadOnly;
#endregion ***** End of Variable/constant declarations *****

# *****
# The Call Operator "&"
# The little call operator "&" gives you great discretionary power
# over the execution of PowerShell commands. If you place this
# operator in front of a string (or a string variable), the string
# will be interpreted as a command and executed just as if you had
# input it directly into the console.
# http://powershell.com/cs/blogs/ebook/archive/2009/03/30/chapter-12-command-discovery-and-scriptblocks.aspx#building-scriptblocks
# *****

# The pathname of JAVA_TOP changes due to Java updates to new
# versions. Check the location really exists and that we've
# not forgotten to change it to the most recent Java update
# file path.
if (-not (Test-Path -Path $JAVA_TOP -PathType 'Container'))
{
    throw [System.IO.DirectoryNotFoundException] "JAVA_TOP $JAVA_TOP not found";
}

Write-Output "Running program $MyFile";

$Prog = $MyFile.ToString();
Set-Variable -Name 'Prog' -Option ReadOnly;

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output $aLine;
& $JAVAEXE -classpath $CPATH $Prog;
$rc = $LastExitCode;

Write-Output $aLine;
[System.Linq.Enumerable]::Repeat("", 2); #blanklines
$RunDate = Get-Date -Format "HH:mm:ss";
Write-Output "Process exited at $RunDate with exit code $rc";
Write-Output "Java file [$Prog] completed";

exit $rc;
##=============================================
## END OF SCRIPT: run_java.ps1
##=============================================
