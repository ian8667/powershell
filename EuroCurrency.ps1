<#
<item rdf:about="http://www.ecb.europa.eu/stats/exchange/eurofxref/html/eurofxref-graph-gbp.en.html?date=2016-09-02&amp;rate=0.84260">
<title xml:lang="en">0.84260 GBP = 1 EUR 2016-09-02 ECB Reference rate</title>
<link>http://www.ecb.europa.eu/stats/exchange/eurofxref/html/eurofxref-graph-gbp.en.html?date=2016-09-02&amp;rate=0.84260</link>
<description xml:lang="en">1 EUR buys 0.84260 Pound sterling (GBP) - The reference exchange rates are published both by electronic market information providers and on the ECB's website shortly after the concertation procedure has been completed. Reference rates are published according to the same  calendar as the TARGET system.</description>
<dc:date>2016-09-02T14:15:00+01:00</dc:date>
<dc:language>en</dc:language>
<cb:statistics>
<cb:country>U2</cb:country>
<cb:institutionAbbrev>ECB</cb:institutionAbbrev>
<cb:exchangeRate>
<cb:value frequency="daily" decimals="5">0.84260</cb:value>
<cb:baseCurrency unit_mult="0">EUR</cb:baseCurrency>
<cb:targetCurrency>GBP</cb:targetCurrency>
<cb:rateType>Reference rate</cb:rateType>
</cb:exchangeRate>
</cb:statistics>
</item>

#>

# PowerShell script to obtain currency rates from
# the European Central Bank.
#
# XmlDocument Class
# https://msdn.microsoft.com/en-us/library/system.xml.xmldocument(v=vs.110).aspx
#
cls;
#$url = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
$url = 'http://www.ecb.europa.eu/rss/fxref-gbp.html'

#$xml = New-Object xml
$xdoc = New-Object -TypeName System.Xml.XmlDocument;
[System.Xml.XmlNode]$xnode = $null;

# Loads the XML document from the specified URL.
$xdoc.Load($url)

# -----

$root = $xdoc.DocumentElement.ToString();
Write-Host ('Root node is {0}' -f $root);
$xnode = $xdoc.FirstChild;
Write-Host ('Child 1 is {0}' -f $xnode.ToString());
Write-Host ('has any child nodes {0}' -f $xdoc.HasChildNodes);
$xnode = $xdoc.LastChild;
Write-Host ('Last child is {0}' -f $xnode.ToString());


# -----

$xdoc.RDF.item |
    ForEach-Object {
        $this = $_;

        $rv = 1 | Select-Object Date, Currency, Rate, Description
        $rv.Date = [DateTime]$this.Date
        $rv.Description = $this.description.'#text'
        $rv.Currency = $this.statistics.exchangeRate.targetCurrency
        $rv.rate = $this.statistics.exchangeRate.value.'#text'
        $rv | Format-List;
    }

#Write-Host 'Trying to look at SelectNodes';
#Write-Output $xdoc.SelectNodes("///language");


Write-Host 'All done now';
