<#

Option 1: GetEnumerator()

Note: personal preference; syntax is easier to read

The GetEnumerator() method would be done as shown:

foreach ($hh in $hash.GetEnumerator()) {
    Write-Output "$($hh.Name):   $($hh.Value)"
}
Source: http://stackoverflow.com/questions/9015138/powershell-looping-through-a-hash-or-using-an-array

-----
Can I make of this?
$fred = [System.Numerics.Complex]::Reciprocal(0.86868)
$fred.Real
= 1.15117189298706
is the same as: 1/0.86868

Returns the multiplicative inverse (reciprocal) of a complex number.

-----

Hashtable Class
Represents a collection of key/value pairs that are organized based on the hash code of the key.
https://msdn.microsoft.com/en-us/library/system.collections.hashtable(v=vs.110).aspx

#>
#region ***** function Get-Xmldata *****
function Get-Xmldata {

BEGIN {
#Write-Host 'inside Get-Xmldata';
  # Specify European Central Bank exchange rate data URI.
  #$ecbURL="http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";
  
  $ecbURL='C:/family/powershell/Data/ecb_fx_data.xml';
#  Write-Output ('Source data: {0}' -f $ecbURL);

}

PROCESS {

  # Create and load the currency data into our XML
  # (System.Xml.XmlDocument) object.
  $xmldata = New-Object xml; # TypeName: System.Xml.XmlDocument
  $xmldata.Load($ecbURL);

  # Get the portion of the XML document of interest.
  $mydata = $xmldata.Envelope.Cube.Cube.Cube; # TypeName: System.Object[]

}

END {
  return $mydata;
}
}
#endregion ***** end of function Get-Xmldata *****

#region ***** function Convert-ToDecimal *****
function Convert-ToDecimal {
[cmdletbinding()]
[OutputType([System.Double])]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $strnum
      ) #end param

BEGIN {

  $roundAway = [System.MidpointRounding]::AwayFromZero;
  [System.Double]$dec1 = 0.0;
  [System.Double]$dec2 = 0.0;
  [System.Int32]$decPlaces = 4;
  Set-Variable -Name $decPlaces -Option ReadOnly;
  [System.Boolean]$retval = $false;
  $numStyle = [System.Globalization.NumberStyles]::AllowDecimalPoint -bor
              [System.Globalization.NumberStyles]::AllowLeadingWhite -bor
              [System.Globalization.NumberStyles]::AllowTrailingWhite;

}

PROCESS {

  # parse and convert the string to a decimal number.
  $retval = [System.Double]::TryParse($strnum, $numStyle, $null, [ref]$dec1);

  # round the decimal number to the required decimal places.
  $dec2 = [System.Math]::Round($dec1, $decPlaces);

}

END {

  return $dec2;
}

}
#endregion ***** end of function Convert-ToDecimal *****

#region ***** function Display-ExchangeRate *****
function Display-ExchangeRate {
[cmdletbinding()]
[OutputType()]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $Currencies
      ) #end param

BEGIN {


  $results = $Currencies.GetEnumerator() | Where-Object { $_.Key -in ('GBP') }
  [System.Double]$decstr = 0.0;

}

