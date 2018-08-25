<#
.SYNOPSIS

Examines a file for illegal characters.

.DESCRIPTION

Reads in a file line by line examining each one for illegal characters.
As my interest is with ASCII files, an illegal character is deemed to
be anything with a value outside the range of 0 to 127 (decimal).

This program came about when I compiled a Java program which complained
about illegal characters. I had a rough idea where in the program it
was going wrong but I wanted to be sure there were no other problem lines.

Compiling program VisitDirs.java on Tuesday, 24 April 2018 22:51:33
VisitDirs.java:50: error: illegal character: '\u2039'
    dirNames = HashSetÔÇï(500);
                        ^
1 error
exitcode = 1

.EXAMPLE

PS> ./Find-IllegalChars.ps1

An internal function will be invoked to obtain the file to examine.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Find-IllegalChars.ps1
Author       : Ian Molloy
Last updated : 2018-04-27

.LINK

PSScriptAnalyzer deep dive Part 1 of 4
https://blogs.technet.microsoft.com/heyscriptingguy/2017/01/31/psscriptanalyzer-deep-dive-part-1-of-4/

About Functions Advanced Parameters
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-6

System.String.GetEnumerator Method
an object that can iterate through the individual characters in a string.

System.CharEnumerator
Supports iterating over a String object and reading its individual characters.

#>

[CmdletBinding()]
Param () #end param

#region ***** Function Get-Filename *****
function Get-Filename {
[CmdletBinding()]
[OutputType([System.String])]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="ShowDialog box title")]
        [ValidateNotNullOrEmpty()]
        [String]$Boxtitle
      ) #end param

BEGIN {
  Write-Verbose -Message "Invoking function to obtain the to file to examine";

  Add-Type -AssemblyName "System.Windows.Forms";
  [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

  $myok = [System.Windows.Forms.DialogResult]::OK;
  $retFilename = "";
  $ofd.AddExtension = $false;
  $ofd.CheckFileExists = $true;
  $ofd.CheckPathExists = $true;
  $ofd.DefaultExt = ".txt";
  $ofd.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*";
  $ofd.InitialDirectory = "C:\Family\powershell";
  $ofd.Multiselect = $false;
  $ofd.Title = $Boxtitle; # sets the file dialog box title
  $ofd.ShowHelp = $false;
  $ofd.RestoreDirectory = $false;
  Set-Variable -Name 'ofd' -Option ReadOnly;

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
#endregion ***** End of function Get-Filename *****

#region ***** function Examine-String *****
function Examine-String {
[CmdletBinding()]
[OutputType([System.Management.Automation.PSCustomObject])]
Param (
       [parameter(Position=0,
                  Mandatory=$true)]
       [AllowEmptyString()]
       [ValidateNotNull()]
       [String]$DataLine
      ) #end param

  BEGIN {
    [Int32]$pos = 0;
    $myEnum = $DataLine.GetEnumerator();
    [Int32]$val = 0;
    $bob = New-Object -TypeName System.Text.StringBuilder -ArgumentList $DataLine.Length;
    $myObject = [PSCustomObject]@{
        HasErrors  = $false;
        Markers    = '';
    }
    # Delimits the range of byte values we're prepared to accept.
    # Anything outside the range is deemed to be illegal. All
    # values are in decimal.
    $range = @{
        Min = 1
        Max  = 127
    }
        
  }

  PROCESS {
    # Initialise our StringBuilder object with spaces.
    $bob = $bob.Insert(0, ' ', $DataLine.Length);

    # The statement '$myEnum.MoveNext()' will return False if
    # variable $DataLine happens to be an empty string. Thus
    # the WHILE loop will not be executed. The source file being
    # examined may well have blank lines in it. This is
    # expected behaviour and how we cater for these blank
    # (empty) lines.
    while ($myEnum.MoveNext()) {
        $val = [Int32]$myEnum.Current;
        if ($val -notin ($range.Min..$range.Max)) {

            # Mark the appropriate spot in the StringBuilder object
            # where an illegal character was found. This helps to show
            # where the error(s) are later on when we output the
            # StringBuilder as a string.
            $bob = $bob.Insert($pos, '^');
            $myObject.HasErrors = $true;
        }
        $pos++;
    }# end WHILE loop
    $myObject.Markers = $bob.ToString();
  }

  END {
    $myEnum.Dispose();
    return $myObject;
  }

} #end function Examine-String
#endregion ***** end of function Examine-String *****

#region ***** function Main-Routine *****
function Main-Routine {
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param () #end param

        BEGIN {
          $inf = Get-Filename 'File to examine'  ;
          Set-Variable -Name "inf" -Option ReadOnly `
              -Description 'Input file to be examined for illegal characters';
          $utf8 = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false, $false;
          $sread = New-Object -TypeName System.IO.StreamReader -ArgumentList $INF, $utf8;
          [UInt16]$lineCounter = 0;
          [String]$inrec = '';
          # Contains information relating to a string which contains illegal
          # characters. The structure of this variable is defined in function
          # 'Examine-String'.
          $illChars = New-Object PSCustomObject;
          [UInt16]$errorLines = 0;
        }

        PROCESS {
        	Write-Output ('Looking for illegal characters in file {0}' -f $INF);
            Write-Output '';
            try {
              while (-not $sread.EndOfStream) {
                  # I've had to put the first read from the file at
                  # the beginning of the WHILE loop as other variations
                  # of writing this loop failed to stop reading at the
                  # end-of-file correctly. In other words, it kept on
                  # trying to read beyond the end-of-file despite the
                  # fact it had reached the end.
                  $inrec = $sread.ReadLine();

                  $lineCounter++;
                  # Examine the string for any illegal characters.
                  Write-Verbose $inrec;
                  $illChars = Examine-String -DataLine $inrec;

                  if ($illChars.HasErrors) {
                      Write-Output ('Source line #{0}' -f $lineCounter);
                      Write-Output $inrec;
                      Write-Output $illChars.Markers;
                      Write-Output '';

                      $errorLines++;
                  }
              }# end WHILE loop
          } finally {
              $sread.Dispose();
          }

        }

        END {
          Write-Output '';
          Write-Output ('{0} lines read from input file {1}' -f $lineCounter, $INF);
          Write-Output ('Lines in error: {0}' -f $errorLines);
        }

} #end function Main-Routine
#endregion ***** end of function Main-Routine *****

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
    Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
    Write-Output '';
 
}

Main-Routine;

##=============================================
## END OF SCRIPT: tt.ps1
##=============================================
