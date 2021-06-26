<#

.NOTES

File Name    : Modify-PdfFile.ps1
Author       : Ian Molloy
Last updated : 2021-06-18T16:38:33
Keywords     : pdf itext modify

iText Java API docs URL
https://api.itextpdf.com/iText7/java/7.1.15/

iText 7 7.1.15 API Documentation URL
https://api.itextpdf.com/iText7/dotnet/7.1.15/

iText company web site
https://itextpdf.com/en


This program requires the following DLL files:
BouncyCastle.Crypto.dll
Common.Logging.Core.dll
Common.Logging.dll
itext.io.dll
itext.kernel.dll
itext.layout.dll

iText Core 7.1.15 is the second quarterly release for 2021
of our multifunctional PDF SDK.
https://github.com/itext/itext7-dotnet/releases/tag/7.1.15

#>

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------
$IsPdfFile = [Predicate[System.String]]{
    <#
    Checks the file supplied as a parameter is a PDF file. To a
    point, a file can have any file extension but by convention,
    PDF files have a file extension of 'pdf'. If the file doesn't
    have an extension of 'pdf', we'll reject it. The first four
    bytes of the file (magic numbers) are also checked to ensure
    we have a valid pdf file. If the magic numbers are not as
    expected, we'll reject the file.

    Return true if this is a pdf file; otherwise, false.
    #>
    param($pdffile)

    [Byte[]]$MagicBytes = @(0X25, 0X50, 0X44, 0X46, 0X2D);
    [Byte[]]$FileBytes = Get-Content -Path $pdffile -AsByteStream -TotalCount $MagicBytes.Length;
    Set-Variable -Name 'MagicBytes','FileBytes' -Option ReadOnly;

    $ext = Split-Path -Path $pdffile -Extension;
    if ($ext -ne '.pdf') {
        return $false;
    }

    if ($MagicBytes.Length -ne $FileBytes.Length) {
        return $false;
    }

    #Check both arrays, byte for byte.
    foreach ($num in 0..($MagicBytes.Length - 1)) {
        if ($MagicBytes[$num] -ne $FileBytes[$num]) {
            return $false;
        }

    }

    return $true;
}
Set-Variable -Name 'IsPdfFile' -Option ReadOnly;

#----------------------------------------------------------
# End of delegates
#----------------------------------------------------------

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
          throw [System.IO.DirectoryNotFoundException] "DLL library directory [$myargs] not found";
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
  Write-Output 'Modify PDF file with itext 7 software';
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

#DLL files required by the program
$dllfiles = @(
    "$libdir\itext.layout.dll";
    "$libdir\itext.kernel.dll";
    "$libdir\BouncyCastle.Crypto.dll";
    "$libdir\Common.Logging.dll";
    "$libdir\Common.Logging.Core.dll";
    "$libdir\itext.io.dll";
);
Set-Variable -Name 'libdir', 'dllfiles' -Option ReadOnly;

foreach ($dll in $dllfiles) {
    Write-Verbose -Message "Loading dll file $dll";
    Add-Type -Path $dll;
}

# Input and output files used - Change accordingly
$DataFile = [PSCustomObject]@{
    PSTypeName   = 'DataFiles';
    Source       = 'C:\Gash\gashpdf.pdf'; #Existing PDF file
    Destination  = 'C:\Gash\gashpdf99.pdf'; #New PDF file
}
Set-Variable -Name 'DataFile' -Option ReadOnly;

if ($IsPdfFile.Invoke($DataFile.Source)) {
    #
    if (Test-Path -Path $DataFile.Destination) {
        Write-Warning -Message ('Removing existing output file {0}' -f $DataFile.Destination);
        Remove-Item -Path $DataFile.Destination -Force;
    }

    $reader = New-Object -typeName 'iText.Kernel.Pdf.PdfReader' -ArgumentList $DataFile.Source;
    $reader.SetUnethicalReading($true) | Out-Null;
    $reader.SetCloseStream($true);
    $writer = New-Object -typeName 'iText.Kernel.Pdf.PdfWriter' -ArgumentList $DataFile.Destination;
    $writer.SetCloseStream($true);
    $pdfDoc = New-Object -typeName 'iText.Kernel.Pdf.PdfDocument' -ArgumentList $reader, $writer;
    $numPages = $pdfDoc.GetNumberOfPages();

    #Has type of iText.Kernel.Pdf.PdfDocumentInfo Class
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
    $dt = Get-Date -Format 's';
    $metadata.setMoreInfo("DateTime", $dt);

    $pdfDoc.Close();
    $writer.Close();
    $reader.Close();

    Get-ChildItem -File -Path $DataFile.Source, $DataFile.Destination;
    Write-Output ('Pages in input file: {0}' -f $numPages);

} else {

    Write-Warning -Message ('File [{0}] is not a valid zip file' -f $DataFile.Source);
}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Modify-PdfFile.ps1
##=============================================
