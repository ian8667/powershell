# Stuart Moore
# Finding the bottom folders of a file tree using PowerShell
# (the last folder in a known path).
# Source: https://stuart-moore.com/finding-bottom-folders-file-tree-using-powershell/
#

[CmdletBinding()]
Param () #end param

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

} #end function Get-Filecount

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

$startDir = 'C:\Test2\jar_temp';  # <-- Change accordingly
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
