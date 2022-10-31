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
Copies file data from one location to another.
https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy

Directory: C:\WINDOWS\SYSTEM32
Robocopy.exe

-----
Robocopy snag: (something to fix)

Robocopy does not copy the root folder

robocopy C:\Family  E:\Backups\Laptop\Backup2020-05-03

This seems to be copying everything but not the root directory
(Family). In the destination folder I only see subfolders and
files, but not the root "Family" folder.

I would like to copy the Family folder (root directory) from one
server to another with all attributes, root directories, and files.
The command above is copying everything WITHIN the directory but
not the directory itself.


Robocopy does not copy the root folder and its time stamp - it copies
all subdirectories and files (when the appropriate options are set)
and there seems to be no option/argument to tell Robocopy you want
the root folder itself and its timestamp or attributes to be copied
verbatim also.

So say I want I want to copy C:/Brushes

Robocopy will copy all its subdirectories and files into the
destination, but not the Brushes folder itself, with all
associated attributes and timestamp.
-----

File Name    : Robocopy.ps1
Author       : Ian Molloy
Last updated : 2022-06-19T23:02:10
Keywords     : robocopy backup copy file

-----
Collecting Information About Computers
https://docs.microsoft.com/en-us/powershell/scripting/samples/collecting-information-about-computers?view=powershell-7.1
Cmdlets from CimCmdlets
-----
Seagate drive on desktop: E:\
Seagate drive on laptop: D:\

-----
this seems to work out OK.
Use this bit of code to check the hash of the
directories concerned to check the copy went
OK?

$temp = @($tempfile01, $tempfile02);
$tempfile01 = New-TemporaryFile;
cat $tempfile01;
# -----
Compare source and backup directory

$sb = {
<#
$tempfile02
#>

    Get-Date;

    # --------------------
    # Part one
    # --------------------
    $path01 = 'C:\Gash';
    $tempfile01 = 'C:\Users\ianm7\AppData\Local\Temp\tmp64E2.tmp';

    ls -File -Recurse -Path $path01 |
      Get-FileHash -Algorithm 'MD5' |
      Select-Object -ExpandProperty Hash |
      Out-File -FilePath $tempfile01;

    # --------------------
    # Part two
    # --------------------
    $path02 = 'C:\Test\gash';
    $tempfile02 = 'C:\Users\ianm7\AppData\Local\Temp\tmpD89F.tmp';

    ls -File -Recurse -Path $path02 |
      Get-FileHash -Algorithm 'MD5' |
      Select-Object -ExpandProperty Hash |
      Out-File -FilePath $tempfile02;

    $hashes = Get-FileHash -Algorithm 'MD5' -Path $tempfile01, $tempfile02

    $hashes | Format-List *
    if (($hashes[0].Hash).Trim() -ceq ($hashes[1].Hash).Trim() ) {
        Write-Output 'Hash compare of source/backup directory successful';
    } else {
        Write-Output 'Problems with hash compare of source and backup';
    }

    Get-Date;

}
-----
Try using Enums(?)
Enum Device {
  Laptop = 0
  Desktop = 1
}

Enum Fruit {
  Apple = 0
  Pear = 1
  Kiwi = 2
  Orange = 3
}
$fred = [Fruit]::Kiwi;  #[Fruit]::Kiwi.ToString();
How to Create and Use Enums in Powershell
https://social.technet.microsoft.com/wiki/contents/articles/26436.how-to-create-and-use-enums-in-powershell.aspx

about_Enum
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_enum?view=powershell-7.2
[Fruit].GetEnumNames();

[Fruit].GetEnumNames() | ForEach-Object {
  "{0,-10} {1}" -f $_, [int]([Fruit]::$_);
}

#>

[CmdletBinding()]
Param()

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------

#region ***** Delegate isLaptop *****
[System.Func[Boolean]]$isLaptop = {
<#
Type of the computer in use, such as laptop, desktop, or
Tablet. It appears that only a value of 2 is a mobile
computer (laptop). Based on some of the comments listed
on the scenario requirements for this event, it appears
to be safe to assume that all others are considered to
be desktops.

https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-computersystem
https://mikefrobbins.com/2012/04/20/determine-hardware-type-2012-powershell-scripting-games-beginner-event-8/
#>
    $splat = @{
        ClassName = 'Win32_ComputerSystem'
        Namespace = 'root/cimv2'
    }
    [UInt16]$SystemType = (Get-CimInstance @splat).PCSystemType;

    # Returns true if $SystemType = Mobile (2)
    $SystemType -eq 2;
}
#endregion ***** end of delegate isLaptop *****

#----------------------------------------------------------

#region ***** Delegate Get_BackupPath *****
[Func[String]]$Get_BackupPath = {

    if ($isLaptop.Invoke()) {
        $DriveLetter = 'D:';
        $Device = 'Laptop';
        $RootFolder = 'Ian';
    } else {
        $DriveLetter = 'E:';
        $Device = 'Desktop';
        $RootFolder = 'Family';
    }
need to take into account whether is an E: or D: drive ?
    $today = (Get-Date).ToString('yyyy-MM-dd');
    $BackupPath = ('{0}\Backups\{1}\Backup{2}\{3}' -f $DriveLetter,$Device,$today,$RootFolder);
    $BackupPath;
}
#endregion ***** end of delegate Get_BackupPath *****

#----------------------------------------------------------
# End of delegates
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

$robokopy = 'C:\WINDOWS\SYSTEM32\Robocopy.exe';
$source = "C:\Family";
$dest = $Get_BackupPath.Invoke();
$logfile = Invoke-Command -ScriptBlock {
  #$mask = 'yyyy-MM-ddTHH-mm-ss';
  $mask = 'yyyy-MM-dd';
  $timestamp = (Get-Date).ToString($mask);

  $log = ("C:\temp\robocopylog_{0}.log" -f $timestamp);

  return $log;
}
Set-Variable -Name 'robokopy', 'source', 'dest', 'logfile' -Option ReadOnly;

$what = @("*.*", "/MIR");
$options = @("/E", "/V", "/R:3", "/W:3","/NP", "/DCOPY:DAT", "/LOG:$logfile");
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
    $rc = $LastExitCode;
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
  TargetObject = "Get-Item -Path $($dest)"
}

   Set-Content -Path $logfile -Value $errorMsg;
   Write-Output "Logfile used: $logfile";
   Write-Error @splat;
   Get-Error;
}

Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Robocopy.ps1
##=============================================
