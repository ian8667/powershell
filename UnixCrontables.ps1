# Creates an XML file from the output of the Unix command
# $ crontab -l > cron.txt.
#
# This program is also an example of creating XML files from PowerShell.
#

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

function Write-Dataline($xwriter, $cronbits, $id) {

  $xwriter.WriteStartElement("Line");
  $xwriter.WriteAttributeString("ID", "$id");

  $xwriter.WriteStartElement("CronTime");
  $xwriter.WriteString($cronbits.DateTime);
  $xwriter.WriteEndElement();

  $xwriter.WriteStartElement("Executable");
  $xwriter.WriteString($cronbits.Executable);
  $xwriter.WriteEndElement();

  $xwriter.WriteStartElement("Logfile");
  $xwriter.WriteString($cronbits.Logfile);
  $xwriter.WriteEndElement();

  $xwriter.WriteStartElement("ErrorRedirect");
  $xwriter.WriteRaw($cronbits.ErrorRedirect);
  $xwriter.WriteEndElement();
write-output ("error thing = $($cronbits.ErrorRedirect)");
  $xwriter.WriteFullEndElement();     # <-- Close element ''Line''.

} #end function Write-Dataline

#----------------------------------------------------------

function Close-XmlFile($xwriter) {

  Write-Host "Closing the xml file";
  # The closing bits of the XML file
  $xwriter.WriteEndElement();     # <-- Close root element
  $xwriter.WriteEndDocument();    # <-- Close the document

  # Finish The Document
  $xwriter.Finalize;
  $xwriter.Flush;
  $xwriter.Close();

} #end function Close-XmlFile

function Get-Lineparts($str) {
  begin {
    $props = [ordered]@{
       DateTime = "";
       Executable = "";
       Logfile = "";
       ErrorRedirect = "";
    }
    $cronbits = New-Object psobject -Property $props;

    $props = [ordered]@{
       Start = 0;
       End = 0;
    }
    $pos = New-Object psobject -Property $props;
  } #end begin

  process {

    # Get the date/time part of the cron line.
    $pos.End=$str.IndexOf('/');
    $cronbits.DateTime=$str.Substring($pos.Start,$pos.End).Trim();

    # Get the executable, i.e. the shell script bit.
    $pos.Start=$pos.End;
    $pos.End=$str.IndexOf('>', $pos.End);
    $cronbits.Executable=$str.Substring($pos.Start,($pos.End-$pos.Start)).Trim();

    # Get the logfile name.
    $pos.Start=$str.IndexOf('/', $pos.End);
    $pos.End=$str.IndexOf('2>&1', $pos.End);
    $cronbits.Logfile=$str.Substring($pos.Start,($pos.End-$pos.Start)).Trim();

    # Get the error redirect.
    $cronbits.ErrorRedirect=$str.Substring($pos.End).Trim();

  } #end process

  end {
    return $cronbits;
  } #end end

} #end function Get-Lineparts

#----------------------------------------------------------

function Set-XmlWriterSettings {

  $xsettings = New-Object -TypeName System.Xml.XmlWriterSettings;
  $xsettings.CloseOutput = $true;
  $xsettings.Encoding = [System.Text.Encoding]::UTF8;
  $xsettings.Indent = $true;
  $xsettings.IndentChars = "    "; # 4 spaces
  $xsettings.WriteEndDocumentOnClose = $true;
  $xsettings.CheckCharacters = $true;
  #$xsettings.NewLineChars = "0xoa";
  $xsettings.NewLineOnAttributes = $true;
  $xsettings.OmitXmlDeclaration = $false;
  $xsettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Auto;

  return $xsettings;

} #end function Set-XmlWriterSettings

#----------------------------------------------------------

function Set-XmlFile {

  # Do some initialising
  $filePath = "C:\ian\PowerShell\good03.xml";
  $xset = Set-XmlWriterSettings;
  [System.Xml.XmlWriter]$xwriter = [System.Xml.XmlWriter]::Create($filePath,$xset);
  $server="MyServer";
  $owner="Ian";
  $ymd=(Get-Date).ToString("s");

  # Write the header elements to our XML file
  $xwriter.WriteStartDocument();               # <-- Start the document
  $xwriter.WriteStartElement("CronTable");     # <-- Important root element

  $xwriter.WriteStartElement("Server");
  $xwriter.WriteString($server);
  $xwriter.WriteEndElement();

  $xwriter.WriteStartElement("CronOwner");
  $xwriter.WriteString($owner);
  $xwriter.WriteEndElement();

  $xwriter.WriteStartElement("DateStamp");
  $xwriter.WriteString($ymd);
  $xwriter.WriteEndElement();

  $xwriter.WriteStartElement("CronLines");

  return $xwriter;

} #end function Set-XmlFile

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
   Write-Output 'Create XML file from Unix command crontab';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

$counter=0;
$infile="C:\ian\PowerShell\single_line.txt";
$input = New-Object -TypeName System.IO.StreamReader -ArgumentList $infile;
$ymd=(Get-Date).ToString("s");
$cronbits=$null;

#Create and write the header to the XmlFile.
$xwriter=Set-XmlFile;

$inrec = $input.ReadLine();
while ($inrec -ne $null) {
   Write-Output ($inrec);
   $counter++;
   $cronbits=Get-Lineparts $inrec;
   Write-Dataline $xwriter $cronbits $counter;
   $cronbits | Format-list;

   $inrec = $input.ReadLine();
}

$input.Close();
$input.Dispose();

Close-XmlFile($xwriter);

Write-Output "`nRecords read: $counter";
Write-Output "The date is $ymd";
##=============================================
## END OF SCRIPT: UnixCrontables.ps1
##=============================================
