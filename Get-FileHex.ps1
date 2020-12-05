<#

File Name    : Get-FileHex.ps1
Author       : Ian Molloy
Last updated : 2020-12-04T18:09:41
Keywords     : hex file dump

[Predicate[Byte]]$$IsLetterOrDigit = {param($x) $x -gt 15 } #returns true or false
$IsLetterOrDigit.Invoke(5);
#>

##############################################################################
#  Script: Get-FileHex.ps1
#    Date: 16.May.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Shows the hex translation of a file, binary or otherwise.  The
#          $width argument determines how many bytes are output per line.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $Filename
) #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** Predicate IsLetterOrDigit *****
[Predicate[Byte]]$IsLetterOrDigit = {
   param([Byte]$b)
     [Char]::IsLetterOrDigit($b) -or
     [Char]::IsPunctuation($b) -or
     [Char]::IsSymbol($b) -or
     $b -eq 0X20;
   } #returns true or false
#endregion ***** end of Predicate IsLetterOrDigit *****

#----------------------------------------------------------

#region ***** function Get-HexDump *****
function Get-HexDump {
[CmdletBinding()]
param (
   [parameter(Position=0,
              Mandatory=$true)]
   [ValidateNotNullOrEmpty()]
   [String]$HexDumpFile
) #end param

    $linecounter = 0;
    [String]$offsettext = '';
    [String]$paddedhex = '';
    $header = @(
      '     Offset Bytes                                           Ascii'
      '            00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F'
      '     ------ ----------------------------------------------- -----'
      );
    Set-Variable -Name 'header' -Option ReadOnly;

    $width = 16;
    $padwidth = $width * 3;
    [String]$placeholder = "."; # What to print when byte is not a letter or digit.
    Set-Variable -Name 'width', 'padwidth', 'placeholder' -Option ReadOnly;
    $asciitext = New-Object -TypeName 'System.Collections.Generic.List[String]';
    $ttest = New-Object -TypeName 'System.Collections.Generic.List[String]';
    $asciitext.Capacity = 50;
    $ttest.Capacity = 20;

    Write-Output $header;
    # Gets the content of the file as a stream of bytes
    Get-Content -Path $HexDumpFile -ReadCount $width -AsByteStream |
    ForEach-Object {

        Clear-Variable -Name 'paddedhex';
        $asciitext.Clear();
        $ttest.Clear();
        $byteArray = $_; # Array of [Byte] objects that is $width items in length.
        $counter = 0;

        foreach ($byte in $byteArray) {
            #$paddedhex += $paddedhex = ('{0:X2} ' -f $byte);
            $counter += 3;
            $ttest.Add(('{0:X2}' -f $byte));
        } #end foreach loop

        # Total bytes in file unlikely to be evenly divisible by $width,
        # so fix the last line so the padding looks right and everything
        # aligns up
        if ($counter -lt $padwidth) {
            Write-Verbose -Message ('paddedhex is now {0}' -f $paddedhex.Length);
            Write-Verbose -Message ('counter is now {0}' -f $counter);

            #$paddedhex = $paddedhex.PadRight($padwidth," ");
            Write-Verbose -Message ('paddedhex is now {0}' -f $paddedhex.Length);
            $ttest.Add(' ' * ($padwidth - $counter - 1));
        }

        foreach ($byte in $byteArray) {
            if ($IsLetterOrDigit.Invoke($byte)) {
                $asciitext.Add([Char] $byte);
            } else {
                #$asciitext += $placeholder
                $asciitext.Add($placeholder);
            }
        } #end foreach loop

        # Convert variable $linecounter to a hex value
        # with a padding width of nine hex characters
        $offsettext = ('{0:X9}h:' -f $linecounter);

        $linecounter += $width;
        #$m = "$asciitext".Replace(' ', '');
        #Write-Output "$offsettext $paddedhex $m";
        $m = [String]::Join('', $asciitext);
        Write-Output "$offsettext $ttest $m";
    } #end of ForEach-Object loop
}
#endregion ***** end of function Get-HexDump *****

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
  Write-Verbose -Message "Invoking function to obtain the file to hex dump";

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
  $ofd.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*";
  $ofd.FilterIndex = 1;
  $ofd.InitialDirectory = "C:\Family\Ian";
  $ofd.Multiselect = $false;
  $ofd.RestoreDirectory = $false;
  $ofd.Title = $Title; # sets the file dialog box title
  $ofd.DefaultExt = "txt";

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

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

if ($PSBoundParameters.ContainsKey('Filename')) {
   $File = $Filename;
} else {
   # Java file to compile has not been supplied. Get the filename.
   $File = Get-Filename "Get file to display";
}

Write-Output "Hex dump of file $File";
[System.Linq.Enumerable]::Repeat("", 2); #blanklines

Get-HexDump -HexDumpFile $File;
[System.Linq.Enumerable]::Repeat("", 2); #blanklines

##=============================================
## END OF SCRIPT: Get-FileHex.ps1
##=============================================
