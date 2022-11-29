<#
.SYNOPSIS

Copies a file and inserts the current date/time partway through
the name of the copied file.

.DESCRIPTION

By copying a file and inserting the current date/time (timestamp)
partway through the name of the copied file, a 'backup copy' is made
of the original file. This means we can make amendments to the
original file and have a backup copy should we have the need to
revert to it. The date and time show when the file was copied and by
having a time component, we can make more than one copy of a file
per day.

The file that is copied will not be changed or modified in any way.

File 'fred.txt', for example, will be copied to a file named with a
format of 'fred_2018-04-22T14-52-26.txt'. The file, when copied, can
be set to ReadOnly if required.

The date/time component used is:

<filename>_YYYY-MM-DDTHH-MM-SS.<filename extension>

.PARAMETER Path

The file of which a copy will be made

.PARAMETER ReadOnly

An enumeration switch parameter indicating whether to set the copy
of the file to read only when the copy operation is complete.

.EXAMPLE

PS> ./DateCopy-File.ps1

A filename to copy has not been supplied so an internal function
will be invoked to obtain the file to copy.

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

A filename to copy has not been supplied so an internal function will
be invoked to obtain the file to copy. The file, when copied, will be
set to ReadOnly upon completion.

.EXAMPLE

PS> ./DateCopy-File.ps1 'myfile.txt' -ReadOnly

The filename supplied will be copied to a file with the name format
of myfile_YYYY-MM-DDTHH-MM-SS.txt and set to ReadOnly upon completion.

.EXAMPLE

PS> ./DateCopy-File.ps1 -Path 'myfile.txt' -ReadOnly

The filename supplied will be copied to a file with the name format
of 'myfile_YYYY-MM-DDTHH-MM-SS.txt' and set to ReadOnly upon
completion of the copy.

.EXAMPLE

PS> ./DateCopy-File.ps1 $file

The path to the file to copy is passed as a positional
parameter via the contents of variable 'file'. The
filename supplied will be copied to a file, for example,
with the name format of 'myfile_YYYY-MM-DDTHH-MM-SS.txt'.
Variable 'file' can be of type string or a
System.IO.FileInfo object. Variable 'file' can be
assigned as follows:

PS> $file = 'C:\Gash\myfile.ps1'
or
PS> $file = Get-Item 'myfile.ps1'

.EXAMPLE

PS> ./DateCopy-File.ps1 $file -ReadOnly

The path to the file to copy is passed as a positional
parameter via the contents of variable 'file'. The
filename supplied will be copied to a file, for example,
with the name format of 'myfile_YYYY-MM-DDTHH-MM-SS.txt'.
Variable 'file' can be of type string or a
System.IO.FileInfo object. Variable 'file' can be
assigned as follows:

PS> $file = 'C:\Gash\myfile.ps1';
or
PS> $file = Get-Item 'myfile.ps1';

The file will be set to ReadOnly upon completion of the
copy.

.EXAMPLE

PS> ./DateCopy-File.ps1 -Path $file -ReadOnly

The path to the file to copy is passed as a named
parameter via the contents of variable 'file'. The
filename supplied will be copied to a file, for example,
with the name format of 'myfile_YYYY-MM-DDTHH-MM-SS.txt'.
Variable 'file' can be of type string or a
System.IO.FileInfo object. Variable 'file' can be
assigned as follows:

PS> $file = 'C:\Gash\myfile.ps1';
or
PS> $file = Get-Item 'myfile.ps1';

The file will be set to ReadOnly upon completion of the
copy.

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : DateCopy-File.ps1
Author       : Ian Molloy
Last updated : 2022-11-29T18:23:01
Keywords     : pscustomobject pstypename

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

Custom objects and PSTypeName
https://powershellstation.com/2016/05/22/custom-objects-and-pstypename/

Everything you wanted to know about PSCustomObject
(PSTypeName for custom object types)
https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-pscustomobject?view=powershell-7.2

How to find these files again:
$file = 'C:\Gash\mygash_2020-10-01T22-47-03.pdf';
$reg = '(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2})';
Get-ChildItem -File | Where-Object -Property 'name' -Match -Value $reg;
$file -match $reg
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_regular_expressions?view=powershell-7.2

#>

