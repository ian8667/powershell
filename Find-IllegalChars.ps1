﻿<#
.SYNOPSIS

Examines a file for illegal characters.

.DESCRIPTION

Reads in a file byte by byte examining each one for illegal characters.
As my interest is with ASCII files, an illegal character is deemed to
be anything with a value outside the range of 1 to 127 (decimal).

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
Last updated : 2020-08-03T22:29:10

.LINK

PSScriptAnalyzer deep dive Part 1 of 4
https://blogs.technet.microsoft.com/heyscriptingguy/2017/01/31/psscriptanalyzer-deep-dive-part-1-of-4/

#>

[CmdletBinding()]
Param () #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

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

Begin {
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

#region ***** function Get-Filestream *****
function Get-Filestream {
[CmdletBinding()]
[OutputType([System.IO.FileStream])]
Param (
       [parameter(Position=0,
                  Mandatory=$true)]
       [AllowEmptyString()]
       [ValidateNotNull()]
       [String]$Filename
      ) #end param

  Begin {

    [String]$inf = Get-Filename 'File to examine';

    $optIn = [PSCustomObject]@{
        path        = $inf;
        mode        = [System.IO.FileMode]::Open;
        access      = [System.IO.FileAccess]::Read;
        share       = [System.IO.FileShare]::Read;
        bufferSize  = 4KB;
        options     = [System.IO.FileOptions]::SequentialScan;
    }

    $fis = New-Object -typeName 'System.IO.FileStream' -ArgumentList `
           $optIn.path, $optIn.mode, $optIn.access, $optIn.share, $optIn.bufferSize, $optIn.options;

  }

  Process {}

  End {
    return $fis;
  }

} #end function Get-Filestream
#endregion ***** end of function Get-Filestream *****

#----------------------------------------------------------

#region ***** function Main-Routine *****
function Main-Routine {
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param () #end param

        Begin {
          $sourceFile = Get-Filestream 'Filename to check';
          $fname = $sourceFile.Name;
          Set-Variable -Name "sourceFile" -Option ReadOnly `
              -Description 'Input file to be examined for illegal characters';
          New-Variable -Name BUFFSIZE -Value 4KB -Option Constant `
                       -Description 'Buffer size used with file I/O';
          New-Variable -Name EOF -Value 0 -Option Constant `
                       -Description 'Signifies the end of the stream has been reached';
          $dataBuffer = New-Object -TypeName byte[] $BUFFSIZE;
          # Delimits the range of byte values we're prepared to accept.
          # Anything outside the range is deemed to be illegal. All
          # values are in decimal.
          $range = @{
              Min = 1
              Max  = 127
          }
          Set-Variable -Name "range" -Option ReadOnly `
              -Description 'Contains the range of decimal values considered to valid';
          # A set is a collection that contains no duplicate elements,
          # and whose elements are in no particular order.
          $errorSet = New-Object -typeName 'System.Collections.Generic.HashSet[Int32]';
          [UInt16]$errorBytes = 0;
        }

        Process {

          try {
               $bytesRead = $sourceFile.Read($dataBuffer, 0, $dataBuffer.Length);
               # Loop to process file
               while ($bytesRead -gt $EOF) {

                  # Loop to process each dataBuffer
                  foreach ($num in 0..($bytesRead-1)) {

                    if ($dataBuffer[$num] -notin ($range.Min..$range.Max)) {
                    	 $errorBytes++;
                    	 $errorSet.Add($dataBuffer[$num]) | Out-Null;
                    }
                  } #end foreach loop

                  $bytesRead = $sourceFile.Read($dataBuffer, 0, $dataBuffer.Length);
               } #end WHILE loop

             } finally {
               $sourceFile.Dispose();
            }

        }

        End {
          Write-Output '';
          Write-Output ('Target file {0}' -f $fname);
          Write-Output ('Characters in error: {0}' -f $errorBytes);
        }

} #end function Main-Routine
#endregion ***** end of function Main-Routine *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Find illegal characters';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

Main-Routine;

##=============================================
## END OF SCRIPT: Find-IllegalChars.ps1
##=============================================
