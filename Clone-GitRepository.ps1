<#
.SYNOPSIS

Clone an online GitHub repository

.DESCRIPTION

Clones one of my online GitHub repositories to a local Git
repository. When the program is run, the user is able to choose
(select) one of the repositories to clone from the simple list
of repositories as defined in the function 'Get-RepositoryName'.
The repository names are hardcoded in this function, so if there
are changes to the names, the list will have to be manually
edited to reflect these changes.

.EXAMPLE

./Clone-GitRepository.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Clone-GitRepository.ps1
Author       : Ian Molloy
Last updated : 2020-11-08T16:10:30
Keywords     : git github clone repository

.LINK

git documentation
https://git-scm.com/doc

About Object Creation
Explains how to create objects in PowerShell.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_object_creation?view=powershell-7
#>

[CmdletBinding()]
Param () #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Get-RepositoryName *****
function Get-RepositoryName {
[CmdletBinding()]
[OutputType([System.String])]
param()

[String]$Repos = '';
[Byte]$Response = 0;
$menu = @"

Please select a GitHub repository to clone

1 powershell
2 javaFX
3 Learn-Java
4 java
5 Quit

"@

do {
  $Response = Read-Host -Prompt $menu;
} until ($Response -in 1..5)

switch($Response) {
   1 {$Repos = 'powershell'; break}
   2 {$Repos = 'javaFX'; break}
   3 {$Repos = 'Learn-Java'; break}
   4 {$Repos = 'java'; break}
   5 {$Repos = 'quit'; break}
   Default {$Repos = 'quit'; break}
}

return $Repos;

}
#endregion ***** end of function Get-RepositoryName *****

#----------------------------------------------------------

#region ***** function Get-CloneUrl *****
function Get-CloneUrl {
[CmdletBinding()]
[OutputType([System.Uri])]
Param (
    [parameter(Mandatory=$true,
               Position=0,
               HelpMessage="Base URL of online GitHub repository")]
    [ValidateNotNullOrEmpty()]
    [String]$Base
) #end param

#Get the actual repository name to clone
[String]$repos = Get-RepositoryName;

# Now we have the repository name, create the full URI we'll be using
[String]$u = $Base, $repos -join '/';

$CloneUri = [System.Uri]::new($u);

return $CloneUri;
}
#endregion ***** end of function Get-CloneUrl *****

#----------------------------------------------------------

#region ***** function Clone-Repository *****
function Clone-Repository {
[CmdletBinding()]
[OutputType([System.Void])]
Param (
    [parameter(Position=0,
               Mandatory=$true,
               HelpMessage="Online URL of repository to be cloned")]
    [ValidateNotNullOrEmpty()]
    [System.Uri]$CloneUri,

    [parameter(Position=1,
               Mandatory=$true,
               HelpMessage="Base directory of local Git repository")]
    [ValidateNotNullOrEmpty()]
    [String]$Base
) #end param

   #Get the individual repository name which is being cloned. This
   #is the last segment of the URI.
   $ReposName = $CloneUri.Segments[-1];
   Set-Variable -Name 'ReposName' -Option ReadOnly;

   #Get the absolute pathname which will be the path to the local
   #Git repository.
   $LocalRepo = Join-Path -Path $Base -ChildPath $ReposName
   Set-Variable -Name 'LocalRepo' -Option ReadOnly;
   Write-Output ('Local repository pathname is [{0}]' -f $LocalRepo);

   #Syntax used:
   #git clone <options> <repository> <directory>
   #where <repository> = The remote GitHub repository to clone from
   #<directory> = The name of a new local directory to clone into.
   #              Cloning into an existing directory is only allowed
   #              if the directory is empty.
   $gitexe = 'C:\Program Files\Git\bin\git.exe';
   $options = @('clone', '--verbose', '--progress');
   $cmdArgs = @($options, $CloneUri, $LocalRepo);
   Set-Variable -Name 'gitexe', 'options', 'cmdArgs' -Option ReadOnly;

   if (Test-Path -Path $LocalRepo) {
      #As we're going to clone to this directory, remove it
      #if it exists. Cloning into an existing directory is
      #only allowed if the directory is empty.
      Write-Output ('Trying to remove unwanted directory {0}' -f $LocalRepo);
      Remove-Item -Path $LocalRepo -Force -Recurse;
      Write-Output ('Unwanted directory removed');
   }

   & $gitexe @cmdArgs;
   $rc = $LastExitCode;
   Write-Output "Clone of repository exit code = $rc";

}
#endregion ***** end of function Clone-Repository *****

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
   Write-Output 'Clone online GitHub repository to local repository';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

$ConfigData = [PSCustomObject]@{
   #Base URL of my online GitHub repository
   BaseUrl       = 'https://github.com/ian8667';

   #Base directory of my local Git repository. All of my
   #local repositories will be in this directory
   BaseDirectory = 'C:\IanmTools\GitRepos';
}
Set-Variable -Name 'ConfigData' -Option ReadOnly;

#Get the remote GitHub URL that we'll use to clone to a
#local Git repository
$uri = Get-CloneUrl -Base $ConfigData.BaseUrl;
Set-Variable -Name 'uri' -Option ReadOnly;

#The last segment of the URI contains the name of the actual
#repository that will be cloned. i.e., 'powershell' repository,
#'java' repository, etc. If the user has chosen to quit, then
#this segment will contain the value 'Quit'. Exit if this is
#the case with no further action.
$lastSegment = $uri.Segments[-1];
if ($lastSegment -eq 'Quit') {
   Write-Warning -Message 'Quitting at user request. No further action taken';
   return;
}

Write-Output ('The clone uri is now [{0}]' -f $uri);

Clone-Repository -CloneUri $uri -Base $ConfigData.BaseDirectory;

Write-Output 'Local Git repositories created in the last few minutes';
Get-ChildItem -Directory -Path $ConfigData.BaseDirectory |
Where-Object -Property 'CreationTime' -GT -Value (Get-Date).AddMinutes(-5);

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'All done now';
##=============================================
## END OF SCRIPT: Clone-GitRepository.ps1
##=============================================
