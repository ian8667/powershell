<#
.SYNOPSIS

Copies a file and inserts the current date/time partway through
the name of the copied file.

.DESCRIPTION

By copying a file and inserting the current date/time partway through
the name of the copied file, a 'backup copy' is made of the original
file. This means we can make amendments to the original file and have
a backup copy should we have the need to revert to it. The date and
time show when the file was copied and by having a time component, we
can make more than one copy of a file per day.

File 'fred.txt', for example, will be copied to a file named with a
format of 'fred_2018-04-22T14-52-26.txt'. The file when copied can be
set to ReadOnly if required.

The date/time component used is:

<filename>_YYYY-MM-DDTHH-MM-SS.<filename extension>

.EXAMPLE

PS> ./DateCopy-File.ps1

A filename to copy has not been supplied so an internal function will be
invoked to obtain the file to copy.

.EXAMPLE

PS> ./DateCopy-File.ps1 'myfile.txt'

The filename supplied will be copied with the name format of
myfile_YYYY-MM-DDTHH-MM-SS.txt.

.EXAMPLE

PS> ./DateCopy-File.ps1 -Path 'myfile.txt'

The filename supplied will be copied to a file with the name format
of myfile_YYYY-MM-DDTHH-MM-SS.txt.

.EXAMPLE

PS> ./DateCopy-File.ps1 -ReadOnly

A filename to copy has not been supplied so an internal function will be
invoked to obtain the file to copy. The file when copied, will be set to
ReadOnly upon completion.

.EXAMPLE

PS> ./DateCopy-File.ps1 'myfile.txt' -ReadOnly

The filename supplied will be copied to a file with the name format
of myfile_YYYY-MM-DDTHH-MM-SS.txt and set to ReadOnly upon completion.

.EXAMPLE

PS> ./DateCopy-File.ps1 -Path 'myfile.txt' -ReadOnly

The filename supplied will be copied to a file with the name format
of myfile_YYYY-MM-DDTHH-MM-SS.txt and set to ReadOnly upon completion.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : DateCopy-File.ps1
Author       : Ian Molloy
Last updated : 2021-05-09T16:53:50

This program contains examples of using delegates.

.LINK

Date and time format - ISO 8601
https://www.iso.org/iso-8601-date-and-time-format.html

ISO 8601 Data elements and interchange formats
https://en.wikipedia.org/wiki/ISO_8601

Namespace: System.IO.Path Class
https://msdn.microsoft.com/en-us/library/system.io.path(v=vs.110).aspx

Microsoft.PowerShell.Management
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/?view=powershell-5.1

MD5 message-digest algorithm
https://en.wikipedia.org/wiki/MD5

The MD5 Message-Digest Algorithm
https://www.ietf.org/rfc/rfc1321.txt

How to find these files again:
$file = 'C:\Gash\mygash_2020-10-01T22-47-03.pdf';
$reg = '(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2})';
Get-ChildItem -File | Where-Object -Property 'name' -Match -Value $reg;
$file -match $reg

#>

[CmdletBinding()]
Param (
   [parameter(Position=0,
              Mandatory=$false)]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [String]
   $Path,

   [parameter(Position=1,
              Mandatory=$false)]
   [Switch]
   $ReadOnly
) #end param

#----------------------------------------------------------
# Start of delegates
#----------------------------------------------------------
$ErrorsFound = [Predicate[System.Collections.Generic.List[Byte]]]{
<#
The object passed in contains a list of positions within the
filename string which are invalid. If the number of elements
contained in the List is zero (the collection is empty),
there are no errors.

Return true if there are errors; otherwise, false.
#>
param($x) $x.Count -gt 0
}
Set-Variable -Name 'ErrorsFound' -Option ReadOnly;

#----------------------------------------------------------

$invalids = [Func[System.Collections.Generic.List[Byte]]]{
<#
Create a collection and store a list of invalid characters
that should not appear in a filename.

Method GetInvalidFileNameChars is used to build a collection
containing the characters that are not allowed in file names.

Func<TResult> Delegate
Encapsulates a method that has no parameters and returns a
value of the type specified by the TResult parameter.
https://docs.microsoft.com/en-us/dotnet/api/system.func-1?view=net-5.0
#>
    $invalidChars = [System.Collections.Generic.List[Byte]]::new();
    $invalidChars.Capacity = 50;
    $invalidChars.Add(91); #decimal value - Left square bracket [
    $invalidChars.Add(93); #decimal value - Right square bracket ]
    $invalidChars.Add(35); #decimal value - Hash symbol #
    $invalidChars.Add(59); #decimal value - Semicolon ;
    $invalidChars.Add(64); #decimal value - At symbol @
    [System.IO.Path]::GetInvalidFileNameChars() |
    ForEach-Object {
        $invalidChars.Add($PSItem);
    }
    $invalidChars;
}
Set-Variable -Name 'invalids' -Option ReadOnly;