PROCESS {

  # deal with GBP currency first.
  Write-Output '';
  $decstr = Convert-ToDecimal $results.Value;
  Write-Output ('1 GBP{0} = EUR{1} {2} ' -f $CurrSymbol.GBP, $CurrSymbol.EUR, $decstr);
  # removing the GBP symbol from the hashtable will allow us to
  # iterate over the remaining as they are 'dollar' currencies.
  $Currencies.Remove("GBP");
  Write-Output '';

  # iterate over the remaining entries in the hashtable.
  Foreach ($hh in $Currencies.GetEnumerator()) {

      $decstr = Convert-ToDecimal $hh.Value;
      Write-Output ('1 GBP{0} = {1}{2} {3}' -f `
                $CurrSymbol.GBP,$hh.Name,$CurrSymbol.DOLLAR,$decstr);
  }

}

END {}

}
#endregion ***** end of function Display-ExchangeRate *****

#region ***** function Create-CurrencySymbol *****
function Create-CurrencySymbol {
[CmdletBinding()]
[OutputType([System.Management.Automation.PSCustomObject])]
param ()

BEGIN {
  $hash = @{
          EUR       = [char]0x20AC;   # Euro symbol
          GBP       = [char]0x00A3;   # GBP (pound) symbol
          DOLLAR    = [char]0x0024;   # Dollar symbol
          }
}

PROCESS {
  $myObject = New-Object PSObject -Property $hash;
}

END {
  return $myObject;
}

}
#endregion ***** end of function Create-CurrencySymbol *****

#region ***** function Other-Currency *****
function Other-Currency {
[cmdletbinding()]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Currency,
        [parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [System.Double]
        $gbp
      ) #end param

BEGIN {

  [System.Double]$dec = [System.Convert]::ToDouble($Currency);
  [System.Double]$result = 0.0;

}

PROCESS {

  $result = $dec / $gbp;

}

END {

  return $result;

}

}
#endregion ***** end of function Other-Currency *****

#region ***** function Convert-Currencies *****
function Convert-Currencies {
[cmdletbinding()]
[OutputType([System.Collections.Hashtable])]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $Currencies
      ) #end param

BEGIN {

  [System.Double]$dub = [System.Convert]::ToDouble($Currencies.Get_Item("GBP"));
  Set-Variable -Name gbpDub `
               -Value $dub `
               -Description 'The value of the EUR to GBP' `
               -Option ReadOnly;

  # Create an empty System.Collections.Hashtable object to
  # hold the currencies when converted.
  $converted = @{}

}

PROCESS {

  Foreach ($hh in $Currencies.GetEnumerator()) {

    switch ($hh.Name) {
          "GBP" {$result = [System.Numerics.Complex]::Reciprocal($gbpDub)
                 $converted.Add($hh.Name,$result.Real);
                 break;}
          default {$result = Other-Currency $hh.Value $gbpDub;
                   $converted.Add($hh.Name,$result);
                   break;}
    } #end switch statement

  } #end Foreach loop

}

END {

  # Return a 'System.Collections.Hashtable' object containing
  # the converted currencies.
  return $converted;
}
}
#endregion ***** end of function Convert-Currencies *****


##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Set-StrictMode -Version Latest;

Clear-Host;
Write-Output 'Start of test';

# Specify European Central Bank exchange rate data URI.
#$ecbURL='http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml';
#$ecbURL='C:/family/powershell/Data/ecb_fx_data.xml';
#Write-Output ('Source data: {0}' -f $ecbURL);


# Create and load the currency data into our XML
# (System.Xml.XmlDocument) object.
#$myxml = New-Object xml; # TypeName: System.Xml.XmlDocument
#$myxml.Load($ecbURL);

# Get the portion of the XML document of interest.
#$mydata = $myxml.Envelope.Cube.Cube.Cube; # TypeName: System.Object[]
write-host 'getting xml data';
$mydata = Get-Xmldata;
write-host 'getting xml data - done';

write-host 'character currency symbols';
# Define some character currency symbols.
$CurrSymbol = Create-CurrencySymbol;
write-host 'character currency symbols - done';

# The list of wanted currency symbols that we are interested in.
$wantedSymbols = @('USD','GBP','AUD','NZD');
Set-Variable -Name wantedSymbols `
             -Description 'The list of wanted currency symbols' `
             -Option ReadOnly;

# Empty hash table where we eventually store our wanted
# currency rates when converted.
#
# So the hash table key/value pairs will eventually look
# like:
# @{ <name>, <value>; } ie
# @{ <currency symbol>, <value of that currency to the Euro>; }
$myhash = @{}

# Loop through all of the currency rates available in our XML object.
Write-Host 'mydata mydata';
Write-Host 'mydata mydata - done';

Foreach ($xmlProperty in $mydata) {

    # If this is a wanted currency make a note of it. Otherwise
    # ignore it as we don't want it.
    if ($xmlProperty.currency -in $wantedSymbols) {
        $myhash.Add($xmlProperty.currency, $xmlProperty.rate);
    }

} #end Foreach loop

# Windows PowerShell Tip of the Week - hash tables
# https://technet.microsoft.com/en-us/library/ee692803.aspx
# Has columns 'Name' and 'Value'.

#Write-Output 'Original values picked up';
#$myhash;
$convertedCurrencies = Convert-Currencies $myhash;

Display-ExchangeRate $convertedCurrencies;

Write-Output "`nEnd of test";

##=============================================
## END OF SCRIPT: EuroCurrency05.ps1
##=============================================
