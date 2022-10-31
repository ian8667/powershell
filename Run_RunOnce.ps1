<#
Use PowerShell to Enumerate Registry Property Values
https://devblogs.microsoft.com/scripting/use-powershell-to-enumerate-registry-property-values/

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


List of Run keys that are in the Microsoft Windows Registry:

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


See also:
https://labs.jumpsec.com/running-once-running-twice-pwned-windows-registry-run-keys/

Registry Keys / StartUp Folder
https://dmcxblue.gitbook.io/red-team-notes/persistence/registry-keys-startup-folder

Persistence – Registry Run Keys
https://pentestlab.blog/2019/10/01/persistence-registry-run-keys/

Vault 7: CIA Hacking Tools Revealed
https://wikileaks.org/ciav7p1/cms/page_13763758.html

#>

<#
new work:
o add advanced comment in header of the file
o finish off
o upload to github
#>

[CmdletBinding()]
Param () #end param

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

Push-Location;

$paths = ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
          'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run');

foreach ($path in $paths) {
    Set-Location -Path $path;

    [System.Linq.Enumerable]::Repeat("", 3); #blanklines
    Write-Output ('Looking in path [{0}]' -f $path);

    Get-Item -Path '.' |
    Select-Object -ExpandProperty property |
    ForEach-Object {
    New-Object -TypeName psobject -Property @{
       "Property" = $_;
       "Value" = (Get-ItemProperty -Path '.' -Name $_).$_}
    } |
    Format-Table Property, Value -AutoSize;

} #end foreach loop

Pop-Location;
Write-Output 'All done now';

##=============================================
## END OF SCRIPT: Run_RunOnce.ps1
##=============================================
