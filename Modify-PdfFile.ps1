<#

.NOTES

File Name    : Modify-PdfFile.ps1
Author       : Ian Molloy
Last updated : 2020-09-28T18:43:04
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

Everything you wanted to know about PSCustomObject
https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-pscustomobject?view=powershell-7

#>

[CmdletBinding()]
Param() #end param

#region ***** class ValidatePathExistsAttribute *****
class ValidatePathExistsAttribute : System.Management.Automation.ValidateArgumentsAttribute
{
<#
Carries out validation of variable 'libdir'.
Serves as the base class for Validate attributes that validate
parameter arguments. In this case, the argument supplied is
variable 'libdir'.

ValidateArgumentsAttribute Class
https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.validateargumentsattribute?view=powershellsdk-7.0.0

Introduction To PowerShell Classes
https://overpoweredshell.com/Introduction-to-PowerShell-Classes/

#>
    Validate([Object]$Arguments, [System.Management.Automation.EngineIntrinsics]$EngineIntrinsics)
    {
        $myargs = $Arguments;
        if (-not (Test-Path -Path $myargs)) {
          throw [System.IO.DirectoryNotFoundException] "DLL library directory $myargs not found";
        }

        #Ensure we have some dll files in the DLL directory
        $dllFilter = '*.dll';
        $dllCount = (Get-ChildItem -File -Filter $dllFilter -Path $myargs | Measure-Object).Count;
        if ($dllCount -eq 0) {
          throw [System.IO.FileNotFoundException] "DLL files not found in DLL directory $myargs";
        }

    }
}
#endregion ***** end of class ValidatePathExistsAttribute *****

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
#PowerShell class 'ValidatePathExistsAttribute' checks the
#following and throws a terminating error if these checks
#do not succeed.
#1. The directory path exists
#2. The directory contains at least one dll file
[ValidatePathExists()]
$libdir = 'C:\Family\powershell\lib'; # <-- Change accordingly

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

$DataFile = [PSCustomObject]@{
  # Input and output files used - Change accordingly
  PSTypeName   = 'DataFiles';
  Source       = 'C:\Gash\mygash.pdf'; #Existing PDF file
  Destination  = 'C:\Gash\mygash_0025.pdf'; #New PDF file
}
Set-Variable -Name 'DataFile' -Option ReadOnly;
if (Test-Path -Path $DataFile.Destination) {
  Remove-Item -Path $DataFile.Destination -Force;
}

$reader = New-Object -typeName 'iText.Kernel.Pdf.PdfReader' -ArgumentList $DataFile.Source;
$reader.SetUnethicalReading($true) | Out-Null;
$reader.SetCloseStream($true);
$writer = New-Object -typeName 'iText.Kernel.Pdf.PdfWriter' -ArgumentList $DataFile.Destination;
$writer.SetCloseStream($true);
$pdfDoc = New-Object -typeName 'iText.Kernel.Pdf.PdfDocument' -ArgumentList $reader, $writer;
$numPages = $pdfDoc.GetNumberOfPages();

$metadata = $pdfDoc.GetDocumentInfo();
$metadata.setTitle("The Strange Case of Dr. Jekyll and Mr. Hyde") | Out-Null;
$metadata.setAuthor("Ian Molloy") | Out-Null;
$metadata.setSubject("PDF file testing") | Out-Null;
$metadata.setKeywords("keyword1 keyword2") | Out-Null;
$metadata.setCreator("PowerShell script Modify-PdfFile.ps1") | Out-Null; #Field Application:

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

Get-ChildItem -Path $DataFile.Source, $DataFile.Destination;
Write-Output ('Pages in input file: {0}' -f $numPages);

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Modify-PdfFile.ps1
##=============================================
