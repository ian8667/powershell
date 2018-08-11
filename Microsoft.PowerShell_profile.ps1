#------------------------------------------------
# My local Powershell configuration file.
#
# See also
# http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
# http://msdn.microsoft.com/en-us/library/windows/desktop/bb613488(v=vs.85).aspx
# http://technet.microsoft.com/en-us/library/ee156814.aspx
#
# ie, if running a shell with admin privileges.
# (get-host).UI.RawUI.Foregroundcolor="Yellow"
# $a = (Get-Host).UI.RawUI
# $a.WindowTitle = "Admin Session"
# or
# $Host.UI.RawUI.WindowTitle = "PowerShell ROCKS"
#------------------------------------------------

#------------------------------------------------
# Go to our preferred startup location.
#------------------------------------------------
Set-Location C:\Family\powershell
Clear-Host

#------------------------------------------------
# Welcome message and initial setup.
#------------------------------------------------
Write-Host "You are now entering PowerShell : " $env:Username
Get-Date
Write-Host "We're currently in directory $(Get-Location)"

#------------------------------------------------
# Create some aliases.
#------------------------------------------------
Set-Alias -Name 'view' -Value 'c:\windows\notepad.exe';
Set-Alias -Name 'grep' -Value 'Select-String';

Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineOption -TokenKind String -ForegroundColor Cyan
Set-PSReadlineOption -ContinuationPromptForegroundColor Magenta

#------------------------------------------------
# Setup some variables.
#------------------------------------------------
$MaximumHistoryCount = (64 * 2);
Write-Host "MaximumHistoryCount now set to $MaximumHistoryCount";

#------------------------------------------------
# Create some functions.
#------------------------------------------------
function prompt
{
    $width = ($Host.UI.RawUI.WindowSize.Width - 2 - $(Get-Location).ToString().Length)
    $hr = New-Object System.String @('-', $width)

    $currtime=$(get-date).Tostring("HH:mm:ss")
    Write-Host -ForegroundColor Red $(Get-Location) $hr

    Write-Host ("PS " + $($currtime) +"==>") -nonewline
    return " "
}

#------------------------------------------------
# Misc items.
#------------------------------------------------
#Set-PSDebug -Strict
Set-StrictMode -Version Latest
# The JShell tool, also called REPL (Read Evaluate Print Loop),
# allows you to execute Java code, getting immediate results.
$jshell = 'C:\Program Files\Java\jdk-10\bin\jshell.exe';

# Once you've written a number of PowerShell scripts, you
# might find it useful to collect them in one place and
# create a PSDrive named scripts: to find them quickly.
# You could add the following to your profile to create
# such a PSDrive.
#New-PSdrive -name scripts -PSprovider filesystem -root C:\Family\Ian