[CmdletBinding()]
Param(
   [parameter(Position=0,
              Mandatory=$false,
              HelpMessage='File to be date copied')]
   [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
   [Object]
   $Path,

   [parameter(Position=1,
              Mandatory=$false,
              HelpMessage='Whether to set copied file to readonly')]
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
ie, there are no errors.

Return true if there are errors; otherwise, false.
#>
param($x) $x.Count -gt 0;
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
    $invalidChars.Capacity = 60;
    $invalidChars.Add(91); #decimal value - Left square bracket [
    $invalidChars.Add(93); #decimal value - Right square bracket ]
    $invalidChars.Add(35); #decimal value - Hash symbol #
    $invalidChars.Add(59); #decimal value - Semicolon ;
    $invalidChars.Add(64); #decimal value - At symbol @
    [System.IO.Path]::GetInvalidFileNameChars() |
    ForEach-Object {
        $invalidChars.Add($PSItem);
    }
    $invalidChars.TrimExcess();

    # Return the object created
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

#region ***** function Show_Files *****
function Show_Files {
<#
.SYNOPSIS

Lists the file which has just been copied and other copies made

.DESCRIPTION

Lists the file which has just been copied and all other date
copies made of it as created by this script (if any).

The way this program is designed to work, any copies of a file
will be in the same directory. So, for example, if file
'myfile.txt' in directory 'C:\Gash' is 'date copied' by this
script, then all subsequent files created will also be found
in directory 'C:\Gash'. Any such files in other directories
will not be listed.

.PARAMETER InputFilename

A string parameter containing the filename of the file
just copied.

.OUTPUTS

Sample output assuming file 'ggash.pdf' in directory 'C:\Gash'
was copied:


    Directory: C:\Gash

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          25/02/2022    23:08          49249 ggash.pdf
-a---          28/02/2022    22:01          49249 ggash_2022-02-28T22-01-36.pdf
-a---          28/02/2022    22:01          49249 ggash_2022-02-28T22-01-56.pdf
-a---          03/03/2022    17:58          49249 ggash_2022-03-03T17-58-21.pdf
-a---          03/03/2022    18:26          49249 ggash_2022-03-03T18-26-34.pdf
-a---          03/03/2022    18:27          49249 ggash_2022-03-03T18-27-58.pdf

#>

[CmdletBinding()]
param(
    [parameter(Position=0,
               Mandatory=$true,
               HelpMessage="The filename(s) to display")]
    [ValidateNotNullOrEmpty()]
    [String]$InputFilename
) #end param

    begin {
      # Regular expression for the (date/time) string
      # _YYYY-MM-DDTHH-MM-SS
      $DateCopyRegex = '_\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}';
      Set-Variable -Name 'DateCopyRegex' -Option ReadOnly;

      # Original filename without any modifications to it.
      $OrigFile = $InputFilename;
      # I've done this so the code doesn't get confused with the
      # regular expression part of the filename.
      $OrigFile = $OrigFile.Replace('\', '\\');
      Set-Variable -Name 'OrigFile' -Option ReadOnly;

      # Get the parent path (base path) from the input filename.
      # This is where all of the files we'll be dealing with are
      # located.
      #
      # See the following article on the subject of parent
      # paths:
      # How to get the Parent's parent directory in Powershell?
      # https://stackoverflow.com/questions/9725521/how-to-get-the-parents-parent-directory-in-powershell
      $BasePath = Split-Path $OrigFile -Parent;
      Set-Variable -Name 'BasePath' -Option ReadOnly;

      if ([System.IO.Path]::HasExtension($OrigFile)) {
        $pos = $OrigFile.LastIndexOf('.');
        $FileRegex = $OrigFile.Insert($pos, $DateCopyRegex);
      } else {
        # This file doesn't have a file extension
        $FileRegex = [System.String]::Concat($OrigFile, $DateCopyRegex);
      }

    }

    process {
      # I'm using the predicate
      # ($_.Name -eq (Split-Path -Path $OrigFile -Leaf)) so that I
      # match the name 'myfile.txt' for example, and not 'myfile.txt.bak'
      Get-ChildItem -File -Path $BasePath |
        Where-Object {($_.Name -eq (Split-Path -Path $OrigFile -Leaf)) -or ($_.FullName -match $FileRegex)} |
        Sort-Object -Property LastWriteTime;

    }

    end {}

} #end of the function
#endregion ***** end of function Show_Files *****

#----------------------------------------------------------

#region ***** Function Get-OldFilename *****
function Get-OldFilename {
<#
.SYNOPSIS

Gets the name of a file to date copy

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
Param(
   [parameter(Position=0,
              Mandatory=$true,
              HelpMessage="ShowDialog box title")]
   [ValidateNotNullOrEmpty()]
   [String]$Boxtitle
) #end param

Begin {
  Write-Verbose -Message "Invoking function to obtain the to file to copy";

  Add-Type -AssemblyName "System.Windows.Forms";
  [System.Windows.Forms.OpenFileDialog]$ofd = [System.Windows.Forms.OpenFileDialog]::new();

  $myok = [System.Windows.Forms.DialogResult]::OK;
  [String]$retFilename = "";

  $ofd.AddExtension = $false;
  $ofd.CheckFileExists = $true;
  $ofd.CheckPathExists = $true;
  $ofd.DefaultExt = ".txt";
  $ofd.Filter = 'Text files (*.txt)|*.txt|PowerShell files (*.ps1)|*.ps1|All files (*.*)|*.*';
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
Param(
   [parameter(Position=0,
              Mandatory=$true,
              HelpMessage="Data files to hash compare")]
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
parameter. The copied file will have this new filename
when when the copy is complete

Returns a filename in the format of, for example,
myfile_2020-12-22T19-42-58.txt

.PARAMETER OldFilename

Filename from which to construct a new filename

#>

[CmdletBinding()]
[OutputType([System.String])]
Param(
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
      # it back into our new filename which now contains
      # the date and time of the file copy
      $newFilename = ("$($newFilename){0}" -f $f3);
  }

}

Process {}

End {
  # Return the object created
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
    param(
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


#Extract the filename to copy from the parameter
if ($Path -is [String]) {
  Write-Verbose 'The main parameter is a string';
  $OldFilename = Resolve-Path -Path $Path;

} elseif ($Path -is [System.IO.FileInfo]) {
  Write-Verbose 'The main parameter is FileInfo';
  $OldFilename = $Path.FullName;

} else {
  #No value has been supplied
  Write-Verbose 'Not sure what the type of the main parameter is';
  $OldFilename = Get-OldFilename -Boxtitle 'File to copy';
}
Set-Variable -Name 'OldFilename' -Option ReadOnly;


# With a small sleep delay at the start of the program,
# it helps ensure we can never have two timestamps the
# same because we have at least two seconds delay between
# each run of the program.
Start-Sleep -Seconds 2.0;


# Check the input filename doesn't contain any invalid characters
# which may cause problems. If so, terminate the program
Check-Filename -CheckFile $OldFilename;

# Get the new filename name which is derived from the old
# (original) filename from which we are copying.
$NewFilename = Get-NewFilename -OldFilename $OldFilename;
Set-Variable -Name 'NewFilename' -Option ReadOnly;

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output ("File we want to copy: {0}" -f $OldFilename);
Write-Output ("New name of copied file = {0}" -f $NewFilename);
Copy-Item -Path $OldFilename -Destination $NewFilename;

if (Test-Path -Path $NewFilename) {
  # Ensure the file copy was successful by computing the (MD5) hash
  # value of the two files concerned.

  $OldNewName = [PSCustomObject]@{
    #I was using this data structure in a previous version
    #of the program and decided to leave it in as function
    #'Compare-Files' uses and processes this data structure.
    #Of course, I could have changed things but I'm leaving
    #this as it is.
    PSTypeName = 'OldNew';

    # The file to be copied. ie myfile.txt
    OldFilename = $OldFilename;

    # The copied file containing the timestamp, ie
    # myfile_2020-12-22T18-48-20.txt
    NewFilename = $NewFilename;
  }
  Set-Variable -Name 'OldNewName' -Option ReadOnly;

  $compareOK = Compare-Files -DataFile $OldNewName;
  if ($compareOK) {
    Write-Output 'Hash compare of the two files successful';
  } else {
    throw 'Hash values for the two files are not the same. Please check';
  }

  # Set the value of the 'LastWriteTime' property of the file just
  # copied to the current date/time rather than keep the value of
  # the file it was copied from. If we didn't do this, both the
  # original file and the file we've copied will have the same
  # 'LastWriteTime' property. The original file has the earlier
  # 'LastWriteTime' property. By doing this, it makes it easier
  # for me to find the file in any output if I execute the
  # command, for example:
  # PS> Get-ChildItem -File | Sort-Object -Property LastWriteTime;

  # Ensure the attribute 'IsReadOnly' is set to false to avoid the error:
  # Access to the path <filename> is denied
  Set-ItemProperty -Path $NewFilename -Name 'IsReadOnly' -Value $false;
  Set-ItemProperty -Path $NewFilename -Name 'LastWriteTime' -Value (Get-Date);

  if ($PSBoundParameters.ContainsKey('ReadOnly')) {
     # Set the value of the 'IsReadOnly' property of the file just copied
     # to true making it read only.
     Set-ItemProperty -Path $NewFilename -Name 'IsReadOnly' -Value $True;
  }

  #List the old (orig) and new filename objects.
  #I agree this is a convoluted way of listing the files used, but
  #this serves as a reminder of how to iterate over a PowerShell
  #'PSCustomObject' object.
  #$m = $OldNewName.psobject.Members |
  #       Where-Object -Property 'MemberType' -like -Value 'NoteProperty';
  #foreach ($item in $m) {Get-ChildItem -Path $item.value -File}
  Show_Files -InputFilename $OldNewName.OldFilename;

} else {
  Write-Error -Message "Can't seem to find new file $($NewFilename)";
} #end if Test-Path

##=============================================
## END OF SCRIPT: DateCopy-File.ps1
##=============================================
