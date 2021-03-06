<#
.SYNOPSIS

List the contents of a Zip file.

.DESCRIPTION

List the contents of a Zip file and display the results either to
the console or by using the Out-GridView cmdlet.

.EXAMPLE

PS> ./ziplist.ps1

The contents of the zip file will be displayed to the console. The
filename to list will be obtained via an internal function.

.EXAMPLE

PS> ./ziplist.ps1 -GridView

The contents of the zip file will be displayed using the Out-GridView
cmdlet. The filename to list will be obtained via an internal function.

Some entries may be seen with a length of 0 and a blank name, ie nothing
listed. These entries are directories listed from the path of the
zipped object.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : ziplist.ps1
Author       : Ian Molloy
Last updated : 2020-08-05T13:44:38

.LINK

Microsoft.PowerShell.Management
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/?view=powershell-5.1

#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $Path,

   [parameter(Mandatory=$false,
   ParameterSetName="GridView")]
   [Switch]
   $GridView

) #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** Function Get-Filename *****
function Get-Filename {
  <#
  .SYNOPSIS

  Display the OpenFileDialog dialog box

  .DESCRIPTION

  Display the .NET class OpenFileDialog dialog box that prompts
  the user to open a C# file to compile

  .PARAMETER Title

  The title displayed on the dialog box window

  .LINK

  OpenFileDialog Class.
  https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=netcore-3.1
  #>

  [CmdletBinding()]
  Param (
     [parameter(Mandatory=$true,
                HelpMessage="ShowDialog box title")]
     [ValidateNotNullOrEmpty()]
     [String]$Title
  ) #end param

  Begin {
    Write-Verbose -Message "Invoking function to obtain the C# filename to compile";

    Add-Type -AssemblyName "System.Windows.Forms";
    # Displays a standard dialog box that prompts the user
    # to open (select) a file.
    [System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName System.Windows.Forms.OpenFileDialog;

    # The dialog box return value is OK (usually sent
    # from a button labeled OK). This indicates the
    # user has selected a file.
    $myok = [System.Windows.Forms.DialogResult]::OK;
    $retFilename = "";
    $ofd.CheckFileExists = $true;
    $ofd.CheckPathExists = $true;
    $ofd.ShowHelp = $false;
    $ofd.Filter = "Zip files (*.zip)|*.zip|All files (*.*)|*.*";
    $ofd.FilterIndex = 1;
    $ofd.InitialDirectory = "C:\Family\Ian";
    $ofd.Multiselect = $false;
    $ofd.RestoreDirectory = $false;
    $ofd.Title = $Title; # sets the file dialog box title
    $ofd.DefaultExt = "zip";

  }

  Process {
    if ($ofd.ShowDialog() -eq $myok) {
       $retFilename = $ofd.FileName;
    } else {
       Throw "No file chosen or selected";
    }
  }

  End {
    $ofd.Dispose();
    return $retFilename;
  }
}
#endregion ***** End of function Get-Filename *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------
##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'List archive entries in a zipfile';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

Add-Type -AssemblyName "System.IO.Compression.FileSystem";

if ($PSBoundParameters.ContainsKey('Path')) {
	 # Zip filename supplied at the command line.
   $myzip = $Path;
   Write-Verbose -Message "Zip name supplied is $myzip";
} else {
   # Zip file to look at has not been supplied. Get the filename.
   $myzip = Get-Filename -Title "Get Zip file to list";
}

[UInt16]$counter = 0;

# Variable 'arc' has type of ZipArchive Class.
# System.IO.Compression.ZipArchive Class.
# Returns ZipArchive, The opened zip archive.
$arc = [System.IO.Compression.ZipFile]::OpenRead($myzip);
Write-Output ('Looking at Zip file {0}' -f $myzip);

# Variable 'arcent' has type of:
# System.Collections.ObjectModel.ReadOnlyCollection<ZipArchiveEntry>
# meaning that ZipArchiveEntry Class is wrapped in a ReadOnlyCollection.
# System.IO.Compression.ZipArchiveEntry Class
# System.Collections.ObjectModel.ReadOnlyCollection<T>
$arcent = $arc.Entries;

# Variable 'ZipArcEntry' has type of ZipArchiveEntry
# System.IO.Compression.ZipArchiveEntry
if ($PSCmdlet.ParameterSetName -eq "GridView") {
	$arcent | Select-Object LastWriteTime, Length, Name | Out-GridView -Title 'Zip file contents'
} else {

    foreach ($ZipArcEntry in $arcent)
    {
      #Write-Output ("`n`n`n{0}" -f $ZipArcEntry.FullName);
      #Write-Output ($null -eq $ZipArcEntry.Name);
      if (-not ($ZipArcEntry.FullName.EndsWith('/') )) {
        $counter++;

        #$arcname = $ZipArcEntry.Name;
        Write-Output ("(#{0})`nArchive entry: {1}`nCompressed length: {2} bytes`nUncompressed length: {3} bytes`n" -f
        $counter, `
        $ZipArcEntry.Name, `
        $ZipArcEntry.CompressedLength, `
        $ZipArcEntry.Length
        );
      } #end if statement

    } #end foreach loop

}

Write-Output ('{0} entries in zip file {1}' -f $counter, $myzip);
$arc.Dispose();
Write-Output 'All done now!';

##=============================================
## END OF SCRIPT: ziplist.ps1
##=============================================
