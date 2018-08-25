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
which ask for randomly selected characters from a password or user
ID. The program saves me from hunting down these characters and will
display them for me. I.e., if I want the characters from positions one
and seven, for example, then 1,7 should be supplied to parameter
'CharPositions'.

.PARAMETER Phrase

(mandatory) contains the password or User ID which will be searched
for characters to be displayed.

.PARAMETER CharPositions

(mandatory) a byte array containing the positions from which to display
the requested characters. If the first, second and fifth characters are
required, then enter a value of 1,2,5.

Due to the intended use of this program, only two or three characters
can be selected. Any other number of integer digits entered will
generate an error.

.EXAMPLE

./Get-StringChars.ps1 -Phrase helloworld -CharPositions 2,3,5

Displays characters at positions 2,3 and 5 from the phrase helloworld.

.EXAMPLE

./Get-StringChars.ps1 -Phrase helloworldtwo -CharPositions 8,12

Displays characters at positions 8 and 12 from the phrase helloworldtwo.

.NOTES

This program is not intended to be used as a security product so
please be careful when extracting characters from a password for
example.

File Name    : Get-StringChars.ps1
Author       : Ian Molloy
Last updated : 2017-12-31

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
               HelpMessage="Phrase to look at")]
    [String]$Phrase,
    [parameter(Position=1,
               Mandatory=$true,
               HelpMessage="Character positions of interest to look at")]
    [ValidateCount(2,3)]
    [Byte[]]$CharPositions
) #end param


#--------------------------------------------------------------------
# Main routine starts here
#--------------------------------------------------------------------
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# Convert the character positions of the input array to
# a string so we can display them later to remind us
# which character positions of the input phrase we're
# looking for.
[System.Char[]]$myArray = $CharPositions.ToString();

# Display the phrase supplied.
Write-Host ("`nPhrase supplied: {0}     ({1} characters)" -f `
            [System.String]::Join("", $Phrase), $Phrase.Length);

# Show which character positiions we're looking for.
Write-Host ("Looking for characters at Positions: {0}" -f `
            [System.String]::Join(", ", $CharPositions));
Write-Host "";

# Find and display the characters requested.
# One is subtracted from the number requested as positions in
# the string are 0-based, the character positions requested
# (supplied by the user) are 1-based. So if character position 1
# is requested, it will be found at string index 0 not 1.
foreach ($num in $CharPositions) {
     Write-Host ('Position {0}:  {1}' -f $num, $Phrase[$num - 1]);
}

##=============================================
## END OF SCRIPT: Get-StringChars.ps1
##=============================================
