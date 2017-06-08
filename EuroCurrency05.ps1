<#
$states = @{"Washington" = "Olympia"; "Oregon" = "Salem"; California = "Sacramento"}
$states.GetEnumerator() | Sort-Object Name

-----

Option 1: GetEnumerator()

Note: personal preference; syntax is easier to read

The GetEnumerator() method would be done as shown:

foreach ($hh in $hash.GetEnumerator()) {
    Write-Host "$($hh.Name):   $($hh.Value)"
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
#region ***** function Display-ExchangeRates *****
function Display-ExchangeRates {
[cmdletbinding()]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $Currencies
      ) #end param

BEGIN {
  Write-Host 'Inside function Display-ExchangeRates';
  $results = $Currencies.GetEnumerator() | Where-Object { $_.Key -in ('GBP') }

}

PROCESS {
  Write-Host ('1 GBP{0} = EUR{1} {2} ' -f $CurrSymbol.GBP, $CurrSymbol.EUR, $results.value);
  $Currencies.Remove("GBP");

  foreach ($hh in $Currencies.GetEnumerator()) {
      Write-Host ('1 GBP{0} = {1}{2} {3}' -f `
                $CurrSymbol.GBP,$hh.Name,$CurrSymbol.DOLLAR,$hh.Value);
  }

}

END {
}

}
#endregion ***** end of function Display-ExchangeRates *****

#region ***** function Create-CurrencySymbols *****
function Create-CurrencySymbols {

BEGIN {
  $hash = @{
          EUR         = [char]0x20AC;   # Euro symbol
          GBP         = [char]0x00A3;   # GBP (pound) symbol
          DOLLAR      = [char]0x0024;   # Dollar symbol
          }
}

PROCESS {
  $Object = New-Object PSObject -Property $hash
}

END {
  return $Object;
}

}
#endregion ***** end of function Create-CurrencySymbols *****

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

  $dec = [System.Convert]::ToDouble($Currency);
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

function Convert-Currencies {
[cmdletbinding()]
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

  # Create an empty System.Collections.Hashtable object for the
  # currencies when converted.
  $converted = @{}

}

PROCESS {

  foreach ($hh in $Currencies.GetEnumerator()) {

    switch ($hh.Name) {
          "GBP" {$result = [System.Numerics.Complex]::Reciprocal($gbpDub)
                 $converted.Add($hh.Name,$result.Real);
                 break;}
          default {$result = Other-Currency $hh.Value $gbpDub;
                   $converted.Add($hh.Name,$result);
                   break;}
    } #end switch statement

  } #end foreach loop

}

END {

  # Return a 'System.Collections.Hashtable' object containing
  # the converted currencies.
  return $converted;
}
}

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Clear-Host;
Write-Host 'Start of test';

# Specify European Central Bank exchange rate data URI.
$ecbURL='http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml';
#$ecbURL='C:/family/powershell/Data/ecb_fx_data.xml';
Write-Host ('URL path used is {0}' -f $ecbURL);


# Load the currency data into our XML object.
$myxml = New-Object xml;
$myxml.Load($ecbURL);

$mydata = $myxml.Envelope.Cube.Cube.Cube;

# Define some currency symbols.
$CurrSymbol = Create-CurrencySymbols;

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

Write-Host 'Original values picked up';
$myhash;
$convertedCurrencies = Convert-Currencies $myhash;
Write-Host ('{0} entries in myhash hash table' -f $myhash.Count);

# Currencies converted as we want them.
# Use a function to display the results?
Write-Host 'convertedCurrencies - pass 1';
foreach ($hh in $convertedCurrencies.GetEnumerator()) {
      Write-Host "$($hh.Name): ->  $($hh.Value)"
}

##=============================================

Write-Host 'convertedCurrencies - pass 3';
Display-ExchangeRates $convertedCurrencies;

Write-Host "`nEnd of test";

##=============================================
## END OF SCRIPT: EuroCurrency05.ps1
##=============================================
