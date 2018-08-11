[CmdletBinding()]
Param (
) #end param

$sourceDir = "C:\Family\BAE";
$destinationFile = "C:\Test\gashfile.zip";

If (Test-Path -Path $destinationFile) {Remove-Item -Path $destinationFile}

Add-Type -AssemblyName "System.IO.Compression.FileSystem";

$opt = [System.IO.Compression.CompressionLevel]::Optimal;

Write-Output ('Zipping directory {0}' -f $sourceDir);
[System.IO.Compression.ZipFile]::CreateFromDirectory( `
            $sourceDir, `
            $destinationFile, `
            $opt, `
            $false);
Get-ChildItem $destinationFile;

Write-Output '';
Write-Output 'All done now';
