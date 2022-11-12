<#
.SYNOPSIS

Lists entries in the Run or RunOnce registry keys

.DESCRIPTION

The "Run" or "RunOnce" registry keys are used to make a program run
when a user logs on. This happens regardless of user wishes and
may be running programs which are undesirable. This program shows
the entries in these registry keys.

.EXAMPLE

./Run_RunOnce.ps1

No parameters are required

.NOTES

File Name    : Run_RunOnce.ps1
Author       : Ian Molloy
Last updated : 2022-11-12T12:43:54


Run and RunOnce Registry Keys
Use Run or RunOnce registry keys to make a program run when
a user logs on. The Run key makes the program run every time
the user logs on, while the RunOnce key makes the program
run one time, and then the key is deleted. These keys can
be set for the user or the machine.
https://learn.microsoft.com/en-us/windows/win32/setupapi/run-and-runonce-registry-keys

The Windows registry includes the following four Run and RunOnce keys:

HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce


There are seven Run keys in the registry that enable programs to be
run automatically:

1. HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
2. HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
3. HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce
4. HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce

5. HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\ RunServices
6. HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\ RunServicesOnce

7. HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\ RunOnce\Setup

Based on the list mentioned above, run keys '1' through
'4' are processed once doing log in or at boot stage,
'5' and '6' are processed or run in the background, and
run key '7' is solely for Setup or when the Windows
Add/Remove Programs Wizard is being used


The following Registry keys can be used to set startup
folder items for persistence:
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User_Shell_Folders
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
HKEY_LOCAL_MACINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders

HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run
HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce


The following Registry Keys can control automatic
startup services during boot:
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce
HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunServices

.LINK

Run and RunOnce Registry Keys
https://learn.microsoft.com/en-us/windows/win32/setupapi/run-and-runonce-registry-keys

Use PowerShell to Enumerate Registry Property Values
https://devblogs.microsoft.com/scripting/use-powershell-to-enumerate-registry-property-values/

Running Once, Running Twice, Pwned! Windows Registry Run Keys
https://labs.jumpsec.com/running-once-running-twice-pwned-windows-registry-run-keys/

Registry Keys / StartUp Folder
https://dmcxblue.gitbook.io/red-team-notes/persistence/registry-keys-startup-folder

Persistence – Registry Run Keys
https://pentestlab.blog/2019/10/01/persistence-registry-run-keys/

Vault 7: CIA Hacking Tools Revealed
https://wikileaks.org/ciav7p1/cms/page_13763758.html

#>

[CmdletBinding()]
Param() #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Run and RunOnce registry keys';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}
Write-Output '';
Write-Output 'Some registry keys may not exist or have any entries in them';

[byte]$counter = 0;

#Remember where we are so we can return here afterwards
Push-Location;

#These are the registry keys we'll be looking at to see
#what's in them
$paths = (
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\ RunOnce\Setup'
);
Set-Variable -Name 'paths' -Option ReadOnly;

foreach ($path in $paths) {

    if (Test-Path -Path $path -PathType Container) {

         Set-Location -Path $path;
     
         [System.Linq.Enumerable]::Repeat("", 3); #blanklines
         Write-Output ('Looking in path [{0}]' -f $path);
         $counter++;
         Write-Output ('Path #{0}' -f $counter.ToString());
     
         Get-Item -Path '.' |
         Select-Object -ExpandProperty property |
         ForEach-Object {
             New-Object -TypeName psobject -Property @{
                "Property" = $_;
                "Value" = (Get-ItemProperty -Path '.' -Name $_).$_}
         } |
         Format-Table Property, Value -AutoSize;

    } else {
         [System.Linq.Enumerable]::Repeat("", 2); #blanklines
         Write-Output ('Registry path [{0}] does not exist' -f $path);
    }

} #end foreach loop

Pop-Location;
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Run_RunOnce.ps1
##=============================================
