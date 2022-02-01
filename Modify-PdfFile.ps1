<#

.SYNOPSIS

Modifies user selected properties of a PDF file

.DESCRIPTION

Modifies certain properties of a PDF file as selected
by the user. This is achieved by using DLL files from
iTextSharp (https://itextpdf.com/en).

.EXAMPLE

./Modify-PdfFile.ps1

No parameters are required. The action of this program
is to read in a PDF file and write the modifications to
an output file. The input PDF filename is hardcoded
within the program with the ouput filename being derived
from the input filename.

Input file (and thus the output file) are assigned in
Func<TResult> Delegate 'Get_Datafiles'.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Modify-PdfFile.ps1
Author       : Ian Molloy
Last updated : 2022-02-01T19:02:43
Keywords     : pdf itext modify

This program requires the following DLL files:
  BouncyCastle.Crypto.dll
  Common.Logging.Core.dll
  Common.Logging.dll
  itext.io.dll
  itext.kernel.dll
  itext.layout.dll


PowerShell Add-Type Error:
(problems loading DLL files)
PS> $error[0].Exception.InnerException;
loadFromRemoteSources - Specifies whether assemblies from remote
sources should be granted full trust.

Originally, when I first coded this program, I was using the
Add-Type cmdlet to load DLL files which the program requires
in order to work. On a recent Microsoft Windows update, I
started to get the following error message:

Quote
"An attempt was made to load an assembly from a network location
which would have caused the assembly to be sandboxed in previous
versions of the .NET Framework. c, so this load may be dangerous.
If this load is not intended to sandbox the assembly, please
enable the loadFromRemoteSources switch. See
http://go.microsoft.com/fwlink/?LinkId=155569 for more information."
Unquote

Perhaps not a brilliant solution, but I've now resolved the issue
with the use of the following static method to load DLL files:
[System.Reflection.Assembly]::UnsafeLoadFrom()


Starting with the .NET Framework 4, Code Access Security (CAS)
policy is disabled and assemblies are loaded in full trust.
Ordinarily, this would grant full trust to assemblies loaded
with the Assembly.LoadFrom method that previously had been
sandboxed. To prevent this, the ability to run code in
assemblies loaded from a remote source is disabled by default.

The following configuration file example shows how to grant
full trust to (DLL) assemblies loaded from remote sources:
In a PowerShell context, this config file would have the
name of "powershell.exe.config" and sit in the same directory
as "powershell.exe". (I've not tested this configuration file
idea yet).

<?xml version="1.0"?>
<!--
o How to: Configure an App to Support .NET Framework 4 or later versions
https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-configure-an-app-to-support-net-framework-4-or-4-5

-->
<configuration>
  <startup useLegacyV2RuntimeActivationPolicy="true">
    <supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.5"/>
  </startup>
  <runtime>
    <loadFromRemoteSources enabled="true"/>
  </runtime>
</configuration>

.LINK

iText Core 7.1.15 is the second quarterly release for 2021
of our multifunctional PDF SDK.
https://github.com/itext/itext7-dotnet/releases/tag/7.1.15

iText Java API docs URL
https://api.itextpdf.com/iText7/java/7.1.15/

iText 7 7.1.15 API Documentation URL
https://api.itextpdf.com/iText7/dotnet/7.2.0/

iText company web site
https://itextpdf.com/en

What's New in Code Access Security (CAS) in .NET Framework 4.0 ? Part I
https://www.red-gate.com/simple-talk/development/dotnet-development/whats-new-in-code-access-security-in-net-framework-4-0-part-i/

More Implicit Uses of CAS Policy: loadFromRemoteSources
https://docs.microsoft.com/en-us/archive/blogs/shawnfa/more-implicit-uses-of-cas-policy-loadfromremotesources

#>

<#
New work:
o remove password protection so I can update the PDF file  - can I do this?
o upload to github
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

Return true if this is a PDF file; otherwise, false.
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

#------------------------------------------------

[System.Func[PSCustomObject]]$Get_Datafiles = {
<#
Encapsulates a method that has no parameters and returns
a value of the type specified by the TResult parameter.

Input and output files used.
#>
  $input = 'C:\Gash\casio_fx-991ES_plus.pdf'; # <-- Change accordingly
  $output = $input + '-new'; # The output file is derived from the input file.
  $DataFile = [PSCustomObject]@{
      Source       = $input
      Destination  = $output
}

# Return the value
$DataFile;

} #end [Func[PSCustomObject]]

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
    "$libdir\itext.io.dll";
    "$libdir\itext.kernel.dll";
    "$libdir\BouncyCastle.Crypto.dll";
    "$libdir\Common.Logging.dll";
    "$libdir\Common.Logging.Core.dll";
);
Set-Variable -Name 'libdir', 'dllfiles' -Option ReadOnly;

$counter = 0;
foreach ($dll in $dllfiles) {
    $counter++;

    try {
        $AssemblyPath = $dll;
        # Load an assembly into the load-from context, bypassing
        # some security checks.
        [System.Reflection.Assembly]::UnsafeLoadFrom($AssemblyPath);
    } catch {
        Write-Host "Message: $($_.Exception.Message)"
        Write-Host "StackTrace: $($_.Exception.StackTrace)"
        Write-Host "LoaderExceptions: $($_.Exception.LoaderExceptions)"
    }

}

# Input and output files used - Change accordingly
$DataFile = $Get_Datafiles.Invoke();
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
    #ModDate or Trapped.
    $CustomKeywords = $true;
    if ($CustomKeywords) {

        $metadata.setMoreInfo("Breakfast", "Bacon and eggs");
        $metadata.setMoreInfo("Curry", "Chicken tikka masala");
        $dt = Get-Date -Format 's';
        $metadata.setMoreInfo("DateTime", $dt);

    }

    $pdfDoc.Close();
    $writer.Close();
    $reader.Close();

    Get-ChildItem -File -Path $DataFile.Source, $DataFile.Destination;
    Write-Output ('Pages in input file: {0}' -f $numPages);

} else {

    Write-Warning -Message ('File [{0}] is not a valid PDF file' -f $DataFile.Source);
}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Modify-PdfFile.ps1
##=============================================
