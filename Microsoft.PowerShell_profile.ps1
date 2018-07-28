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
#
# Last updated: 28 July 2018
#------------------------------------------------

#------------------------------------------------
# Go to our preferred startup location.
#------------------------------------------------
Set-Location -Path 'C:\Family\powershell'
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
Set-Alias -Name 'view' -Value 'C:\windows\system32\notepad.exe' -Description 'Alias for notepad'
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


# Once you've written a number of PowerShell scripts, you
# might find it useful to collect them in one place and
# create a PSDrive named scripts: to find them quickly.
# You could add the following to your profile to create
# such a PSDrive.
#New-PSdrive -name scripts -PSprovider filesystem -root C:\Family\Ian
