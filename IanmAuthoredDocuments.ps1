<#
.SYNOPSIS

Displays author and comment properties from an MS Word document

.DESCRIPTION

Displays the author and comments from the document properties of
Microsoft Word document written by a specific author.

.EXAMPLE

PS> ./IanmAuthoredDocuments.ps1

.NOTES

File Name    : IanmAuthoredDocuments.ps1
Author       : Ian Molloy
Last updated : 2020-08-04T18:06:06

For information regarding this subject (comment-based help),
execute the command:
PS> Get-Help about_comment_based_help

.LINK

Word Object Model Overview
Word object model showing the classes and interfaces that are provided in the
primary interop assembly for Word, and are defined in the
Microsoft.Office.Interop.Word namespace.
https://msdn.microsoft.com/en-us/library/kw65a0we.aspx

Word 2013 Primary Interop Assembly Class Library
The interfaces and members of the Microsoft.Office.Interop.Word namespace
provide support for interoperability between the COM object model of
Word 2013 and managed applications that automate Word.
https://msdn.microsoft.com/en-us/library/dn320432.aspx

Microsoft.Office.Interop.Word namespace
This section describes the interfaces and members of the Microsoft.Office.Interop.Word
namespace.
https://msdn.microsoft.com/en-us/library/microsoft.office.interop.word.aspx

Documents members
A collection of all the Document objects that are currently open in Word. This page
gives a listing of the properties and methods of the Documents type.
https://msdn.microsoft.com/en-us/library/microsoft.office.interop.word.documents_members.aspx

Documents.Open method
Opens the specified document and adds it to the Documents collection.
https://msdn.microsoft.com/en-us/library/microsoft.office.interop.word.documents.open.aspx

Application Class members
A list of the properties, methods, events and constructor for this class.
https://msdn.microsoft.com/en-us/library/microsoft.office.interop.word.applicationclass_members.aspx

Application members
https://msdn.microsoft.com/en-us/library/microsoft.office.interop.word.application_members.aspx

How to: Programmatically Close Documents
Information on closing documents.
https://msdn.microsoft.com/en-us/library/af6z0wa2.aspx

DocumentProperty interface
Represents a custom or built-in document property of a container document. In other words,
this is the list of document properties that can be retrieved apart from any custom
properties.
https://msdn.microsoft.com/EN-US/library/ms250700

Type.InvokeMember Method
https://msdn.microsoft.com/en-us/library/66btctbe(v=vs.110).aspx

Type Class
https://msdn.microsoft.com/en-us/library/system.type(v=vs.110).aspx

about_Comment_Based_Help:
http://technet.microsoft.com/en-us/library/dd819489.aspx

WTFM: Writing the Fabulous Manual:
http://technet.microsoft.com/en-us/magazine/ff458353.aspx

about_Functions_Advanced_Parameters:
http://technet.microsoft.com/en-us/library/hh847743.aspx

Cmdlet Parameter Sets:
http://msdn.microsoft.com/en-us/library/windows/desktop/dd878348(v=vs.85).aspx

#>

[CmdletBinding()]
Param () #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** Function printBlanklines *****
#
# Prints the number of blank lines specified.
# Parameters:
# lines - the number of blank lines to print.
#
function printBlanklines {
[CmdletBinding()]
param (
    [parameter(Position=0,
               Mandatory=$true)]
    [ValidateRange(1,15)]
    [System.SByte]$lines
) #end param

  1..$lines | ForEach-Object {Write-Host '' }

}
#endregion ***** End of function printBlanklines *****

#------------------------------------------------------------------------------

