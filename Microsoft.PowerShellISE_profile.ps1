#------------------------------------------------
# My local Powershell configuration file.
# Microsoft.PowerShellISE_profile.ps1
#
# Last updated: 2020-08-04T22:12:01
#------------------------------------------------

# Source: http://dougfinke.com/blog/index.php/2009/02/03/powershell-ise-cream/
Function Expand-Alias {

  $content=$psise.CurrentOpenedFile.Editor.text;

  [System.Management.Automation.PsParser]::Tokenize($content, [ref] $null) |
    Where { $_.Type -eq 'Command'} |
    Sort StartLine, StartColumn -Desc | Do-Expansion;

}


Function Expand-CurrentAlias {

  $CaretColumn = $psise.CurrentOpenedFile.Editor.CaretColumn
  $content=$psise.CurrentOpenedFile.Editor.text
  [System.Management.Automation.PsParser]::Tokenize($content, [ref] $null) |

    Where { $_.Type -eq 'Command'} |
       Where { $CaretColumn -eq $_.StartColumn -OR
            $CaretColumn -eq $_.EndColumn} | Do-Expansion;

}

Filter Do-Expansion {

    if ($_.Content -eq '?') {
        $result = Get-Command '`?' -CommandType Alias;
    } else {
        $result = Get-Command $_.Content -CommandType Alias -ErrorAction SilentlyContinue;
    }

    if($result) {

        $psise.CurrentOpenedFile.Editor.Select($_.StartLine,$_.StartColumn,$_.EndLine,$_.EndColumn)
        $psise.CurrentOpenedFile.Editor.InsertText($result.Definition)

    }

} #end function Do-Expansion


#$null = $psISE.CustomMenu.Submenus.Add("Expand Alias", {Expand-Alias}, 'Ctrl+Shift+E')
#$null = $psISE.CustomMenu.Submenus.Add("Expand Current Alias", {Expand-CurrentAlias}, 'Ctrl+Shift+W')

#----------------------------------------------
# Ian added items.
#----------------------------------------------

#------------------------------------------------
# Create some aliases.
#------------------------------------------------
Set-Alias -Name 'view' -Value 'C:\windows\system32\notepad.exe' -Description 'Alias for notepad';
Set-Alias -Name 'vi' -Value 'C:\windows\system32\notepad.exe' -Description 'Alias for notepad';

#------------------------------------------------
# Go to our preferred startup location.
#------------------------------------------------
Set-Location -Path 'C:\Family\powershell';
Clear-Host;

#------------------------------------------------
# Welcome message and initial setup.
#------------------------------------------------
Write-Host "You are now entering PowerShell : " $env:Username;
Get-Date;
Write-Host "We're currently in directory $(Get-Location)";

#------------------------------------------------
# Create some functions.
#------------------------------------------------
function prompt
{
    #$width = ($Host.UI.RawUI.WindowSize.Width - 2 - $(Get-Location).ToString().Length)
    $width = 60;
    $hr = New-Object System.String @('-', $width)

    $currtime=$(get-date).Tostring("HH:mm:ss")
    Write-Host -ForegroundColor Red $(Get-Location) $hr

    #function prompt {"Mugunth: $(get-date)>"}
    #Write-Host ("PS " + $($currtime) +"==>")
    "PS " + $($currtime) + "==> "
    #"Mugunth: $(get-date)> "
    return " "
}

#------------------------------------------------
# Misc items.
#------------------------------------------------
Set-PSDebug -Strict;

# Once you've written a number of PowerShell scripts, you
# might find it useful to collect them in one place and
# create a PSDrive named scripts: to find them quickly.
# You could add the following to your profile to create
# such a PSDrive.
#New-PSdrive -name scripts -PSprovider filesystem -root C:\Family\Ian

#----------------------------------------------
# End of Ian added items.
#----------------------------------------------
