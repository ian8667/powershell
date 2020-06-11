<#

.NOTES

File Name    : compile-csharp.ps1
Author       : Ian Molloy
Last updated : 2020-06-07T00:42:23

#>

[CmdletBinding()]
Param()

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
#$ErrorActionPreference = "Stop";

Write-Output 'Start of compile';
$file = 'C:\Gash\csharp01.cs';
$compile = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe';
$cmdArgs = @('-nologo', '-optimize+');
$mask = 'dddd, dd MMMM yyyy';
$basedir = Split-Path -Path $file;
Set-Variable -Name 'file','compile','cmdArgs','mask','basedir' -Option ReadOnly;
Write-Output '';

Write-Output ('Compiling C# file "{0}"' -f (Split-Path -Path $file -Leaf));
[System.Linq.Enumerable]::Repeat("", 2);
#& $compile $file -nologo;
#& $compile $file;
& $compile $file @cmdArgs;
$rc = $LastExitCode;
Write-Output "Return code = $rc";

if ($rc -eq 0) {
    #List any files created within the last few minutes
    #as a result of this compile
    Write-Output 'Files created within the last few minutes'
    Get-ChildItem -File -Path $basedir |
       Where-Object {$_.LastWriteTime -ge (Get-Date).AddMinutes(-5)} |
       Sort-Object -Property LastWriteTime;
} else {
    Write-Error -Message 'C# sharp compile failed. Please fix the above errors';
}

[System.Linq.Enumerable]::Repeat("", 2);
Write-Output 'End of compile';

##=============================================
## END OF SCRIPT: compile-csharp.ps1
##=============================================