#----------------------------------------------------------
# End of delegates
#----------------------------------------------------------

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Show-ErrorPositions *****
function Show-ErrorPositions {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true,
                   HelpMessage="Show where the errors are in the filename")]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Generic.List[Byte]]$ErrorPositions,

        [parameter(Mandatory=$true,
                   HelpMessage="Filename length")]
        [ValidateScript({$_ -gt 0})]
        [Int32]$FilenameLen
    ) #end param

    begin {
        $k = ' ' * $FilenameLen;
        $sb = [System.Text.StringBuilder]::new();
        $sb.Capacity = $FilenameLen;
        $sb.Append($k) | Out-Null;
        #Write-Output "sb(1) is now: $($sb.ToString())";

    }

    process {
        foreach ($item in $ErrorPositions) {
            $sb[($item - 1)] = '^';
        }

    }

    end {
        #Write-Output "k is now: $k";
        #Write-Output "sb(2) is now: $($sb.ToString())";
        return $sb.ToString();
    }
}
#endregion ***** end of function Show-ErrorPositions *****

#----------------------------------------------------------

#region ***** Function Get-OldFilename *****
function Get-OldFilename {
<#
.SYNOPSIS

Gets the file to copy

.DESCRIPTION

Uses the OpenFileDialog class to obtain a filename to
copy. This file will not be modified or changed in any
way

.PARAMETER Boxtitle

Used to set the file OpenFileDialog box title.

.LINK

OpenFileDialog Class.
https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=netcore-3.1
#>

[CmdletBinding()]
[OutputType([System.String])]
Param (
   [parameter(Position=0,
              Mandatory=$true,
              HelpMessage="ShowDialog box title")]
   [ValidateNotNullOrEmpty()]
   [String]$Boxtitle
) #end param

Begin {
  Write-Verbose -Message "Invoking function to obtain the to file to copy";

  Add-Type -AssemblyName "System.Windows.Forms";
  #[System.Windows.Forms.OpenFileDialog]$ofd = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog';
  [System.Windows.Forms.OpenFileDialog]$ofd = [System.Windows.Forms.OpenFileDialog]::new();

  $myok = [System.Windows.Forms.DialogResult]::OK;
  [String]$retFilename = "";
  $ofd.AddExtension = $false;
  $ofd.CheckFileExists = $true;
  $ofd.CheckPathExists = $true;
  $ofd.DefaultExt = ".txt";
  $ofd.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*";
  $ofd.InitialDirectory = "C:\Family\powershell";
  $ofd.Multiselect = $false;
  $ofd.Title = $Boxtitle; # sets the file dialog box title
  $ofd.ShowHelp = $false;
  $ofd.RestoreDirectory = $false;
  Set-Variable -Name 'myok', 'ofd' -Option ReadOnly;

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
#endregion ***** End of function Get-OldFilename *****

#----------------------------------------------------------

#region ***** Function Compare-Files *****
function Compare-Files {
<#
.SYNOPSIS

Computes the hash value of two files

.DESCRIPTION

Uses the 'Get-FileHash' cmdlet to compute the MD5 hash value
of the original and copied file. The hashes of two sets of
data from the files concerned should match if the
corresponding data also matches. This will verify that the
contents of the copied file has not been changed and thus
the copy was successful.

Returns true if the hash values are the same; false otherwise

.PARAMETER DataFile

A PSCustomObject object containing the original and copied
filenames.

.LINK

Get-FileHash
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-7.1

System.Security.Cryptography.MD5CryptoServiceProvider Class
https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.md5cryptoserviceprovider?view=net-5.0

Microsoft.PowerShell.Commands.FileHashInfo Class
https://docs.microsoft.com/en-us/dotnet/api/microsoft.powershell.commands.filehashinfo?view=powershellsdk-7.0.0

java.security.MessageDigest Class
#>

[CmdletBinding()]
[OutputType([System.Boolean])]
Param (
   [parameter(Position=0,
              Mandatory=$true,
              HelpMessage="Data files to compare")]
   [ValidateNotNullOrEmpty()]
   [PSTypeName('OldNew')]$DataFile
) #end param

[Boolean]$retval = $false;
$splat = @{
    Path = @($DataFile.OldFilename, $DataFile.NewFilename)
    Algorithm = 'MD5'
}
$fHash = Get-FileHash @splat;
if ($fHash[0].Hash -eq $fHash[1].Hash) {
  $retval = $true;
}

return $retval;
}
#endregion ***** End of function Compare-Files *****

#----------------------------------------------------------

#region ***** Function Get-NewFilename *****
function Get-NewFilename {
<#
.SYNOPSIS

Constructs a new filename

.DESCRIPTION

Constructs a new filename from the filename passed as a
parameter. The copied file will have this filename when
when the copy is complete

Returns a filename in the format of, for example,
myfile_2020-12-22T19-42-58.txt

.PARAMETER OldFilename

Filename from which to construct a new filename

#>

[CmdletBinding()]
[OutputType([System.String])]
Param (
   [parameter(Position=0,
              Mandatory=$true,
              HelpMessage="The filename to rename")]
   [ValidateNotNullOrEmpty()]
   [String]$OldFilename
) #end param

Begin {
  # Date format used to help rename the file from the original
  # filename provided.
  $mask = '_yyyy-MM-ddTHH-mm-ss';
  $timestamp = (Get-Date).ToString($mask);
  Set-Variable -Name 'mask', 'timestamp' -Option ReadOnly;

  # Get the absolute path without the filename or extension
  $f1 = [System.io.Path]::GetDirectoryName($OldFilename);

  # Get the filename itself without the path or extension
  $f2 = [System.io.Path]::GetFileNameWithoutExtension($OldFilename);

  # Get the extension (including the period "."), or empty
  # if variable 'OldFilename' does not contain an extension.
  $f3 = [System.io.Path]::GetExtension($OldFilename);

  # Character used to separate directory levels in a path. Returns
  # a backslash on an MS Windows operating system
  $slash = [System.io.Path]::DirectorySeparatorChar;
  Set-Variable -Name 'f1', 'f2', 'f3', 'slash' -Option ReadOnly;

  $newFilename = ("{0}{1}{2}{3}" -f $f1, $slash, $f2, $timestamp);

  if (-not ([System.String]::IsNullOrEmpty($f3))) {
      # The original filename has a file extension. Insert
      # it back into our new filename
      $newFilename = ("$($newFilename){0}" -f $f3);
  }

}

Process {}

End {
  return $newFilename;
}

}
#endregion ***** End of function Get-NewFilename *****

#----------------------------------------------------------

#region ***** function Check-Filename *****
function Check-Filename {
<#
.SYNOPSIS

Check the filename for invalid characters

.DESCRIPTION

Checks the filename supplied for any invalid characters
and throws a terminating error if errors found. Prior
to throwing a terminating error, the filename and where
the errors are in the filename will be written to the
console so the user will be aware of where the problem
characters are in the filename

.PARAMETER CheckFile

The filename to check

.LINK

OpenFileDialog Class.
https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=netcore-3.1
#>

    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true,
                   HelpMessage="Check filename for invalid characters")]
        [ValidateNotNullOrEmpty()]
        [String]$CheckFile
    ) #end param

    begin {
          $invalidChars = $invalids.Invoke();

          #We only need to check the filename, not the pathname so
          #hence the reason for using the Split-Path cmdlet to
          #obtain the leaf part of the path.
          #$filename = 'C:\Gash\gashfile.txt';
          $fname = Split-Path -Path $CheckFile -Leaf;

          [Byte]$PosCounter = 0;
          #Contains the character position(s) within the filename that
          #are in error
          $ErrorPos = [System.Collections.Generic.List[Byte]]::new();
          $ErrorPos.Capacity = 30;

          $encoder = [System.Text.UTF8Encoding]::new();
          Set-Variable -Name 'fname', 'encoder' -Option ReadOnly;
          #Write-Output ('Looking at filename: {0} ({1} characters)' -f $fname, $fname.Length);
    } #end begin block

    process {
          #Iterate over each character in the filename in order
          #to examine or process each character to ensure it's
          #not an invalid character. If it is an invalid character,
          #make a note of it's position.
          $encoder.GetBytes($fname) | ForEach-Object {
              $data = $PSItem;
              $PosCounter++;
              if ($invalidChars.Contains($data)) {
                  $ErrorPos.Add($PosCounter);
              }
          } #end of ForEach-Object loop

          if ($ErrorsFound.Invoke($ErrorPos)) {
              Write-Output '';
              Write-Output ('We have a filename problem, ({0} errors)' -f $ErrorPos.Count);
              $m = Show-ErrorPositions -ErrorPositions $ErrorPos -FilenameLen $fname.Length;
              Write-Output $fname;
              Write-Output $m;

              throw "Invalid characters found in filename $($fname)";
          }

    } #end process block

    end {}

}
#endregion ***** end of function Check-Filename *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Date and copy of file';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

