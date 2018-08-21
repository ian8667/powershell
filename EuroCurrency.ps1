<#
.SYNOPSIS

Displays up-to-date currency exchange rates

.DESCRIPTION

Displays up-to-date currency exchange rates from the European Central
Bank (ECB) for certain selected currencies. Currencies other than those
of interest are ignored. The European Central Bank is the central bank
for the euro and administers monetary policy of the eurozone, which
consists of 19 EU member states and is one of the largest currency areas
in the world.

.EXAMPLE

./EuroCurrency.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : EuroCurrency.ps1
Author       : Ian Molloy
Last updated : 2017-07-25

.LINK

Hashtable Class
Represents a collection of key/value pairs that are organized based on the hash code of the key.
https://msdn.microsoft.com/en-us/library/system.collections.hashtable(v=vs.110).aspx

Approved Verbs for Windows PowerShell Commands
https://msdn.microsoft.com/en-us/library/ms714428(v=vs.85).aspx#Similar Verbs for Different Actions

Get-Verb
The Get-Verb function gets verbs that are approved for use in Windows PowerShell commands.
https://msdn.microsoft.com/en-us/powershell/reference/5.0/microsoft.powershell.core/functions/get-verb

Strongly Encouraged Development Guidelines
https://msdn.microsoft.com/en-us/library/dd878270(v=vs.85).aspx

European Central Bank
https://www.ecb.europa.eu/home/html/index.en.html

XE Currency Converter
http://www.xe.com/

OANDA Corporation is a registered Futures Commission Merchant and
Retail Foreign Exchange Dealer
https://www.oanda.com/

About Reserved Words
https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_reserved_words

#>
[CmdletBinding()]
Param () #end param

#region ***** function Get-Xmldata *****
function Get-Xmldata {
[CmdletBinding()]
[OutputType([System.Object[]])]
param ()

BEGIN {

  # The European Central Bank exchange rate data URI which is
  # the source of our data.
  $ecbURL="http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";

  #$ecbURL='C:/family/powershell/Data/ecb_fx_data.xml';

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
[CmdletBinding()]
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
[CmdletBinding()]
[OutputType([System.Void])]
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
  # iterate over the remaining items as they are 'dollar' currencies.
  $Currencies.Remove("GBP");
  Write-Output '';

  # iterate over the remaining entries in the hashtable.
  Foreach ($hh in $Currencies.GetEnumerator()) {

      $decstr = Convert-ToDecimal $hh.Value;
      Write-Output ('1 GBP{0} = {1}{2} {3}' -f `
                    $CurrSymbol.GBP, `
                    $hh.Name, `
                    $CurrSymbol.DOLLAR, `
                    $decstr);
  } #end Foreach loop

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
           EUR      = [char]0x20AC   # Euro symbol
           GBP      = [char]0x00A3   # GBP (pound) symbol
           DOLLAR   = [char]0x0024   # Dollar symbol
          }

}

PROCESS {

  # In Windows PowerShell 3.0 (and this continues in Windows
  # PowerShell 4.0), it is even easier to create custom objects.
  #$myObject = [PSCustomObject]$hash;
  $myObject = New-Object PSObject -Property $hash;
}

END {

  return $myObject;

}

}
#endregion ***** end of function Create-CurrencySymbol *****

#region ***** function Other-Currency *****
function Other-Currency {
[CmdletBinding()]
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
[CmdletBinding()]
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

#region ***** function Start-MainRoutine *****
function Start-MainRoutine {
[CmdletBinding()]
[OutputType([System.Void])]
Param () #end param

BEGIN {

  # Get the XML currency data of interest.
  $mydata = Get-Xmldata;

  # Define some character currency symbols.
  $CurrSymbol = Create-CurrencySymbol;

  # The list of wanted currency symbols that we are interested in.
  $wantedSymbols = @('USD','GBP','AUD','NZD');
  Set-Variable -Name wantedSymbols `
               -Description 'The list of wanted currency symbols' `
               -Option ReadOnly;

  # Empty hash table where we eventually store our wanted
  # currency rates once they are converted.
  #
  # So the hash table key/value pairs will eventually look
  # like:
  # @{ <name>, <value>; } ie
  # @{ <currency symbol>, <value of that currency to the Euro>; }
  $myhash = @{}

}

PROCESS {

  # Loop through all of the currency rates available in our XML object.
  Foreach ($xmlProperty in $mydata) {

      # If this is a wanted currency make a note of it. Otherwise
      # ignore it as we don't want it.
      if ($xmlProperty.currency -in $wantedSymbols) {
          $myhash.Add($xmlProperty.currency, $xmlProperty.rate);
      }

  } #end Foreach loop

  $convertedCurrencies = Convert-Currencies $myhash;

}

END {

  Display-ExchangeRate $convertedCurrencies;

}

}
#endregion ***** end of function Start-MainRoutine *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

Clear-Host;
Write-Output '';
Write-Output 'Currency exchange rates from the European Central Bank';
Write-Output ('Today is {0:dddd, dd MMMM yyyy}' -f (Get-Date));
Invoke-Command -ScriptBlock {

   Write-Output '';
   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

Start-MainRoutine;

Write-Output '';
Write-Output 'End of output';

##=============================================
## END OF SCRIPT: EuroCurrency.ps1
##=============================================
