<#
.SYNOPSIS

Date-copies a file with a timestamp and verifies its integrity.

.DESCRIPTION

Allows the user to either supply a filename manually or be prompted to select one interactively. The script validates the file, appends a timestamp to its name, copies it, optionally sets it to read-only, and confirms the copy using an MD5 hash comparison. It also lists the original and copied files in the directory.

.PARAMETER Path

The full path of the file to be copied. Mandatory in manual mode.

.PARAMETER AutoSelect

If specified, prompts the user to select the file interactively.

.PARAMETER ReadOnly

Sets the copied file as read-only if specified.

.EXAMPLE

.\DateCopy-File.ps1

If no parameters are passed to the function, it utilizes an internal function to select the file.

This example demonstrates how the function behaves when it is called without any parameters. Instead of requiring external input, it automatically uses an internal function to handle file selection.

.EXAMPLE

.\DateCopy-File.ps1 -Path "C:\Test\myfile.txt"

This command specifies the path to a file that the script will copy with a timestamp appended to the filename. The -Path parameter must point to a file, not a directory.

.EXAMPLE

.\DateCopy-File.ps1 -ReadOnly

Since the file path is not supplied, this command uses an internal function to prompt the user to select a file. Upon completion, the date-copied file will be set to read-only.

.EXAMPLE

.\DateCopy-File.ps1 -Path "C:\Test\myfile.txt" -ReadOnly

This example demonstrates how to use the DateCopy-File.ps1 script to create a date-stamped copy of a file and set it to read-only. If no parameters are provided, the script will prompt you to select a file interactively.

.NOTES

File Name    : DateCopy-File.ps1
Author       : Ian Molloy
Last updated : 2025-07-04T22:24:04
Keywords     : datecopy copilot

#>