#region ***** Function Get-RequiredDocuments *****
function Get-RequiredDocuments {
[CmdletBinding()]
Param () #end param

Begin {

  #Add-Type -AssemblyName 'Microsoft.Office.Interop.Word';
  $dllFile = 'C:\Windows\assembly\GAC_MSIL\Microsoft.Office.Interop.Word\15.0.0.0__71e9bce111e9429c\Microsoft.Office.Interop.Word.dll';
  Add-Type -LiteralPath $dllFile;

  #Microsoft.Office.Interop.Word.ApplicationClass
  $application = New-Object -ComObject word.application;
  $application.Visible = $false;
  $binding = "System.Reflection.BindingFlags" -as [type]
  #[ref]$SaveOption = "microsoft.office.interop.word.WdSaveOptions" -as [type]
  # Get a list of files to look at.
  #$startDir = 'H:\Ian\docs'; # <-- Change accordingly
  $startDir = 'C:\Gash'; # <-- Change accordingly
  # The property(s) we want to extract from our Word document files.
  $AryProperties = @("Author","Comments");
  [System.Int16]$fileCount = 0;
  # Determines whether to print the document details based upon
  # the author name found in the document.
  [System.Boolean]$printName = $false;
  # The name to look for in the author field of the documents.
  $personName = 'Molloy';
  $fileFilter = '*.docx';


  $SaveChanges = [Microsoft.Office.Interop.Word.WdSaveOptions]::wdDoNotSaveChanges;
  $OriginalFormat = [Microsoft.Office.Interop.Word.WdOriginalFormat]::wdWordDocument;
  $RouteDocument = $false;

  [System.Linq.Enumerable]::Repeat("", 2); #blanklines
  Write-Output 'Looking for MS Word documents written by Ian M. Please wait ...';
  Write-Output ('Start directory used is {0}' -f $startDir);
  [System.Linq.Enumerable]::Repeat("", 3); #blanklines

  # Get list of files to process using the start directory determined
  # by variable '$startDir'.
  $docs = Get-ChildItem -Path $startDir -Recurse -Filter $fileFilter;
  Write-Output ('{0} files to process' -f $docs.Count);
  [System.Linq.Enumerable]::Repeat("", 2); #blanklines

} #end BEGIN block

Process {

  # Main loop to process our list of MS Word files found.
  foreach($doc in $docs) {

    Write-Output ('Processing file {0}' -f $doc.Name);

    # Open the document for processing.
    # For details of 'openDoc' see 'Document members'
    $openDoc = $application.Documents.Open($doc.FullName,$false,$true);


    # Returns a DocumentProperties collection that represents all the
    # built-in document properties for the specified document.
    $BuiltinProperties = $openDoc.BuiltInDocumentProperties;
    $objHash = @{"Path"=$doc.FullName}

      # Inner loop to obtain the required document properties for the currently
      # open file. We do this by iterating over the array '$AryProperties'. This
      # tells us which properties to extract from the document.
      foreach($p in $AryProperties) {

         Try {

            $pn = [System.__ComObject].InvokeMember("item",$binding::GetProperty,$null,$BuiltinProperties,$p);
            $value = [System.__ComObject].InvokeMember("value",$binding::GetProperty,$null,$pn,$null);
            $value = $value.Trim();
            $objHash.Add($p,$value);

            # Check whether the document author is the one we want, if so, flag it.
            if ($value -match $personName) {
               $printName = $true;
               $fileCount++;
            }

         } Catch [System.Exception] {

           Write-Host -ForegroundColor Yellow "Value not found for property $p";
         }
         # end try/catch block

      } # end inner Foreach loop

      if ($printName) {
          # Print the information collected for the document of interest.
          $printName = $false;
          $docProperties = New-Object PSObject -Property $objHash;
          Write-Output ("( {0} )" -f $fileCount);
          Write-Output $docProperties | Format-List *
      }

      # Close this particular document as we no longer need it. This will get
      # ready for the next document in our list.
      # Documents.Close method
      # https://msdn.microsoft.com/en-us/library/microsoft.office.interop.word.documents.close.aspx

      #$openDoc.close([ref]$SaveChanges, [ref]$OriginalFormat, [ref]$RouteDocument);
      $openDoc.close($SaveChanges, $OriginalFormat, $RouteDocument);
      [System.Runtime.InteropServices.Marshal]::ReleaseComObject($BuiltinProperties) | Out-Null
      [System.Runtime.InteropServices.Marshal]::ReleaseComObject($openDoc) | Out-Null

      Remove-Variable -Name openDoc, BuiltinProperties;

  } # end outer Foreach loop

} #end PROCESS block

End {

  [System.Linq.Enumerable]::Repeat("", 2); #blanklines
  Write-Output ("{0} Ian M authored files listed" -f $fileCount);

  # Clean up and close.
  $application.Quit();
  [System.Runtime.InteropServices.Marshal]::ReleaseComObject($application) | Out-Null
  [gc]::Collect();
  [gc]::WaitForPendingFinalizers();

} #end END block

}
#endregion ***** End of function Get-RequiredDocuments *****

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
   Write-Output 'Display Ian M authored MS Word documents';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

Get-RequiredDocuments;

##=============================================
## END OF SCRIPT: IanmAuthoredDocuments.ps1
##=============================================
