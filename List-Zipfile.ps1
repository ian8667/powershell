<#
.SYNOPSIS

List contents of a zip file

.NOTES

File Name    : List-Zipfile.ps1
Author       : Ian Molloy
Last updated : 2021-06-17T23:36:34
Keywords     : zipfile zip contents

*****
Get the first four bytes of the file
$fourBytes = cat 'ian.ian' -AsByteStream -TotalCount 4
*****
Some ideas on comparing byte arrays (not tested)
$gash = @(0x50, 0x4B, 0x03, 0x04);
$gash2 = @(0x50, 0x4B, 0x03, 0x04);

This is the very simple method in which we will follow below steps to compare array elements and check if both arrays are equal or not.

Steps:

Create 2 arrays with elements.
Check the length of both arrays and compare it.
If they are not equal, then arrays are not equal and no need to process further.
if both the arrays length is equal, then retrieve each corresponding element from both array by traversing within a loop and compare them till last element. If all are equal, then array will be equal or if any of the elements are not equal then arrays will not be equal.
Source: https://www.interviewsansar.com/how-to-compare-two-arrays-in-c-if-they-are-equal-or-not/
$gash.SequenceEqual($gash2);

int[] arr1 = { 1, 2, 3, 4, 4, 5 };
int[] arr2 = { 1, 2, 3, 9, 4, 5 };

static bool ByteArrayCompare(byte[] a1, byte[] a2)
{
    if (a1.Length != a2.Length)
        return false;

    for (int i=0; i<a1.Length; i++)
        if (a1[i]!=a2[i])
            return false;

    return true;
}
# -----
private static bool SafeEquals(byte[] strA, byte[] strB)
{
   int length = strA.Length;
   if (length != strB.Length)
   {
       return false;
   }
   for (int i = 0; i < length; i++)
   {
       if( strA[i] != strB[i] ) return false;
   }
   return true;
}


*****
This might do it,
[int[]] $num1 = @(3, 1, 4, 1, 5 );
[int[]] $num2 = @(3, 4, 1, 1, 5);
[System.Linq.Enumerable]::SequenceEqual($num1, $num2);
High Performance PowerShell with LINQ
https://www.red-gate.com/simple-talk/development/dotnet-development/high-performance-powershell-linq/#post-71022-_Toc482783754
*****

[Byte[]] $MagicBytes = @(0X50, 0X4B, 0X03, 0X04);

#>

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------
$IsZipFile = [Predicate[System.String]]{
    <#
    Checks the file supplied as a parameter is a zip file. To a
    point, a file can have any file extension but by convention,
    zip files have a file extension of 'zip'. If the file doesn't
    have an extension of 'zip', we'll reject it. The first four
    bytes of the file (magic numbers) are also checked to ensure
    we have a valid zip file. If the magic numbers are not as
    expected, we'll reject the file.

    Return true if this is a zip file; otherwise, false.
    #>
    param($zipfile)

    [Byte[]]$MagicBytes = @(0X50, 0X4B, 0X03, 0X04);
    [Byte[]]$FileBytes = Get-Content -Path $zipfile -AsByteStream -TotalCount 4;
    Set-Variable -Name 'MagicBytes','FileBytes' -Option ReadOnly;

    $ext = Split-Path -Path $zipfile -Extension;
    if ($ext -ne '.zip') {
        return $false;
    }

    if ($MagicBytes.Length -ne $FileBytes.Length) {
        return $false;
    }

    #Check both arrays, byte for byte.
    foreach ($num in 0..3) {
        if ($MagicBytes[$num] -ne $FileBytes[$num]) {
            return $false;
        }

    }

    return $true;
}
Set-Variable -Name 'IsZipFile' -Option ReadOnly;

#----------------------------------------------------------
# End of delegates
#----------------------------------------------------------

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Get-FriendlySize *****
function Get-FriendlySize {
[CmdletBinding()]
[OutputType([System.String])]
Param (
    [parameter(Mandatory=$true,
               HelpMessage="File length in bytes to convert")]
    [ValidateNotNullOrEmpty()]
    [System.Double]$ByteLength
) #end param

Begin {
  $suffix = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB");
  Set-Variable -Name 'suffix' -Option ReadOnly;
  $index = 0;
  [System.Double]$n = $ByteLength;
}

Process {
  while ($n -gt 1KB) {
       $n = $n / 1024;
       $index++;
  }

}

End {
  return ("{0:N3} {1}" -f $n, $suffix[$index]);
}

}
#endregion ***** end of function Get-FriendlySize *****

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
<#
$MyInvocation
TypeName: System.Management.Automation.InvocationInfo
This automatic variable contains information about the current
command, such as the name, parameters, parameter values, and
information about how the command was started, called, or
invoked, such as the name of the script that called the current
command.

$MyInvocation is populated differently depending upon whether
the script was run from the command line or submitted as a
background job. This means that $MyInvocation may not be able
to return the path and file name of the script concerned as
intended.
#>
   Write-Output '';
   Write-Output 'List contents of a zip file';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   if ($MyInvocation.OffsetInLine -ne 0) {
       #I think the script was run from the command line
       $script = $MyInvocation.MyCommand.Name;
       $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
       Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
   }

} #end of Invoke-Command -ScriptBlock

$inputzipFile = 'C:\Family\powershell\ScriptingGames2013\Beginner-5.zip';
Set-Variable -Name '$inputzipFile' -Option ReadOnly;

if (-not (Test-Path -Path $inputzipFile)) {
    throw [System.IO.FileNotFoundException] "Input file [$zipFile] not found.";
}

if ($IsZipFile.Invoke($inputzipFile)) {

    Add-Type -AssemblyName 'System.IO.Compression.FileSystem';

    [System.Linq.Enumerable]::Repeat("", 2); #blanklines
    $fred = [System.IO.Compression.ZipFile]::OpenRead($inputzipFile);
    $dateTimeMask = 'dddd, dd MMMM yyyy HH:mm:ss';
    Set-Variable -Name 'fred','dateTimeMask' -Option ReadOnly;
    [System.UInt16]$entryCount = 0;
    [String]$flength = "";

    Write-Output ('Zipfile contents of [{0}]' -f $inputzipFile);
    [System.Linq.Enumerable]::Repeat("", 2); #blanklines

    #Variable '$fred.Entries' contains the list of entries that
    #are currently in the zip archive being looked at. Loop
    #through these entries and display some information.
    foreach ($zipentry in $fred.Entries) {

        # Variable zipentry is of type:
        # TypeName: System.IO.Compression.ZipArchiveEntry
        $entryCount++;
        Write-Output ('Entry #{0}' -f $entryCount);
        Write-Output ('Entry name: {0}' -f $zipentry.Name);
        $flength = Get-FriendlySize -ByteLength $zipentry.CompressedLength;
        Write-Output ('Compressed size: {0}' -f $flength);
        $flength = Get-FriendlySize -ByteLength $zipentry.Length ;
        Write-Output ('Uncompressed size: {0}' -f $flength);
        $lwt = $zipentry.LastWriteTime.DateTime.ToString($dateTimeMask);
        Write-Output ('Last write for entry: {0}' -f $lwt);
        Write-Output '';

    } #end foreach loop

    Write-Output ("`n{0} entries found in zipfile [{1}]" -f $entryCount, $inputzipFile);
    $fred.Dispose();

    # Clean up
    Remove-Variable fred -Force;

} else {
    Write-Warning -Message ('File [{0}] is not a valid zip file' -f $inputzipFile);
}

Write-Output 'All done now';

##=============================================
## END OF SCRIPT: List-Zipfile.ps1
##=============================================
