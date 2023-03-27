<#
.SYNOPSIS

Compiles a Java program.

.DESCRIPTION

Compiles a Java program. The CLASSPATH used is a CONSTANT declared
in the 'Variable/constant declarations' section. This may have to
be updated depending upon the program being compiled.

.PARAMETER JavaFilename

(optional) the Java program to compile in the format of
<programname>.java. If a parameter is not supplied, an internal
function is invoked to obtain the Java program.

.EXAMPLE

./compile.ps1

As a parameter has not been supplied, an internal function is invoked
to obtain the Java filename.

.EXAMPLE

./compile.ps1 'myfile.java'

The Java program to compile (in this example, myfile.java) is
supplied as a parameter. Error message:

Error: file myfile.java not found to compile

is displayed if, for example, file 'myfile.java' cannot be found or
doesn't exist.

.EXAMPLE

./compile.ps1 -JavaFilename myfile.java

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

File Name    : compile.ps1
Author       : Ian Molloy
Last updated : 2023-03-27T19:31:03


.LINK

JDK 20 Documentation home
https://docs.oracle.com/en/java/javase/20/index.html

Java SE Version 20 API docs
https://docs.oracle.com/en/java/javase/20/docs/api/index.html

JSR 394: Java SE 19: Annex 3
Final Release Specification
JLS & JVMS
https://cr.openjdk.java.net/~iris/se/19/latestSpec/java-se-19-annex-3.html

The Java Tutorials`
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
Param(
   [parameter(Position=0,
              Mandatory=$false)]
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
the user to open a Java file to compile

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
  Write-Verbose -Message "Invoking function to obtain the Java file to compile";

  Add-Type -AssemblyName "System.Windows.Forms";
  # Displays a standard dialog box that prompts the user
  # to open (select) a file.
  [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

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

# *****
# The Call Operator "&"
# The little call operator "&" gives you great discretionary power
# over the execution of PowerShell commands. If you place this
# operator in front of a string (or a string variable), the string
# will be interpreted as a command and executed just as if you had
# input it directly into the console.
# http://powershell.com/cs/blogs/ebook/archive/2009/03/30/chapter-12-command-discovery-and-scriptblocks.aspx#building-scriptblocks
# *****

#----------------------------------------------------------
# SCRIPT BODY
# Main routine starts here
#----------------------------------------------------------
Set-StrictMode -Version Latest;

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Compile Java file';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

#region ***** Variable/constant declarations *****
Write-Verbose -Message "Declaring variables and constants";

#Set the Java CLASSPATH
New-Variable -Name "CPATH" -Option Constant -Value "C:\Family\Ian;C:\Program Files\Java\iText_v724\*";
#'Java_Top' is the root directory of the currently
#installed Java SDK
New-Variable -Name "JAVA_TOP" -Option Constant -Value 'C:\Program Files\Java\jdk-20';
New-Variable -Name "JAVAEXE" -Option Constant -Value "$JAVA_TOP\bin\javac.exe";
Write-Verbose -Message "Java CLASSPATH used is:`n$CPATH";
[String]$ProgramName = "";
[String]$aLine = ('=' * 45);
Set-Variable -Name 'aLine' -Option ReadOnly;

#endregion ***** End of Variable/constant declarations *****

# The pathname of JAVA_TOP changes due to Java updates to new
# versions. Check the location really exists and that we've
# not forgotten to change it to the most recent Java update
# file path.
if (-not (Test-Path -Path $JAVA_TOP -PathType 'Container')) {
    throw [System.IO.DirectoryNotFoundException] "JAVA_TOP $JAVA_TOP not found";
}

if ($PSBoundParameters.ContainsKey('JavaFilename')) {
   # A Java filename has been supplied. Use it.
   $ProgramName = $JavaFilename;
   Write-Output "Program name supplied is $ProgramName";
} else {
   # Java file to compile has not been supplied. Get the
   # filename via internal function Get-Filename.
   $ProgramName = Get-Filename "Get Java file to compile";
}
Set-Variable -Name ProgramName -Option ReadOnly;

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output $aLine;

$dd = Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss";
Write-Output "Compiling program $ProgramName on $dd";
Write-Output "";

#javac.exe compiler options
$options = @("-Xlint:all",
             "-Xmaxerrs", "10",
             "-Xmaxwarns", "10",
             "-Xdiags:verbose");
$what = @("-classpath","$CPATH", "$ProgramName");
$cmdArgs = @($options, $what);
Set-Variable -Name 'cmdArgs' -Option ReadOnly;

try {

  & $JAVAEXE @cmdArgs;
  $rc = $LastExitCode;
} catch {
  Write-Error -Message "Java compile failed";
}

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
   $dd = Get-Date -Format "HH:mm:ss";
   Write-Output "Current time is: $dd";

} else {
  Write-Warning -Message "Process exited with exit code $rc";
}

Write-Output $aLine;
[System.Linq.Enumerable]::Repeat("", 2); #blanklines

exit $rc;

##=============================================
## END OF SCRIPT: compile.ps1
##=============================================