# With a small sleep delay at the start of the program,
# it helps ensure we can never have two timestamps the
# same because we have at least two seconds delay between
# each run of the program.
Start-Sleep -Seconds 2.0;

$OldNewName = [PSCustomObject]@{
   PSTypeName = 'OldNew';

   # The file to be copied. ie myfile.txt
   OldFilename = 'NotModified';

   # The copied file containing the timestamp, ie
   # myfile_2020-12-22T18-48-20.txt
   NewFilename = 'NotModified';
}

if ($PSBoundParameters.ContainsKey('Path')) {
   # Use the filename supplied.
   $OldNewName.OldFilename = Resolve-Path -LiteralPath $Path;
} else {
   # Filename has not been supplied. Execute function Get-OldFilename
   # to allow the user to select a file to copy.
   $OldNewName.OldFilename = Get-OldFilename -Boxtitle 'File to copy';
}

# Check the input filename doesn't contain any invalid characters
# which may cause problems. If so, terminate the program
Check-Filename -CheckFile $OldNewName.OldFilename;

# Get the new filename name which is derived from the old
# (original) filename from which we are copying.
$OldNewName.NewFilename = Get-NewFilename -OldFilename $OldNewName.OldFilename;
Set-Variable -Name 'OldNewName' -Option ReadOnly;

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output ("File we want to copy: {0}" -f $OldNewName.OldFilename);
Write-Output ("New name of copied file = {0}" -f $OldNewName.NewFilename);
Copy-Item -Path $OldNewName.OldFilename -Destination $OldNewName.NewFilename;

