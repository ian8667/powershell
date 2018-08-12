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

$xmlline = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList 100;
$ff = 'C:\Family\ian\hello.xml';
$xreader = Get-XmlReader $ff;
# An start element tag, ie <item>.
$element = [System.Xml.XmlNodeType]::Element;
# An end element tag ie ie <item>.
$endelement = [System.Xml.XmlNodeType]::EndElement;
$indentVal = 0;
$Depth = 0;
New-Variable -Name indentInc -Value 4 -Option Constant `
             -Description 'Amount by which text is indented/decremented by';

Write-Output 'Start of test';

while ($xreader.Read()) {

    if ($xreader.Depth -gt $Depth) {
        # Increase the indent.
        $indentVal += $indentInc;
    } elseif ($xreader.Depth -lt $Depth) {
        # Decrease the indent.
        $indentVal -= $indentInc;
    }

    $xmlline.Length = 0;
    switch ($xreader.NodeType) {
        $element {
            # A start element tag
            $xmlline.Append("".PadLeft($indentVal, " ")) | Out-Null;
            $xmlline.Append('<') | Out-Null;
            $xmlline.Append($($xreader.Name)) | Out-Null;
            $xmlline.Append('>') | Out-Null;
            Write-Output $xmlline.ToString();

            Write-Verbose("Depth = {0}" -f $xreader.Depth);
            break;}
        $endelement {
            # An end element tag
            #$tagname = -Join ($xreader.Name, ">");
            #$tagname = -Join ('</', 'parttwo', '>');
            #$tagname = -Join ($xreader.Name, '>');

            #$tagname = ("{0,$($indentVal)}{1}>" -f "</", $xreader.Name);
            #Write-Output("{0,$($indentVal)}{1}" -f "</", $($tagname));
            #Write-Output("{0,$($indentVal)}{1}" -f '</', $xreader.Name, ">");
            $xmlline.Append("".PadLeft($indentVal, " ")) | Out-Null;
            $xmlline.Append('</') | Out-Null;
            $xmlline.Append($($xreader.Name)) | Out-Null;
            $xmlline.Append('>') | Out-Null;
            Write-Output $xmlline.ToString();

            #Write-Output ("{0,$($indentVal)}" -f 'hellotagname');
            Write-Verbose("Depth = {0}" -f $xreader.Depth);
            Write-Verbose("indent = {0}" -f $indentVal);
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
