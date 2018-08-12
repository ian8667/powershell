#
[CmdletBinding()]
Param () #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

$settings = New-Object -TypeName System.Xml.XmlReaderSettings;
$settings.Async = $true;
$settings.CheckCharacters = $true;
$settings.CloseInput = $true;
$settings.ConformanceLevel = [System.Xml.ConformanceLevel]::Document;
$settings.IgnoreWhitespace = $true;
$ff = 'C:\Family\ian\hello.xml';
$element = [System.Xml.XmlNodeType]::Element;
$endelement = [System.Xml.XmlNodeType]::EndElement;
$prolog = [System.Xml.XmlNodeType]::XmlDeclaration;
$indent = 0;
# $Depth = @{ Old = 0;
#             New = 0;}
$Depth = 0;
New-Variable -Name indentInc -Value 4 -Option ReadOnly `
             -Description 'Amount by which text is indented by';
$tagname = "";
$reader = [System.Xml.XmlReader]::Create($ff, $settings);

Write-Output 'Start of test';

while ($reader.Read()) {

    if ($reader.Depth -gt $Depth) {
        # Increase the indent.
        $indent += $indentInc;
    } elseif ($reader.Depth -lt $Depth) {
        # Decrease the indent.
        $indent -= $indentInc;
    }

    switch ($reader.NodeType) {
        $element {
            # A start element tag
            Write-Output("{0,$($indent)}{1}>" -f "<", $reader.Name);
            Write-Verbose("Depth = {0}" -f $reader.Depth);
            break;}
        $endelement {
            # An end element tag
            #$tagname = -Join ($reader.Name, ">");
            #$tagname = -Join ('</', 'parttwo', '>');
            $tagname = -Join ($reader.Name, '>');
            
            #Write-Output("tagname === $tagname");
            #Write-Output("indent === $($indent)");

            #$tagname = ("{0,$($indent)}{1}>" -f "</", $reader.Name);
            #Write-Output("{0,$($indent)}{1}" -f "</", $($tagname));
            Write-Output("{0,$($indent)}{1}" -f '</', $tagname);

            #Write-Output ("{0,$($indent)}" -f 'hellotagname');
            Write-Verbose("Depth = {0}" -f $reader.Depth);
            Write-Verbose("indent = {0}" -f $indent);
            break;}
        default {break;}
    }# end switch
    $Depth = $reader.Depth;
} #end WHILE loop

$reader.Dispose();
Remove-Variable indentInc -Force;
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: readxml.ps1
##=============================================
