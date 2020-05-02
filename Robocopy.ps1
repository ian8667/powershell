<#
.SYNOPSIS

PowerShell wrapper for robocopy to copy files

.DESCRIPTION

ROBOCOPY :: Robust File Copy for Windows

Shall I use robocopy to copy files as part of my backup
to a USB drive?

The Ultimate Guide to Robocopy
https://adamtheautomator.com/robocopy-the-ultimate/

robocopy
https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy

Directory: C:\WINDOWS\SYSTEM32
Robocopy.exe

Last updated : 2020-05-02T22:49:31
Keywords     : robocopy backup copy file

#>

[CmdletBinding()]
Param()

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

$robokopy = 'C:\WINDOWS\SYSTEM32\Robocopy.exe';
$source = "C:\Family\EmailsSent";
$dest = "C:\Gash\gashdir";
$logfile = Invoke-Command -ScriptBlock {
  #$mask = '_yyyy-MM-ddTHH-mm-ss';
  $mask = '_yyyy-MM-dd';
  $timestamp = (Get-Date).ToString($mask);

  $log = ("C:\Gash\robocopylog{0}.log" -f $timestamp);

  return $log;
}
Set-Variable -Name 'robokopy', 'source', 'dest', 'logfile' -Option ReadOnly;

$what = @("*.*", "/MIR");
$options = @("/E", "/V", "/R:3", "/W:3", "/NP", "/LOG:$logfile");
$cmdArgs = @("$source", "$dest", $what, $options);

# Ensure the destination directory is empty before we do the Robocopy
# copy. Otherwise we could be copying to an existing backup directory
# which we don't want to do.
$d = Get-Item -Path $dest;
if ((($d.EnumerateFileSystemInfos() | Measure-Object).Count) -eq 0) {
    Write-Output 'About to run Robocopy';
    Write-Output "Backing up files in directory $source";
    Write-Output "Destination directory $dest";
    & $robokopy @cmdArgs;
    $rc = $LASTEXITCODE;
    Write-Output "Robocopy return code: $rc";

    Write-Output "";
    Write-Output "Robocopy logfile summary";
    Get-Content -Encoding ascii -Tail 13 -Path $logfile;
  } else {

    $errorMsg = @"
Destination directory --> $dest <--
should be empty for this backup copy
Please make sure we're using the correct
destination directory and try again
"@
$splat = @{
  Message = $errorMsg
  Category = 'InvalidOperation'
  CategoryActivity = 'Robocopy backup'
  CategoryReason = 'Destination directory is not empty'
  CategoryTargetName = $dest
  CategoryTargetType = 'Directory'
  ErrorId = '1001'
  RecommendedAction = 'Empty destination directory and try again'
  TargetObject = "Get-Item -Path 'C:\Gash\gashdir'"
}

   Set-Content -Path $logfile -Value $errorMsg;
   Write-Output "Logfile used: $logfile";
   Write-Error @splat;
   Get-Error;
}

Write-Output 'end of test';

##=============================================
## END OF SCRIPT: Robocopy.ps1
##=============================================
