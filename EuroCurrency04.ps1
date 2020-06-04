<#
  # Find the exchange rate data for currency symbol GBP.
  $gbp = $exRates |
       Where-Object { $_.currency -eq 'GBP' } |
       Select-Object -ExpandProperty rate;

#>

function foo01 {

Begin {
  # Create an XML object to hold our exchange rates data
  $myxml = New-Object xml;
  
  # Specify European Central Bank exchange rate data URI.
  $ecbURL='http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml';

  # Load the data into our XML object.
  $myxml.Load($ecbURL);

  # Get the exchange rates portion of the data.
  $exRates = $myxml.Envelope.Cube.Cube.Cube;
  
  # Identifies when the data was compiled. Although the tag
  # in the XML structure is written as 'time', the data
  # returned from this node is data in the format of
  # YYYY-MM-DD.
  $ttime = $myxml.Envelope.Cube.Cube.time;
  
  # In effect the title of this data feed.
  $subject = $myxml.Envelope.subject;

  # Source of the data which is typically returned as 'European Central Bank'.
  $dataSource = $myxml.Envelope.Sender.name;
  
  # Define the Euro and pound (GBP) currency symbols.
  $euroSymbol=[char]0x20AC;
  $poundSymbol=[char]0x00A3;
  $usdSymbol=[char]0x0024;
}

Process {
  # Find the exchange rate data for currency symbol GBP.
  $gbp = $exRates |
       Where-Object { $_.currency -eq 'GBP' } |
       Select-Object -ExpandProperty rate;
}

End {

  Write-Host ("{0} as of {1}" -f $subject, $ttime);
  Write-Host ("Source of data: {0}" -f $dataSource);
  Write-Host ("Current GBP exchange rate: {0}" -f $gbp);
  $dd=[System.Convert]::ToDecimal($gbp);

  Write-Host ("{0}1" -f $euroSymbol);
  Write-Host ("{0}1" -f $poundSymbol);
  Write-Host ("{0}1" -f $usdSymbol);
}

} #end function foo01

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

foo01;

##=============================================
## END OF SCRIPT: EuroCurrency04.ps1
##=============================================
