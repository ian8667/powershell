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
