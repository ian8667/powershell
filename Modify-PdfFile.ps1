<#

.NOTES

File Name    : Modify-PdfFile.ps1
Author       : Ian Molloy
Last updated : 2020-09-14T11:44:15
Keywords     : pdf itext modify

iText Java API docs URL
iText 7 7.1.11 Java API docs: https://api.itextpdf.com/iText7/java/7.1.11/

iText .NET API docs URL
iText 7 7.1.12 .NET API https://api.itextpdf.com/iText7/dotnet/7.1.12/

iText company web site
https://itextpdf.com/en


This program requires the following DLL files:
BouncyCastle.Crypto.dll
Common.Logging.Core.dll
Common.Logging.dll
itext.io.dll
itext.kernel.dll
itext.layout.dll

#>

[CmdletBinding()]
Param() #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

  Write-Output '';
  Write-Output 'Modify PDF file with itext 7';
  $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
  Write-Output ('Today is {0}' -f $dateMask);

  $script = $MyInvocation.MyCommand.Name;
  $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
  Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

#[System.Reflection.AssemblyName]::GetAssemblyName($Path).FullName;
$libdir = 'C:\Ian\PowerShell\lib'; # <-- Change accordingly
$dllfiles = @(
  "$libdir\itext.layout.dll";
  "$libdir\itext.kernel.dll";
  "$libdir\BouncyCastle.Crypto.dll";
  "$libdir\Common.Logging.dll";
  "$libdir\Common.Logging.Core.dll";
  "$libdir\itext.io.dll";
)
Set-Variable -Name 'libdir', 'dllfiles' -Option ReadOnly;

foreach ($dll in $dllfiles) {
  Write-Verbose -Message "Loading dll file $dll";
  Add-Type -Path $dll;
}

$src = "C:\gash\SamplePdffile.pdf"; # Existing PDF file  <-- Change accordingly
$dest = "C:\gash\SamplePdffile_0025.pdf"; # New PDF file <-- Change accordingly
Set-Variable -Name 'src', 'dest' -Option ReadOnly;
if (Test-Path -Path $dest) {
  Remove-Item -Path $dest -Force;
}

$reader = New-Object -typeName iText.Kernel.Pdf.PdfReader -ArgumentList $src;
$reader.SetUnethicalReading($true) | Out-Null;
$reader.SetCloseStream($true);
$writer = New-Object -typeName iText.Kernel.Pdf.PdfWriter -ArgumentList $dest;
$writer.SetCloseStream($true);
$pdfDoc = New-Object -typeName iText.Kernel.Pdf.PdfDocument -ArgumentList $reader, $writer;
$numPages = $pdfDoc.GetNumberOfPages();

$metadata = $pdfDoc.GetDocumentInfo();
$metadata.setAuthor("Ian Molloy") | Out-Null;
$metadata.setCreator("A simple PDF tutorial example") | Out-Null; #Application:
$metadata.setKeywords("keyword1 keyword2") | Out-Null;
$metadata.setSubject("PDF file testing") | Out-Null;
$metadata.setTitle("The Strange Case of Dr. Jekyll and Mr. Hyde") | Out-Null;

#Custom keywords
#You can add custom properties to a PDF document. Each
#custom property requires a unique name, which must not
#be one of the standard property names, i.e. Title, Author,
#Subject, Keywords, Creator, Producer, CreationDate,
#ModDate and Trapped.
$metadata.setMoreInfo("Breakfast", "Bacon and eggs");
$metadata.setMoreInfo("Curry", "Chicken tikka masala");

$pdfDoc.close();
$writer.close();
$reader.close();

Get-ChildItem -Path $dest;
Write-Output ('Pages in file: {0}' -f $numPages);

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Modify-PdfFile.ps1
##=============================================