[CmdletBinding(DefaultParameterSetName = 'Interactive')]
param (
    [Parameter(Mandatory = $true, ParameterSetName = 'Manual', Position = 0)]
    [string]$Path,

    [Parameter(ParameterSetName = 'Interactive')]
    [switch]$AutoSelect,

    [switch]$ReadOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Helper Functions

#region Prompt-ForFilename
function Prompt-ForFilename {
<#
.SYNOPSIS
Prompts the user to select a file from a dialog.

.DESCRIPTION
Displays a file open dialog allowing the user to choose an existing file.
Throws an error if the user cancels.

.PARAMETER Boxtitle
The title text shown at the top of the file dialog.

.OUTPUTS
[string] The selected file's full path.
#>
    param (
        [Parameter(Mandatory=$true)]
        [string]$Boxtitle
    )

    Add-Type -AssemblyName "System.Windows.Forms"
    $ofd = [System.Windows.Forms.OpenFileDialog]::new()
    $ofd.Title = $Boxtitle
    $ofd.InitialDirectory = "C:\Family\powershell"
    $ofd.Filter = 'Text files (*.txt)|*.txt|PowerShell files (*.ps1)|*.ps1|All files (*.*)|*.*'
    $ofd.Multiselect = $false

    if ($ofd.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        throw "No file chosen or selected"
    }

    return $ofd.FileName
}
#endregion

#------------------------------------------------

#region Validate-Filename
function Validate-Filename {
<#
.SYNOPSIS
Validates that the file path exists and is safe to use.

.DESCRIPTION
Performs a series of checks on the filename:
- Ensures there are no invalid characters.
- Confirms the file exists.
- Allows empty files.

.PARAMETER Path
The full file path to validate.

.OUTPUTS
[bool] Returns $true if valid. Throws if invalid.

    if ((Get-Item -LiteralPath $Path).Length -eq 0) {
        throw "File '$Path' is empty and not permitted for this operation."
    }

#>
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    $name = Split-Path -Path $Path -Leaf

    # Check for trailing dots or spaces
    if ($name -match '[\. ]$') {
        throw "Filename '$name' has a trailing dot or space, which is not permitted."
    }

    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    if ($name.IndexOfAny($invalidChars) -ne -1) {
        throw "Filename '$name' contains invalid characters."
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "File '$Path' does not exist."
    }

    return $true
}
#endregion

#------------------------------------------------

#region Generate-DateFilename
function Generate-DateFilename {
<#
.SYNOPSIS
Creates a timestamped version of the original filename.

.DESCRIPTION
Appends a timestamp to the base name of the original file.
Preserves the original directory and file extension.

.PARAMETER OldFilename
The original file's full path.

.OUTPUTS
[string] The new file path with timestamp.
#>
    param (
        [Parameter(Mandatory=$true)]
        [string]$OldFilename
    )

    $timestamp = (Get-Date).ToString('_yyyy-MM-ddTHH-mm-ss')
    $directory = [System.IO.Path]::GetDirectoryName($OldFilename)
    $base = [System.IO.Path]::GetFileNameWithoutExtension($OldFilename)
    $ext = [System.IO.Path]::GetExtension($OldFilename)

    if (-not $ext) {
        Write-Verbose "No file extension detected in '$OldFilename'"
    }

    return Join-Path -Path $directory -ChildPath ("$base$timestamp$ext")
}
#endregion

#------------------------------------------------

#region Compare-Hash
function Compare-Hash {
<#
.SYNOPSIS
Compares MD5 hash values of two files.

.DESCRIPTION
Generates MD5 hashes for two files and returns true if they match, false otherwise.

.PARAMETER Original
Path to the original file.

.PARAMETER Copy
Path to the copied file.

.OUTPUTS
[bool] Returns true if file contents are identical.
#>
    param (
        [Parameter(Mandatory=$true)][string]$Original,
        [Parameter(Mandatory=$true)][string]$Copy
    )

    $hashes = Get-FileHash -Path @($Original, $Copy) -Algorithm MD5
    return ($hashes[0].Hash -eq $hashes[1].Hash)
}
#endregion

#------------------------------------------------

#region List-DateCopies
function List-DateCopies {
<#
.SYNOPSIS
Lists the original file and its timestamped copies.

.DESCRIPTION
Searches the file's directory for any files with a name pattern matching the timestamped version.

.PARAMETER InputFilename
The full path to the original file.

.OUTPUTS
[List[FileInfo]] A sorted list of related files.
#>
    param (
        [Parameter(Mandatory)]
        [string]$InputFilename
    )

    $dir = Split-Path $InputFilename -Parent
    $name = [System.IO.Path]::GetFileNameWithoutExtension($InputFilename)
    $ext = [System.IO.Path]::GetExtension($InputFilename)
    $pattern = "$name(_\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2})?$ext"

    Get-ChildItem -Path $dir -File |
        Where-Object {
            $_.Name -match "^$pattern$"
        } |
        Sort-Object -Property LastWriteTime

}
#endregion

#endregion Helper Functions

#------------------------------------------------

#region Main-Routine
function Main-Routine {
<#
.SYNOPSIS
Main entry point for the date-copying workflow.

.DESCRIPTION
Handles input mode selection, validation, filename generation, copying, verification, and final listing.

.NOTES
Automatically selects interactive or manual mode based on the active parameter set.
#>
    Write-Output "`nDate and copy of file"
    Write-Output "Today is $(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss')"
    Write-Output "Running script $($MyInvocation.MyCommand.Name) in directory $(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

    $source = if ($PSCmdlet.ParameterSetName -eq 'Manual') {
        Resolve-Path -Path $Path | Select-Object -ExpandProperty Path
    } else {
        Prompt-ForFilename -Boxtitle 'Select file to copy'
    }

    Validate-Filename -Path $source

    Start-Sleep -Seconds 2
    $destination = Generate-DateFilename -OldFilename $source

    Copy-Item -Path $source -Destination $destination -Force

    if (-not (Compare-Hash -Original $source -Copy $destination)) {
        throw "Hash mismatch! Copy may be corrupt."
    }

    # Update metadata
    Set-ItemProperty -Path $destination -Name IsReadOnly -Value $false
    Set-ItemProperty -Path $destination -Name LastWriteTime -Value (Get-Date)

    if ($ReadOnly) {
        Set-ItemProperty -Path $destination -Name IsReadOnly -Value $true
    }

    Write-Output "`nFile copied to: $destination"
    List-DateCopies -InputFilename $source
}
#endregion

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Main-Routine

##=============================================
## END OF SCRIPT: DateCopy-File.ps1
##=============================================
