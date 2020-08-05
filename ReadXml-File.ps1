<#
.SYNOPSIS

Reads through an XML file and prints start and end tags in a
hierarchical fashion.

.DESCRIPTION

Reads through an XML file printing the start and end tags to give
an idea of the structure of the input file. No data is printed.

The input filename is hard coded within the program.

.EXAMPLE

PS> ./ReadXml-File.ps1

If the input file was something like:

<note>
  <to>Tove</to>
  <from>Jani</from>
  <heading>Reminder</heading>
  <body>Don't forget me this weekend!</body>
</note>

The sample output will be:

Processing XML file C:\Family\ian\note.xml
<note>
    <to>
    </to>
    <from>
    </from>
    <heading>
    </heading>
    <body>
    </body>
</note>
All done now

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : ReadXml-File.ps1
Author       : Ian Molloy
Last updated : 2020-08-04T22:23:26

#>

[CmdletBinding()]
Param () #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

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

Begin {
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

Process {}

End {
  return $xobj;
}

}
#endregion ***** End of function Get-XmlReader *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Read and interpret XML files';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines

New-Variable -Name 'inputXML' -Value 'C:\Gash\gash.xml' -Option Constant `
             -Description 'XML file to process';
New-Variable -Name indentInc -Value 4 -Option Constant `
             -Description 'Amount by which text is indented/decremented by';
$xmlline = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList 100;
$xreader = Get-XmlReader -Filename $inputXML;
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
## END OF SCRIPT: ReadXml-File.ps1
##=============================================
