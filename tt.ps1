# PSScriptAnalyzer deep dive � Part 1 of 4
# https://blogs.technet.microsoft.com/heyscriptingguy/2017/01/31/psscriptanalyzer-deep-dive-part-1-of-4/
#
# About Functions Advanced Parameters
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-6
#
# System.String.GetEnumerator Method
# an object that can iterate through the individual characters in a string.
#
# System.CharEnumerator
# Supports iterating over a String object and reading its individual characters.
#
[CmdletBinding()]
Param () #end param

#region ***** function Examine-String *****
function Examine-String {
[CmdletBinding()]
[OutputType([System.String])]
Param (
       [parameter(Position=0,
                  Mandatory=$true)]
       [AllowEmptyString()]
       [ValidateNotNull()]
       [String]$DataLine
      ) #end param

  BEGIN {
    [UInt16]$pos = 0;
    $myEnum = $DataLine.GetEnumerator();
    [Int32]$val = 0;
    $snag = $false;
    $marker = "";
    $bits = New-Object -TypeName System.Collections.BitArray -ArgumentList $DataLine.Length;
  }

  PROCESS {

    # The statement '$myEnum.MoveNext()' will return False if
    # variable $DataLine happens to be an empty string. Thus
    # the WHILE loop will not be executed.
    while ($myEnum.MoveNext()) {
        $val = [Int32]$myEnum.Current;
        $pos++;
        if ($val -notin (0..127)) {
            $bits.Set($pos, $true);
            $snag = $true;
            #Write-Output $DataLine;
            #Write-Output ('Target found as position {0}' -f $pos);
            Write-Host -Message "Snag at pos $pos";
        }
    }# end WHILE loop

    if ($snag) {
        Write-Host $DataLine;
        foreach ($m in $bits.GetEnumerator()) {
            switch ($m) {
                $true {$marker = "^"}
                $false {$marker = " "}
            }
            Write-Host $marker -NoNewline;
        }
        
    }# end if ($snag)

  }

  END {
    $myEnum.Dispose();
  }

} #end function Examine-String
#endregion ***** end of function Examine-String *****

#region ***** function Main-Routine *****
function Main-Routine {
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param () #end param

        BEGIN {
          $inf = 'C:\Family\ian\VisitDirs.java';
          $utf8 = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false, $false;
          $sread = New-Object -TypeName System.IO.StreamReader -ArgumentList $inf, $utf8;
          [UInt16]$lineCounter = 0;
          [String]$inrec = '';
        }

        PROCESS {
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
                  Examine-String $inrec;

              }# end WHILE loop
          } finally {
              $sread.Dispose();
          }

        }

        END {
          Write-Output "`nTest complete";
          Write-Output ('{0} lines read from input file {1}' -f $lineCounter, $inf);
        }

} #end function Main-Routine
#endregion ***** end of function Main-Routine *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Main-Routine;

##=============================================
## END OF SCRIPT: Get-Lastlines.ps1
##=============================================
