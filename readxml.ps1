#
[CmdletBinding()]
Param () #end param

#region ***** Function Get-XmlReader *****
function Get-XmlReader {
[CmdletBinding()]
[OutputType([System.Xml.XmlReader])]
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="XML file to read")]
        [ValidateNotNullOrEmpty()]
        [String]$Filename
      ) #end param

BEGIN {
if (-not (Test-Path -Path $Filename)) {
    Write-Error -Message "Cannot find path '$Filename' because it does not exist" `
     -Category ObjectNotFound `
     -RecommendedAction "Supply correct filename" `
     -CategoryActivity "Opening input file" `
     -CategoryReason "File not found" `
     -CategoryTargetName $Filename `
     -CategoryTargetType "XML file"
}
$xsettings = New-Object -TypeName 'System.Xml.XmlReaderSettings';
$xsettings.Async = $false;
$xsettings.CheckCharacters = $true;
$xsettings.CloseInput = $true;
$xsettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Document;
$xsettings.DtdProcessing = [System.Xml.DtdProcessing]::Ignore;
$xsettings.IgnoreComments = $true;
$xsettings.IgnoreProcessingInstructions = $true;
$xsettings.IgnoreWhitespace = $true;

$xobj = [System.Xml.XmlReader]::Create($Filename, $xsettings);

}

PROCESS {}

END {
  return $xobj;
}

}
#endregion ***** End of function Get-XmlReader *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

New-Variable -Name 'inputXML' -Value 'C:\Family\ian\hello.xml' -Option Constant `
             -Description 'XML file to process';
New-Variable -Name indentInc -Value 4 -Option Constant `
             -Description 'Amount by which text is indented/decremented by';
$xmlline = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList 100;
$xreader = Get-XmlReader $inputXML;
# An start element tag, ie <item>.
$element = [System.Xml.XmlNodeType]::Element;
# An end element tag ie ie </item>.
$endelement = [System.Xml.XmlNodeType]::EndElement;
$indentVal = 0; # The current value by which a line will be indented.
$Depth = 0; # Holds the depth of the current node in the XML document.

Write-Output "Processing XML file $inputXML";

while ($xreader.Read()) {

    if ($xreader.Depth -gt $Depth) {
        # Increase the indent.
        $indentVal += $indentInc;
    } elseif ($xreader.Depth -lt $Depth) {
        # Decrease the indent.
        $indentVal -= $indentInc;
    }

    # Empty the StringBuilder object ready for the next line to construct.
    $xmlline.Length = 0;
    switch ($xreader.NodeType) {
        $element {
            # A start element tag

            Write-Verbose "depth is now $($xreader.Depth)"
            $xmlline.Append("".PadLeft($indentVal, " ")) | Out-Null;
            $xmlline.Append('<') | Out-Null;
            $xmlline.Append($($xreader.Name)) | Out-Null;
            $xmlline.Append('>') | Out-Null;
            Write-Output $xmlline.ToString();

            break;}
        $endelement {
            # An end element tag

            Write-Verbose "depth is now $($xreader.Depth)"
            $xmlline.Append("".PadLeft($indentVal, " ")) | Out-Null;
            $xmlline.Append('</') | Out-Null;
            $xmlline.Append($($xreader.Name)) | Out-Null;
            $xmlline.Append('>') | Out-Null;
            Write-Output $xmlline.ToString();

            break;}
        default {break;}
    }# end switch

    $Depth = $xreader.Depth;
} #end WHILE loop

$xreader.Dispose();
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: readxml.ps1
##=============================================