if (Test-Path -Path $OldNewName.NewFilename) {
  # Ensure the file copy was successful by computing the (MD5) hash
  # value of the two files concerned.
  $compareOK = Compare-Files -DataFile $OldNewName;
  if ($compareOK) {
    Write-Output 'Hash compare of the two files successful';
  } else {
    throw 'Hash values for the two files are not the same. Please check';
  }

  # Set the value of the 'LastWriteTime' property of the file just copied
  # to the current date/time rather than keep the value of the file it
  # was copied from. If we didn't do this, both the original file and the
  # file we've copied will have the same 'LastWriteTime' property. The
  # original file has the earlier 'LastWriteTime' property. By doing this,
  # it makes it easier for me to find the file in any output if I execute
  # the command:
  # PS> Get-ChildItem -File | Sort-Object -Property LastWriteTime;

  # Ensure the attribute 'IsReadOnly' is set to false to avoid the error:
  # Access to the path <filename> is denied
  Set-ItemProperty -Path $OldNewName.NewFilename -Name 'IsReadOnly' -Value $false;
  Set-ItemProperty -Path $OldNewName.NewFilename -Name 'LastWriteTime' -Value (Get-Date);

  if ($PSBoundParameters.ContainsKey('ReadOnly')) {
     # Set the value of the 'IsReadOnly' property of the file just copied
     # to true making it read only.
     Set-ItemProperty -Path $OldNewName.NewFilename -Name 'IsReadOnly' -Value $True;
  }

  #List the old and new filename objects.
  #I agree this is a convoluted way of listing the files used, but
  #this serves as a reminder of how to iterate over a PowerShell
  #'PSCustomObject' object.
  $m = $OldNewName.psobject.Members |
         Where-Object -Property 'MemberType' -like -Value 'NoteProperty';
  foreach ($item in $m) {Get-ChildItem -Path $item.value -File}

} else {
  Write-Error -Message "Can't seem to find new file $($OldNewName.NewFilename)";
} #end if Test-Path

##=============================================
## END OF SCRIPT: DateCopy-File.ps1
##=============================================
