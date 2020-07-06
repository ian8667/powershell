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

ISO 4217 Currency Codes

Every world currency has an assigned code(ie NZD), used on currency
exchange markets, and a currency code symbol (ie $) which is typically
used when pricing goods in a store, or dishes in a restaurant for
example. The International Organization for Standardization (ISO)
publishes a list of standard currency codes referred to as the
ISO 4217 code list.

The first two letters of the code are the two letters of the
ISO 3166-1 alpha-2 country codes (which are also used as the basis
for national top-level domains on the Internet) and the third is
usually the initial of the currency itself. So Japan's currency code
is JPY, JP for Japan and Y for yen.

Currency codes are composed of a country's two-character Internet
country code plus a third character denoting the currency unit. For
example, the Canadian Dollar code (CAD) is made up of Canada's
Internet code ("CA") plus a currency designator ("D").

The currency code for (Australian) Dollars is AUD, and the currency
symbol is $. Currency symbols are part of the Unicode point range
from 20A0 to 20CF. Currency symbols are a quick and easy way to show
specific currency names in a written form. It’s a convenient shorthand,
replacing the words with a graphic symbol for ease - for example $40
instead of the full version - 40 US dollars.

Summary

Currency code - NZD (New Zealand dollar)
Currency symbol (or currency sign) - $

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
Last updated : 2020-07-06T18:47:29

System.Numerics.Complex
Returns the multiplicative inverse of a complex number.
$recip = [System.Numerics.Complex]::Reciprocal(0.25);
$recip.real;
or
for example, 1 / 0.25.

Sample output:

1 GBP£ = EUR€ 1.1096

1 GBP£ = NZD$ 1.909
1 GBP£ = USD$ 1.2455
1 GBP£ = AUD$ 1.7948

.LINK

European Central Bank
https://www.ecb.europa.eu/home/html/index.en.html

XE Currency Converter
http://www.xe.com/

OANDA Corporation is a registered Futures Commission Merchant and
Retail Foreign Exchange Dealer
https://www.oanda.com/

Currency Symbol
https://www.investopedia.com/terms/c/currency-symbol.asp

Invoke-WebRequest
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7

About Functions Advanced Parameters
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7

Strongly Encouraged Development Guidelines
https://msdn.microsoft.com/en-us/library/dd878270(v=vs.85).aspx

#>

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Display-ExchangeRate *****
function Display-ExchangeRate {
[CmdletBinding()]
param (
    [Parameter(Position=0,
               Mandatory=$true,
               HelpMessage="Currency symbol or currency sign")]
    [ValidateSet('AUD','EUR','NZD','USD')]
    [String]$CurrencyCode,

    [Parameter(Position=1,
               Mandatory=$true,
               HelpMessage="Value of the currency code concerned")]
    [ValidateRange("Positive")]
    [Double]$CurrencyValue
) #end param

    begin {

        $CurrencySign = @{
            EUR     = [char]0x20AC   # Euro sign
            GBP     = [char]0x00A3   # GBP (pound) sign
            DOLLAR  = [char]0x0024   # Dollar sign
        }
        switch ($CurrencyCode) {
            'EUR' {$sign = $CurrencySign.EUR; break;}
            default {$sign = $CurrencySign.DOLLAR; break;}
        }

    }

    process {
        Write-Output ('1 GBP{0} = {1}{2} {3:N4}' -f `
           $CurrencySign.GBP, `
           $CurrencyCode, `
           $sign, `
           $CurrencyValue);

    }

    end {}
}
#endregion ***** end of function Display-ExchangeRate *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
$address = 'https://api.exchangeratesapi.io/latest';
$uri = New-Object -TypeName System.Uri -ArgumentList $address;

$splat = @{
    # Splat data for use with Invoke-WebRequest cmdlet.
    Uri               = $uri
    Method            = 'Get'
    TimeoutSec        = 5
    MaximumRetryCount = 5
    RetryIntervalSec  = 3
}
$allData = Invoke-WebRequest @splat;
if ($allData.StatusCode -ne 200) {
    #Problems with the data
    Write-Error -Message 'Problems with the data';
}

#Currency codes of interest
[String[]]$cCodes = @('AUD','NZD','USD');

#Get the currency rates from the json object
$rates = $allData.Content | ConvertFrom-Json | Select-Object -ExpandProperty rates;

Set-Variable -Name 'address','uri','allData','rates','cCodes' -Option ReadOnly;

#GBP to EUR
$gbp = 1 / $rates.gbp;
Set-Variable -Name 'gbp' -Option ReadOnly;
Display-ExchangeRate -CurrencyCode 'EUR' -CurrencyValue $gbp;

#Process our currency codes of interest
foreach ($code in $cCodes) {
    Write-Output '';
    Write-Verbose -Message "Country code: GBP to $code";
    Display-ExchangeRate -CurrencyCode $code -CurrencyValue ($gbp * $rates.$code);
}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'All done now';
##=============================================
## END OF SCRIPT: EuroCurrency.ps1
##=============================================
