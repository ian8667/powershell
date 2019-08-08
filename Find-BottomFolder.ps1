<#
.SYNOPSIS

Finds the bottom directories of a directory structure

.DESCRIPTION

Finds the bottom folder(s) of a directory structure. ie the last
directory in a known path. The directory to start from is
hardcoded within the program.

.EXAMPLE

./Find-BottomFolder.ps1

No parameters are required

Sample output (assuming a start directory of 'C:\Test').

C:\Test\Blankdir (4 files in directory)
C:\Test\Blankdir2 (0 files in directory)
C:\Test\gashexpand (1 files in directory)
C:\Test\t1\t1\t1\t1\longdirectorynamehere (0 files in directory)
C:\Test\t2\t2\t99 (0 files in directory)


Start directory used: C:\Test
5 'bottom folders' listed

All done now


From the above output, you can see that the start directory has five
subfolders,
ie

C:\Test
-> Blankdir
-> Blankdir2
-> gashexpand
-> t1
-> t2

Subfolder Blankdir contains four files.
Subfolder Blankdir2 contains no files.

The bottom (base) directory of t2 for example is t99.
ie

C:\Test
-> t2
-> t2
-> t99

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Find-BottomFolder.ps1
Author       : Ian Molloy
Last updated : 2019-08-08

.LINK

List<T> Class
Represents a strongly typed list of objects that can be accessed
by index. Provides methods to search, sort, and manipulate lists.
https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1?view=netframework-4.8

About Comment Based Help
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-6

With inspiration from 'Finding the bottom folders of a file tree using PowerShell'
by Stuart Moore
https://stuart-moore.com/finding-bottom-folders-file-tree-using-powershell/

#>

[CmdletBinding()]
Param () #end param

#region ***** function Get-Filecount *****
function Get-Filecount {
[CmdletBinding()]
[OutputType([System.Int32])]
Param (
        [parameter(Position=0,
                   Mandatory=$true,
                   HelpMessage="Directory of interest")]
        [ValidateNotNullOrEmpty()]
        [String]$Directory
      ) #end param

  $gash = New-Object -TypeName 'System.IO.DirectoryInfo' -ArgumentList $Directory;
  $filecount = $gash.EnumerateFiles();

  return [System.Linq.Enumerable]::Count($filecount);

}
#endregion ***** end of function Get-Filecount *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

$startDir = 'C:\Test';  # <-- Change accordingly
# Get a recursive list directories starting from our start directory.
$dirlist = Get-ChildItem -Recurse -Directory -Path $startDir;
Set-Variable -Name 'startDir', 'dirlist' -Option ReadOnly;

$children3 = New-Object -TypeName 'System.Collections.Generic.List[String](100)';

[System.Linq.Enumerable]::Repeat("", 2);
foreach ($d in $dirlist) {

    $newParent = Split-Path $d.FullName -Parent;
    #Write-Output "t is now $($newParent)";
    if ($children3.Contains($newParent)) {
        $children3.Remove($newParent) | Out-Null;
    }
    $children3.Add($d.fullname);

}

foreach ($item in $children3) {
   $fcount = Get-Filecount $item;
   Write-Output ('{0} ({1} files in directory)' -f $item, $fcount);
}

[System.Linq.Enumerable]::Repeat("", 2);
Write-Output "Start directory used: $($startDir)";
if ($children3.Count -eq 0) {
  Write-Output "`nNo bottom filders found from start directory";
  Write-Output "In other words, the start directory is the bottom folder";
} else {
  Write-Output ("{0} 'bottom folders' listed" -f $children3.Count);
}
Write-Output "`nAll done now";

# -----
#Checking for an elevated PowerShell prompt
#https://www.undocumented-features.com/2016/11/28/checking-for-an-elevated-powershell-prompt/

##=============================================
## END OF SCRIPT: Find-BottomFolder.ps1
##=============================================
