# PowerShell script to obtain currency rates from
# the European Central Bank.
#
cls;
#$url = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
$url = 'http://www.ecb.europa.eu/rss/fxref-gbp.html'

#$xml = New-Object xml
$xml = New-Object -TypeName System.Xml.XmlDocument;

# Loads the XML document from the specified URL.
$xml.Load($url)

$xml.RDF.Item |
    ForEach-Object {
        $this = $_;

        $rv = 1 | Select-Object Date, Currency, Rate, Description
        $rv.Date = [DateTime]$this.Date
        $rv.Description = $this.description.'#text'
        $rv.Currency = $this.statistics.exchangeRate.targetCurrency
        $rv.rate = $this.statistics.exchangeRate.value.'#text'
        $rv | fl;
    }

