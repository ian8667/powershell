<#
.SYNOPSIS

Displays selected characters from an input string.

.DESCRIPTION

Displays characters from an input string at positions specified in
parameter 'CharPositions'. Due to the intended use of this program,
I'm typically only interested in selecting either two or three
characters from the input string. Any other number of characters
will generate an error.

This program came about after using security validation procedures
which ask for randomly selected characters from a password, phrase
or user ID. The program saves me from hunting down these characters
and will display them for me. I.e., if I want the characters from
positions one and seven, for example, then 1,7 should be supplied
to parameter 'CharPositions'.

.PARAMETER Phrase

(mandatory) contains the password or phrase from which characters
will be extracted in order to be displayed to the user.

.PARAMETER CharPositions

(mandatory) a [System.Byte] array containing the positions from
which to display (extract) the requested characters. If the
first, second and fifth characters are required, then enter a
value of 1,2,5.

Due to the intended use of this program, only two or three characters
can be selected. Any other number of integer digits entered will
generate an error.

.EXAMPLE

./Get-StringChars.ps1 -Phrase 'helloWorld' -CharPositions 2,4,9

Displays characters at positions 2,4 and 9 from the phrase helloworld.
The positions used are one-based indices. In this example, we have the
options of specifying positions 1 to 10 inclusive.

.EXAMPLE

./Get-StringChars.ps1 -Phrase 'TheQuickBrownFox' -CharPositions 5,12

Displays characters at positions 5 and 12 from the phrase TheQuickBrownFox.
The positions used are one-based indices. In this example, we have the
options of specifying positions 1 to 16 inclusive.

.NOTES

This program is not intended to be used as a security product so
please be careful when extracting characters from a password for
example.

File Name    : Get-StringChars.ps1
Author       : Ian Molloy
Last updated : 2020-05-14T15:39:50

.LINK

about_Functions_Advanced_Parameters
https://technet.microsoft.com/en-us/library/hh847743.aspx

about_Comment_Based_Help
https://technet.microsoft.com/en-us/library/hh847834.aspx

https://ramblingcookiemonster.wordpress.com/2013/12/08/building-powershell-functions-best-practices/

#>

[CmdletBinding()]
Param (
    [parameter(Position=0,
               Mandatory=$true,
               HelpMessage="Phrase or password to look at")]
    [ValidateScript({$_.Length -ge 5})]
    [String]$Phrase,
    [parameter(Position=1,
               Mandatory=$true,
               HelpMessage="Character positions of interest to look at")]
    [ValidateCount(2,3)]
    [Byte[]]$CharPositions
) #end param

#region ***** function Get-LetterCase *****
function Get-LetterCase {
[CmdletBinding()]
Param (
    [parameter(Position=0,
               Mandatory=$true,
               HelpMessage="Character to determine whether it is upper or lower case")]
    [ValidateScript({$_.ToString().Length -eq 1})]
    [Char]$Letter
) #end param

# The numeric values used to determine whether the parameter
# is upper or lower case are decimal.

[String]$case = '';
$num = [Byte]$Letter;
switch ($num) {
    {65..90 -contains $PSItem} {$case = "(uppercase)"; Break}
    {97..122 -contains $PSItem} {$case = "(lowercase)"; Break}
    default {$case = ""; Break}
}

return $case;
}
#endregion ***** end of function Get-LetterCase *****

#region ***** function Indicate-Positions *****
function Indicate-Positions {
[CmdletBinding()]
Param (
    [parameter(Position=0,
               Mandatory=$true,
               HelpMessage="Phrase or password to look at")]
    [ValidateScript({$_.Length -ge 5})]
    [String]$Phrase,
    [parameter(Position=1,
               Mandatory=$true,
               HelpMessage="Character positions of interest to look at")]
    [ValidateCount(2,3)]
    [Byte[]]$ByteArray
) #end param

$len = $Phrase.Length;
$ba = New-Object -TypeName System.Collections.BitArray -ArgumentList $len;
$sb = New-Object -TypeName System.Text.StringBuilder -ArgumentList $len, $len;

# Manages a compact array of bit values, which are represented
# as Booleans, where true indicates that the bit is on (1) and
# false indicates the bit is off (0).
#
# A [System.Byte] array contains the integer positions which
# indicate which characters to display (extract) from the
# supplied input string. For every integer in this array, the
# corresponding bit position in the BitArray object will be
# set to true.
#
# The BitArray object is zero-based so this is why we
# subtract one from the actual value from the [System.Byte]
# array. If, for example, we have a value of 1 in the Byte
# array, we subtract 1 from this in order to set position
# 0 (zero) in the BitArray object to true which indicates
# a position of interest in the supplied input string.
foreach ($item in $ByteArray) {
    Write-Verbose "Setting for pos $item";
    $ba.Set(($item-1), $true) | Out-Null;
}

# For every zero-based index position in the BitArray object
# set to true, set the corresponding StringBuilder object
# position with a 'Caret - circumflex' character else set the
# StringBuilder object position with a space.
[String]$m = '';
foreach ($num in 0..($len-1)) {
    #
    $m = (($ba.Item($num)) ? "^" : " "); #Ternary operator
    $sb.Append($m) | Out-Null;
}

return $($sb.ToString());
}
#endregion ***** end of function Indicate-Positions *****

#--------------------------------------------------------------------
# Main routine starts here
#--------------------------------------------------------------------
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# Validate the parameters supplied to the program. Throw a
# terminating error if any parameters are invalid.
Invoke-Command -ScriptBlock {
  # The minimum value in array 'CharPositions' should be one (1).
  [Byte]$validate = ($CharPositions | Measure-Object -Minimum).Minimum;
  if ($validate -eq 0) {
      throw [System.ArgumentOutOfRangeException] "Minimum value allowed for parameter CharPositions is 1";
  }

  # Make sure the maximum value in array 'CharPositions'
  # is not greater than the length of string 'Phrase'.
  $validate = ($CharPositions | Measure-Object -Maximum).Maximum;
  if ($validate -gt $Phrase.Length) {
      $errmsg = "For the password/phrase supplied, values in parameter CharPositions cannot be greater than $($Phrase.Length)";
      throw [System.ArgumentOutOfRangeException] $errmsg;
  }

} #end scriptblock checks


# Display the phrase or password supplied and it's length.
Write-Output ("`nPhrase supplied: {0}     ({1} characters)" -f `
              $Phrase, $Phrase.Length);

# Show which character positiions we're looking for in the
# input string supplied.
Write-Output ("Looking for characters at positions: {0}" -f `
              [System.String]::Join(", ", $CharPositions));
Write-Output "";


# Find and display the characters requested.
# One is subtracted from the number requested, as positions in
# the string are 0-based, and the character positions requested
# (as supplied by the user) in [System.Byte] array
# 'CharPositions' are are 1-based. So if the character at
# position 1 is requested, it will be found at string index
# 0 not 1.
foreach ($num in $CharPositions) {
     $letter = $Phrase[$num - 1];
     $case = Get-LetterCase -Letter $letter;
     Write-Output ('Position {0}:  {1}     {2}' -f $num, $letter, $case);
}
$result = Indicate-Positions -Phrase $Phrase -ByteArray $CharPositions;
Write-Output "";
Write-Output "Positions indicated in phrase:";
Write-Output $Phrase;
Write-Output $result;

##=============================================
## END OF SCRIPT: Get-StringChars.ps1
##=============================================
