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
Last updated : 2021-05-23T20:13:00

.LINK

List<T> Class
Represents a strongly typed list of objects that
can be accessed by index. Provides methods to search,
sort, and manipulate lists.
https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1?view=netframework-4.8

DirectoryInfo Class
Exposes instance methods for creating, moving, and
enumerating through directories and subdirectories.
https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=netcore-3.1

About Comment Based Help
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-6

With inspiration from 'Finding the bottom folders of a file tree using PowerShell'
by Stuart Moore
https://stuart-moore.com/finding-bottom-folders-file-tree-using-powershell/

#>

[CmdletBinding()]
Param() #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

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

  $dirInfo = New-Object -TypeName 'System.IO.DirectoryInfo' -ArgumentList $Directory;
  #Returns an enumerable collection of files (if any) in the
  #current directory. From this, we'll count how many files
  #there are
  $filecount = $dirInfo.EnumerateFiles();

  return [System.Linq.Enumerable]::Count($filecount);

}
#endregion ***** end of function Get-Filecount *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";
Write-Output 'Finding the bottom folder';

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
     Write-Output 'Finding the bottom folder';
     $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
     Write-Output ('Today is {0}' -f $dateMask);

     if ($MyInvocation.OffsetInLine -ne 0) {
         #I think the script was run from the command line
         $script = $MyInvocation.MyCommand.Name;
         $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
         Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);
     }

} #end of Invoke-Command -ScriptBlock

$startDir = 'C:\IanmTools\GitRepos';  # <-- Change accordingly
#Get a recursive list directories starting from our start directory.
$dirlist = Get-ChildItem -Recurse -Directory -Path $startDir;
Set-Variable -Name 'startDir', 'dirlist' -Option ReadOnly;

$children3 = New-Object -TypeName 'System.Collections.Generic.List[String]()';
$children3.Capacity = 100;

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
#Iterate through our list of directories and see what we have
foreach ($d in $dirlist) {

    $newParent = Split-Path -Path $d.FullName -Parent;
    Write-Verbose -Message "The new parent is now: $($newParent)";
    if ($children3.Contains($newParent)) {
      Write-Verbose -Message "Removing parent $($newParent)";
      $children3.Remove($newParent) | Out-Null;
    }
    Write-Verbose -Message "Adding item $($d.fullname)";
    $children3.Add($d.fullname);

}

#Iterate through our Generic.List of directories that we've collected
#and see how files (if any) each directory has
foreach ($item in $children3) {
   $fcount = Get-Filecount -Directory $item;
   Write-Output ('{0} ({1} files in directory)' -f $item, $fcount);
}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output "Start directory used: $($startDir)";
if ($children3.Count -eq 0) {
  Write-Output "`nNo bottom filders found from start directory";
  Write-Output "In other words, the start directory is the bottom folder";
} else {
  Write-Output ("{0} 'bottom folders' listed" -f $children3.Count);
}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output "All done now";

##=============================================
## END OF SCRIPT: Find-BottomFolder.ps1
##=============================================
